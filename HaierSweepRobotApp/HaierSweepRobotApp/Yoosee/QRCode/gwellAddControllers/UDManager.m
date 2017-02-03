//
//  UDManager.m
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "UDManager.h"
#import "LoginResult.h"
@implementation UDManager

+(BOOL)isLogin{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    return [manager boolForKey:kIsLogin];
}

+(void)setIsLogin:(BOOL)isLogin{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setBool:isLogin forKey:kIsLogin];
    [manager synchronize];
}

+(void)setLoginInfo:(LoginResult *)loginResult{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSArray *array = [[NSArray alloc] initWithObjects:loginResult,nil];
    
    [manager setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:kLoginInfo];
    [manager synchronize];
}

+(LoginResult*)getLoginInfo{
    LoginResult *result = nil;
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSData *data = [manager objectForKey:kLoginInfo];
    if(data!=nil){
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        result = [array objectAtIndex:0];
    }
    return result;
}

+(NSString*)getEmail{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
    }else{
        return nil;
    }
    
}

+(void)setEmail:(NSString*)email{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:email forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kEmail]];
        [manager synchronize];
    }
}

+(NSString*)getPhone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        return [manager stringForKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
    }else{
        return nil;
    }
    
}

+(void)setPhone:(NSString*)phone{
    if([UDManager isLogin]){
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
        [manager setValue:phone forKey:[NSString stringWithFormat:@"%@%@",loginResult.contactId,kPhone]];
        [manager synchronize];
    }
}

+(void)pushAPSupportDevByContactID:(unsigned int)dwSrcID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    [manager setBool:YES forKey:[NSString stringWithFormat:@"%d", dwSrcID]];
    [manager synchronize];
}

+(BOOL)isSupportAp:(unsigned int)dwSrcID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%d", dwSrcID];
    return [manager boolForKey:key];
}

+(void)udSetTypeWithContactID:(unsigned int)dwID Type:(NSInteger)iType
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    
    NSString* key = [NSString stringWithFormat:@"NVRType%d", dwID];
    NSInteger type = [manager integerForKey:key];
    if (type == 0) {
        [manager setInteger:iType forKey:key];
        [manager synchronize];
    }
}

+(NSInteger)udGetTypeWithContactID:(unsigned int)dwID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"NVRType%d", dwID];
    return [manager integerForKey:key];
}

///--------------
+(void)udSetNvrInfoWithContactID:(unsigned int)dwID Count:(NSInteger)iChnCount UserName:(NSString*)sUserName NvrID:(NSString*)sNvrId
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    
    NSString* key = [NSString stringWithFormat:@"NVRChnCount%d", dwID];
    NSInteger count = [manager integerForKey:key];
    if (count == 0) {
        [manager setInteger:iChnCount forKey:key];
        [manager synchronize];
    }
    
    NSString* key1 = [NSString stringWithFormat:@"NVRUserName%d", dwID];
    NSString* name = [manager stringForKey:key1];
    if (name == nil) {
        [manager setObject:sUserName forKey:key1];
        [manager synchronize];
    }
    
    NSString* key2 = [NSString stringWithFormat:@"NVRID%d", dwID];
    NSString* nvrid = [manager stringForKey:key2];
    if (nvrid == nil) {
        [manager setObject:sNvrId forKey:key2];
        [manager synchronize];
    }
}

+(NSInteger)udGetChnCountWithContactID:(unsigned int)dwID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"NVRChnCount%d", dwID];
    return [manager integerForKey:key];
}

+(NSString*)udGetUserNameWithContactID:(unsigned int)dwID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"NVRUserName%d", dwID];
    return [manager stringForKey:key];
}

+(NSString*)udGetNvrIDWithContactID:(unsigned int)dwID
{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"NVRID%d", dwID];
    return [manager stringForKey:key];
}

@end
