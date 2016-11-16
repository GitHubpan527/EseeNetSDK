//
//  NSTimer+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "NSTimer+LC.h"

@implementation NSTimer (LC)

+ (NSTimer *)lc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(lc_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)lc_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if(block) {
        block();
    }
}

@end
