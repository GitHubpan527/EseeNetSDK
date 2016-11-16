//
//  JPData.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPData : NSData

#pragma mark - data转字典
+ (NSDictionary *)jp_getDicWithData:(NSData *)data;

@end
