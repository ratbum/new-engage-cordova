//
//  CLUtilities.h
//  CrowdLab
//
//  Created by Terence Baker on 15/10/2012.
//  Copyright (c) 2012 CrowdLab. All rights reserved.
//

typedef void (^ voidBlock)(void);

@interface CLUtilities : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (void)runOnMainQueueWithoutDeadlocking:(voidBlock)block;
+ (UIWindowLevel)getLastWindowLevel;

@end
