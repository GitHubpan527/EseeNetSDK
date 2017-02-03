//
//  AlarmPushViewController.h
//  AlarmPush
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 tangxingchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface AlarmPushViewController : BaseViewController

/*
dic=@{
      @"contactId":contactId,
      @"contactName":contactName,
      @"type":[NSNumber numberWithInt:type],
      @"typeStr":typeStr,
      @"group":[NSNumber numberWithInt:group],
      @"item":[NSNumber numberWithInt:item],
      @"alarmName":alarmName,
      @"isSupportDelAlarmPushId":[NSNumber numberWithBool:isSupportDelAlarmPushId],
      @"isSupportAlarmPic":[NSNumber numberWithBool:isSupportAlarmPic],
      @"capCount":capCount,
      @"sPicPath":sPicPath,
      @"alarmPicstPath":alarmPicstPath
 };
 */
@property(nonatomic,strong) NSDictionary *dic;

-(void)refreshViewsWithDic:(NSDictionary *)alarmInfoDic;

@end
