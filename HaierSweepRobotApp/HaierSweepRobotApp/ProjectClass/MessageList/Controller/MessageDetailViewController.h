//
//  MessageDetailViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"

@interface MessageDetailViewController : BaseViewController

@property (nonatomic,copy)NSString *messageId;
@property (nonatomic,copy)NSString *messageTitle;
@property (nonatomic, copy)NSString *messageContent;
@property (nonatomic,copy)NSString *messageDate;

@end
