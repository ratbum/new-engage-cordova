//
//  UIView+Position.m
//  CLEngine
//
//  Created by Callum Abele on 18/06/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "UIView+Position.h"

@implementation UIView (Position)

- (void)setTop:(float)top {
    
    CGRect frame = self.frame;
    
    frame.origin.y = top;
    
    self.frame = frame;
}

- (float)top {
    
    return self.frame.origin.y;
}

- (void)setBottom:(float)bottom {
    
    CGRect frame = self.frame;
    
    float newHeight =  bottom - frame.origin.y;
    
    frame.size.height = newHeight;
    
    self.frame = frame;
}

- (float)bottom {
    
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLeft:(float)left {
    
    CGRect frame = self.frame;
    
    frame.origin.x = left;
    
    self.frame = frame;
    
}

- (float)left {
    
    return self.frame.origin.x;
}

- (void)setRight:(float)right {
    
    CGRect frame = self.frame;
    
    float newWidth = right - frame.origin.x;
    
    frame.size.width = newWidth;
    
    self.frame = frame;
    
}

- (float)right {
    
    return self.frame.origin.x + self.frame.size.width;
}


- (void)setX:(float)x {
    
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(float)y {
   
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setWidth:(float)width {
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (void)setHeight:(float)height {
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


@end
