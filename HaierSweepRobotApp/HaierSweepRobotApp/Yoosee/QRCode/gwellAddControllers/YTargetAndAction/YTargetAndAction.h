//
//  YTargetAndAction.h
//  YTargetAndAction
//
//  Created by apple on 16/9/20.
//  Copyright © 2016年 YuanHongQiang. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface YTargetAndAction : NSObject
-(void)addTarget:(nullable id)target withAction:(nullable SEL)action forEvent:(NSInteger)event withObject:(nullable id)object;
-(void)sendActionForEvent:(NSInteger)event;
-(void)deleteTarget:(nullable id)target withAction:(nullable SEL)action forEvent:(NSInteger)event;
-(void)deleteTarget:(nullable id)target;
-(void)deleteTarget:(nullable id)target forEvent:(NSInteger)event;
@end
