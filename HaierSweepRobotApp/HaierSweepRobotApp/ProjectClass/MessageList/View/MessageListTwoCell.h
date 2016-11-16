//
//  MessageListTwoCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageListModel.h"

@interface MessageListTwoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic,strong)MessageListModel *model;

@end
