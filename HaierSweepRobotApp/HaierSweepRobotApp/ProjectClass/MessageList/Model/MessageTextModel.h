//
//  MessageTextModel.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageTextModel : NSObject

@property (nonatomic,copy)NSString *textId;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *createDate;
@property (nonatomic,copy)NSString *bsType;

@end
