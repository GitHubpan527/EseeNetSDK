//
//  UIButton+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)(UIButton *sender);

@interface UIButton (LC)

- (void)lc_block:(ActionBlock)block;

@end
