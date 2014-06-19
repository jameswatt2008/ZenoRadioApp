///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//


// additional util imports
#import "ZRPJUtil.h"


// just in case we need to compile w/o assertions
#define ZRAssert NSAssert


// PJSIP status check macros
#define ZRLogSipError(status_)                                      \
    NSLog(@"Gossip: %@", [ZRPJUtil errorWithSIPStatus:status_]);

#define ZRLogIfFails(aStatement_) do {      \
    pj_status_t status = (aStatement_);     \
    if (status != PJ_SUCCESS)               \
        ZRLogSipError(status);              \
} while (0)

#define ZRReturnValueIfFails(aStatement_, returnValue_) do {            \
    pj_status_t status = (aStatement_);                                 \
    if (status != PJ_SUCCESS) {                                         \
        ZRLogSipError(status);                                          \
        return returnValue_;                                            \
    }                                                                   \
} while(0)

#define ZRReturnIfFails(aStatement_) ZRReturnValueIfFails(aStatement_, )
#define ZRReturnNoIfFails(aStatement_) ZRReturnValueIfFails(aStatement_, NO)
#define ZRReturnNilIfFails(aStatement_) ZRReturnValueIfFails(aStatement_, nil)
