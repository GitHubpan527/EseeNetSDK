//
//  LocalDeviceListController.h
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDeviceListController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray* newDevicesArray;
@property (strong, nonatomic) NSArray* isNewDevicesArray;

@end