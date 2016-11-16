//
//  RegisterViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^RegisterBlock)(NSString *mobile,NSString *password);

@interface RegisterViewController : BaseViewController

@property (nonatomic,strong)RegisterBlock block;

@end
