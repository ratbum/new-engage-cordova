//
//  CLLanguageSync.m
//  CrowdLab
//
//  Created by Thomas Lee on 26/11/2019.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "CLEnvironmentSync.h"

@implementation CLEnvironmentSync

- (void)syncEnvironment:(CDVInvokedUrlCommand *)command
{
  if (command == nil) {
    return;
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"invoke sync");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    // This path must match EnvironmentJS.fileUrl()
    NSURL *environmentURL = [documentsDirectory URLByAppendingPathComponent: @"environment.js"];
    NSString *newEnvContents = command.arguments.firstObject;
    NSError *potentialError = nil;
    [newEnvContents writeToFile:environmentURL.path atomically:false encoding:NSUTF8StringEncoding error: &potentialError];
    if (potentialError != nil) {
      NSLog(@"%@", potentialError);
    }
  });
  
}

@end
