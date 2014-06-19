///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Defines notification names
#define ZRConstDefine(name_) extern NSString *const name_;

ZRConstDefine(ZRSIPRegistrationStateDidChangeNotification);
ZRConstDefine(ZRSIPRegistrationDidStartNotification);
ZRConstDefine(ZRSIPCallStateDidChangeNotification);
ZRConstDefine(ZRSIPIncomingCallNotification);
ZRConstDefine(ZRSIPCallMediaStateDidChangeNotification);
ZRConstDefine(ZRSIPVolumeDidChangeNotification);

ZRConstDefine(ZRVolumeDidChangeNotification);

ZRConstDefine(ZRSIPAccountIdKey);
ZRConstDefine(ZRSIPRenewKey);
ZRConstDefine(ZRSIPCallIdKey);
ZRConstDefine(ZRSIPDataKey);

ZRConstDefine(ZRVolumeKey);
ZRConstDefine(ZRMicVolumeKey);


// helper macros
#define ZRNotifGetInt(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] intValue])
#define ZRNotifGetBool(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] boolValue])
#define ZRNotifGetString(info_, key_) ((NSString *)[[notif_ userInfo] objectForKey:key_])

