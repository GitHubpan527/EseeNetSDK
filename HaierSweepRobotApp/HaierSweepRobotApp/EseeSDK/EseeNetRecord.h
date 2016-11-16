//
//  EseeNetRecord.h
//  EseeNet
//
//  Created by Wynton on 15/9/14.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EseeNetStateEnum.h"

typedef enum : NSUInteger {
    RecordConnectSuccess,
    RecordConnectFile,
    RecordConnectLoginFile,
    RecordConnectTimeOut,
} RecordConnectResult;

typedef void(^curPlayTimeBlock)(NSInteger);


@protocol EseeNetRecordDelegate <NSObject>

- (void)eseeNetRecordCurTime:(int)curTime;

@end

@interface EseeNetRecord : UIView

@property (nonatomic, retain,readonly) NSDictionary *deviceInfo;/**< 设备信息(id,userName,channel)*/
@property (nonatomic, retain, readonly) UIImage      *currentImage;/**< 当前播放画面*/
@property (nonatomic, assign         ) BOOL         pause;


@property (nonatomic, assign) unsigned long handle;

@property (nonatomic, assign) id<EseeNetRecordDelegate> delegate;


@property (nonatomic, assign) BOOL     videoSelect;/**< 播放view是否为选择状态*/

#pragma mark - --- Zoom ---
@property (nonatomic, assign) BOOL  allowScale;     /**< 是否允许放大,默认YES   */

@property (nonatomic, assign) float maxScale;       /**< 最大缩放倍数,默认3     */
@property (nonatomic, assign) float minScale;       /**< 最小缩放倍数,默认1     */
@property (nonatomic, assign,readonly) float currentScale;   /**< 当前放大倍数*/





/**
 *  显示指定提示文字
 *
 *  @param text 提示文字
 */
-(void)showOSDText:(NSString *)text;


/**
 *  设置提示文字
 *
 *  @param ErrorText @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
 */
- (void)initOSDText:(NSDictionary *)ErrorText;

/**
 *  主动改变缩放倍数
 *
 *  @param scale    缩放倍数
 *  @param animated 是否需要过渡动画
 */
- (void)setVideoScale:(float)scale Animated:(BOOL)animated;

/**
 *  初始化方法
 *
 *  @param frame    窗口位置大小
 *  @param divID    设备ID
 *  @param pwd      设备密码
 *  @param userName 设备用户名
 *  @param chn      设备通道号
 *
 *  @return EseeNetRecord
 */
- (EseeNetRecord *)initEseeNetRecordVideoWithFrame:(CGRect)frame;

- (EseeNetRecord *)initEseeNetRecordVideoWithFrame:(CGRect)frame IsFishEye:(BOOL)isFishEye;


- (void)setDeviceInfoWithDeviceID:(NSString *)deviceID
                        Passwords:(NSString *)passwords
                         UserName:(NSString *)userName
                          Channel:(int)channel
                             Port:(int)port
                           Verify:(NSString *)verify;


/**
 *  设置设备信息
 *
 *  @param devceID   设备ID
 *  @param passwords 设备密码
 *  @param userName  设备用户名
 *  @param channel   通道号
 *  @param port      端口
 */
- (void)setDeviceInfoWithDeviceID:(NSString *)deviceID
                        Passwords:(NSString *)passwords
                         UserName:(NSString *)userName
                          Channel:(int)channel
                             Port:(int)port;

/**
 *  连接设备
 *
 *  @param completion 连接登陆设备结果
 */
- (void)connectDevice:(void (^)(RecordConnectResult result))completion;

/**
 *  搜索录像(调用前需要先连接设备)
 *
 *  @param fromTime 搜索起始时间
 *  @param toTime   搜索结束时间
 *  @param completion    搜索结果
 */
- (void)searchRecordWithFromTime:(int)fromTime ToTime:(int)toTime Completion:(void (^)(NSArray *recordTimesArr))completion;

/**
 *  播放录像
 *
 *  @param startTime 播放起始时间
 *  @param toTime    播放结束时间
 */
- (void)playWithStartTime:(int)startTime ToTime:(int)toTime;


/**
 *  播放录像
 *
 *  @param startTime 播放起始时间
 *  @param toTime    播放结束时间
 *  @param channel   播放通道号
 */
- (void)playWithStartTime:(int)startTime ToTime:(int)toTime Channel:(int)channel;



/**
 *  停止播放录像
 */
- (void)stop:(void(^)(BOOL success))completion;

/**
 *  开启音效
 */
- (void)audioOpen;

/**
 *  关闭音效
 */
- (void)audioClose;


/**
 *  截图并保存到相册
 *
 *  @param albumName  相册名,若为空,则不保存到相册
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
- (BOOL)beginRecord;

/**
 *  结束录制,并保存只相册
 *
 *  @param albumName  相册名
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
- (void)endRecordAndSave:(NSString *)albumName Completion:(void(^)(int result))completion;

@end
