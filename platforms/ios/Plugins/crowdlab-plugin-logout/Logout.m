//
//  Logout.m
//  Engage
//
//  Created by Thomas Lee on 01/10/2019.
//

#import <Foundation/Foundation.h>
#import "Logout.h"
#import <Cordova/CDVPlugin.h>

#ifdef CrowdLab
#define APP_NAME_LOWERCASE @"crowdlab"
#endif
#ifdef CrowdLabQA
#define APP_NAME_LOWERCASE @"crowdlab"
#endif
#ifdef Cymbol
#define APP_NAME_LOWERCASE @"cymbol"
#endif
#ifdef Momento
#define APP_NAME_LOWERCASE @"momento"
#endif
#ifdef Tempo
#define APP_NAME_LOWERCASE @"tempo"
#endif
#ifdef TempoQA
#define APP_NAME_LOWERCASE @"tempo"
#endif


@implementation Logout

- (void)logout:(CDVInvokedUrlCommand *)command
{
  [[[[UIApplication sharedApplication] delegate] window] setRootViewController:[UIViewController new]];
  
  
  NSURL *url = [NSURL URLWithString:[APP_NAME_LOWERCASE stringByAppendingString: @"://logout"]];
  NSLog(@"%@", [@"Logging out... " stringByAppendingFormat:@"%@", url.absoluteString]);
  CDVPluginResult *result = [CDVPluginResult resultWithStatus:(CDVCommandStatus)[NSNumber numberWithInt:INT_MAX] messageAsString:@"LOGOUT"];
  
  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL didOpen) {
    if (!didOpen) {
      exit(1);
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    return;
  }];
}

@end
