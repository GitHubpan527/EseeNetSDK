//
//  AccountController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_TAG_UNBIND_PHONE 2
#define ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD 3
@interface AccountController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end
