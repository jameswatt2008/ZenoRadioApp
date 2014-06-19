///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRUserAgent.h"
#import "ZRConfiguration.h"


@interface ZRUserAgent (Private)

@property (nonatomic, readonly) ZRConfiguration *configuration;
@property (nonatomic, readwrite) ZRUserAgentState status;

@end
