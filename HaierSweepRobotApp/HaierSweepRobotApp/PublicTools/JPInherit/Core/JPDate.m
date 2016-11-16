//
//  JPDate.m
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPDate.h"

@implementation JPDate

+ (NSString *)jp_stringWithDate:(NSDate *)date format:(NSString *)format;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

@end
