/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  Engage
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//
#import <Sentry/Sentry.h>
#import "CLAuthenticator.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import <os/log.h>

#ifdef CrowdLab
#import "CrowdLab-Swift.h"
#define APP_NAME_LOWERCASE @"crowdlab"
#endif
#ifdef CrowdLabQA
#import "CrowdLabQA-Swift.h"
#define APP_NAME_LOWERCASE @"crowdlab"
#endif
#ifdef Cymbol
#import "Cymbol-Swift.h"
#define APP_NAME_LOWERCASE @"cymbol"
#endif
#ifdef Momento
#import "Momento-Swift.h"
#define APP_NAME_LOWERCASE @"momento"
#endif
#ifdef Tempo
#import "Tempo-Swift.h"
#define APP_NAME_LOWERCASE @"tempo"
#endif
#ifdef TempoQA
#import "TempoQA-Swift.h"
#define APP_NAME_LOWERCASE @"tempo"
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  if (!url) {
    return NO;
  }
  NSString *action = [url resourceSpecifier];
  NSLog(@"Starting up... %@", action);
  if ([action isEqualToString:@"//logout"]) {
    CLUserDefaults *userDefaults = [CLUserDefaults standard];
    [userDefaults setDeviceId:0];
    [userDefaults deleteUser];
    [userDefaults deleteUserToken];
    [userDefaults deleteDeviceUUID];
    [CLAuthenticator.shared clearBacklog];
    self.startupConfig.deepLinkDestination = @"login";
    [self startup];
    self.startupConfig.deepLinkDestination = @"";
  }

  return true;
}

- (void)startup {

  self.mediaServer = [MediaMiddleman new];

  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
  UIViewController *yourController = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"SplashViewController"];

  SplashViewController *splashController = (SplashViewController *) yourController;
  splashController.startupConfig = self.startupConfig;
  self.window.rootViewController = yourController;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   [self.mediaServer setup];
  });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.startupConfig = [StartupConfig createPopulatedWithCommandLineArgs];
  [self startup];
  
  @try {
    NSError *sentryError;
    SentryClient.sharedClient = [[SentryClient alloc] initWithDsn:@"___PUBLIC_DSN___" didFailWithError:nil];
    [SentryClient.sharedClient startCrashHandlerWithError:&sentryError];
  }
  @catch (NSError *exc){
    NSLog(@"%@", exc);
  }
  return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  self.webTokenHandler = [WebTokenHandler create];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  self.webTokenHandler = [WebTokenHandler create];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.mediaServer setup];
  });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

@end
