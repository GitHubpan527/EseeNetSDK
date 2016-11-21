//
//  GCDManager.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/7.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

typedef void(^GCDResultBlock)(NSData *data);

@interface GCDManager : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic,copy)GCDResultBlock block;

+ (GCDManager *)shareManager;
- (void)objectRelease;
- (void)sendMessageToServer;
- (void)sendMessageToServerAgain:(NSString *)deviceId;
- (void)sendDataPackageToServerWithCommand:(NSString *)command;
- (void)sendRoomCleanTheAreaToServerWithCommand:(NSString *)command;

@end
