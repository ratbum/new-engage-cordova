//
//  Echo.h
//  Engage
//
//  Created by Patrick Corbett on 01/10/2019.
//

/********* Echo.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>

@interface Echo : CDVPlugin

- (void)echo:(CDVInvokedUrlCommand*)command;

@end
