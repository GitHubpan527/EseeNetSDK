//
//  DevicesReadyViewController.h
//  Yoosee
//
//  Created by apple on 16/10/18.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "BaseViewController.h"
#import "AddDevicesPopTipsView.h"

@class TopBar;
@interface DevicesReadyViewController : BaseViewController<AddDevicesPopTipsViewDelegate>

@property(strong,nonatomic) TopBar *devicesReadyTopbar;
@property(strong,nonatomic) UILabel *readyTipsLb;
@property(strong,nonatomic) UILabel *soundTipsLb;
@property(strong,nonatomic) UIImageView *animatedImgView;
@property(strong,nonatomic) UIButton *notListenedBtn;
@property(strong,nonatomic) UIButton *alreadyListenedBtn;

@property(strong,nonatomic) AddDevicesPopTipsView *readyAddDevicesPopTipsView;

@end
