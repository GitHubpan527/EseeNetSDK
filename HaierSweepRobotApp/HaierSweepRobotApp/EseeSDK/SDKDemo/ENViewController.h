//
//  ENViewController.h
//  HaierSweepRobotApp
//
//  Created by lichao pan on 2016/11/16.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENViewController : UIViewController

/**
 *  设置设备信息
 *
 *  @param IDOrIP    登陆的ID或IP
 *  @param userName  设备用户名
 *  @param passwords 设备密码
 *  @param port      IP登陆时的端口号
 */
- (void)setDeviceInfoWithDeviceIDOrIP:(NSString *)IDOrIP
                             UserName:(NSString *)userName
                            Passwords:(NSString *)passwords
                                 Port:(int)port;

@end
