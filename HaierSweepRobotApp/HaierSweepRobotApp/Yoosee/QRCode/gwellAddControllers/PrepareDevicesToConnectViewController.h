//
//  PrepareDevicesToConnectViewController.h
//  Yoosee
//
//  Created by apple on 16/10/14.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "BaseViewController.h"

typedef enum { //连接方式
    ViaWired  = 0,
    ViaWiFi
}ConnectType;

@class TopBar;
@interface PrepareDevicesToConnectViewController : BaseViewController

@property(strong,nonatomic) UIImageView *wiredPrepareImageView;
@property(strong,nonatomic) UIImageView *wifiPrepareImageView;
@property(strong,nonatomic) UILabel *wiredPrepareLabel;
@property(strong,nonatomic) UILabel *wifiPrepareLabel;
@property(strong,nonatomic) UIButton *wiredPrepareBtn;
@property(strong,nonatomic) UIButton *wifiPrepareBtn;
@property(assign,nonatomic) int connectType;//连接方式的区别
@property(strong,strong) TopBar *prepareTopBar;
@property(nonatomic,assign)BOOL shouldPopToRoot;

@end





