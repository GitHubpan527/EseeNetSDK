//
//  StorageManager.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/10.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

//用户存储本地plist文件信息到内存中
@property(nonatomic,retain)NSMutableDictionary * systemControlDataDic;

+ (StorageManager *)shareStorageManager;
+ (id)alloc;

//根据属性的名字取得属性的值
-(id)getPropertyWithKey:(NSString *)propertyName;
//设置属性的值
-(BOOL)setPropertyWithKey:(NSString *)propertyName value:(id)propertyValue;

@end
