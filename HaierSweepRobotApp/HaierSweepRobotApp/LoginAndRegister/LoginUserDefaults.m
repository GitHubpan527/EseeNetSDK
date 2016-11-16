//
//  LoginUserDefaults.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LoginUserDefaults.h"

#import <objc/runtime.h>

@implementation LoginUserDefaults

//获取key值
+ (NSString *)getLoginUserModelKey
{
    return @"loginUserModel";
}
//获取数据
+ (LoginUserModel *)getLoginUserModelForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [userDefaults objectForKey:key];
    LoginUserModel *userModel = [[LoginUserModel alloc] initWithDic:userDic];
    return userModel;
}
//保存数据
+ (void)setLoginUserModel:(LoginUserModel *)model forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [self getDictionaryWithModel:model];
    [userDefaults setObject:userDic forKey:key];
    [userDefaults synchronize];
}
//对象模型转换成字典
+ (NSDictionary *)getDictionaryWithModel:(LoginUserModel *)model
{
    if (model == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    //获取类名，根据类名获取类对象
    NSString *className = NSStringFromClass([model class]);
    id classObject = objc_getClass([className UTF8String]);
    //获取所有属性
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(classObject, &count);
    
    // 遍历所有属性
    for (int i = 0; i < count; i++) {
        // 取得属性
        objc_property_t property = properties[i];
        // 取得属性名
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property)
                                                          encoding:NSUTF8StringEncoding];
        // 取得属性值
        id propertyValue = nil;
        id valueObject = [model valueForKey:propertyName];
        
        if ([valueObject isKindOfClass:[NSDictionary class]]) {
            propertyValue = [NSDictionary dictionaryWithDictionary:valueObject];
        } else if ([valueObject isKindOfClass:[NSArray class]]) {
            propertyValue = [NSArray arrayWithArray:valueObject];
        } else {
            propertyValue = [NSString stringWithFormat:@"%@", [model valueForKey:propertyName]];
        }
        
        [dict setObject:propertyValue forKey:propertyName];
    }
    return [dict copy];
}

@end
