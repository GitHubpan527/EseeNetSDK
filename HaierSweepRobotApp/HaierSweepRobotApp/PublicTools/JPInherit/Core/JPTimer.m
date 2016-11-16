//
//  JPTimer.m
//  JPInherit
//
//  Created by Ljp on 16/8/24.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPTimer.h"

@implementation JPTimer

+ (NSTimer *)jp_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(jp_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)jp_blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if(block) {
        block();
    }
}

@end