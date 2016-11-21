//
//  JPArray.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPArray : NSArray

#pragma mark - 遍历数组
+ (void)jp_eachWithArray:(NSArray *)array block:(void (^)(id object))block;

@end
