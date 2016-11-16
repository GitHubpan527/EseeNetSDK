//
//  NSString+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (LC)

#pragma mark - md5加密
+ (NSString *)lc_md5String:(NSString *)string;

#pragma mark - 日期转换成字符串
+ (NSString *)lc_stringWithDate:(NSDate *)date;

#pragma mark - 验证是否是0-9数字
+ (BOOL)lc_isValidateEditNum:(NSString *)string;

#pragma mark - 验证邮箱
+ (BOOL)lc_isValidateEmail:(NSString *)string;

#pragma mark - 验证手机号
+ (BOOL)lc_isValidateMobile:(NSString *)string;

#pragma mark - 验证身份证号
+ (BOOL)lc_isValidateIdentityCard:(NSString *)string;

#pragma mark - 计算Label高度
+ (CGFloat)lc_calculateLabelHeight:(NSString *)labelStr labelSize:(CGSize)labelSize labelFont:(CGFloat)labelFont;

@end
