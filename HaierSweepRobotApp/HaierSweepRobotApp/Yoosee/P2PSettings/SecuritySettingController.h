//
//  SecuritySettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@interface SecuritySettingController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;



@property(assign) BOOL isFirstLoadingCompolete;
@property (strong,nonatomic) UISwitch *autoUpdateSwitch;
@property (nonatomic) BOOL isLoadingAutoUpdate;
@property(assign) NSInteger autoUpdateState;
@property (assign) NSInteger lastAutoUpdateState;

@property (nonatomic) BOOL isLoadingVisitorPassword;
@property (nonatomic) BOOL isNotSupportVisitorPassword;
@property (strong,nonatomic) NSString *visitorPassword;

@property (nonatomic) BOOL isSupportAutoUpdate;
@end
