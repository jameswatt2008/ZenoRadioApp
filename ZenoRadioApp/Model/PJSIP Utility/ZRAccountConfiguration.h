///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Account configuration. Only supports "digest" and plain-text password authentication atm.
@interface ZRAccountConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSString *address; ///< SIP address.
@property (nonatomic, copy) NSString *domain; ///< SIP domain.
@property (nonatomic, copy) NSString *proxyServer; ///< SIP outbound proxy server.
@property (nonatomic, copy) NSString *authScheme; ///< Authentication scheme. Defaults to "digest".
@property (nonatomic, copy) NSString *authRealm; ///< Authentication realm. Defaults to "*".
@property (nonatomic, copy) NSString *username; ///< SIP username.
@property (nonatomic, copy) NSString *password; ///< SIP password.

@property (nonatomic) BOOL enableStatusPublishing; ///< Enable online/status publishing for services that support them.

@property (nonatomic) BOOL enableRingback; ///< Enable automatic ringback sounds.
@property (nonatomic, copy) NSString *ringbackFilename; ///< Filename to play as ringback sounds. Defaults to "ringtone.wav" so you can just include it in your bundle and Gossip will pick it up.

+ (id)defaultConfiguration; ///< Creates a GSAccountConfiguration instance with default configuration values.
+ (id)configurationWithConfiguration:(ZRAccountConfiguration *)configuration; ///< Copy constructor.

@end
