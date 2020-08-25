//
//  NSObject+PerformBlockAfterDelay.h
//  Halloween Prank
//
//  Created by Callum Abele on 15/08/2012.
//  Copyright (c) 2012 Abele Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VoidBlock)(void);
typedef void(^VoidBlockWithId)(id arg0);

@interface NSObject (PerformBlockAfterDelay)

- (void)performBlock:(VoidBlockWithId)block withId:(id)argument;
- (void)performBlock:(VoidBlock)block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(VoidBlock)block;


@end
