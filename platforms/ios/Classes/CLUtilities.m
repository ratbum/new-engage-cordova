//
//  CLUtilities.m
//  CLEngine
//
//  Created by Albert Devesa on 20/01/2016.
//  Copyright © 2016 CrowdLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLUtilities.h"

@implementation CLUtilities

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)runOnMainQueueWithoutDeadlocking:(voidBlock)block {
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (UIWindowLevel)getLastWindowLevel {
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *lastWindow = (UIWindow *)[windows lastObject];
    return lastWindow.windowLevel;
}

@end
