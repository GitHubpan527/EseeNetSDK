//
//  LocalDeviceListController.h
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AddDevicesPopTipsView.h"
@class YProgressView;

@interface LocalDeviceListController : UIViewController<UITableViewDataSource,UITableViewDelegate,AddDevicesPopTipsViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *isNewDevicesArray;
@property (strong, nonatomic) YProgressView *yProgressViewRefresh; //刷新控件 没有设备时候刷新


@property (strong, nonatomic) AddDevicesPopTipsView *addDevicesPopView; 

@end
