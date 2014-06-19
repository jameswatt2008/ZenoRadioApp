///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRAccount.h"
#import "ZRAccount+Private.h"
#import "ZRCall.h"
#import "ZRDispatch.h"
#import "ZRUserAgent.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRAccount {
    ZRAccountConfiguration *_config;
}

- (id)init {
    if (self = [super init]) {
        _accountId = PJSUA_INVALID_ID;
        _status = ZRAccountStatusOffline;
        _config = nil;
        
        _delegate = nil;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(didReceiveIncomingCall:)
                       name:ZRSIPIncomingCallNotification
                     object:[ZRDispatch class]];
        [center addObserver:self
                   selector:@selector(registrationDidStart:)
                       name:ZRSIPRegistrationDidStartNotification
                     object:[ZRDispatch class]];
        [center addObserver:self
                   selector:@selector(registrationStateDidChange:)
                       name:ZRSIPRegistrationDidStartNotification
                     object:[ZRDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    ZRUserAgent *agent = [ZRUserAgent sharedAgent];
    if (_accountId != PJSUA_INVALID_ID && [agent status] != ZRUserAgentStateDestroyed) {
        int nAccountId = (int)_accountId;
        ZRLogIfFails(pjsua_acc_del(nAccountId));
        _accountId = PJSUA_INVALID_ID;
    }

    _accountId = PJSUA_INVALID_ID;
    _config = nil;
}


- (ZRAccountConfiguration *)configuration {
    return _config;
}


- (BOOL)configure:(ZRAccountConfiguration *)configuration {
    _config = [configuration copy];
    
    // prepare account config
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);
    
    accConfig.id = [ZRPJUtil PJAddressWithString:_config.address];
    accConfig.reg_uri = [ZRPJUtil PJAddressWithString:_config.domain];
    accConfig.register_on_acc_add = PJ_FALSE; // connect manually
    accConfig.publish_enabled = _config.enableStatusPublishing ? PJ_TRUE : PJ_FALSE;
    
    if (!_config.proxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [ZRPJUtil PJAddressWithString:_config.proxyServer];
    }
    
    // adds credentials info
    pjsip_cred_info creds;
    creds.scheme = [ZRPJUtil PJStringWithString:_config.authScheme];
    creds.realm = [ZRPJUtil PJStringWithString:_config.authRealm];
    creds.username = [ZRPJUtil PJStringWithString:_config.username];
    creds.data = [ZRPJUtil PJStringWithString:_config.password];
    creds.data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    
    accConfig.cred_count = 1;
    accConfig.cred_info[0] = creds;

    // finish
    int nAccountId = (int)_accountId;
    ZRReturnNoIfFails(pjsua_acc_add(&accConfig, PJ_TRUE, &nAccountId));
    return YES;
}


- (BOOL)connect {
    NSAssert(!!_config, @"ZRAccount not configured.");
    int nAccountID = (int)_accountId;
    ZRReturnNoIfFails(pjsua_acc_set_registration(nAccountID, PJ_TRUE));
    ZRReturnNoIfFails(pjsua_acc_set_online_status(nAccountID, PJ_TRUE));
    return YES;
}

- (BOOL)disconnect {
    NSAssert(!!_config, @"ZRAccount not configured.");
    int nAccountID = (int)_accountId;
    ZRReturnNoIfFails(pjsua_acc_set_online_status(nAccountID, PJ_FALSE));
    ZRReturnNoIfFails(pjsua_acc_set_registration(nAccountID, PJ_FALSE));
    return YES;
}


- (void)setStatus:(ZRAccountStatus)newStatus {
    if (_status == newStatus) // don't send KVO notices unless it really changes.
        return;
    
    _status = newStatus;
}


- (void)didReceiveIncomingCall:(NSNotification *)notif {
    pjsua_acc_id accountId = ZRNotifGetInt(notif, ZRSIPAccountIdKey);
    pjsua_call_id callId = ZRNotifGetInt(notif, ZRSIPCallIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    __block ZRAccount *self_ = self;
    __block id delegate_ = _delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        ZRCall *call = [ZRCall incomingCallWithId:callId toAccount:self];        
        if (![delegate_ respondsToSelector:@selector(account:didReceiveIncomingCall:)])
            return; // call is disposed/hungup on dealloc
        
        [delegate_ performSelector:@selector(account:didReceiveIncomingCall:)
                        withObject:self_
                        withObject:call];
    });
}

- (void)registrationDidStart:(NSNotification *)notif {
    pjsua_acc_id accountId = ZRNotifGetInt(notif, ZRSIPAccountIdKey);
    pj_bool_t renew = ZRNotifGetInt(notif, ZRSIPRenewKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    ZRAccountStatus accStatus = 0;
    accStatus = renew ? ZRAccountStatusDisconnecting : ZRAccountStatusDisconnecting;

    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:accStatus]; });
}

- (void)registrationStateDidChange:(NSNotification *)notif {
    pjsua_acc_id accountId = ZRNotifGetInt(notif, ZRSIPAccountIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    ZRAccountStatus accStatus;
    
    pjsua_acc_info info;
    ZRReturnIfFails(pjsua_acc_get_info(accountId, &info));

    if (info.reg_last_err != PJ_SUCCESS) {
        accStatus = ZRAccountStatusInvalid;
        
    } else {
        pjsip_status_code code = info.status;
        if (code == 0 || (info.online_status == PJ_FALSE)) {
            accStatus = ZRAccountStatusOffline;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 100) || PJSIP_IS_STATUS_IN_CLASS(code, 300)) {
            accStatus = ZRAccountStatusDisconnecting;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 200)) {
            accStatus = ZRAccountStatusConnected;
        } else {
            accStatus = ZRAccountStatusInvalid;
        }
    }
    
    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:accStatus]; });
}

@end
