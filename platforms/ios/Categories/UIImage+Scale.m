//
//  UIImage+Scale.m
//  CLEngine
//
//  Created by Callum Abele on 25/08/2015.
//  Copyright (c) 2015 CrowdLab. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

- (UIImage *)drawIntoSize:(CGFloat)newHeight newWidth:(CGFloat)newWidth {
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
  [self drawInRect:CGRectMake(0.0, 0.0, newWidth, newHeight)];

  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return newImage;
}

- (UIImage *)resizeWidth:(CGFloat)newWidth {
  float scaleFactor = newWidth / self.size.width;
  float newHeight = self.size.height * scaleFactor;
  return [self drawIntoSize:newHeight newWidth:newWidth];
}

- (UIImage *)resizeHeight:(CGFloat)newHeight {
  CGFloat scaleFactor = newHeight / self.size.height;
  CGFloat newWidth = floor(self.size.width * scaleFactor);
  return [self drawIntoSize:newHeight newWidth:newWidth];
}

- (UIImage *)imageScaledToFitWidth:(CGFloat)newWidth andHeight:(CGFloat)newHeight {
  //calculate rect
  CGSize size = CGSizeMake(newWidth, newHeight);
  CGFloat aspect = self.size.width / self.size.height;
  if (size.width / aspect <= size.height) {
    //        return [self imageScaledToSize:CGSizeMake(size.width, size.width / aspect)];
    return [self drawIntoSize:size.width / aspect newWidth:size.width];
  } else {
    //        return [self imageScaledToSize:CGSizeMake(size.height * aspect, size.height)];
    return [self drawIntoSize:size.height newWidth:size.height * aspect];
  }
}

@end
