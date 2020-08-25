//
//  AwesomeMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kAwesomeMenuDefaultNearRadius = 110.0f;
static CGFloat const kAwesomeMenuDefaultEndRadius = 120.0f;
static CGFloat const kAwesomeMenuDefaultFarRadius = 140.0f;
static CGFloat const kAwesomeMenuDefaultStartPointX = 160.0;
static CGFloat const kAwesomeMenuDefaultStartPointY = 240.0;
static CGFloat const kAwesomeMenuDefaultTimeOffset = 0.036f;
static CGFloat const kAwesomeMenuDefaultRotateAngle = 0.0;
static CGFloat const kAwesomeMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kAwesomeMenuDefaultExpandRotation = M_PI;
static CGFloat const kAwesomeMenuDefaultCloseRotation = M_PI * 2;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);
}

@interface AwesomeMenu ()
- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation AwesomeMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation;
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;

#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
		
		self.nearRadius = kAwesomeMenuDefaultNearRadius;
		self.endRadius = kAwesomeMenuDefaultEndRadius;
		self.farRadius = kAwesomeMenuDefaultFarRadius;
		self.timeOffset = kAwesomeMenuDefaultTimeOffset;
		self.rotateAngle = kAwesomeMenuDefaultRotateAngle;
		self.menuWholeAngle = kAwesomeMenuDefaultMenuWholeAngle;
		self.startPoint = CGPointMake(kAwesomeMenuDefaultStartPointX, kAwesomeMenuDefaultStartPointY);
        self.expandRotation = kAwesomeMenuDefaultExpandRotation;
        self.closeRotation = kAwesomeMenuDefaultCloseRotation;
        
        self.menusArray = aMenusArray;
        self.enabled = YES;
        
        _addButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"transparent.png"]
                                           highlightedImage:[UIImage imageNamed:@"transparent.png"]
                                               ContentImage:[UIImage imageNamed:@"transparent.png"]
                                    highlightedContentImage:[UIImage imageNamed:@"transparent.png"]];
        _addButton.delegate = self;
        _addButton.center = self.startPoint;
        [self addSubview:_addButton];
    }
    return self;
}

#pragma mark - getters & setters

- (void)setStartPoint:(CGPoint)aPoint {
    
    startPoint = aPoint;
    _addButton.center = aPoint;
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
    
	_addButton.image = image;
}

- (UIImage*)image {
    
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
    
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
    
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
    
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
    
	return _addButton.contentImageView.highlightedImage;
}
                               
#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        
        return NO;
    }
    // if the menu is animating, prevent touches
    if (_isAnimating) {
        
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding) {
        
        return YES;
    }
    else {

        // KAC - updated to respond if a hit happens in our frame, rather than in our _addButton.
        return CGRectContainsPoint(self.bounds, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.enabled) {
        
        return;
    }
    self.expanding = !self.isExpanding;
    
    if ([_delegate respondsToSelector:@selector(awesomeMenu:isAnimating:)]) {
        
        [_delegate awesomeMenu:self isAnimating:_isAnimating];
    }
}

#pragma mark - AwesomeMenuItem delegates

- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item
{
    if (item == _addButton) {
        
        if (!self.enabled) {
            
            return;
        }
        self.expanding = !self.isExpanding;
        if ([_delegate respondsToSelector:@selector(awesomeMenu:isAnimating:)]) {
            
            [_delegate awesomeMenu:self isAnimating:_isAnimating];
        }
    }
}

- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item {
    
    // exclude the "add" button
    if (item == _addButton) {
        
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    
    [item.layer addAnimation:blowup forKey:nil];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++) {
        
        AwesomeMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            
            continue;
        }
        
        [otherItem.layer addAnimation:shrink forKey:nil];

        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate "add" button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_delegate respondsToSelector:@selector(AwesomeMenu:didSelectIndex:)]) {
        
        [_delegate AwesomeMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - instant methods

- (void)setMenusArray:(NSArray *)aMenusArray {
    
    if (aMenusArray == _menusArray) {
        
        return;
    }

    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) {
        
        if (v.tag >= 1000) {
            
            [v removeFromSuperview];
        }
    }
}


- (void)_setMenu {

    NSUInteger count = [_menusArray count];
    for (NSUInteger i = 0; i < count; i ++) {
        
        AwesomeMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = startPoint;
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
        item.alpha = 0.001;
		[self insertSubview:item belowSubview:_addButton];
    }
}

- (BOOL)isExpanding {
    
    return _expanding;
}

- (void)setExpanding:(BOOL)expanding {
    
	if (expanding) {
        
		[self _setMenu];
        [[NSNotificationCenter defaultCenter] postNotificationName:AWESOMEMENU_EXPANDING object:nil];
	}
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AWESOMEMENU_CLOSING object:nil];
    }
	
    _expanding = expanding;    
    
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        
        _addButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    // expand or close animation
    if (!_timer) {
        
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}

#pragma mark - private methods

- (void)_expand {
	
    if (_flag == [_menusArray count]) {
        
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = @[@1.0];

    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, opacityAnimation, nil];

    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    
    [item.layer addAnimation:animationgroup forKey:nil];
    item.center = item.endPoint;
    
    _flag ++;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {

    CGFloat newAlpha = self.isExpanding ? 1.0f : 0.001f;
    for (AwesomeMenuItem *item in _menusArray) {

        item.alpha = newAlpha;
    }
    
    if ([_delegate respondsToSelector:@selector(awesomeMenu:isAnimating:)]) {
        
        [_delegate awesomeMenu:self isAnimating:_isAnimating];
    }
}

- (void)_close {
    
    if (_flag == -1) {
        
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
     AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.5f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.001f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, opacityAnimation, nil];

    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    
    [item.layer addAnimation:animationgroup forKey:nil];
    item.center = item.startPoint;
    _flag --;
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p {
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:1.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];

    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;

    animationgroup.delegate = self;

    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p {
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.001f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.fillMode = kCAFillModeForwards;
    
    animationgroup.delegate = self;

    return animationgroup;
}

@end
