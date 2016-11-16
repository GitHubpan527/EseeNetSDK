//
//  JPString.h
//  JPInherit
//
//  Created by Ljp on 16/8/24.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPString : NSString

#pragma mark - md5加密
+ (NSString *)jp_md5String:(NSString *)string;

#pragma mark - 验证是否是0-9数字
+ (BOOL)jp_validateEditNum:(NSString *)string;

#pragma mark - 验证邮箱
+ (BOOL)jp_validateEmail:(NSString *)string;

#pragma mark - 验证手机号
+ (BOOL)jp_validateMobile:(NSString *)string;

#pragma mark - 验证身份证号
+ (BOOL)jp_validateIdentityCard:(NSString *)string;

#pragma mark - 计算字符串高度
+ (CGFloat)jp_calculateHeightWithStr:(NSString *)str size:(CGSize)size fontSize:(CGFloat)fontSize;

@end
