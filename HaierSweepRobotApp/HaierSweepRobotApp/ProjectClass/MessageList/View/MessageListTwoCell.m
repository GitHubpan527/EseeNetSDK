//
//  MessageListTwoCell.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "MessageListTwoCell.h"

@implementation MessageListTwoCell

- (void)setModel:(MessageListModel *)model
{
    _model = model;
    
    self.contentLabel.text = model.messageText.content;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
