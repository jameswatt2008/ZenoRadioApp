///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Ringback sound player.
@interface ZRRingback : NSObject

@property (nonatomic, readonly) BOOL isPlaying; ///< Returns wether ringback is already playing or not.
@property (nonatomic, readonly) float volume; ///< Returns current ringback volume.

/// Creates GSRingback instance with ringback tone from the specified filename.
+ (id)ringbackWithSoundNamed:(NSString *)filename;

- (BOOL)setVolume:(float)volume; ///< Sets ringback volume. This value is subject to GSConfiguration.volumeScale.

- (BOOL)play; ///< Plays the ringback sound on the default sound device.
- (BOOL)stop; ///< Stops the playback.

@end
