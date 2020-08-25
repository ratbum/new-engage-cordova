//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockUI.h"
#import "UIImage+Scale.h"

@implementation BlockAlertView

@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIImage *backgroundlandscape = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;


#pragma mark - init

+ (void)initialize
{
    if (self == [BlockAlertView class])
    {
        background = [UIImage imageNamed:kAlertViewBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight];
        
        backgroundlandscape = [UIImage imageNamed:kAlertViewBackgroundLandscape];
        backgroundlandscape = [backgroundlandscape stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight];
    }
}

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[self class] alloc] initWithTitle:title message:message];
}

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:title message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"Dismiss", nil) block:nil];
    [alert show];
}

+ (void)showErrorAlert:(NSError *)error
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:NSLocalizedString(@"Operation Failed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The operation did not complete successfully: %@", nil), error]];
    [alert setCancelButtonWithTitle:@"Dismiss" block:nil];
    [alert show];
}

//
#pragma mark - NSObject

- (NSNumber *)dismissViewWhenTappingCancelButton {
    
    if (!_dismissViewWhenTappingCancelButton) {
        
        _dismissViewWhenTappingCancelButton = @YES;
    }
    return _dismissViewWhenTappingCancelButton;
}

- (void)addComponents:(CGRect)frame {
    if (_title)
    {
        CGSize size = [_title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                             lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width-kAlertViewBorder*2, size.height)];
        labelView.font = titleFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = [UIColor blackColor];
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.text = _title;
        [_view addSubview:labelView];
        labelView.isAccessibilityElement = true;
        self.titleLabel = labelView;
        
        _height += size.height + kAlertViewBorder;
    }
    
    if (_message)
    {
        CGSize size = [_message sizeWithFont:messageFont
                           constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width-kAlertViewBorder*2, size.height)];
        labelView.font = messageFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = UIColor.blackColor;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.text = _message;
        [_view addSubview:labelView];
        
        _height += size.height + kAlertViewBorder;
    }
}

- (void)setupDisplay
{
    [[_view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    CGRect frame = self.blockBackground.bounds;
    frame.origin.x = floorf((frame.size.width - background.size.width) * 0.5);
    frame.size.width = background.size.width;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        frame.size.width += 150;
        frame.origin.x -= 75;
    }
    
    _view.frame = frame;
    
    _height = kAlertViewBorder + 15;
    
    if (NeedsLandscapePhoneTweaks) {
        _height -= 15; // landscape phones need to trimmed a bit
    }
    
    [self addComponents:frame];

    if (_shown)
        [self show];
}

- (BOOL)isShowing {
    
    return  _shown;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message 
{
    self = [super init];
    
    if (self)
    {
        _title = [title copy];
        _message = [message copy];
        
        _view = [[UIView alloc] init];
        
        _view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _blocks = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(setupDisplay) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                   object:nil];   
        
        if ([[self class] isSubclassOfClass:[BlockAlertView class]]) {
         
            [self setupDisplay];
        }
        
        _vignetteBackground = NO;
    }
    
    return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block 
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        block ? [block copy] : [NSNull null],
                        title,
                        color,
                        nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"black" block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block];
}

- (void)addButtonWithTitle:(NSString *)title imageIdentifier:(NSString*)identifier block:(void (^)())block {
    [self addButtonWithTitle:title color:identifier block:block];
}

