//
//  MessageDetailOneCell.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "MessageDetailOneCell.h"

@implementation MessageDetailOneCell

- (void)setModel:(MessageListModel *)model
{
    _model = model;
    
    NSArray *typeArray = @[@"业务",@"系统",@"聊天"];
    self.typeLabel.text = typeArray[[model.messageText.bsType integerValue]-1];
    self.timeLabel.text = model.messageText.createDate;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
