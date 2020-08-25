//
//  BlockProgressAlertView+FakeProgress.h
//  CLEngine
//
//  Created by Callum Abele on 04/08/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "BlockProgressAlertView.h"

@interface BlockProgressAlertView (FakeProgress)

@property(nonatomic,copy) NSNumber *fakeProgress;
@property(nonatomic,strong) NSTimer *fakeProgressTimer;

@end
