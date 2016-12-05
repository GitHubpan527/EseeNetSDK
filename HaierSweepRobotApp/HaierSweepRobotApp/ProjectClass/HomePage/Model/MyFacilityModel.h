//
//  MyFacilityModel.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFacilityModel : NSObject

@property (nonatomic,copy)NSString *id;
@property (nonatomic,copy)NSString *deviceId;
@property (nonatomic,copy)NSString *addTime;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *typeId;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *uid;
@property (nonatomic,copy)NSString *modelId;
@property (nonatomic,copy)NSString *modelImg;
@property (nonatomic , copy) NSString * res2;//设备id
@property (nonatomic , copy) NSString * res1;//设备密码
@property (nonatomic , copy) NSString * res3;//附加信息

@end
