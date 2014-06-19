///
//  ZRMainDisplayViewController.m
//  ZenoRadioApp
//
//  Created by Atamosa Antonio Jr. on 6/16/14.
//  Copyright (c) 2014 ICONS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZRAccount.h"
#import "ZRConfiguration.h"


typedef enum {
    ZRUserAgentStateUninitialized = 0,
    ZRUserAgentStateCreated = 1,
    ZRUserAgentStateConfigured = 2,
    ZRUserAgentStateStarted = 3,
    ZRUserAgentStateDestroyed = -1, // TODO: Remove? Since it's equivalent to uninitialized.
} ZRUserAgentState;


/// Mains SIP user agent interface. Applications should configure the shared instance on startup.
/** Only a single GSUserAgent may be created for each application since PJSIP only supports a single user agent at a time.
 *  Applications should follow the following steps to initialize the agent:
 *
 *  1. Obtain an instance of this class using sharedAgent()
 *  2. Creates and configure an instance of GSConfiguration.
 *  3. Calls configure:() to configure the agent.
 *  4. (Optional) GSAccount::connect to the SIP server
 */
@interface ZRUserAgent : NSObject

@property (nonatomic, strong, readonly) ZRAccount *account; ///< Default GSAccount instance with the configured SIP account registration.
@property (nonatomic, readonly) ZRUserAgentState status; ///< User agent configuration state. Supports KVO notification.

/// Obtains the shared user agent instance.
+ (ZRUserAgent *)sharedAgent;

/// Configure the agent for use.
/** This method must be called on application startup and before using any SIP functionality.
 *  Check http://www.pjsip.org/pjsip/docs/html/structpjsua__acc__config.htm for additional reference. */
- (BOOL)configure:(ZRConfiguration *)config;

/// Starts the user agent.
/** This method effectively cause PJSIP to begin connecting to the configured SIP server
 *  using the credentials specified when configure:() was called. A GSAccount instance
 *  will be created and used for registration automatically.
 *
 *  After a successful start, application should call GSAccount::connect() to connect
 *  to the SIP server to listen for incoming calls (or making outgoing calls.)
 */
- (BOOL)start;

/// Resets the user agent to an unconfigured state.
/** You will need to call GSUserAgent::configure() and GSUserAgent::start() again.
 *  You may use this method to resets and reconnect user agent to a different account.
 */
- (BOOL)reset;

/// Gets an array of GSCodecInfo for codecs loaded by PJSIP.
- (NSArray *)arrayOfAvailableCodecs;

@end
