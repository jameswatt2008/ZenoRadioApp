///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PJSIP.h"
#import "ZRNotifications.h" // almost always needed by importers


@interface ZRDispatch : NSObject

+ (void)configureCallbacksForAgent:(pjsua_config *)uaConfig;

@end
