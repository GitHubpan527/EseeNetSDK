//
//  ContactTypeManager.h
//  Yoosee
//
//  Created by wutong on 16/3/31.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDevice.h"

/*
 这个类用来在内存中保存设备信息。由于时间关系没有完全整理好。
 以后完全可以把FListManager里的功能整合到这里。
 还可以把数据库相关的操作简化，不要每次操作都访问数据库，以至于经常返回数据库读写异常的消息。
 */

@interface ContactTypeManager : NSObject

@property (retain, nonatomic) NSMutableArray *arraryDevices;

+ (id)sharedDefault;

-(void)cySetTypeWithContactID:(NSInteger)iContactID type:(NSInteger)iType;
-(NSInteger)cyGetTypeWithContactID:(NSInteger)iContactID;

-(void)cySetNvrInfoWithContactID:(NSInteger)iContactID Count:(NSInteger)iChnCount UserName:(NSString*)sUserName NvrID:(NSString*)sNvrID;
-(NSInteger)cyGetChnCountWithContactID:(NSInteger)iContactID;
-(NSString*)cyGetUserNameWithContactID:(NSInteger)iContactID;
-(NSString*)cyGetNvrIDWithContactID:(NSInteger)iContactID;
@end
