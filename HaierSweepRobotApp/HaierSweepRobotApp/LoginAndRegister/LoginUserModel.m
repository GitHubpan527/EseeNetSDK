//
//  LoginUserModel.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LoginUserModel.h"

@implementation LoginUserModel

- (id)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        //mj
        self = [LoginUserModel mj_objectWithKeyValues:dic];
        
        /*
        self.id = dic[@"id"];
        self.userName = dic[@"userName"];
        self.visitCode = dic[@"visitCode"];
        self.superVisitCode = dic[@"superVisitCode"];
        self.nickName = dic[@"nickName"];
        self.password = dic[@"password"];
        self.accountType = dic[@"accountType"];
        self.realName = dic[@"realName"];
        self.sex = dic[@"sex"];
        self.cardNo = dic[@"cardNo"];
        self.birthday = dic[@"birthday"];
        self.address = dic[@"address"];
        self.telephone = dic[@"telephone"];
        self.email = dic[@"imail"];
        self.emailVerify = dic[@"emailVerify"];
        self.status = dic[@"status"];
        self.lastLoginTime = dic[@"lastLoginTime"];
        self.lastLoginIp = dic[@"lastLoginIp"];
        self.openid = dic[@"openid"];
        self.createTime = dic[@"createTime"];
        self.updateTime = dic[@"updateTime"];
        self.language = dic[@"language"];
        self.token = dic[@"token"];
        self.headUrl = dic[@"headUrl"];
         */
    }
    return self;
}

@end
