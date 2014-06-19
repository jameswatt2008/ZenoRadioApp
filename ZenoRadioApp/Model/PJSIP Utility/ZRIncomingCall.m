///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRIncomingCall.h"
#import "ZRCall+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRIncomingCall

- (id)initWithCallId:(NSInteger)callId toAccount:(ZRAccount *)account {
    if (self = [super initWithAccount:account]) {
        [self setCallId:callId];
    }
    return self;
}


- (BOOL)begin {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    
    int nCallId = (int)self.callId;
    ZRReturnNoIfFails(pjsua_call_answer(nCallId, 200, NULL, NULL));
    return YES;
}

- (BOOL)end {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    int nCallId = (int)self.callId;
    ZRReturnNoIfFails(pjsua_call_hangup(nCallId, 0, NULL, NULL));
    
    [self setStatus:GSCallStatusDisconnected];
    [self setCallId:PJSUA_INVALID_ID];
    return YES;
}

@end
