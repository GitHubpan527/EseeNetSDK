//
//  LocalDeviceCell.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "LocalDeviceCell.h"
#import "Constants.h"
@implementation LocalDeviceCell

//-(void)dealloc{
//    [self.leftImage release];
//    [self.leftImageView release];
//    [self.rightImage release];
//    [self.rightImageView release];
//    [self.idContentText release];
//    [self.idContentLabel release];
//    [self.ipContentText release];
//    [self.ipContentLabel release];
//    [super dealloc];
//}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define LEFT_IMAGE_VIEW_WIDTH_HEIGHT 24
#define RIGHT_IMAGE_VIEW_WIDTH_HEIGHT 18
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    //左边图标
    if(!self.leftImageView){
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45/2.0, (cellHeight-LEFT_IMAGE_VIEW_WIDTH_HEIGHT)/2, LEFT_IMAGE_VIEW_WIDTH_HEIGHT, LEFT_IMAGE_VIEW_WIDTH_HEIGHT)];
        leftImageView.image = [UIImage imageNamed:self.leftImage];
        [self.contentView addSubview:leftImageView];
        self.leftImageView = leftImageView;
//        [leftImageView release];
    }else{
        self.leftImageView.frame = CGRectMake(45/2.0, (cellHeight-LEFT_IMAGE_VIEW_WIDTH_HEIGHT)/2, LEFT_IMAGE_VIEW_WIDTH_HEIGHT, LEFT_IMAGE_VIEW_WIDTH_HEIGHT);
        self.leftImageView.image = [UIImage imageNamed:self.leftImage];
        [self.contentView addSubview:self.leftImageView];
    }
    
   
    //id号显示
    if(!self.idContentLabel){
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+CGRectGetMaxX(self.leftImageView.frame), 0, (cellWidth-5*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, cellHeight)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = XBlack;
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.text = self.idContentText;
        self.idContentLabel = contentLabel;
        [self.contentView addSubview:self.idContentLabel];
//        [contentLabel release];
    }else{
        self.idContentLabel.frame = CGRectMake(5+CGRectGetMaxX(self.leftImageView.frame), 0, (cellWidth-5*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, cellHeight);
        self.idContentLabel.text = self.idContentText;
        [self.contentView addSubview:self.idContentLabel];
    }
    
    
    //ip地址显示
    if(!self.ipContentLabel){
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2.0, 0, cellWidth-10*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, cellHeight)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = UIColorFromRGB(0xaaaaaa);
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.text = self.ipContentText;
        self.ipContentLabel = contentLabel;
        [self.contentView addSubview:self.ipContentLabel];
//        [contentLabel release];
    }else{
        self.ipContentLabel.frame = CGRectMake(cellWidth/2.0, 0, cellWidth-10*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, cellHeight);
        self.ipContentLabel.text = self.ipContentText;
        [self.contentView addSubview:self.ipContentLabel];
    }
    

    //右边图标
    if(!self.rightImageView){
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-33-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, (cellHeight-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)];
        rightImageView.image = [UIImage imageNamed:self.rightImage];
        [self.contentView addSubview:rightImageView];
        self.rightImageView = rightImageView;
//        [rightImageView release];
    }else{
        self.rightImageView.frame = CGRectMake(cellWidth-33-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, (cellHeight-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT);
        self.rightImageView.image = [UIImage imageNamed:self.rightImage];
        [self.contentView addSubview:self.rightImageView];
    }
    
}
@end
