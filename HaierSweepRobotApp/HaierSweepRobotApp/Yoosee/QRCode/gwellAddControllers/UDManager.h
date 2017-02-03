//
//  UDManager.h
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginResult;
#define kIsLogin @"isLogin"
#define kLoginInfo @"kLoginInfo"

#define kEmail @"email"
#define kPhone @"phone"



@interface UDManager : NSObject

+(BOOL)isLogin;
+(void)setIsLogin:(BOOL)isLogin;
+(LoginResult*)getLoginInfo;
+(void)setLoginInfo:(LoginResult*)loginResult;

+(void)setEmail:(NSString*)email;
+(NSString*)getEmail;
+(void)setPhone:(NSString*)phone;
+(NSString*)getPhone;

+(NSInteger)getDBVersion;
+(void)setDBVersion:(NSInteger)version;

+(void)pushAPSupportDevByContactID:(unsigned int)dwSrcID;
+(BOOL)isSupportAp:(unsigned int)dwSrcID;

+(NSInteger)udGetTypeWithContactID:(unsigned int)dwID;
+(void)udSetTypeWithContactID:(unsigned int)dwID Type:(NSInteger)iType;


+(void)udSetNvrInfoWithContactID:(unsigned int)dwID Count:(NSInteger)iChnCount UserName:(NSString*)sUserName NvrID:(NSString*)sNvrId;
+(NSInteger)udGetChnCountWithContactID:(unsigned int)dwID;
+(NSString*)udGetUserNameWithContactID:(unsigned int)dwID;
+(NSString*)udGetNvrIDWithContactID:(unsigned int)dwID;

@end
