///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import "ZRCall.h"


@interface ZROutgoingCall : ZRCall

@property (nonatomic, copy, readonly) NSString *remoteUri;

- (id)initWithRemoteUri:(NSString *)remoteUri
            fromAccount:(ZRAccount *)account;

@end
