//
//  AddFacilityCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DeviceTypeModel.h"
#import "AddFacilityModel.h"

@interface AddFacilityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *facilityView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic,strong)DeviceTypeModel *typeModel;
@property (nonatomic,strong)AddFacilityModel *listModel;

@end
