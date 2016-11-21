//
//  AppInterface.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/4.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInterface : NSObject

/**< 发送验证码 */
extern NSString *const SendCode;

/**< 切换语言 */
extern NSString *const UserFrontLanguage;

/**< 换取语言列表 */
extern NSString *const UserFrontLanguagePageList;

/**< 校验验证码 */
extern NSString *const CheckMobileCode;

/**< 用户注册 */
extern NSString *const UserFrontRegister;

/**< 用户登录 */
extern NSString *const AuthLogin;

/**< 获取外部账号 */
extern NSString *const GetExternalAccount;

/**< 通知外部帐号注册通知 */
extern NSString *const RegisterExternalAccount;

/**< 修改(忘记)密码 */
extern NSString *const UpdatePasswd;

/**< 用户修改用户信息 */
extern NSString *const UserFrontUpdate;

/**< 用户详情 */
extern NSString *const UserFrontDetail;

/**< 根据密码验证修改密码 */
extern NSString *const UpdatePassByPasswd;

/**< 退出登录 */
extern NSString *const UserFrontLogout;

/**< 获取消息列表 */
extern NSString *const FindMessagePage;

/**< 获取消息总数 */
extern NSString *const FindMessageCount;

/**< 消息详细 */
extern NSString *const FindMessageDetail;

/**< 删除消息 */
extern NSString *const MessageFrontDelete;

/**< 商城链接 */
extern NSString *const LinkFrontPage;

/**< 关于我们 */
extern NSString *const AboutFrontPage;

/**< 使用帮助 */
extern NSString *const UseHelpFront;

/**< 查询意见反馈 */
extern NSString *const FeedBackPage;

/**< 增加反馈 */
extern NSString *const FeedBackAdd;

/**< 首页轮播图 */
extern NSString *const IndexImgFindAll;

/**< 获取设备类型列表 */
extern NSString *const DeviceTypeFrontFindAll;

/**< 获取平台设备型号列表 */
extern NSString *const DeviceModelFrontFindAll;

/**< 绑定设备 */
extern NSString *const DeviceAdd;

/**< 删除设备 */
extern NSString *const DeviceDelete;

/**< 重命名设备 */
extern NSString *const DeviceUpdate;

/**< 用户已绑定的设备列表 */
extern NSString *const UserDeviceFindPage;

/**< 查扫地机任务执行-清扫 */
extern NSString *const FindCleanTask;

/**< 清扫详情 */
extern NSString *const FindCleanDetail;

/**< 指令列表 */
extern NSString *const DeviceCommandFindPage;

/**< 是否存在户型图 */
extern NSString *const CheckRoomExist;

/**< 添加坐标 */
extern NSString *const RoomCoordinateFrontAdd;

/**< 删除房间坐标 */
extern NSString *const RoomCoordinateFrontDelete;

/**< 绘制户型图 */
extern NSString *const DrawHouseType;

/**< 绘制完成 */
extern NSString *const DrawFinish;

/**< 上传户型图 */
extern NSString *const UploadHouseType;

/**< 删除户型图 */
extern NSString *const RoomFrontDelete;

/**< 查看户型图 */
extern NSString *const RoomFrontDetail;

/**< 查看房间id */
extern NSString *const RoomFrontQueryRoomId;

/**< 自动标记和添加区域 */
extern NSString *const RoomAreaFrontAdd;

/**< 修改区域名称 */
extern NSString *const RoomAreaFrontUpdate;

/**< 删除区域 */
extern NSString *const RoomAreaFrontDelete;

/**< 指定清扫区域打扫 */
extern NSString *const AssignAreaClean;

/**< 身份 */
extern NSString *const Identity;

/**< 连接 */
extern NSString *const Connect;

/**< 心跳 */
extern NSString *const HeartBeat;

/**< 数据 */
extern NSString *const Data;

/**< 上传用户头像 */
extern NSString *const UploadUserHead;

/**< 获取系统时间 */
extern NSString *const GetTimeMillis;

@end
