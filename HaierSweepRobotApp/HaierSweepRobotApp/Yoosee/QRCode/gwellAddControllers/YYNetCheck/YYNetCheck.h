//
//  YYNetCheck.h
//  YYNetCheck
//
//  Created by apple on 16/10/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "YYDelegates.h"


/********************看这里******************
 注意,本类既可以有单个delegate,直接设置delegete=self之类的即可
 也可以有多个,使用addDelegate:self  这样的方法添加delegate,使用deleteDelegate:self 这样的方法删除delegate
 增强型的delegate机制即可以达到类似消息中心的多个监听者效果,也避开了消息中心的缺点
 不想使用消息发送中心,那东西用多了会使代码维护起来非常困难
 *******************************************/

@protocol YYNetCheckDelegate;

typedef NS_ENUM(NSInteger,YYNetCheckState){
    YYNetCheckStateNoInternet,      //彻底没网  !!!
    YYNetCheckStateWiFiHave,        //WiFi有用
    YYNetCheckStateWiFiNo,          //WiFi没用  也是没网!!!
    YYNetCheckStateWWANHave,        //流量有用
    YYNetCheckStateWWANNo,          //流量没用   也是没网!!!
    YYNetCheckStateHaveInternet,    //不知道什么类型,但有网,请注意,以上有3种情况是表示上不了网的,写程序的时候要区分一下
};

@interface YYNetCheck : NSObject
@property(nonatomic,weak,nullable)id<YYNetCheckDelegate> delegate;//设置单个代理
-(void)addTheDelegate:(nullable id<YYNetCheckDelegate>)delegate;//添加代理,可以添加多个
-(void)deleteTheDelegate:(nullable id<YYNetCheckDelegate>)delegate;//删除代理
-(void)deleteAllTheDelegate;//删除所有代理

+(nullable instancetype)shareInstance;//获取单例
-(void)startCheckInternet;//启动网络检查
-(void)stopCheckInternet;//停止网络检查
-(BOOL)isChecking;//是否在运行网络检查程序
-(YYNetCheckState)currentState;//立即返回当前网络状态,当没有启动网络检查时,此状态不一定正确

@end
@protocol YYNetCheckDelegate <NSObject>
@optional
-(void)yyNetCheck:(nullable YYNetCheck*)net netStateChangeWithTheState:(YYNetCheckState)state;//当网络发生变化的时候,会在子线程回调此方法
@end
