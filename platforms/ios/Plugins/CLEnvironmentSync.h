//
//  CLEnvironmentSync.h
//  CrowdLab
//
//  Created by Thomas Lee on 26/11/2019.
//

#import <Cordova/CDVPlugin.h>

#ifndef CLEnvironmentSync_h
#define CLEnvironmentSync_h


@interface CLEnvironmentSync : CDVPlugin

- (void)syncEnvironment:(CDVInvokedUrlCommand *)command;


@end

#endif /* CLEnvironmentSync_h */
