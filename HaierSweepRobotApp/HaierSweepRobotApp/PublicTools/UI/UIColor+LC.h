//
//  UIColor+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (LC)

+ (UIColor *)lc_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)lc_colorWithHex:(NSInteger)hexValue;

@end
