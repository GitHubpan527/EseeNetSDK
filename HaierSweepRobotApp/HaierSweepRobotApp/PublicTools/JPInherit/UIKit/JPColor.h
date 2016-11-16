//
//  JPColor.h
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPColor : UIColor

+ (UIColor *)jp_colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)jp_colorWithHex:(NSInteger)hexValue;

@end
