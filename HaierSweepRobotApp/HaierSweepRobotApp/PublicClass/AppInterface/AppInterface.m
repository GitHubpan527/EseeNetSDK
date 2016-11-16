//
//  AppInterface.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/4.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AppInterface.h"

/**< 发送验证码 */
NSString *const SendCode = @"mobileCodeFront/sendCode";

/**< 切换语言 */
NSString *const UserFrontLanguage = @"userFront/language";

/**< 换取语言列表 */
NSString *const UserFrontLanguagePageList = @"languageFront/findAll";

/**< 校验验证码 */
NSString *const CheckMobileCode = @"mobileCodeFront/checkMobileCode";

/**< 用户注册 */
NSString *const UserFrontRegister = @"userFront/register";

/**< 获取外部账号 */
NSString *const GetExternalAccount = @"externalUserFront/getExternalAccount";

/**< 通知外部帐号注册通知 */
NSString *const RegisterExternalAccount = @"externalUserFront/registerExternalAccount";

/**< 用户登录 */
NSString *const AuthLogin = @"auth/login";

/**< 修改(忘记)密码 */
NSString *const UpdatePasswd = @"userFront/updatePasswd";

/**< 用户修改用户信息 */
NSString *const UserFrontUpdate = @"userFront/update";

/**< 用户详情 */
NSString *const UserFrontDetail = @"userFront/detail";

/**< 根据密码验证修改密码 */
NSString *const UpdatePassByPasswd = @"userFront/updatePassByPasswd";

/**< 退出登录 */
NSString *const UserFrontLogout = @"userFront/logout";

/**< 获取消息列表 */
NSString *const FindMessagePage = @"messageFront/findMessagePage";

/**< 获取消息总数 */
NSString *const FindMessageCount = @"messageFront/findMessageCount";

/**< 消息详细 */
NSString *const FindMessageDetail = @"messageFront/findMessageDetail";

/**< 删除消息 */
NSString *const MessageFrontDelete = @"messageFront/delete";

/**< 商城链接 */
NSString *const LinkFrontPage = @"linkFront/findPage";

/**< 关于我们 */
NSString *const AboutFrontPage = @"aboutFront/findAll";

/**< 使用帮助 */
NSString *const UseHelpFront = @"useHelpFront/findPage";

/**< 查询意见反馈 */
NSString *const FeedBackPage = @"feedbackFront/findPage";

/**< 增加反馈 */
NSString *const FeedBackAdd = @"feedbackFront/add";

/**< 首页轮播图 */
NSString *const IndexImgFindAll = @"indexImgFront/findAll";

/**< 获取设备类型列表 */
NSString *const DeviceTypeFrontFindAll = @"deviceTypeFront/findAll";

/**< 获取平台设备型号列表 */
NSString *const DeviceModelFrontFindAll = @"deviceModelFront/findAll";

/**< 绑定设备 */
NSString *const DeviceAdd = @"userDeviceFront/add";

/**< 删除设备 */
NSString *const DeviceDelete = @"userDeviceFront/delete";

/**< 重命名设备 */
NSString *const DeviceUpdate = @"userDeviceFront/update";

/**< 用户已绑定的设备列表 */
NSString *const UserDeviceFindPage = @"userDeviceFront/findPage";

/**< 查扫地机任务执行-清扫 */
NSString *const FindCleanTask = @"taskTrailFront/findCleanTask";

/**< 清扫详情 */
NSString *const FindCleanDetail = @"taskTrailFront/findCleanDetail";

/**< 指令列表 */
NSString *const DeviceCommandFindPage = @"deviceCommandFront/findPage";

/**< 是否存在户型图 */
NSString *const CheckRoomExist = @"roomFront/checkRoomExist";

/**< 添加坐标 */
NSString *const RoomCoordinateFrontAdd = @"roomCoordinateFront/add";

/**< 删除房间坐标 */
NSString *const RoomCoordinateFrontDelete = @"roomCoordinateFront/delete";

/**< 绘制户型图 */
NSString *const DrawHouseType = @"Z001";

/**< 绘制完成 */
NSString *const DrawFinish = @"A5A0";

/**< 上传户型图 */
NSString *const UploadHouseType = @"";

/**< 删除户型图 */
NSString *const RoomFrontDelete = @"roomFront/delete";

/**< 查看户型图 */
NSString *const RoomFrontDetail = @"roomFront/detail";

/**< 查看房间id */
NSString *const RoomFrontQueryRoomId = @"roomFront/queryRoomId";

/**< 自动标记和添加区域 */
NSString *const RoomAreaFrontAdd = @"roomAreaFront/add";

/**< 修改区域名称 */
NSString *const RoomAreaFrontUpdate = @"roomAreaFront/update";

/**< 删除区域 */
NSString *const RoomAreaFrontDelete = @"roomAreaFront/delete";

/**< 指定清扫区域打扫 */
NSString *const AssignAreaClean = @"K0";

/**< 身份 */
NSString *const Identity = @"U0";

/**< 连接 */
NSString *const Connect = @"U1";

/**< 心跳 */
NSString *const HeartBeat = @"U2";

/**< 数据 */
NSString *const Data = @"A0";

/**< 上传用户头像 */
NSString *const UploadUserHead = @"userFront/uploadUserHead";

/**< 获取系统时间 */
NSString *const GetTimeMillis = @"auth/getTimeMillis";

@implementation AppInterface

@end
