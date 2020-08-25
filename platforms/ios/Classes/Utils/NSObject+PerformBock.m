//
//  NSObject+PerformBlockAfterDelay.m
//  Halloween Prank
//
//  Created by Callum Abele on 15/08/2012.
//  Copyright (c) 2012 Abele Apps. All rights reserved.
//

#import "NSObject+PerformBlock.h"

@implementation NSObject (PerformBlockAfterDelay)

- (void)performBlock:(VoidBlockWithId)block withId:(id)argument {
  block(argument);
}

- (void)performBlock:(VoidBlock)block afterDelay:(NSTimeInterval)delay {
  [self performSelector:@selector(performBlock:) withObject:block afterDelay:delay];
}

- (void)performBlock:(VoidBlock)block {
  block();
}

@end
