//
//  NSTimer+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (LC)

//__weak Class *weakSelf = self;
//Class *strongSelf = weakSelf;

#pragma mark - 通过block来解决使用NSTimer时容易造成的循环引用问题
+ (NSTimer *)lc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;
@end
