///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRCall.h"
#import "ZRCall+Private.h"
#import "ZRAccount+Private.h"
#import "ZRDispatch.h"
#import "ZRIncomingCall.h"
#import "ZROutgoingCall.h"
#import "ZRRingback.h"
#import "ZRUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRCall {
    pjsua_call_id _callId;
    float _volume;
    float _micVolume;
    float _volumeScale;
}

+ (id)outgoingCallToUri:(NSString *)remoteUri fromAccount:(ZRAccount *)account {
    ZROutgoingCall *call = [ZROutgoingCall alloc];
    call = [call initWithRemoteUri:remoteUri fromAccount:account];
    
    return call;
}

+ (id)incomingCallWithId:(NSInteger)callId toAccount:(ZRAccount *)account {
    ZRIncomingCall *call = [ZRIncomingCall alloc];
    call = [call initWithCallId:callId toAccount:account];

    return call;
}


- (id)init {
    return [self initWithAccount:nil];
}

- (id)initWithAccount:(ZRAccount *)account {
    if (self = [super init]) {
        ZRAccountConfiguration *config = account.configuration;

        _account = account;
        _status = GSCallStatusReady;
        _callId = PJSUA_INVALID_ID;
        
        _ringback = nil;
        if (config.enableRingback) {
            _ringback = [ZRRingback ringbackWithSoundNamed:config.ringbackFilename];
        }

        _volumeScale = [ZRUserAgent sharedAgent].configuration.volumeScale;
        _volume = 1.0 / _volumeScale;
        _micVolume = 1.0 / _volumeScale;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(callStateDidChange:)
                       name:ZRSIPCallStateDidChangeNotification
                     object:[ZRDispatch class]];
        [center addObserver:self
                   selector:@selector(callMediaStateDidChange:)
                       name:ZRSIPCallStateDidChangeNotification
                     object:[ZRDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    if (_ringback && _ringback.isPlaying) {
        [_ringback stop];
        _ringback = nil;
    }

    if (_callId != PJSUA_INVALID_ID && pjsua_call_is_active(_callId)) {
        ZRLogIfFails(pjsua_call_hangup(_callId, 0, NULL, NULL));
    }
    
    _account = nil;
    _callId = PJSUA_INVALID_ID;
    _ringback = nil;
}


- (NSInteger)callId {
    return _callId;
}

- (void)setCallId:(NSInteger)callId {
    [self willChangeValueForKey:@"callId"];
    int nCallId = (int)callId;
    _callId = nCallId;
    [self didChangeValueForKey:@"callId"];
}

- (void)setStatus:(GSCallStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}


- (float)volume {
    return _volume;
}

- (BOOL)setVolume:(float)volume {
    [self willChangeValueForKey:@"volume"];
    BOOL result = [self adjustVolume:volume mic:_micVolume];
    [self didChangeValueForKey:@"volume"];
    
    return result;
}

- (float)micVolume {
    return _micVolume;
}

- (BOOL)setMicVolume:(float)micVolume {
    [self willChangeValueForKey:@"micVolume"];
    BOOL result = [self adjustVolume:_volume mic:micVolume];
    [self didChangeValueForKey:@"micVolume"];
    
    return result;
}


- (BOOL)begin {
    // for child overrides only
    return NO;
}

- (BOOL)end {
    // for child overrides only
    return NO;
}

- (BOOL)hold {
    // for child overrides only
    return NO;
}

- (BOOL)reinvite {
    // for child overrides only
    return NO;
}


- (void)startRingback {
    if (!_ringback || _ringback.isPlaying)
        return;

    [_ringback play];
}

- (void)stopRingback {
    if (!(_ringback && _ringback.isPlaying))
        return;

    [_ringback stop];
}


- (void)callStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = ZRNotifGetInt(notif, ZRSIPCallIdKey);
    pjsua_acc_id accountId = ZRNotifGetInt(notif, ZRSIPAccountIdKey);
    if (callId != _callId || accountId != _account.accountId)
        return;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    
    GSCallStatus callStatus;
    switch (callInfo.state) {
        case PJSIP_INV_STATE_NULL: {
            callStatus = GSCallStatusReady;
        } break;
            
        case PJSIP_INV_STATE_CALLING:
        case PJSIP_INV_STATE_INCOMING: {
            callStatus = GSCallStatusCalling;
        } break;
            
        case PJSIP_INV_STATE_EARLY:
        case PJSIP_INV_STATE_CONNECTING: {
            [self startRingback];
            callStatus = GSCallStatusConnecting;
        } break;
            
        case PJSIP_INV_STATE_CONFIRMED: {
            [self stopRingback];
            callStatus = GSCallStatusConnected;
        } break;
            
        case PJSIP_INV_STATE_DISCONNECTED: {
            [self stopRingback];
            callStatus = GSCallStatusDisconnected;
        } break;
    }
    
    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:callStatus]; });
}

- (void)callMediaStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = ZRNotifGetInt(notif, ZRSIPCallIdKey);
    if (callId != _callId)
        return;

    pjsua_call_info callInfo;
    ZRReturnIfFails(pjsua_call_get_info(_callId, &callInfo));
    
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
        ZRReturnIfFails(pjsua_conf_connect(callPort, 0));
        ZRReturnIfFails(pjsua_conf_connect(0, callPort));
        
        [self adjustVolume:_volume mic:_micVolume];
    }
}


- (BOOL)adjustVolume:(float)volume mic:(float)micVolume {
    ZRAssert(0.0 <= volume && volume <= 1.0, @"Volume value must be between 0.0 and 1.0");
    ZRAssert(0.0 <= micVolume && micVolume <= 1.0, @"Mic Volume must be between 0.0 and 1.0");
    
    _volume = volume;
    _micVolume = micVolume;
    if (_callId == PJSUA_INVALID_ID)
        return YES;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        
        // scale volume as per configured volume scale
        volume *= _volumeScale;
        micVolume *= _volumeScale;
        pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
        ZRReturnNoIfFails(pjsua_conf_adjust_rx_level(callPort, volume));
        ZRReturnNoIfFails(pjsua_conf_adjust_tx_level(callPort, micVolume));
    }
    
    // send volume change notification
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:volume], ZRVolumeKey,
            [NSNumber numberWithFloat:micVolume], ZRMicVolumeKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRVolumeDidChangeNotification
                          object:self
                        userInfo:info];
    
    return YES;
}

@end
