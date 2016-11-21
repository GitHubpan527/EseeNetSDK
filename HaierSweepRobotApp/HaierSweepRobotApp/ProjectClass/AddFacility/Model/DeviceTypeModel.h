//
//  DeviceTypeModel.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/9.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTypeModel : NSObject

@property (nonatomic,copy)NSString *id;
@property (nonatomic,copy)NSString *deviceTypeName;
@property (nonatomic,copy)NSString *minImg;
@property (nonatomic,copy)NSString *maxImg;
@property (nonatomic,copy)NSString *sortBy;
@property (nonatomic,copy)NSString *createDate;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)NSString *icon;

@property (nonatomic, assign) BOOL isExpanded;
/** 存放着一堆的数据（里面都是AddFacilityModel模型） */
@property (nonatomic,strong) NSArray * deviceModelList;

@end






