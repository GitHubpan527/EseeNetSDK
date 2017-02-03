//
//  ContactTypeManager.m
//  Yoosee
//
//  Created by wutong on 16/3/31.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "ContactTypeManager.h"
#import "Contact.h"
#import "UDManager.h"

@interface TempDevice : NSObject
@property (strong, nonatomic) NSString *contactId;
@property (nonatomic) NSInteger contactType;
@property (nonatomic) NSInteger chnCount;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *nvrId;
@end

@implementation TempDevice

@end



@implementation ContactTypeManager
-(void)dealloc
{
//    [self.arraryDevices release];
//    [super dealloc];
}

+ (id)sharedDefault
{
    static ContactTypeManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            manager = [[ContactTypeManager alloc] init];
            NSMutableArray* arraryDevices = [NSMutableArray arrayWithCapacity:0];
            manager.arraryDevices = arraryDevices;
        }
    }
    return manager;
}

/*
如果内存中已经存在，则判断是否已经获取类型，如果没有，则设置类型
如果内存中不存在，则在内存中增加一项，另外持久保存
 */
-(void)cySetTypeWithContactID:(NSInteger)iContactID type:(NSInteger)iType
{
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            if (device.contactType == CONTACT_TYPE_UNKNOWN) {
                device.contactType = iType;
            }
            return;
        }
    }
    
    //内存增加一项
    TempDevice *localDevice = [[TempDevice alloc] init];
    localDevice.contactId = [NSString stringWithFormat:@"%i",iContactID];
    localDevice.contactType = iType;
    localDevice.chnCount = 0;
    localDevice.userName = nil;
    localDevice.nvrId = nil;
    [self.arraryDevices addObject:localDevice];
//    [localDevice release];
    
    if (iType != CONTACT_TYPE_UNKNOWN)
    {
        [UDManager udSetTypeWithContactID:iContactID Type:iType];
    }
}

-(NSInteger)cyGetTypeWithContactID:(NSInteger)iContactID
{
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            if (device.contactType == CONTACT_TYPE_UNKNOWN)
            {
                
                NSInteger iType = [UDManager udGetTypeWithContactID:iContactID];
                if (iType != CONTACT_TYPE_UNKNOWN) {
                    device.contactType = iType;
                }
                return iType;
            }
            else
            {
                return device.contactType;
            }
        }
    }
    
    
    NSInteger iType = [UDManager udGetTypeWithContactID:iContactID];
    return iType;
}


//------------------------------------------------
-(void)cySetNvrInfoWithContactID:(NSInteger)iContactID Count:(NSInteger)iChnCount UserName:(NSString*)sUserName NvrID:(NSString*)sNvrID
{
    BOOL isExsit = NO;
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            isExsit = YES;
            if (device.chnCount == 0) {
                device.chnCount = iChnCount;
            }
            
            if (device.nvrId == nil) {
                device.nvrId = sNvrID;
            }
            
            if (device.userName == nil) {
                device.userName = sUserName;
            }
        }
    }
    
    if (!isExsit) {
        //内存增加一项
        TempDevice *localDevice = [[TempDevice alloc] init];
        localDevice.contactId = [NSString stringWithFormat:@"%i",iContactID];
        localDevice.contactType = CONTACT_TYPE_UNKNOWN;
        localDevice.chnCount = iChnCount;
        localDevice.userName = sUserName;
        localDevice.nvrId = sNvrID;
        [self.arraryDevices addObject:localDevice];
//        [localDevice release];
    }
    
    if (iChnCount != 0)
    {
        [UDManager udSetNvrInfoWithContactID:iContactID Count:iChnCount UserName:sUserName NvrID:sNvrID];
    }
}

-(NSInteger)cyGetChnCountWithContactID:(NSInteger)iContactID
{
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            if (device.chnCount == 0)
            {
                NSInteger iChnCount = [UDManager udGetChnCountWithContactID:iContactID];
                if (iChnCount != 0) {
                    device.chnCount = iChnCount;
                }
                return iChnCount;
            }
            else
            {
                return device.chnCount;
            }
        }
    }
    
    
    NSInteger iChnCount = [UDManager udGetChnCountWithContactID:iContactID];
    return iChnCount;
}

-(NSString*)cyGetUserNameWithContactID:(NSInteger)iContactID
{
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            if (device.userName == nil)
            {
                NSString* username = [UDManager udGetUserNameWithContactID:iContactID];
                if (username != nil) {
                    device.userName = username;
                }
                return username;
            }
            else
            {
                return device.userName;
            }
        }
    }
    
    NSString* username = [UDManager udGetUserNameWithContactID:iContactID];
    return username;
}

-(NSString*)cyGetNvrIDWithContactID:(NSInteger)iContactID
{
    for (int i=0; i<[self.arraryDevices count]; i++) {
        TempDevice* device = [self.arraryDevices objectAtIndex:i];
        if (device.contactId.integerValue == iContactID)
        {
            if (device.nvrId == nil)
            {
                NSString* nvrid = [UDManager udGetNvrIDWithContactID:iContactID];
                if (nvrid != nil) {
                    device.nvrId = nvrid;
                }
                return nvrid;
            }
            else
            {
                return device.nvrId;
            }
        }
    }
    
    NSString* nvrid = [UDManager udGetNvrIDWithContactID:iContactID];
    return nvrid;
}
@end
