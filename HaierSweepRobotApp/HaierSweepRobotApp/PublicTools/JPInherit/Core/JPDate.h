//
//  JPDate.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPDate : NSDate

#pragma mark - 日期转换成字符串 @"yyyy-MM-dd HH:mm:ss"
+ (NSString *)jp_stringWithDate:(NSDate *)date format:(NSString *)format;

@end
