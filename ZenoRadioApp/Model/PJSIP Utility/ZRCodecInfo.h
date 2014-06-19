///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Contains information for a codec.
@interface ZRCodecInfo : NSObject

@property (nonatomic, readonly) NSString *codecId; ///< Codec id as given by PJSIP
@property (nonatomic, readonly) NSString *description; ///< Codec descrition as given by PJSIP
@property (nonatomic, readonly) NSUInteger priority; ///< Codec priority in the range 1-254 or 0 to disable.

- (BOOL)setPriority:(NSUInteger)newPriority; ///< Sets codec priority.
- (BOOL)setMaxPriority; ///< Sets codec priority to maximum (254)

- (BOOL)disable; ///< Disable the codec. (Sets priority to 0)

@end
