///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRUserAgent.h"
#import "ZRUserAgent+Private.h"
#import "ZRCodecInfo.h"
#import "ZRCodecInfo+Private.h"
#import "ZRDispatch.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRUserAgent {
    ZRConfiguration *_config;
    pjsua_transport_id _transportId;
}

@synthesize account = _account;
@synthesize status = _status;

+ (ZRUserAgent *)sharedAgent {
    static dispatch_once_t onceToken;
    static ZRUserAgent *agent = nil;
    dispatch_once(&onceToken, ^{ agent = [[ZRUserAgent alloc] init]; });
    
    return agent;
}


- (id)init {
    if (self = [super init]) {
        _account = nil;
        _config = nil;
        
        _transportId = PJSUA_INVALID_ID;
        _status = ZRUserAgentStateUninitialized;
    }
    return self;
}

- (void)dealloc {
    if (_transportId != PJSUA_INVALID_ID) {
        pjsua_transport_close(_transportId, PJ_TRUE);
        _transportId = PJSUA_INVALID_ID;
    }
    
    if (_status >= ZRUserAgentStateConfigured) {
        pjsua_destroy();
    }
    
    _account = nil;
    _config = nil;
    _status = ZRUserAgentStateDestroyed;
}


- (ZRConfiguration *)configuration {
    return _config;
}

- (ZRUserAgentState)status {
    return _status;
}

- (void)setStatus:(ZRUserAgentState)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}


- (BOOL)configure:(ZRConfiguration *)config {
    ZRAssert(!_config, @"Gossip: User agent is already configured.");
    _config = [config copy];
    
    // create agent
    ZRReturnNoIfFails(pjsua_create());
    [self setStatus:ZRUserAgentStateCreated];
    
    // configure agent
    pjsua_config uaConfig;
    pjsua_logging_config logConfig;
    pjsua_media_config mediaConfig;
    
    pjsua_config_default(&uaConfig);
    [ZRDispatch configureCallbacksForAgent:&uaConfig];
    
    pjsua_logging_config_default(&logConfig);
    int nLogLevel = (int)_config.logLevel;
    int nConsoleLogLevel = (int)_config.consoleLogLevel;
    logConfig.level = nLogLevel;
    logConfig.console_level = nConsoleLogLevel;
    
    pjsua_media_config_default(&mediaConfig);
    unsigned uClockRate = (unsigned)_config.clockRate;
    unsigned uSoundClockRate = (unsigned)_config.soundClockRate;
    mediaConfig.clock_rate = uClockRate;
    mediaConfig.snd_clock_rate = uSoundClockRate;
    mediaConfig.ec_tail_len = 0; // not sure what this does (Siphon use this.)
    
    ZRReturnNoIfFails(pjsua_init(&uaConfig, &logConfig, &mediaConfig));
    
    // create UDP transport
    // TODO: Make configurable? (which transport type to use/other transport opts)
    // TODO: Make separate class? since things like public_addr might be useful to some.
    pjsua_transport_config transportConfig;
    pjsua_transport_config_default(&transportConfig);
    
    pjsip_transport_type_e transportType = 0;
    switch (_config.transportType) {
        case GSUDPTransportType: transportType = PJSIP_TRANSPORT_UDP; break;
        case GSUDP6TransportType: transportType = PJSIP_TRANSPORT_UDP6; break;
        case GSTCPTransportType: transportType = PJSIP_TRANSPORT_TCP; break;
        case GSTCP6TransportType: transportType = PJSIP_TRANSPORT_TCP6; break;
    }
    
    ZRReturnNoIfFails(pjsua_transport_create(transportType, &transportConfig, &_transportId));
    [self setStatus:ZRUserAgentStateConfigured];

    // configure account
    _account = [[ZRAccount alloc] init];
    return [_account configure:_config.account];
}


- (BOOL)start {
    ZRReturnNoIfFails(pjsua_start());
    [self setStatus:ZRUserAgentStateCreated];
    return YES;
}

- (BOOL)reset {
    [_account disconnect];

    // needs to nil account before pjsua_destroy so pjsua_acc_del succeeds.
    _transportId = PJSUA_INVALID_ID;
    _account = nil;
    _config = nil;
    NSLog(@"Destroying...");
    ZRReturnNoIfFails(pjsua_destroy());
    [self setStatus:ZRUserAgentStateDestroyed];
    return YES;
}


- (NSArray *)arrayOfAvailableCodecs {
    ZRAssert(!!_config, @"Gossip: User agent not configured.");
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    unsigned int count = 255;
    pjsua_codec_info codecs[count];
    ZRReturnNilIfFails(pjsua_enum_codecs(codecs, &count));
    
    for (int i = 0; i < count; i++) {
        pjsua_codec_info pjCodec = codecs[i];
        
        ZRCodecInfo *codec = [ZRCodecInfo alloc];
        codec = [codec initWithCodecInfo:&pjCodec];
        [arr addObject:codec];
    }
    
    return [NSArray arrayWithArray:arr];
}

@end
