//
//  LoginUserModel.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUserModel : NSObject

@property (nonatomic,copy)NSString *id;
@property (nonatomic,copy)NSString *userName;
@property (nonatomic,copy)NSString *visitCode;
@property (nonatomic,copy)NSString *superVisitCode;
@property (nonatomic,copy)NSString *nickName;
@property (nonatomic,copy)NSString *password;
@property (nonatomic,copy)NSString *accountType;
@property (nonatomic,copy)NSString *realName;
@property (nonatomic,copy)NSString *sex;
@property (nonatomic,copy)NSString *cardNo;
@property (nonatomic,copy)NSString *birthday;
@property (nonatomic,copy)NSString *address;
@property (nonatomic,copy)NSString *telephone;
@property (nonatomic,copy)NSString *email;
@property (nonatomic,copy)NSString *emailVerify;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)NSString *lastLoginTime;
@property (nonatomic,copy)NSString *lastLoginIp;
@property (nonatomic,copy)NSString *openid;
@property (nonatomic,copy)NSString *createTime;
@property (nonatomic,copy)NSString *updateTime;
@property (nonatomic,copy)NSString *language;
@property (nonatomic,copy)NSString *token;
@property (nonatomic,copy)NSString *headUrl;

- (id)initWithDic:(NSDictionary *)dic;

@end
