//
//  BlockProgressAlertView.h
//  CLEngine
//
//  Created by Callum Abele on 21/07/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "BlockAlertView.h"

@interface BlockProgressAlertView : BlockAlertView

- (void)setProgress:(float)progress;
- (float)progress;
- (void)removeProgressFromView;
- (void)addSpinningWheel;

@end
