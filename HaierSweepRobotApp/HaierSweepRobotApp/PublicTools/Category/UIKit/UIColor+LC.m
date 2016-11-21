//
//  UIColor+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UIColor+LC.h"

@implementation UIColor (LC)

+ (UIColor *)lc_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(red)/255.0f green:(green)/255.0f blue:(blue)/255.0f alpha:alpha];
}

+ (UIColor *)lc_colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0];
}

@end
