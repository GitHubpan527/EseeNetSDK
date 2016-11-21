//
//  JPTimer.h
//  JPInherit
//
//  Created by Ljp on 16/8/24.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPTimer : NSTimer

//__weak Class *weakSelf = self;
//Class *strongSelf = weakSelf;

#pragma mark - 通过block来解决使用NSTimer时容易造成的循环引用问题
+ (NSTimer *)jp_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                         block:(void(^)())block
                                       repeats:(BOOL)repeats;

@end
