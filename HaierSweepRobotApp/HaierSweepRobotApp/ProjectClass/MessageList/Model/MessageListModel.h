//
//  MessageListModel.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageTextModel.h"

@interface MessageListModel : NSObject

@property (nonatomic,copy)NSString *messageId;
@property (nonatomic,copy)NSString *sendId;
@property (nonatomic,copy)NSString *recId;
@property (nonatomic,copy)NSString *textId;
@property (nonatomic,copy)NSString *status;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,strong)MessageTextModel *messageText;

@end
