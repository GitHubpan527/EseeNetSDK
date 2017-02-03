//
//  HDManager.h
//  AXMDemo
//
//  Created by qianfeng on 16/5/31.
//  Copyright © 2016年 pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDManager : NSObject

+ (void)startLoading;//开始加载数据，让加载指示器显示到窗口上
+ (void)stopLoading;//数据加载完毕，让加载指示器隐藏

@end
