//
//  ENPlaybackkViewController.h
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/20.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENPlaybackkViewController : UIViewController
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
