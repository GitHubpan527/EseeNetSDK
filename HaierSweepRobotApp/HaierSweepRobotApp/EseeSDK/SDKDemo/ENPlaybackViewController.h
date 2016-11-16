//
//  PlaybackSDKDemoViewController.h
//  EseeNet
//
//  Created by Wynton on 15/9/12.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENPlaybackViewController : UIViewController

/**
 *  设置设备信息
 *
 *  @param devIDOrIP 登陆的ID或IP
 *  @param userName  设备用户名
 *  @param passwords 设备密码
 *  @param channel   回放通道号
 *  @param port      IP登陆时的端口号
 *  @param playTime  回放的时间(格式如:2015-06-16)
 */
- (void)setPlayBackInfoWithDevIDOrIP:(NSString *)devIDOrIP
                            UserName:(NSString *)userName
                           Passwords:(NSString *)passwords
                             Channel:(int)channel
                                Port:(int)port
                            PlayTime:(NSString *)playTime;

@end
