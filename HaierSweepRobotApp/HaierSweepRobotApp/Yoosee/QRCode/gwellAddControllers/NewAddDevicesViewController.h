//
//  NewAddDevicesViewController.h
//  Yoosee
//
//  Created by apple on 16/10/11.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "BaseViewController.h"



@class TopBar;
@interface NewAddDevicesViewController : BaseViewController

@property(strong,nonatomic) UIButton *wifiAddButton;
@property(strong,nonatomic) UIButton *wiredNetworkAddButton;

@property(strong,nonatomic) UIImageView *wifiAddImageVeiw;
@property(strong,nonatomic) UIImageView *wiredNetworkAddImageVeiw;

@property(strong,nonatomic) TopBar *addDevicesTopbar;
@property(nonatomic) BOOL fromWiFiConnectFail; //智能联机失败提示

/* 技威方案摄像头类型 */
@property (nonatomic,assign) int type;

-(void)setUpNeedWiFiNetworkTips;

@end
