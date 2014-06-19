///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZROutgoingCall.h"
#import "ZRCall+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZROutgoingCall

@synthesize remoteUri = _remoteUri;

- (id)initWithRemoteUri:(NSString *)remoteUri fromAccount:(ZRAccount *)account {
    if (self = [super initWithAccount:account]) {
        _remoteUri = [remoteUri copy];
    }
    return self;
}

- (void)dealloc {
    _remoteUri = nil;
}


- (BOOL)begin {
    if (![_remoteUri hasPrefix:@"sip:"])
        _remoteUri = [@"sip:" stringByAppendingString:_remoteUri];
    
    pj_str_t remoteUri = [ZRPJUtil PJStringWithString:_remoteUri];
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);
    callSetting.aud_cnt = 1;
    callSetting.vid_cnt = 0; // TODO: Video calling support?
    
    pjsua_call_id callId;
    int nAccountId = (int)self.account.accountId;
    ZRReturnNoIfFails(pjsua_call_make_call(nAccountId, &remoteUri, &callSetting, NULL, NULL, &callId));
    
    [self setCallId:callId];
    return YES;
}

- (BOOL)end {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    int nCallId = (int)self.callId;
    ZRReturnNoIfFails(pjsua_call_hangup(nCallId, 0, NULL, NULL));
    
    
    PJ_DECL(pj_status_t) pjsua_call_hangup(pjsua_call_id call_id,
                                           unsigned code,
                                           const pj_str_t *reason,
                                           const pjsua_msg_data *msg_data);
    
    
    [self setStatus:GSCallStatusDisconnected];
    [self setCallId:PJSUA_INVALID_ID];
    return YES;
}


-(BOOL)hold
{
    int nCallId = (int)self.callId;
    ZRReturnNoIfFails(pjsua_call_set_hold(nCallId,NULL));
    return YES;
}

-(BOOL)reinvite
{
    int nCallId = (int)self.callId;
    ZRReturnNoIfFails(pjsua_call_reinvite(nCallId,0,NULL));
    return YES;
}

@end
