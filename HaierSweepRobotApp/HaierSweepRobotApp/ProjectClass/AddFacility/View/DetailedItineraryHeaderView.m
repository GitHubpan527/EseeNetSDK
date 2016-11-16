//
//  DetailedItineraryHeaderView.m
//  rujingyouapp1.0
//
//  Created by zhengju on 16/4/29.
//  Copyright © 2016年 shengmei. All rights reserved.
//

#import "DetailedItineraryHeaderView.h"
#import "DeviceTypeModel.h"
@interface DetailedItineraryHeaderView()


@property (nonatomic, strong) UIImageView *arrowImageView;
@end
@implementation DetailedItineraryHeaderView

//重写initWithReuseIdentifier:方法创建自定义headerView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        //加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMethod:)];
        [self addGestureRecognizer:tap];
        
        self.BGview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        [self.contentView addSubview:self.BGview];
    
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 10, 40, 40)];
        [self.contentView addSubview:self.iconView];

        self.arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"brand_expand"]];
        self.arrowImageView.frame = CGRectMake(ScreenWidth-40, 15 + 8, 15, 8);
        [self.contentView addSubview:self.arrowImageView];
        
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(ScreenWidth - 40, 5, 30, 30);
        [self.contentView addSubview:self.moreBtn];
        self.moreBtn.backgroundColor = [UIColor clearColor];
        [self.moreBtn addTarget:self action:@selector(goMore) forControlEvents:UIControlEventTouchUpInside];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, ScreenWidth - 120, 60)];
        
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];

        [self.contentView addSubview:self.titleLabel];
        
        self.contentView.backgroundColor = [UIColor whiteColor];

    }
    return self;
}

//手势点击加载cell
-(void)tapMethod:(UITapGestureRecognizer *)tap{

    self.model1.isExpanded = !self.model1.isExpanded;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.model1.isExpanded) {
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
        } else {
            self.arrowImageView.transform = CGAffineTransformIdentity;
        }
    }];
    
    if (self.expandCallback) {
        self.expandCallback(self.model1.isExpanded);
    }
}
//加载更多
-(void)goMore{
    if (_goBlock) {
        _goBlock();
    }
}
//返回按钮
- (IBAction)goClick:(UIButton *)sender {
    
    if (self.myblock) {
        
        self.myblock();
        
    }
}
//头视图上对应的数据模型显示
-(void)setModel1:(DeviceTypeModel *)model1{
    _model1 = model1;
    
    if (model1.isExpanded) {
        //箭头所在的ImageView
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);

    } else {
        self.arrowImageView.transform = CGAffineTransformIdentity;

    }

    
    self.titleLabel.text = model1.deviceTypeName;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model1.icon] placeholderImage:LCImage(@"海尔")];
    
}


@end
