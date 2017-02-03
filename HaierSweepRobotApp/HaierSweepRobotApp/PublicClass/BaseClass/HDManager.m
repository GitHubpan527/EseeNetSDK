//
//  HDManager.m
//  AXMDemo
//
//  Created by qianfeng on 16/5/31.
//  Copyright © 2016年 pan. All rights reserved.
//

#import "HDManager.h"

@implementation HDManager
+ (MBProgressHUD *)shareHDView
{
    static MBProgressHUD *hdView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!hdView) {
            //获取程序的主窗口
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            hdView = [[MBProgressHUD alloc]initWithWindow:window];
            hdView.labelText = @"正在努力加载...";
        }
    });
    
//    //置当前的view为灰度
//    hdView.dimBackground = YES;
//    //设置对话框样式
//    hdView.mode = MBProgressHUDModeText;
//    [hdView showAnimated:YES whileExecutingBlock:^{
//        sleep(1);
//    } completionBlock:^{
//        [hdView removeFromSuperview];
//    }];
    
    
    return hdView;
}
+ (void)startLoading
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hd = [self shareHDView];
    [window addSubview:hd];
    [hd show:YES];
}
+ (void)stopLoading
{
    MBProgressHUD *hd = [self shareHDView];
    [hd hide:YES];
}

@end










