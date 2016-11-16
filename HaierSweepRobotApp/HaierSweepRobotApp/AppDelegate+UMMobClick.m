//
//  AppDelegate+UMMobClick.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/2.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AppDelegate+UMMobClick.h"
#import <UMMobClick/MobClick.h>

@implementation AppDelegate (UMMobClick)

- (void)setUMMobClick
{
    [MobClick setLogEnabled:YES];
    UMConfigInstance.appKey = @"57f89289e0f55a8dca00184a";
   // UMConfigInstance.secret = @"secretstringaldfkals";
    [MobClick startWithConfigure:UMConfigInstance];
}

@end
