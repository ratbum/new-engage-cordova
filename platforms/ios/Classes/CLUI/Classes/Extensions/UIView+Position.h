//
//  UIView+Position.h
//  CLEngine
//
//  Created by Callum Abele on 18/06/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Position)

- (void)setTop:(float)top;
- (float)top;

- (void)setBottom:(float)bottom;
- (float)bottom;

- (void)setLeft:(float)left;
- (float)left;

- (void)setRight:(float)right;
- (float)right;

- (void)setX:(float)x;
- (void)setY:(float)y;
- (void)setWidth:(float)width;
- (void)setHeight:(float)height;

@end
