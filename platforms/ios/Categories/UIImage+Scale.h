//
//  UIImage+Scale.h
//  CLEngine
//
//  Created by Callum Abele on 25/08/2015.
//  Copyright (c) 2015 CrowdLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
- (UIImage *)resizeWidth:(CGFloat)width;
- (UIImage *)resizeHeight:(CGFloat)newHeight;
- (UIImage *)imageScaledToFitWidth:(CGFloat)newWidth andHeight:(CGFloat)newHeight;

@end
