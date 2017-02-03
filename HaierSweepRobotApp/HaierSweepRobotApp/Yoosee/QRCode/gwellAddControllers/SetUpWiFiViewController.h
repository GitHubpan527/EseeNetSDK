//
//  SetUpWiFiViewController.h
//  Yoosee
//
//  Created by apple on 16/10/17.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "BaseViewController.h"
#import "AddDevicesPopTipsView.h"

@class TopBar;
@class CustomTextField;

@interface SetUpWiFiViewController : BaseViewController<UITextFieldDelegate,UIAlertViewDelegate,AddDevicesPopTipsViewDelegate>

@property(nonatomic,strong) TopBar *setUpWiFiTopbar;
@property(nonatomic,strong) UILabel *needWiFiTipsLb;
@property(nonatomic,strong) UILabel *aWiFiNameLb;
@property(nonatomic,strong) UILabel *no5GWiFiTipsLb;
@property(nonatomic,strong) CustomTextField *passwordTF;
@property(nonatomic,strong) UIButton *tipsBtn;
@property(nonatomic,strong) UIButton *nextStepBtn;
@property(nonatomic,assign) BOOL eitherPasswordSee;
@property(nonatomic,strong) AddDevicesPopTipsView *setWiFiAddDevicesPopTipsView;

@end
