//
//  LoginUserDefaults.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoginUserModel.h"

@interface LoginUserDefaults : NSObject

//获取key值
+ (NSString *)getLoginUserModelKey;
//获取数据
+ (LoginUserModel *)getLoginUserModelForKey:(NSString *)key;
//保存数据
+ (void)setLoginUserModel:(LoginUserModel *)model forKey:(NSString *)key;

@end
