//
//  BlockProgressAlertView.m
//  CLEngine
//
//  Created by Callum Abele on 21/07/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "BlockProgressAlertView.h"
#import "UIView+Position.h"

@interface BlockProgressAlertView()

@property(nonatomic,strong)UIProgressView* progressView;
@property(nonatomic,strong)UIActivityIndicatorView* activityIndicator;

@end

@implementation BlockProgressAlertView

- (void)addComponents:(CGRect)frame {
    
    [super addComponents:frame];
    
    if(self.progressView == NULL) {
    
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    
    [self.view addSubview:self.progressView];
}

#define BottomPadding 15.0f;
- (void)show {
    
    CGPoint center;
    
    center.x = self.view.frame.size.width * 0.5f;
    center.y = _height;
    
    self.progressView.center = center;
    
    _height = [self.progressView bottom] + BottomPadding;
    
    [super show];
}

- (void)setProgress:(float)progress {
    
    self.progressView.progress = progress;
}

- (float)progress {
    
    return self.progressView.progress;
}

- (void)removeProgressFromView {
    
    [self.progressView removeFromSuperview];
}

- (void)addSpinningWheel {
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGPoint center;
    
    center.x = self.view.frame.size.width * 0.5f;
    center.y = self.view.frame.size.height * 0.5f + BottomPadding;
    
    self.activityIndicator.center = center;
    
    [self.activityIndicator startAnimating];

    [self.view addSubview:self.activityIndicator];
}


@end
