//
//  DetailedItineraryHeaderView.h
//  rujingyouapp1.0
//
//  Created by zhengju on 16/4/29.
//  Copyright © 2016年 shengmei. All rights reserved.
//
//四天行程

#import <UIKit/UIKit.h>
@class DeviceTypeModel;
typedef void(^DetailedItineraryHeaderViewBlcok) ();
typedef void(^DetailedItineraryHeaderViewBlock) (BOOL isExpanded);

@interface DetailedItineraryHeaderView : UITableViewHeaderFooterView

@property (nonatomic , copy) DetailedItineraryHeaderViewBlock expandCallback;

@property (nonatomic , copy) DetailedItineraryHeaderViewBlcok myblock;

@property (nonatomic, copy) dispatch_block_t goBlock;
@property (nonatomic,strong) UIImageView * iconView;
@property (nonatomic,strong) UILabel * titleLabel;


@property (nonatomic ,strong) DeviceTypeModel *model1;

@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIImageView *BGview;
@end
