//
//  UIView+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/16.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIView (LC)

- (void)lc_whenTapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block;

@end
