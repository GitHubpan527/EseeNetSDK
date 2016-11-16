 //
//  EseeNetLive.h
//  EseeNetLive
//
//  Created by Wynton on 15/8/5.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//  Last change 15/11/26 17:54

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EseeNetStateEnum.h"

@class EseeNetLive;
@class FishEyeMapping;
@protocol EseeNetLiveDelegate <NSObject>

@optional
/// 错误信息回调
///@param live 发生错误EseeNetLive对象
///@param description 错误描述
- (void)eseeNetLiveErrorWithLive:(EseeNetLive *)live Description:(NSDictionary *)description;

- (void)vconControlCallBack:(NSDictionary *)backInfo Error:(NSDictionary *)error;

- (void)eseeNetLive:(EseeNetLive *)live BitrateChanged:(BITREAT)bitrate;

- (void)eseeNetLive:(EseeNetLive *)live CurrentTimeChanged:(NSString *)timeStr;

@end



@interface EseeNetLive : UIView

@property (nonatomic, retain,readonly) NSDictionary *deviceInfo;/**< 设备信息(id,userName,channel)*/
@property (nonatomic, retain,readonly) UIImage      *currentImage;/**< 当前播放画面*/

@property (nonatomic, assign, readonly) BITREAT  bitRate; /**< 播放的view当前的码流 */
@property (nonatomic, assign) unsigned long p2pHandle;

@property (nonatomic, assign) id<EseeNetLiveDelegate> delegate;


@property (nonatomic, assign) BOOL     videoSelect;/**< 播放view是否为选择状态,添加红边*/

@property (nonatomic, assign) BOOL  allowScale;     /**< 是否允许放大,默认YES   */
@property (nonatomic, assign) float maxScale;       /**< 最大缩放倍数,默认3     */
@property (nonatomic, assign) float minScale;       /**< 最小缩放倍数,默认1     */






/**
 *  显示指定提示文字
 *
 *  @param text 提示文字
 */
- (void)showOSDText:(NSString *)text;

/**
 *  主动改变视频缩放大小
 *
 *  @param scale    缩放倍数
 *  @param animated 是否动画过渡
 */
- (void)setVideoScale:(float)scale Animated:(BOOL)animated;

#pragma mark - --- Live Control Method ---
/**
 *  初始化视频(务必使用此方法来初始化)
 *
 *  @param frame 视频位置大小
 *
 *  @return EseeNetLive
 */
- (EseeNetLive *)initEseeNetLiveVideoWithFrame:(CGRect)frame;

- (instancetype)initEseeNetLiveVideoWithFrame:(CGRect)frame IsFishEye:(BOOL)isFishEye;

/**
 *  设置提示文字
 *
 *  @param ErrorText'key: @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
 */
- (void)initOSDText:(NSDictionary *)ErrorText;


- (void)setDeviceInfoWithDeviceID:(NSString *)deviceID
                        Passwords:(NSString *)passwords
                         UserName:(NSString *)userName
                          Channel:(int)channel
                             Port:(int)port
                           Verify:(NSString *)verify;

/**
 *  设置设备信息
 *
 *  @param devceID   设备ID/IP
 *  @param passwords 设备密码
 *  @param userName  设备用户名
 *  @param port      端口
 */
- (void)setDeviceInfoWithDeviceID:(NSString *)deviceID
                        Passwords:(NSString *)passwords
                         UserName:(NSString *)userName
                          Channel:(int)channel
                             Port:(int)port;


/**
 *  连接设备,并开始播放
 */
- (void)connectAndPlay;

/**
 *  连接设备,并播放
 *
 *  @param play       是否连接完马上播放
 *  @param bitRate    播放的码流
 *  @param completion 完成结果
 */
- (void)connectWithPlay:(BOOL)play BitRate:(BITREAT)bitRate Completion:(void(^)(EseeNetState result))completion;


@property (nonatomic, assign,readonly) EseeNetState connectState;



/**
 *  开启音效(一次只能开启一个视频音效,若多视频调用,播放最后调用的视频声音),默认关闭
 */
- (void)audioOpen;

/**
 *  关闭音频
 */
- (void)audioClose;

/// 云台控制
- (void)ptzControlWithType:(PTZ_CONTROL)type;

/**
 *  码流切换(默认为SD标清)
 *
 *  @param bitrate 码流类型
 */
- (void)changeBitrate:(BITREAT)bitrate;

/**
 *  关闭视频,并断开连接
 */
- (void)stop;

/**
 *  暂停视频
 */
- (void)videoPause;

/**
 *  重新开始视频
 */
- (void)videoResume;



/**
 *  截图并保存到相册
 *
 *  @param albumName  相册名
 *  @param completion 保存回调结果(是否成功)
 */
- (void)saveCurrentImageToAlbumWithAlbumName:(NSString *)albumName
                                  Completion:(void(^)(BOOL success))completion DEPRECATED_ATTRIBUTE;

/**
 *  截图保存至手机相册
 *
 *  @param albumName  相册名(空则不保存)
 *  @param Completion 0:成功, 1:无录像画面可截, 2:无相册访问权限, 3:相册名空, 4:保存到相册失败
 */
- (void)captureImage:(NSString *)albumName Completion:(void(^)(int result))completion;

#pragma mark - --- 录像 ---
@property (nonatomic, assign,readonly) BOOL isRecording;/**< 是否正在录像*/

/**
 开始录制视频
 
 @param filePath 视频保存路径
 */
- (void)beginRecordWithFilePath:(NSString *)filePath;

/**
 结束录制视频
 
 @return 0:成功, 1:录像文件未生成
 */
- (int)endRecord;

/**
 *  开始录制
 */
- (void)beginRecord;


/**
 *  结束录制,并保存只相册
 *
 *  @param albumName  相册名,若为空, 则不保存到相册
 *  @param completion 保存结果(是否成功)
 */
- (void)endRecordAndSaveToAlbum:(NSString *)albumName
                     Completion:(void(^)(BOOL success))completion DEPRECATED_ATTRIBUTE;

/**
 *  结束录像, 并将录像保存至手机相册
 *
 *  @param albumName  相册名(空则不保存)
 *  @param Completion 0:成功, 1:录像文件未生产(可能录制时间为0), 2:无相册访问权限, 3:相册名空, 4:保存到相册失败
 */
- (void)endRecordAndSave:(NSString *)albumName
              Completion:(void(^)(int result))completion;

#pragma mark - --- 远程设置 ---
/**
 *  远程设置
 *
 *  @param content 设置内容
 */
- (void)vconSendWithcontent:(NSString *)content;

@end


