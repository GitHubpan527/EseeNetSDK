//
//  MessageListOneCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageListModel.h"

@interface MessageListOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic,strong)MessageListModel *model;

@end
