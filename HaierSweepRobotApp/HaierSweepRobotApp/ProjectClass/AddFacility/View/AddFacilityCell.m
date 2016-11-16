//
//  AddFacilityCell.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AddFacilityCell.h"

@implementation AddFacilityCell
//一级列表
- (void)setTypeModel:(DeviceTypeModel *)typeModel
{
    _typeModel = typeModel;
    self.titleLabel.text = typeModel.deviceTypeName;
    [self.facilityView sd_setImageWithURL:[NSURL URLWithString:typeModel.icon] placeholderImage:LCImage(@"海尔")];
}
//二级列表
- (void)setListModel:(AddFacilityModel *)listModel
{
    _listModel = listModel;
    self.titleLabel.text = listModel.deviceModelName;
    [self.facilityView sd_setImageWithURL:[NSURL URLWithString:listModel.icon] placeholderImage:LCImage(@"海尔")];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
