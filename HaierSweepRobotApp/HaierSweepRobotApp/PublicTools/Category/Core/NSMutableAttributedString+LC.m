//
//  NSMutableAttributedString+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/8.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "NSMutableAttributedString+LC.h"

@implementation NSMutableAttributedString (LC)

#pragma mark - 富文本
+ (NSMutableAttributedString *)lc_textStr:(NSString *)textStr textColor:(UIColor *)textColor fromIndex:(NSUInteger)fromIndex textLength:(NSUInteger)textLength
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(fromIndex, textLength)];
    
    return attributedString;
}

#pragma mark - 中划线
+ (NSMutableAttributedString *)lc_strikethroughStyleWith:(NSString *)oldString
{
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:oldString attributes:attribtDic];
    return attribtStr;
}

#pragma mark - 下划线
+ (NSMutableAttributedString *)lc_underlineStyleWith:(NSString *)oldString
{
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:oldString attributes:attribtDic];
    return attribtStr;
}

@end
