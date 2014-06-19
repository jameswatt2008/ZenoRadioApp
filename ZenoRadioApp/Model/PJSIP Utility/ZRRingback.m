///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRRingback.h"
#import "ZRUserAgent.h"
#import "ZRUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation ZRRingback {
    float _volume;
    float _volumeScale;

    pjsua_conf_port_id _confPort;
    pjsua_player_id _playerId;
}

+ (id)ringbackWithSoundNamed:(NSString *)filename {
    return [[self alloc] initWithSoundNamed:filename];
}


- (id)initWithSoundNamed:(NSString *)filename {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];

        _isPlaying = NO;
        _confPort = PJSUA_INVALID_ID;
        _playerId = PJSUA_INVALID_ID;

        _volumeScale = [ZRUserAgent sharedAgent].configuration.volumeScale;
        _volume = 0.5 / _volumeScale; // half volume by default

        // resolve bundle filename
        filename = [filename lastPathComponent];
        filename = [bundle pathForResource:[filename stringByDeletingPathExtension]
                                    ofType:[filename pathExtension]];
        NSLog(@"Gossip: ringbackWithSoundNamed: %@", filename);

        // create pjsua media playlist
        const pj_str_t filenames[] = { [ZRPJUtil PJStringWithString:filename] };
        ZRReturnNilIfFails(pjsua_playlist_create(filenames, 1, NULL, 0, &_playerId));

        _confPort = pjsua_player_get_conf_port(_playerId);
    }
    return self;
}

- (void)dealloc {
    if (_playerId != PJSUA_INVALID_ID) {
        ZRLogIfFails(pjsua_player_destroy(_playerId));
        _playerId = PJSUA_INVALID_ID;
    }
}


- (BOOL)setVolume:(float)volume {
    ZRAssert(0.0 <= volume && volume <= 1.0, @"Volume value must be between 0.0 and 1.0");

    _volume = volume;
    volume *= _volumeScale;
    ZRReturnNoIfFails(pjsua_conf_adjust_rx_level(_confPort, volume));
    ZRReturnNoIfFails(pjsua_conf_adjust_tx_level(_confPort, volume));

    return YES;
}


- (BOOL)play {
    ZRAssert(!_isPlaying, @"Already connected to a call.");

    ZRReturnNoIfFails(pjsua_conf_connect(_confPort, 0));
    _isPlaying = YES;
    return YES;
}

- (BOOL)stop {
    ZRAssert(_isPlaying, @"Not connected to a call.");

    ZRReturnNoIfFails(pjsua_conf_disconnect(_confPort, 0));
    _isPlaying = NO;
    return YES;
}


@end
