//
//  Echo.m
//  Engage
//
//  Created by Patrick Corbett on 01/10/2019.
//

/********* Echo.m Cordova Plugin Implementation *******/

#import "Echo.h"
#import <Cordova/CDVPlugin.h>

@implementation Echo

- (void)echo:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];

    NSLog(@"Tell Cersei, it was me");
  
    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
