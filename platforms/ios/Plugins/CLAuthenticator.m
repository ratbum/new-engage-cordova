//
//  CLAuthenticator.m
//  CrowdLab
//
//  Created by Thomas Lee on 26/11/2019.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "CLAuthenticator.h"

@implementation CLAuthenticator

- (void)requestAuthToken:(CDVInvokedUrlCommand *)command
{
  if (command == nil) {
    return;
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (sharedAuthenticator == nil){
      sharedAuthenticator = self;
      [[NSNotificationCenter defaultCenter] addObserver:sharedAuthenticator selector:@selector(returnAuthToken:) name:@"CLTokenRequestFulfilled" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:sharedAuthenticator selector:@selector(clearBacklog) name:@"CLTokenRequestsClear" object:nil];
    }
    
    if (CLAuthenticator.shared.authList == nil) {
      CLAuthenticator.shared.authList = [NSMutableArray new];
    }
    
    [CLAuthenticator.shared.authList addObject:command.callbackId];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"CLTokenRequest" object:nil]];
  });
}

- (void)clearBacklog {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    CLAuthenticator.shared.authList = [NSMutableArray new];
  });
}

+ (CLAuthenticator *)shared {
  return sharedAuthenticator;
}

- (void)returnAuthToken:(NSNotification *)notification {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    CDVPluginResult *result;
    NSLog(@"Returning token%@", notification.object);
    if (notification.object == nil) {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"no token"];
    } else {
      result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:notification.object];
    }
    NSString *callbackId = [[CLAuthenticator shared].authList objectAtIndex:0];
    [CLAuthenticator.shared.authList removeObjectAtIndex:0];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
  });
}

@end
