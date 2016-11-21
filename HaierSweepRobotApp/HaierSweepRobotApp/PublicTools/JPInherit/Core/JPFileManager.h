//
//  JPFileManager.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPFileManager : NSFileManager

#pragma mark - 获取缓存大小
+ (float)jp_getCacheSize;

#pragma mark - 清除缓存，在block回调中刷新页面
+ (void)jp_cleanCacheBlock:(void (^)())block;

@end
