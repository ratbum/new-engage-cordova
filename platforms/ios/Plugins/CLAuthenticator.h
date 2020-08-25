//
//  CLAuthenticator.h
//  CrowdLab
//
//  Created by Thomas Lee on 26/11/2019.
//

#import <Cordova/CDVPlugin.h>

#ifndef CLAuthenticator_h
#define CLAuthenticator_h


@interface CLAuthenticator : CDVPlugin

- (void)requestAuthToken:(CDVInvokedUrlCommand *)command;
- (void)returnAuthToken:(NSNotification *)notification;

- (void)clearBacklog;

@property (strong, nonatomic) NSMutableArray *authList;

+ (CLAuthenticator *)shared;

@end

static CLAuthenticator *sharedAuthenticator;


#endif /* CLAuthenticator_h */
