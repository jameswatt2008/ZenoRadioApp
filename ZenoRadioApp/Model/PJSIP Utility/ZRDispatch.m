///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRDispatch.h"


void onRegistrationStarted(pjsua_acc_id accountId, pj_bool_t renew);
void onRegistrationState(pjsua_acc_id accountId);
void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata);
void onCallMediaState(pjsua_call_id callId);
void onCallState(pjsua_call_id callId, pjsip_event *e);


static dispatch_queue_t _queue = NULL;


@implementation ZRDispatch

+ (void)initialize {
    _queue = dispatch_queue_create("GSDispatch", DISPATCH_QUEUE_SERIAL);
}

+ (void)configureCallbacksForAgent:(pjsua_config *)uaConfig {
    uaConfig->cb.on_reg_started = &onRegistrationStarted;
    uaConfig->cb.on_reg_state = &onRegistrationState;
    uaConfig->cb.on_incoming_call = &onIncomingCall;
    uaConfig->cb.on_call_media_state = &onCallMediaState;
    uaConfig->cb.on_call_state = &onCallState;
}


#pragma mark - Dispatch sink

// TODO: May need to implement some form of subscriber filtering
//   orthogonaly/globally if we're to scale. But right now a few
//   dictionary lookups on the receiver side probably wouldn't hurt much.

+ (void)dispatchRegistrationStarted:(pjsua_acc_id)accountId renew:(pj_bool_t)renew {
    NSLog(@"Gossip: dispatchRegistrationStarted(%d, %d)", accountId, renew);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:accountId], ZRSIPAccountIdKey,
            [NSNumber numberWithBool:renew], ZRSIPRenewKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRSIPRegistrationDidStartNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchRegistrationState:(pjsua_acc_id)accountId {
    NSLog(@"Gossip: dispatchRegistrationState(%d)", accountId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:accountId]
                                       forKey:ZRSIPAccountIdKey];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRSIPRegistrationDidStartNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchIncomingCall:(pjsua_acc_id)accountId
                      callId:(pjsua_call_id)callId
                        data:(pjsip_rx_data *)data {
    NSLog(@"Gossip: dispatchIncomingCall(%d, %d)", accountId, callId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:accountId], ZRSIPAccountIdKey,
            [NSNumber numberWithInt:callId], ZRSIPCallIdKey,
            [NSValue valueWithPointer:data], ZRSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRSIPIncomingCallNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallMediaState:(pjsua_call_id)callId {
    NSLog(@"Gossip: dispatchCallMediaState(%d)", callId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:callId]
                                       forKey:ZRSIPCallIdKey];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRSIPCallMediaStateDidChangeNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallState:(pjsua_call_id)callId event:(pjsip_event *)e {
    NSLog(@"Gossip: dispatchCallState(%d)", callId);

    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:callId], ZRSIPCallIdKey,
            [NSValue valueWithPointer:e], ZRSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ZRSIPCallMediaStateDidChangeNotification
                          object:self
                        userInfo:info];
}

@end


#pragma mark - C event bridge

// Bridge C-land callbacks to ObjC-land.

static inline void dispatch(dispatch_block_t block) {    
    // autorelease here since events wouldn't be triggered that often.
    // + GCD autorelease pool do not have drainage time guarantee (== possible mem headaches).
    // See the "Implementing tasks using blocks" section for more info
    // REF: http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
    @autoreleasepool {

        // NOTE: Needs to use dispatch_sync() instead of dispatch_async() because we do not know
        //   the lifetime of the stuff being given to us by PJSIP (e.g. pjsip_rx_data*) so we
        //   must process it completely before the method ends.
        dispatch_sync(_queue, block);
    }
}


void onRegistrationStarted(pjsua_acc_id accountId, pj_bool_t renew) {
    dispatch(^{ [ZRDispatch dispatchRegistrationStarted:accountId renew:renew]; });
}

void onRegistrationState(pjsua_acc_id accountId) {
    dispatch(^{ [ZRDispatch dispatchRegistrationState:accountId]; });
}

void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata) {
    dispatch(^{ [ZRDispatch dispatchIncomingCall:accountId callId:callId data:rdata]; });
}

void onCallMediaState(pjsua_call_id callId) {
    dispatch(^{ [ZRDispatch dispatchCallMediaState:callId]; });
}

void onCallState(pjsua_call_id callId, pjsip_event *e) {
    dispatch(^{ [ZRDispatch dispatchCallState:callId event:e]; });
}