- (void)show {

    _shown = YES;
    
    BOOL isSecondButton = NO;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < _blocks.count; i++)
    {
        NSArray *block = [_blocks objectAtIndex:i];
        NSString *title = [block objectAtIndex:1];

        CGFloat maxHalfWidth = floorf((_view.bounds.size.width-kAlertViewBorder*3)*0.5);
        CGFloat width = _view.bounds.size.width-kAlertViewBorder*2;
        CGFloat xOffset = kAlertViewBorder;
        
        UIImage *currentUpImage = [UIImage imageNamed:@"alert_btn_up.png"];
        UIImage *currentDownImage = [UIImage imageNamed:@"alert_btn_down.png"];
        
      UIImage *upImage = [UIImage imageNamed: @"background-image"]; // [styleBook imageForKey:@"background-image"
//                                     defaultImage:currentUpImage
//                                         inStyles:styles];
//
//        UIImage *downImage = [styleBook imageForKey:@"background-image:active"
//                                       defaultImage:currentDownImage
//                                           inStyles:styles];
        
        CGFloat dividingPoint = floor((upImage.size.width+1.0) / 2.0);
    
        if (isSecondButton) {
            width = maxHalfWidth;
            xOffset = width + kAlertViewBorder * 2;
            isSecondButton = NO;
        } else if (i + 1 < _blocks.count) {
            
            // In this case there's another button.
            // Let's check if they fit on the same line.
            CGSize size = [title sizeWithFont:buttonFont 
                                  minFontSize:10 
                               actualFontSize:nil
                                     forWidth:_view.bounds.size.width-kAlertViewBorder*2 
                                lineBreakMode:NSLineBreakByClipping];
            
            if (size.width < maxHalfWidth - kAlertViewBorder) {
                
                // It might fit. Check the next Button
                NSArray *block2 = [_blocks objectAtIndex:i+1];
                NSString *title2 = [block2 objectAtIndex:1];
                size = [title2 sizeWithFont:buttonFont 
                                minFontSize:10 
                             actualFontSize:nil
                                   forWidth:_view.bounds.size.width-kAlertViewBorder*2 
                              lineBreakMode:NSLineBreakByClipping];
                
                if (size.width < maxHalfWidth - kAlertViewBorder) {
                    
                    // They'll fit!
                    isSecondButton = YES;  // For the next iteration
                    width = maxHalfWidth;
                }
            }
        }
        else if (_blocks.count  == 1) {
            
            // In this case this is the ony button. We'll size according to the text
            CGSize size = [title sizeWithFont:buttonFont
                                  minFontSize:10
                               actualFontSize:nil
                                     forWidth:_view.bounds.size.width-kAlertViewBorder*2
                                lineBreakMode:NSLineBreakByClipping];
            
            size.width = MAX(size.width, 80);
            if (size.width + 2 * kAlertViewBorder < width)
            {
                width = size.width + 2 * kAlertViewBorder;
                xOffset = floorf((_view.bounds.size.width - width) * 0.5);
            }
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, _height, width, kAlertButtonHeight);
        button.titleLabel.font = buttonFont;
        if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic`   pop
        }
        else {
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.adjustsLetterSpacingToFitWidth = YES;
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i+1;
        
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setBackgroundImage:nil forState:UIControlStateHighlighted];


        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_view addSubview:button];
        
        if (!isSecondButton)
            _height += kAlertButtonHeight + kAlertViewBorder;
        
        index++;
    }

    if (_height < background.size.height)
    {
        CGFloat offset = background.size.height - _height;
        _height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < _blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[_view viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }
    
    
    CGRect frame = _view.frame;
    frame.origin.y = - _height;
    frame.size.height = _height;
    _view.frame = frame;
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        modalBackground.image = backgroundlandscape;
    else
        modalBackground.image = background;

    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view insertSubview:modalBackground atIndex:0];
    
    if (_backgroundImage)
    {
        self.blockBackground.backgroundImage = _backgroundImage;
        _backgroundImage = nil;
    }
    
    self.blockBackground.vignetteBackground = _vignetteBackground;
    [self.blockBackground addToMainWindow:_view];

    __block CGPoint center = _view.center;
    center.y = floorf(self.blockBackground.bounds.size.height * 0.5) + kAlertViewBounce;
    
    _cancelBounce = NO;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.blockBackground.alpha = 1.0f;
                         _view.center = center;
                     } 
                     completion:^(BOOL finished) {
                         if (_cancelBounce) return;
                         
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              center.y -= kAlertViewBounce;
                                              _view.center = center;
                                          } 
                                          completion:^(BOOL finished) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
                                          }];
                     }];
    
}

- (void)dissmissView:(BOOL)animated {
    
    if (animated) {
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             CGPoint center = _view.center;
                             center.y += 20;
                             _view.center = center;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.4
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  
                                                  CGRect frame = _view.frame;
                                                  frame.origin.y = -frame.size.height;
                                                  _view.frame = frame;
                                                  [self.blockBackground reduceAlphaIfEmpty];
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  [self.blockBackground removeView:_view];
                                                  _view = nil;
                                              }];
                         }];
    }
    else {
        
        [self.blockBackground removeView:_view];
        _view = nil;
    }
}

- (void)runBlockWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex >= 0 && buttonIndex < [_blocks count]) {
        
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]]) {
            
          ((void (^)(void))obj)();
        }
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    
    _shown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self runBlockWithButtonIndex:buttonIndex];
    
    [self dissmissView:animated];
}

- (void)dismissWithAnimation:(BOOL)animated {
    
    _shown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self dissmissView:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = (int)([(UIButton *)sender tag] - 1);
    
    if ([self.dismissViewWhenTappingCancelButton isEqualToNumber:@YES]) {
        
        [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [(UIButton*)sender removeFromSuperview];
        
        [self runBlockWithButtonIndex:buttonIndex];
    }
}

- (void)styleView {
  // Do nothing
}

@end
