///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZRAccountConfiguration.h"


/// Supported transport types.
typedef enum {
    GSUDPTransportType, ///< UDP transport type.
    GSUDP6TransportType, ///< UDP on IPv6 transport type.
    GSTCPTransportType, ///< TCP transport type.
    GSTCP6TransportType, ///< TCP on IPv6 transport type.
} GSTransportType;


/// Main class for configuring a SIP user agent.
@interface ZRConfiguration : NSObject <NSCopying>

@property (nonatomic) NSUInteger logLevel; ///< PJSIP log level.
@property (nonatomic) NSUInteger consoleLogLevel; ///< PJSIP console output level.

@property (nonatomic) GSTransportType transportType; ///< Transport type to use for connection.

@property (nonatomic) NSUInteger clockRate; ///< PJSIP clock rate.
@property (nonatomic) NSUInteger soundClockRate; ///< PJSIP sound clock rate.
@property (nonatomic) float volumeScale; ///< Used for scaling volumes up and down.

@property (nonatomic, strong) ZRAccountConfiguration *account;

+ (id)defaultConfiguration;
+ (id)configurationWithConfiguration:(ZRConfiguration *)configuration;

@end
