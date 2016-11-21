//
//  JPString.m
//  JPInherit
//
//  Created by Ljp on 16/8/24.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPString.h"
#import <CommonCrypto/CommonDigest.h>

@implementation JPString

#pragma mark - md5加密
+ (NSString *)jp_md5String:(NSString *)string
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

#pragma mark - 验证是否是0-9数字
+ (BOOL)jp_validateEditNum:(NSString *)string
{
    NSString *numRegex = @"^[1-9]\\d*|0$";
    NSPredicate *numTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numRegex];
    return [numTest evaluateWithObject:string];
}

#pragma mark - 验证邮箱
+ (BOOL)jp_validateEmail:(NSString *)string
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

#pragma mark - 验证手机号
+ (BOOL)jp_validateMobile:(NSString *)string
{
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:string];
}

#pragma mark - 验证身份证号
+ (BOOL)jp_validateIdentityCard:(NSString *)string
{
    NSString * sfzRegex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",sfzRegex];
    return [phoneTest evaluateWithObject:string];
}

#pragma mark - 计算字符串高度
+ (CGFloat)jp_calculateHeightWithStr:(NSString *)str size:(CGSize)size fontSize:(CGFloat)fontSize
{
    CGRect bounds = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName] context:nil];
    
    return bounds.size.height;
}

@end
