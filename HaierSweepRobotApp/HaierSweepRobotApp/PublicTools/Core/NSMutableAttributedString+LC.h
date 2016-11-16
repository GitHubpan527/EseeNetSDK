//
//  NSMutableAttributedString+LC.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/8.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSMutableAttributedString (LC)

#pragma mark - 富文本
+ (NSMutableAttributedString *)lc_textStr:(NSString *)textStr textColor:(UIColor *)textColor fromIndex:(NSUInteger)fromIndex textLength:(NSUInteger)textLength;

#pragma mark - 中划线
+ (NSMutableAttributedString *)lc_strikethroughStyleWith:(NSString *)oldString;

#pragma mark - 下划线
+ (NSMutableAttributedString *)lc_underlineStyleWith:(NSString *)oldString;

@end
