//
//  JPData.m
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPData.h"

@implementation JPData

+ (NSDictionary *)jp_getDicWithData:(NSData *)data;
{
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return dic;
}

@end
