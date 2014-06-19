///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRConfiguration.h"


@implementation ZRConfiguration

+ (id)defaultConfiguration {
    return [[ZRConfiguration alloc] init];
}

+ (id)configurationWithConfiguration:(ZRConfiguration *)configuration {
    return [configuration copy];
}


- (id)init {
    if (!(self = [super init]))
        return nil; // init failed.

    // default values
    _logLevel = 2;
    _consoleLogLevel = 2;
    
    _transportType = GSUDPTransportType;
    
    // match clock rate to default number provided by PJSIP.
    // http://www.pjsip.org/pjsip/docs/html/structpjsua__media__config.htm#a24792c277d6c6c309eccda9047f641a5
    // setting sound clock rate to zero makes it use the conference bridge rate
    // http://www.pjsip.org/pjsip/docs/html/structpjsua__media__config.htm#aeb0fbbdf83b12a29903509adf16ccb3b
    _clockRate = 16000;
    _soundClockRate = 0;
    
    // default volume scale to 2.0 so 1.0 is twice as loud as PJSIP would normally emit.
    _volumeScale = 2.0;
    
    _account = [ZRAccountConfiguration defaultConfiguration];
    return self;
}

- (void)dealloc {
    _account = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    ZRConfiguration *replica = [[[self class] allocWithZone:zone] init];
    
    // TODO: Probably better to do via class_copyPropertyList.
    replica.logLevel = self.logLevel;
    replica.consoleLogLevel = self.consoleLogLevel;
    replica.transportType = self.transportType;

    replica.clockRate = self.clockRate;
    replica.soundClockRate = self.soundClockRate;
    replica.volumeScale = self.volumeScale;

    replica.account = [self.account copy];
    return replica;
}

@end
