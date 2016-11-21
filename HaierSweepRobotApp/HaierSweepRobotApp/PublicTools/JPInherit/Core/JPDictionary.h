//
//  JPDictionary.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPDictionary : NSDictionary

#pragma mark - 字典转JSON字符串
+ (NSString *)jp_getJSONStringWithDic:(NSDictionary *)dic;

@end
