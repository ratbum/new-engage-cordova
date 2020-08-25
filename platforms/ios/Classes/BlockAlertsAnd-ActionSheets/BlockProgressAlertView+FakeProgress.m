//
//  BlockProgressAlertView+FakeProgress.m
//  CLEngine
//
//  Created by Callum Abele on 04/08/2014.
//  Copyright (c) 2014 CrowdLab. All rights reserved.
//

#import "BlockProgressAlertView+FakeProgress.h"
#import "objc/runtime.h"

NSString *const fakeProgressKey = @"FakeProgressKey";
NSString *const fakeTimerKey = @"FakeTimerKey";


#import "NSObject+PerformBlock.h"
@implementation BlockProgressAlertView (FakeProgress)

@dynamic fakeProgress;
@dynamic fakeProgressTimer;


- (void)setFakeProgressTimer:(NSTimer *)fakeProgressTimer {
    
    objc_setAssociatedObject(self, @selector(fakeProgressTimer), fakeProgressTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
- (NSTimer*)fakeProgressTimer {
    
    return objc_getAssociatedObject(self,@selector(fakeProgressTimer));
}

#define TimeInterval 0.5f
- (void)setFakeProgress:(NSNumber*)fakeProgress {
    
    
    objc_setAssociatedObject(self,@selector(fakeProgress), fakeProgress, OBJC_ASSOCIATION_COPY);
    
    if([self.fakeProgress boolValue]) {
        
        if(self.fakeProgressTimer == NULL) {
            
            self.fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:TimeInterval target:self selector:@selector(incrementProgress) userInfo:NULL repeats:YES];
        }
        
        
    }
    else {
        
        if(self.fakeProgressTimer) {
            
            [self.fakeProgressTimer invalidate];
            self.fakeProgressTimer = NULL;
        }
        
    }    
}

- (NSNumber*)fakeProgress {
    
    return objc_getAssociatedObject(self,@selector(fakeProgress));
}


#define IncrementAmount 0.02f
- (void)incrementProgress {
    
    if([self progress] < 0.9f) {
        
        [self setProgress:[self progress] + IncrementAmount];
    }
    
}

@end
