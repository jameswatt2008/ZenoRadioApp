///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZRAccountConfiguration.h"
@class ZRAccount, ZRCall;


/// Account Status enum.
typedef enum {
    ZRAccountStatusOffline, ///< Account is offline or no registration has been done.
    ZRAccountStatusInvalid, ///< Gossip has attempted registration but the credentials were invalid.
    ZRAccountStatusConnecting, ///< Gossip is trying to register the account with the SIP server.
    ZRAccountStatusConnected, ///< Account has been successfully registered with the SIP server.
    ZRAccountStatusDisconnecting, ///< Account is being unregistered from the SIP server.
} ZRAccountStatus; ///< Account status enum.


/// Delegate to receive account activity.
@protocol ZRAccountDelegate <NSObject>

/// Called when an account recieves an incoming call.
/** Call GSCall::begin to accept incoming call or GSCall::end to deny. 
 *  This should be done in a timely fashion since we do not support timeouts for incoming call yet. */
- (void)account:(ZRAccount *)account didReceiveIncomingCall:(ZRCall *)call;

@end


/// Represents a single PJSIP account. Only one account per session is supported right now.
@interface ZRAccount : NSObject

@property (nonatomic, readonly) NSInteger accountId; ///< Account Id, automatically assigned by PJSIP.
@property (nonatomic, readonly) ZRAccountStatus status; ///< Account registration status. Supports KVO notification.

@property (nonatomic, unsafe_unretained) id<ZRAccountDelegate> delegate; ///< Account activity delegate.

/// Configures account with the specified configuration.
/** Must be run once and only once before using the GSAccount instance.
 *  Usually this is called automatically by the GSUserAgent instance. */
- (BOOL)configure:(ZRAccountConfiguration *)configuration;

- (BOOL)connect; ///< Connects and begin registering with the configured SIP registration server.
- (BOOL)disconnect; ///< Unregister from the SIP registration server and disconnects.

@end
