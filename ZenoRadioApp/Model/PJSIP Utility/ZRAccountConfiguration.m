///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRAccountConfiguration.h"


@implementation ZRAccountConfiguration

+ (id)defaultConfiguration {
    return [[self alloc] init];
}

+ (id)configurationWithConfiguration:(ZRAccountConfiguration *)configuration {
    return [configuration copy];
}


- (id)init {
    if (!(self = [super init]))
        return nil; // super init failed.
    
    _address = nil;
    _domain = nil;
    _proxyServer = nil;
    _authScheme = @"digest";
    _authRealm = @"*";
    _username = nil;
    _password = nil;

    _enableRingback = YES;
    _ringbackFilename = @"ringtone.wav";
    
    // can prevent registration for services which don't support it so NO by default.
    _enableStatusPublishing = NO;
    return self;
}

- (void)dealloc {
    _address = nil;
    _domain = nil;
    _proxyServer = nil;
    _authScheme = nil;
    _authRealm = nil;
    _username = nil;
    _password = nil;
    _ringbackFilename = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    ZRAccountConfiguration *replica = [ZRAccountConfiguration defaultConfiguration];
    
    replica.address = self.address;
    replica.domain = self.domain;
    replica.proxyServer = self.proxyServer;
    replica.authScheme = self.authScheme;
    replica.authRealm = self.authRealm;
    replica.username = self.username;
    replica.password = self.password;
    
    replica.enableStatusPublishing = self.enableStatusPublishing;

    replica.enableRingback = self.enableRingback;
    replica.ringbackFilename = self.ringbackFilename;
    return replica;
}

@end
