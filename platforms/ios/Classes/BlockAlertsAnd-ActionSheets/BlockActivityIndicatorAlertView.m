//
//  BlockActivityIndicatorAlertView.m
//  CLEngine
//
//  Created by Callum Abele on 11/04/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "BlockActivityIndicatorAlertView.h"

@interface BlockActivityIndicatorAlertView()

@property(nonatomic,strong)UIActivityIndicatorView* activityIndicatorView;

@end

@implementation BlockActivityIndicatorAlertView

- (void)addComponents:(CGRect)frame {
    
    [super addComponents:frame];
    
    if(self.activityIndicatorView == NULL) {

        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView startAnimating];
    }
    
    [self.view addSubview:self.activityIndicatorView];
    
    
}

- (void)show {
    
    CGPoint center;
    
    center.x = self.view.frame.size.width * 0.5f;
    center.y = _height;

    self.activityIndicatorView.center = center;
    
    _height += self.activityIndicatorView.frame.size.height ;
    
    [super show];
    
}

@end
