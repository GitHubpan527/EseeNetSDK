//
//  FacilityContactCell.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "FacilityContactCell.h"

@implementation FacilityContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setContactModel:(Contact *)contactModel
{
    _contactModel = contactModel;
    //[self.iconImageView sd_setImageWithURL:[NSURL URLWithString:contactModel.modelImg] placeholderImage:LCImage(@"海尔")];
    //self.titleL.text = contactModel.contactName;
}

- (void)setModel:(MyFacilityModel *)model
{
    _model = model;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.modelImg] placeholderImage:LCImage(@"海尔")];
    self.titleL.text = model.name;
}

- (void)setupView
{
    //头像
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
    self.iconImageView.image = LCImage(@"海尔");
    [self addSubview:self.iconImageView];
    //名称
    self.titleL = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, ScreenWidth-75, 70)];
    self.titleL.textColor = [UIColor blackColor];
    self.titleL.font = LCFont(15);
    [self addSubview:self.titleL];
    //分割线
    UILabel *sepLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 69.5, ScreenWidth-15, 0.5)];
    sepLabel.backgroundColor = [UIColor lc_colorWithR:220 G:220 B:223 alpha:1.0];
    [self addSubview:sepLabel];
    //设置
    /*
    self.setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.setButton.frame = CGRectMake(ScreenWidth-70, 0, 70, 69);
    [self.setButton setBackgroundImage:LCImage(@"编辑") forState:UIControlStateNormal];
    [self.setButton lc_block:^(id sender) {
        [UIView animateWithDuration:0.3 animations:^{
            self.detailView.frame = CGRectMake(ScreenWidth-210, 0, 210, 70);
        }];
    }];
    [self addSubview:self.setButton];
     */
    //详情
    self.detailView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, 210, 70)];
    self.detailView.backgroundColor = [UIColor lc_colorWithR:235 G:235 B:241 alpha:1.0];
    //[self addSubview:self.detailView];
    
    for (int i = 0; i < 3; i++) {
        NSArray *arr = @[@"重命名",@"删除",@"取消"];
        NSArray *colorArr = @[[UIColor lc_colorWithR:240 G:124 B:12 alpha:1.0],[UIColor lc_colorWithR:59 G:140 B:254 alpha:1.0],[UIColor lc_colorWithR:45 G:151 B:175 alpha:1.0]];
        UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        detailBtn.frame = CGRectMake(70*i, 0, 70, 70);
        [detailBtn setTitle:arr[i] forState:UIControlStateNormal];
        [detailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [detailBtn setBackgroundColor:colorArr[i]];
        detailBtn.titleLabel.font = LCFont(15);
        detailBtn.tag = 100+i;
        [detailBtn lc_block:^(UIButton *sender) {
            switch (sender.tag) {
                case 100:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.detailView.frame = CGRectMake(ScreenWidth, 0, 210, 70);
                    }];
                    if ([_delegate respondsToSelector:@selector(ContactRenameVC:)]) {
                        [_delegate ContactRenameVC:_contactModel];
                    }
                }
                    break;
                    
                case 101:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.detailView.frame = CGRectMake(ScreenWidth, 0, 210, 70);
                    }];
                    if ([_delegate respondsToSelector:@selector(ContactDeleteAction:)]) {
                        [_delegate ContactDeleteAction:_contactModel];
                    }
                }
                    break;
                    
                case 102:
                {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.detailView.frame = CGRectMake(ScreenWidth, 0, 210, 70);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }];
        [self.detailView addSubview:detailBtn];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(70*i, 0, 1, 70)];
        lineLabel.backgroundColor = [UIColor lc_colorWithR:220 G:220 B:223 alpha:1.0];
        [self.detailView addSubview:lineLabel];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
