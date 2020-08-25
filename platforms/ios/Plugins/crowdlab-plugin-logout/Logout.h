//
//  Logout.h
//  Engage
//
//  Created by Thomas Lee on 01/10/2019.
//

#import <Cordova/CDVPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface Logout : CDVPlugin
- (void)logout:(CDVInvokedUrlCommand *)command;
@end

NS_ASSUME_NONNULL_END
