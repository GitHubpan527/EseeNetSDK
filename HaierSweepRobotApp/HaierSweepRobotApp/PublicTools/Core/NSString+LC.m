//
//  NSString+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "NSString+LC.h"

//md5
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LC)

#pragma mark - md5加密
+ (NSString *)lc_md5String:(NSString *)string
{
    const char *cStr = [string UTF8String];
    int length = (int)strlen(cStr);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, length, result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

#pragma mark - 日期转换成字符串
+ (NSString *)lc_stringWithDate:(NSDate *)date;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - 验证是否是0-9数字
+ (BOOL)lc_isValidateEditNum:(NSString *)string
{
    NSString *numRegex = @"^[1-9]\\d*|0$";
    NSPredicate *numTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numRegex];
    return [numTest evaluateWithObject:string];
}

#pragma mark - 验证邮箱
+ (BOOL)lc_isValidateEmail:(NSString *)string
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

#pragma mark - 验证手机号
+ (BOOL)lc_isValidateMobile:(NSString *)string
{
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:string];
}

#pragma mark - 验证身份证号
+ (BOOL)lc_isValidateIdentityCard:(NSString *)string
{
    NSString * sfzRegex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",sfzRegex];
    return [phoneTest evaluateWithObject:string];
}

#pragma mark - 计算Label高度
+ (CGFloat)lc_calculateLabelHeight:(NSString *)labelStr labelSize:(CGSize)labelSize labelFont:(CGFloat)labelFont
{
    CGRect bounds = [labelStr boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:labelFont] forKey:NSFontAttributeName] context:nil];
    
    return bounds.size.height;
}

@end
