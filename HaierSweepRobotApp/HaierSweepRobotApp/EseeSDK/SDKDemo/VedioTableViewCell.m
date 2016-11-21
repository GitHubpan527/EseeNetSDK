//
//  VedioTableViewCell.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/18.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "VedioTableViewCell.h"

@implementation VedioTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 150)];
        self.myImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.myImageView];
        
//        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.myImageView.bounds.size.width - 200, 5, 200, 30)];
        
        self.pauseView = [[UIView alloc] initWithFrame:CGRectMake((self.myImageView.bounds.size.width - 64) / 2, (self.myImageView.bounds.size.height - 64) / 2, 64, 64)];
//        self.pauseView.backgroundColor = [UIColor blackColor];
        self.pauseView.userInteractionEnabled = YES;
        [self.myImageView addSubview:self.pauseView];
        
        self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.pauseBtn.frame = CGRectMake(0, 0, self.pauseView.bounds.size.width, self.pauseView.bounds.size.height);
        [self.pauseBtn setImage:[UIImage imageNamed:@"pausew.png"] forState:UIControlStateNormal];
        [self.pauseView addSubview:self.pauseBtn];
        
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
