//
//  SetUserTokenPlugin.h
//  CrowdLab
//
//  Created by Thomas Lee on 22/10/2019.
//

#import <Cordova/CDVPlugin.h>


NS_ASSUME_NONNULL_BEGIN

@interface SetUserToken : CDVPlugin

- (void)setUserToken:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
