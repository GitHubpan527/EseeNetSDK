//
//  StorageManager.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/10.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "StorageManager.h"

@implementation StorageManager

static StorageManager *storageManager = nil;

+(StorageManager *)shareStorageManager
{
    @synchronized(self)
    {
        if (!storageManager) {
            storageManager = [[StorageManager alloc] init];
        }
        return storageManager;
    }
}

+(id)alloc
{
    @synchronized(self)
    {
        if (!storageManager) {
            storageManager =[super alloc];
        }
        return storageManager;
    }
}

-(id)init
{
    if (self = [super init]) {
        self.systemControlDataDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [self readSystemControlDataFromFile];
    }
    return self;
}

//读取系统的ControlData
-(BOOL)readSystemControlDataFromFile
{
    self.systemControlDataDic = [StorageManager loadFromFile:@"system_control_data"];
    if (self.systemControlDataDic == nil) {
        self.systemControlDataDic = [NSMutableDictionary dictionary];
        return NO;
    }
    return YES;
}

//将本地plist文件加载到内存
+(NSMutableDictionary *)loadFromFile:(NSString *) plistName{
    NSString *error = nil;
    NSPropertyListFormat format;
    NSMutableDictionary *dict = nil;
    NSString *filePath = [self dataFilePath:plistName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        filePath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:filePath];
    dict = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML
                                                                   mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                             format:&format
                                                                   errorDescription:&error];
    return dict;
}

//获取文件路径
+ (NSString *)dataFilePath:(NSString *) dataPath {
    dataPath = [dataPath stringByAppendingString:@".plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dataPath];
}

//根据属性的名字取得属性的值
-(id)getPropertyWithKey:(NSString *)propertyName
{
    if (propertyName == nil) {
        return nil;
    }
    
    id propertyValue = [self.systemControlDataDic objectForKey:propertyName];
    if (propertyValue == nil) {
        propertyValue = @"";
    }
    
    return propertyValue;
}

//设置属性的值
-(BOOL)setPropertyWithKey:(NSString *)propertyName value:(id)propertyValue
{
    [self.systemControlDataDic setValue:propertyValue forKey:propertyName];
    
    NSLog(@"%@",self.systemControlDataDic);
    
    //将内存中的数据保存进入plist
    return [self saveSystemControlDataToFile];
}

//写入系统的ControlData
-(BOOL)saveSystemControlDataToFile
{
    //写入本地的dic
    //将整个字典写入文件
    BOOL rst = [StorageManager saveToFile:self.systemControlDataDic fileName:@"system_control_data"];
    return rst;
}

//保存文件到沙盒
+(BOOL)saveToFile:(NSMutableDictionary *)withData fileName:(NSString *) fileName{
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:withData format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if(plistData) {
        
        return [plistData writeToFile:[self dataFilePath:fileName] atomically:YES];
    } else {
        return NO;
    }
}

@end
