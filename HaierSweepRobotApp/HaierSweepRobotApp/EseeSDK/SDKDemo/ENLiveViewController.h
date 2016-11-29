//
//  IndependentViewController.h
//  EseeNet
//
//  Created by Wynton on 15/8/4.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ENLiveViewController : UIViewController


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
                                 Port:(int)port
                                 Channel:(int)channel;


@end
