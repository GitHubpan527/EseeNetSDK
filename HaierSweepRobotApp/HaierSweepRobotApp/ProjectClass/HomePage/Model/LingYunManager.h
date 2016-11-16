//
//  LingYunManager.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/2.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "hci_asr_recorder_visualcontrol.h"

typedef void(^ResultBlock)(NSString *result);

@interface LingYunManager : NSObject<AsrRecorderCallBackDelegate>

@property(retain,nonatomic) JTAsrRecorderDialog *asrDlg;
@property(copy, nonatomic) NSString *asrCapKey;

@property (nonatomic,copy)ResultBlock block;

+ (LingYunManager *)shareManager;
- (void)startSpeak;

@end
