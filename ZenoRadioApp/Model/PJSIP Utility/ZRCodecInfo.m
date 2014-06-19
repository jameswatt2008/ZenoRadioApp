///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRCodecInfo.h"
#import "ZRCodecInfo+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRCodecInfo {
    pjsua_codec_info _info;
}

- (id)initWithCodecInfo:(pjsua_codec_info *)codecInfo {
    if (self = [super init]) {
        _info = *codecInfo;
    }
    return self;
}


- (NSString *)codecId {
    return [ZRPJUtil stringWithPJString:&_info.codec_id];
}

- (NSString *)description {
    return [ZRPJUtil stringWithPJString:&_info.desc];
}

- (NSUInteger)priority {
    return _info.priority;
}

- (BOOL)setPriority:(NSUInteger)newPriority {
    ZRReturnNoIfFails(pjsua_codec_set_priority(&_info.codec_id, newPriority));
    
    _info.priority = newPriority; // update cached info
    return YES;
}

- (BOOL)setMaxPriority {
    return [self setPriority:254];
}


- (BOOL)disable {
    return [self setPriority:0]; // 0 disables the codec as said in pjsua online doc
}

@end
