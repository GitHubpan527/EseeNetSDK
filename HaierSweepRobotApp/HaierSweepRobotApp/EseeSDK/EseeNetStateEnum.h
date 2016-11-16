//
//  EseeNetStateEnum.h
//  EseeNetDemo
//
//  Created by Wynton on 16/1/7.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#ifndef EseeNetStateEnum_h
#define EseeNetStateEnum_h


typedef enum : NSUInteger {
    EseeNetStateDisconnect,    //0 ->断开连接
    EseeNetStateGetHandleFail, //1 ->获取句柄失败
    EseeNetStateConnecting,    //2 ->连接设备中
    EseeNetStateConnectSuccess,//3 ->设备连接成功
    EseeNetStateConnectFail,   //4 ->设备连接失败
    EseeNetStateLogining,      //5 ->登陆设备中
    EseeNetStateLoginSuccess,  //6 ->登陆设备成功
    EseeNetStateLoginTimeout,  //7 ->登陆设备超时
    EseeNetStateAuthorFail,    //8 ->登陆信息错误
    EseeNetStateLoading,       //9 ->码流开启成功
    EseeNetStateLoadFail,      //10->码流开启失败
    EseeNetStatePlaying        //11->播放中
} EseeNetState;

///云台控制类型
typedef enum : NSUInteger {
    PTZ_STOP,       /**< 云台停止运动*/
    PTZ_UP,         /**< 上*/
    PTZ_DOWN,       /**< 下*/
    PTZ_LEFT,       /**< 左*/
    PTZ_RIGHT,      /**< 右*/
    PTZ_ZOOM_IN,    /**< 放大*/
    PTZ_ZOOM_OUT,   /**< 缩小*/
    PTZ_FOCUS_FAR,  /**< 焦距放大*/
    PTZ_FOCUS_NEAR, /**< 焦距缩小*/
    PTZ_IRIS_OPEN,  /**< 光圈开启*/
    PTZ_IRIS_CLOSE, /**< 光圈关闭*/
} PTZ_CONTROL;

///清晰度类型
typedef enum : NSUInteger {
    HD,/**< 高清*/
    SD,/**< 标清*/
} BITREAT;



#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#endif /* EseeNetStateEnum_h */
