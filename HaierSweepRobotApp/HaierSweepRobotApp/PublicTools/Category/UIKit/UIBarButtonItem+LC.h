//
//  UIBarButtonItem+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/7.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^BarButtonBlock)();

@interface UIBarButtonItem (LC)

+ (UIBarButtonItem *)lc_itemWithIcon:(NSString *)icon block:(BarButtonBlock)block;

+ (UIBarButtonItem *)lc_itemWithTitle:(NSString *)title block:(BarButtonBlock)block;

@end
