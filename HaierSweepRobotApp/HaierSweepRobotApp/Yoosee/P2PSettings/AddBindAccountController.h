//
//  AddBindAccountController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
//test svn
#import <UIKit/UIKit.h>
@class Contact;
@class  AlarmSettingController;
@interface AddBindAccountController : BaseViewController

@property(strong, nonatomic) NSMutableArray *lastSetBindIds;
@property (strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@end
