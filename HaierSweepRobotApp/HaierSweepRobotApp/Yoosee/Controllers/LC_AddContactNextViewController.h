//
//  LC_AddContactNextViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/10/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"
@class  Contact;
@class MyFacilityModel;
@interface LC_AddContactNextViewController : BaseViewController

@property (retain, nonatomic) NSString *contactId;
@property (nonatomic,strong) MyFacilityModel *selectModel;
@property(strong, nonatomic) Contact *modifyContact;
@property (nonatomic) BOOL isModifyContact;//修改密码
@property (nonatomic) BOOL isInFromLocalDeviceList;
@property (nonatomic) BOOL isInFromManuallAdd;
@property (nonatomic) BOOL isInFromQRCodeNextController;
@property (nonatomic) BOOL isPopRoot;

@property (nonatomic,assign) int inType;//多出的

@property(strong, nonatomic) UIView *pwdStrengthView;//password strength

@property (nonatomic) BOOL isFromHomePage;

@end
