//
//  BaseViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

#pragma mark - 返回事件
- (void)backClick;

#pragma mark - MBProgressHUD
- (void)mb_normal;

- (void)mb_stop;

- (void)mb_show:(NSString *)show;

@end
