//
//  JPArray.m
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPArray.h"

@implementation JPArray

+ (void)jp_eachWithArray:(NSArray *)array block:(void (^)(id object))block
{
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

@end
