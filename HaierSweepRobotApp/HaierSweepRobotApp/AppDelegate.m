//
//  AppDelegate.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AppDelegate.h"

#import "GuidePageViewController.h"

#import "AppDelegate+JPush.h"

#import "AppDelegate+UMMobClick.h"

#import "MyFacilityViewController.h"

#import "LingYunManager.h"

//ljp
#import "MainController.h"
#import "UDManager.h"
#import "LoginController.h"
#import "Constants.h"
#import "AutoNavigation.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "NetManager.h"
#import "AccountResult.h"
#import "Reachability.h"
#import "Message.h"
#import "Utils.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "CheckAlarmMessageResult.h"
#import "ContactDAO.h"
#import "GlobalThread.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "UncaughtExceptionHandler.h"
#import "Alarm.h"
#import "AlarmDAO.h"
#import "MPNotificationView.h"
#import "LaunchImageTransition.h"
#import "AlarmPushController.h"//door ring push
#import "UDPManager.h"
#import "PAIOUnit.h"//rtsp监控界面弹出修改
#import "MD5Manager.h"

//UMSocial
#import <UMSocialCore/UMSocialCore.h>


@interface AppDelegate ()
{
    UIAlertView *_alarmAlertView;
}
@end

@implementation AppDelegate
/*
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (self.isForceLandscape) {
        
        return UIInterfaceOrientationMaskLandscape;
        
    }else if (self.isForcePortrait){
        
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#pragma mark - 设置背景颜色
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
#pragma mark - 键盘设置
    [self setupIQKeyBoaredManager];
    
#pragma mark - 极光推送
    [self setJPushWithLaunchOptions:launchOptions];
    
#pragma mark - 友盟统计
    [self setUMMobClick];
    
#pragma mark - 国际化相关
    /*
    if (![[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage]) {
        NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSLog(@"%@",currentLanguage);
        if ([currentLanguage hasPrefix:@"zh-Hans"]) {
            currentLanguage = @"zh-Hans";
        } else {
            currentLanguage = @"en";
        }
        [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:AppLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
     */
    
    [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //ljp
    //app 启动时，检查更新
//    [self checkAppToUpdate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapReceivedNotificationHandler:)
                                                 name:kMPNotificationViewTapReceivedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionIdError:) name:NOTIFICATION_ON_SESSION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveAlarmMessage:) name:RECEIVE_ALARM_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveDoorbellAlarmMessage:) name:RECEIVE_DOORBELL_ALARM_MESSAGE object:nil];
    
    [AppDelegate getAppVersion];

    self.networkStatus = ReachableViaWWAN;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.baidu.com";
    
    
    [[Reachability reachabilityWithHostName:remoteHostName] startNotifier];
    int ap3cid = [[ShakeManager sharedDefault] ApModeGetID];
    if (ap3cid != 0)
    {
        self.dwApContactID = ap3cid;
        self.sWifi = [Utils currentWifiSSID];
        //ljp
//        MainController *mainController_ap = [[MainController alloc] init];
//        self.mainController_ap = mainController_ap;
//        self.window.rootViewController = self.mainController_ap;
//        [self.window makeKeyAndVisible];
        
        MyFacilityViewController *vc = [[MyFacilityViewController alloc] init];
        BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:vc];
        self.window.rootViewController = navi;
        self.mainVC = vc;
        
        [[UDPManager sharedDefault] ScanLanDevice];
        return YES;
    }
    else
    {
        self.dwApContactID = 0;
        self.sWifi = nil;
    }
    
#pragma mark - 是否首次启动
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstLaunch"]) {
//        //引导页
//        GuidePageViewController *vc = [[GuidePageViewController alloc] init];
//        [self.window setRootViewController:vc];
//        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"FirstLaunch"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    } else {
        if([UDManager isLogin]){
            
            MyFacilityViewController *vc = [[MyFacilityViewController alloc] init];
            BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:vc];
            self.window.rootViewController = navi;
            self.mainVC = vc;
            
            LoginResult *loginResult = [UDManager getLoginInfo];
            [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                
                AccountResult *accountResult = (AccountResult*)JSON;
                if(accountResult.error_code==NET_RET_GET_ACCOUNT_SUCCESS){
                    loginResult.email = accountResult.email;
                    loginResult.phone = accountResult.phone;
                    loginResult.countryCode = accountResult.countryCode;
                    [UDManager setLoginInfo:loginResult];
                }
            }];
        }else{
            UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
            BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.window setRootViewController:loginNavi];
        }
//    }
    
    [[UDPManager sharedDefault] ScanLanDevice];
    
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57f89289e0f55a8dca00184a"];
    
    // 获取友盟social版本号
    //NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxf493082560dc8323" appSecret:@"5d2ef054407ac3a881c3dcc136cbb456" redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105846096"  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1716662439"  appSecret:@"f224b37ef5d714821a3b83d80d912850" redirectURL:@"http://sns.whalecloud.com/sina2/callback"];

    return YES;
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)againLogin
{
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.window setRootViewController:loginNavi];
}

#pragma mark - 键盘设置
- (void)setupIQKeyBoaredManager{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if (self.isMonitoring) {
        if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
            [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
            //ljp
            //[[PAIOUnit sharedUnit] stopAudio];
        }
        [[P2PClient sharedClient] p2pHungUp];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    DLog(@"applicationDidEnterBackground");
    
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)orientation] forKey:@"orientationorientation"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
    
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskID;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [[P2PClient sharedClient] p2pDisconnect];
        [app endBackgroundTask:taskID];
    }];
    
    if (taskID == UIBackgroundTaskInvalid) {
        [[P2PClient sharedClient] p2pDisconnect];
        NSLog(@"Failed to start background task!");
        return;
    }
    
    self.isGoBack = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.isGoBack) {
            DLog(@"run background");
            sleep(1.0);
            
        }
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"aaaaa" object:nil];
    
//    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"orientationorientation"];
//    
//    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: [string integerValue]] forKey:@"orientation"];
//    
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    
    self.isGoBack = NO;
    BOOL isModeChanged = NO;
    int ap3cid = [[ShakeManager sharedDefault] ApModeGetID];
    if (self.dwApContactID != ap3cid) {
        if (ap3cid == 0 || self.dwApContactID == 0) {
            isModeChanged = YES;
        }
        self.dwApContactID = ap3cid;
        self.sWifi = [Utils currentWifiSSID];
    }
    if (isModeChanged)
    {
        [[P2PClient sharedClient]p2pDisconnect];
        if (self.dwApContactID != 0)
        {
            //联网模式->单机模式
            if (!self.mainController_ap)
            {
                MainController *mainController_ap = [[MainController alloc] init];
                self.mainController_ap = mainController_ap;
            }
            else
            {
                BOOL result = [[P2PClient sharedClient] p2pConnectWithId:@"0517401" codeStr1:@"0" codeStr2:@"0"];
                NSLog(@"p2pConnectWithId %d", result);
                [[NSNotificationCenter defaultCenter] postNotificationName:AP_ENTER_FORCEGROUND_MESSAGE
                                                                    object:self
                                                                  userInfo:nil];
            }
            [[P2PClient sharedClient]setDelegate:self.mainController_ap];
            self.window.rootViewController = self.mainController_ap;
        }
        else
        {
            //单机模式->联网模式
            if([UDManager isLogin])
            {
                LoginResult *loginResult = [UDManager getLoginInfo];
                if (!self.mainController)
                {
                    MainController *mainController = [[MainController alloc] init];
                    self.mainController = mainController;
                }
                else
                {
                    BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
                }
                [[P2PClient sharedClient]setDelegate:self.mainController];
                self.window.rootViewController = self.mainController;
                [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                    AccountResult *accountResult = (AccountResult*)JSON;
                    loginResult.email = accountResult.email;
                    loginResult.phone = accountResult.phone;
                    loginResult.countryCode = accountResult.countryCode;
                    [UDManager setLoginInfo:loginResult];
                }];
            }
            else
            {
                LoginController *loginController = [[LoginController alloc] init];
                AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
                self.window.rootViewController = mainController;
            }
        }
    }
    else
    {
        if ([[AppDelegate sharedDefault]dwApContactID])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:AP_ENTER_FORCEGROUND_MESSAGE
                                                                object:self
                                                              userInfo:nil];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NVRHengScreen" object:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if([UDManager isLogin]){
        application.applicationIconBadgeNumber = 0;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//摄像头
#pragma mark - 返回三种类型的rect，分别是水平、7.0和其他情况
+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal{
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if(isHorizontal){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-20);
    }
    return rect;
}

+ (AppDelegate*)sharedDefault
{
    return [UIApplication sharedApplication].delegate;
}

+ (NSString*)getAppVersion{
    
    return [NSString stringWithFormat:APP_VERSION];
    
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
    [parameter setObject:[NSNumber numberWithInt:self.networkStatus] forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NET_WORK_CHANGE
                                                        object:self
                                                      userInfo:parameter];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskAll;
}

- (void)tapReceivedNotificationHandler:(NSNotification *)notice
{
    MPNotificationView *notificationView = (MPNotificationView *)notice.object;
    if ([notificationView isKindOfClass:[MPNotificationView class]])
    {
        //NSLog( @"Received touch for notification with text: %@", ((MPNotificationView *)notice.object).textLabel.text );
        
        //ljp
//        [self.mainController setSelectedIndex:1];
//        [self.mainController setBottomBarHidden:NO];
//        self.isNotificationBeClicked = YES;
//        self.window.rootViewController = self.mainController;
    }
}

-(void)onSessionIdError:(id)sender{
    
//    [[P2PClient sharedClient] p2pHungUp];
//    
//    [self.mainController dismissP2PView];
//    [UDManager setIsLogin:NO];
//    
//    [[GlobalThread sharedThread:NO] kill];
//    [[FListManager sharedFList] setIsReloadData:YES];
//    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    LoginController *loginController = [[LoginController alloc] init];
//    loginController.isSessionIdError = YES;
//    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
//    
//    [AppDelegate sharedDefault].window.rootViewController = mainController;
//    
//    //APP将返回登录界面时，注册新的token，登录时传给服务器
//    [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
//    
//    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
//    dispatch_async(queue, ^{
//        [[P2PClient sharedClient] p2pDisconnect];
//        DLog(@"p2pDisconnect.");
//    });
    
    //ljp
    [[P2PClient sharedClient] p2pHungUp];
    
    [self.mainVC dismissP2PView];
    [UDManager setIsLogin:NO];
    
    [[GlobalThread sharedThread:NO] kill];
    [[FListManager sharedFList] setIsReloadData:YES];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.window setRootViewController:loginNavi];
    
    //APP将返回登录界面时，注册新的token，登录时传给服务器
    [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
    
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(queue, ^{
        [[P2PClient sharedClient] p2pDisconnect];
        DLog(@"p2pDisconnect.");
    });
}

-(NSString *)groupName:(int)group{//addgroupItem
    NSString *groupName = @"";
    switch(group){
        case 1:
        {
            groupName = CustomLocalizedString(@"hall", nil);
        }
            break;
        case 2:
        {
            groupName = CustomLocalizedString(@"window", nil);
        }
            break;
        case 3:
        {
            groupName = CustomLocalizedString(@"balcony", nil);
        }
            break;
        case 4:
        {
            groupName = CustomLocalizedString(@"bedroom", nil);
        }
            break;
        case 5:
        {
            groupName = CustomLocalizedString(@"kitchen", nil);
        }
            break;
        case 6:
        {
            groupName = CustomLocalizedString(@"courtyard", nil);
        }
            break;
        case 7:
        {
            groupName = CustomLocalizedString(@"door_lock", nil);
        }
            break;
        case 8:
        {
            groupName = CustomLocalizedString(@"other", nil);
        }
            break;
    }
    return groupName;
}

- (void)onReceiveAlarmMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    
    //contact name
    NSString *contactId   = [parameter valueForKey:@"contactId"];
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    NSString *contactName = contact.contactName;
    
    //YES 表示删除绑定的报警推送ID,显示“解绑”按钮
    BOOL isSupportDelAlarmPushId = [[parameter valueForKey:@"isSupportDelAlarmPushId"] boolValue];
    
    //contact type
    int type   = [[parameter valueForKey:@"type"] intValue];
    
    //防区、通道
    int group   = [[parameter valueForKey:@"group"] intValue];
    int item   = [[parameter valueForKey:@"item"] intValue];
    
    //推送提示消息
    NSString *message2 = @"";//addgroupItem
    NSString *leftSpace = @"";
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 && [UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        leftSpace = @"";//
    }else{
        leftSpace = @"                ";//16
    }
    
    
    //根据报警类型显示文字
    NSString *typeStr = @"";
    BOOL isUnknownType = NO;
    switch(type){
        case 1:
        {
            typeStr = CustomLocalizedString(@"extern_alarm", nil);
            if (group>=1 && group<=8) {//addgroupItem
                message2 = [NSString stringWithFormat:@"%@%@ :%@\n%@%@ :%d",leftSpace,CustomLocalizedString(@"defence_group", nil),[self groupName:group],leftSpace,CustomLocalizedString(@"defence_item", nil),item+1];
            }
        }
            break;
        case 2:
        {
            typeStr = CustomLocalizedString(@"motion_dect_alarm", nil);
        }
            break;
        case 3:
        {
            typeStr = CustomLocalizedString(@"emergency_alarm", nil);
        }
            break;
        case 4:
        {
            typeStr = CustomLocalizedString(@"debug_alarm", nil);
        }
            break;
        case 5:
        {
            typeStr = CustomLocalizedString(@"ext_line_alarm", nil);
        }
            break;
        case 6:
        {
            typeStr = CustomLocalizedString(@"low_vol_alarm", nil);
        }
            break;
        case 7:
        {
            typeStr = CustomLocalizedString(@"pir_alarm", nil);
        }
            break;
        case 8:
        {
            typeStr = CustomLocalizedString(@"defence_alarm", nil);
        }
            break;
        case 9:
        {
            typeStr = CustomLocalizedString(@"defence_disable_alarm", nil);
        }
            break;
        case 10:
        {
            typeStr = CustomLocalizedString(@"battery_low_vol", nil);
        }
            break;
        case 11:
        {
            typeStr = CustomLocalizedString(@"update_to_ser", nil);
        }
            break;
        case 13://门铃报警类型
        {
            typeStr = CustomLocalizedString(@"somebody_visit", nil);
        }
            break;
        default:
        {
            //未知类型
            typeStr = [NSString stringWithFormat:@"%d",type];
            isUnknownType = YES;
        }
            break;
    }
    
    
    //APP在后台
    if(self.isGoBack){
        UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
        alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
        alarmNotify.soundName = [self playAlarmMessageRingWithAlarmType:type isBeBackground:YES];
        if ([contactId isEqualToString:contactName] || contactName == nil) {
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
        }else{
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
        }
        alarmNotify.applicationIconBadgeNumber = 1;
        alarmNotify.alertAction = CustomLocalizedString(@"open", nil);
        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
    }
    
    
    //YES表示正处于视频通话中，不接收推送
    if (self.isBeingInP2PVideo) {
        return;
    }
    
    
    //alarmContactId正处于被监控状态,不作推送
    if ([self.monitoredContactId isEqualToString:contactId]) {
        return;
    }
    
    
    //alarmContactId正处于弹出状态,不作推送
    if ([self.currentPushedContactId isEqualToString:contactId]) {
        return;
    }
    
    
    //YES表示接收到推送，正在输入密码准备进行监控，此时不弹出任何推送
    if (self.isInputtingPwdToMonitor) {
        return;
    }
    
    
    //YES表示正显示门铃推送界面，不弹出任何推送
    if (self.isShowingDoorBellAlarm) {
        return;
    }
    
    
    //isCanShow = NO表示监控中
    P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
    BOOL isCanShow = NO;
    if(p2pCallState==P2PCALL_STATUS_NONE){
        isCanShow = YES;
    }else{
        isCanShow = NO;
    }
    
    //上一次与当前推送的时间间隔,超过10秒，则弹出推送框
    BOOL isTimeAfter = NO;
    if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>10){
        isTimeAfter = YES;
        
    }else{
        isTimeAfter = NO;
    }
    
    
    
    //弹出推送提示框，一是门铃推送，二是其他
    if(isTimeAfter&&!self.isGoBack){//alarmAlertview   isCanShow&&
        [self playAlarmMessageRingWithAlarmType:type isBeBackground:NO];//播放推送铃声
        
        self.alarmContactId = contactId;
        self.currentPushedContactId = contactId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type == 13 && isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
                self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
                
                //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
                if (_alarmAlertView) {
                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    _alarmAlertView = nil;//alarmAlertview
                }
                
                //显示门铃推送界面
                [self.mainController dismissP2PView];//在"报警设置"进入AlarmPushController前执行,若不执行，则会导致从AlarmPushController返回时，无法再进入"报警设置"
                AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
                alarmpushcontroller.contactId = contactId;
                alarmpushcontroller.contactName = contactName;
                self.window.rootViewController = alarmpushcontroller;
                
            }else{//为其他推送
                if (type == 13 && !isCanShow) {//为门铃推送,isCanShow为NO表示在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                }else{
                    self.isDoorBellAlarm = NO;//在监控界面使用,区分门铃推送，其他推送
                }
                
                
                //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
                if (_alarmAlertView) {
                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                //显示其他推送提示
                NSString* title = @"";
                NSString *message = @"";
                if (isUnknownType) {
                    message = [NSString stringWithFormat:@"%@%@%@\n%@\n",leftSpace,CustomLocalizedString(@"unknown_type", nil),typeStr,message2];
                }else{
                    message = [NSString stringWithFormat:@"%@%@%@\n%@\n",leftSpace,CustomLocalizedString(@"alarm_type", nil),typeStr,message2];
                }
                
                if ([contactId isEqualToString:contactName] || contactName == nil) {
                    
                    title = [NSString stringWithFormat:@"%@：%@",CustomLocalizedString(@"device", nil),contactId] ;
                    
                }else {
                    
                    title = [NSString stringWithFormat:@"%@:%@",CustomLocalizedString(@"device", nil),contactName];
                    
                }
                
                _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:CustomLocalizedString(@"view", nil) otherButtonTitles:CustomLocalizedString(@"cancel", nil),nil];
                if (isSupportDelAlarmPushId) {//删除绑定的报警推送ID
                    [_alarmAlertView addButtonWithTitle:CustomLocalizedString(@"delete_alarm_push_id", nil)];
                }
                _alarmAlertView.tag = ALERT_TAG_ALARMING;
                
                //UIAlertView 左对齐 iOS7及iOS6不同处理
                if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
                    CGSize size = [_alarmAlertView.message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240,400) lineBreakMode:NSLineBreakByTruncatingTail];
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -120,size.width, size.height)];
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.textColor = [UIColor blackColor];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.text = _alarmAlertView.message;
                    [_alarmAlertView setValue:textLabel forKey:@"accessoryView"];
                    
                    _alarmAlertView.message =@"";
                }
                [_alarmAlertView show];
            }
        });//alarmAlertview
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
    //UIAlertView 左对齐 iOS7及iOS6不同处理
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        NSInteger count = 0;
        for( UIView * view in _alarmAlertView.subviews )
        {
            if( [view isKindOfClass:[UILabel class]] )
            {
                count ++;
                if ( count == 2 ) { //仅对message左对齐
                    UILabel* label = (UILabel*) view;
                    label.textAlignment =NSTextAlignmentLeft;
                }
            }
        }
    }
}

#pragma mark - 透传门铃（安尔发...）
-(void)onReceiveDoorbellAlarmMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    
    NSString *cmd = [parameter valueForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"anerfa:disconnect"]) {
        NSString *contactId = [parameter valueForKey:@"contactId"];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:contactId];
        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contact.contactPassword cmd:@"IPC1anerfa:disconnect"];
        
    }else if ([[cmd substringToIndex:11] isEqualToString:@"anerfa:call"]) {
        NSString *contactId = [parameter valueForKey:@"contactId"];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:contactId];
        NSString *contactName = contact.contactName;
        
        NSString *typeStr = CustomLocalizedString(@"somebody_visit", nil);
        
        //后台推送
        if(self.isGoBack){
            UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = [self playAlarmMessageRingWithAlarmType:13 isBeBackground:YES];
            if ([contactId isEqualToString:contactName] || contactName == nil) {
                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
            }else{
                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
            }
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = CustomLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
        }
        
        
        //YES表示正处于视频通话中，不接收推送
        if (self.isBeingInP2PVideo) {
            return;
        }
        
        
        //alarmContactId正处于被监控状态,不作推送
        if ([self.monitoredContactId isEqualToString:contactId]) {
            return;
        }
        
        
        //alarmContactId正处于弹出状态,不作推送
        if ([self.currentPushedContactId isEqualToString:contactId]) {
            return;
        }
        
        
        //YES表示接收到推送，正在输入密码准备进行监控，此时不弹出任何推送
        if (self.isInputtingPwdToMonitor) {
            return;
        }
        
        
        //YES表示正显示门铃推送界面，不弹出任何推送
        if (self.isShowingDoorBellAlarm) {
            return;
        }
        
        
        //isCanShow = NO表示监控中
        P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
        BOOL isCanShow = NO;
        if(p2pCallState==P2PCALL_STATUS_NONE){
            isCanShow = YES;
        }else{
            isCanShow = NO;
        }
        
        
        //上一次与当前推送的时间间隔,超过10秒，则弹出推送框
        BOOL isTimeAfter = NO;
        if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>10){
            isTimeAfter = YES;
            
        }else{
            isTimeAfter = NO;
        }
        
        
        
        if(isTimeAfter&&!self.isGoBack){//alarmAlertview
            [self playAlarmMessageRingWithAlarmType:13 isBeBackground:NO];//播放推送铃声
            
            self.alarmContactId = contactId;
            self.currentPushedContactId = contactId;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                    self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
                    
                    //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
                    if (_alarmAlertView) {
                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                        _alarmAlertView = nil;//alarmAlertview
                    }
                    
                    //显示门铃推送界面
                    [self.mainController dismissP2PView];//在"报警设置"进入AlarmPushController前执行,若不执行，则会导致从AlarmPushController返回时，无法再进入"报警设置"
                    AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
                    alarmpushcontroller.contactId = contactId;
                    alarmpushcontroller.contactName = contactName;
                    self.window.rootViewController = alarmpushcontroller;
                    
                }else{//为门铃推送,isCanShow为NO表示在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                    
                    //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
                    if (_alarmAlertView) {
                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    }
                    //显示其他推送提示
                    if ([contactId isEqualToString:contactName] || contactName == nil) {
                        NSString* title = [NSString stringWithFormat:@"%@：%@",CustomLocalizedString(@"device", nil),contactId] ;
                        NSString *message = [NSString stringWithFormat:@"%@%@",CustomLocalizedString(@"alarm_type", nil),typeStr];
                        _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:CustomLocalizedString(@"view", nil) otherButtonTitles:CustomLocalizedString(@"cancel", nil),nil];
                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
                        [_alarmAlertView show];
                    }else {
                        NSString* title = [NSString stringWithFormat:@"%@:%@",CustomLocalizedString(@"device", nil),contactName] ;
                        NSString *message = [NSString stringWithFormat:@"%@%@",CustomLocalizedString(@"alarm_type", nil),typeStr];
                        _alarmAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:CustomLocalizedString(@"view", nil) otherButtonTitles:CustomLocalizedString(@"cancel", nil),nil];
                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
                        [_alarmAlertView show];
                    }
                }
                
            });
        }//alarmAlertview
    }else{
        //unknown error
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self stopToPlayAlarmRing];
    
    switch(alertView.tag){
        case ALERT_TAG_ALARMING:
        {
            _alarmAlertView = nil;//alarmAlertview
            if(buttonIndex==0){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:self.alarmContactId];
                
                if(nil!=contact){
                    self.currentPushedContactId = nil;
                    
                    if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
                        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
                        //
                        //[[PAIOUnit sharedUnit] stopAudio];
                        [[P2PClient sharedClient] p2pHungUp];
                    }
                    
                    
                    //ljp
//                    self.mainController.contactName = contact.contactName;//昵称显示不对
//                    [AppDelegate sharedDefault].contact = nil;
//                    NSArray *contactArr = [[FListManager sharedFList] getContacts];
//                    for (Contact *device in contactArr) {
//                        if ([device.contactId isEqualToString:self.alarmContactId]) {
//                            //为了获取设备的布防状态（如布防、撤防、无权限...）
//                            //应用于监控界面的判断条件
//                            self.mainController.contact = device;
//                        }
//                    }
//                    
//                    
//                    if (self.isMonitoring) {//监控界面时，接收到推送
//                        if (self.gApplicationDelegate && [self.gApplicationDelegate respondsToSelector:@selector(gApplicationWithId:password:callType:)]) {
//                            [self.gApplicationDelegate gApplicationWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
//                        }
//                        return;
//                    }
//                    
//                    [self.mainController dismissP2PView:^{
//                        [self.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
//                        self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//                    }];
                    
                    self.mainVC.contactName = contact.contactName;//昵称显示不对
                    [AppDelegate sharedDefault].contact = nil;
                    NSArray *contactArr = [[FListManager sharedFList] getContacts];
                    for (Contact *device in contactArr) {
                        if ([device.contactId isEqualToString:self.alarmContactId]) {
                            //为了获取设备的布防状态（如布防、撤防、无权限...）
                            //应用于监控界面的判断条件
                            self.mainController.contact = device;
                        }
                    }
                    
                    
                    if (self.isMonitoring) {//监控界面时，接收到推送
                        if (self.gApplicationDelegate && [self.gApplicationDelegate respondsToSelector:@selector(gApplicationWithId:password:callType:)]) {
                            [self.gApplicationDelegate gApplicationWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                        }
                        return;
                    }
                    
                    [self.mainVC dismissP2PView:^{
                        [self.mainVC setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                        self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    }];
                    
                    
                }else{
                    self.isInputtingPwdToMonitor = YES;
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = ALERT_TAG_MONITOR;
                    [inputAlert show];
                }
            }else if(buttonIndex==2){//删除绑定的报警推送ID
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:CustomLocalizedString(@"confirm_unbind", nil) delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
                alertView.tag = 1000;
                [alertView show];
            }else{//取消
                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                self.currentPushedContactId = nil;
            }
        }
            break;
        case 1000://删除绑定的报警推送ID
        {
            self.currentPushedContactId = nil;
            if (buttonIndex==1) {
                [[P2PClient sharedClient] deleteAlarmPushIDWithId:self.alarmContactId];
            }
        }
            break;
        case ALERT_TAG_MONITOR:
        {
            _alarmAlertView = nil;//alarmAlertview
            self.currentPushedContactId = nil;
            self.isInputtingPwdToMonitor = NO;
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                
                NSString *inputPwd = passwordField.text;
                if(!inputPwd||inputPwd.length==0){
                    [self.mainController.view makeToast:CustomLocalizedString(@"input_device_password", nil)];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = ALERT_TAG_MONITOR;
                    [inputAlert show];
                    return;
                }
                if ([[P2PClient sharedClient] p2pCallState] == P2PCALL_STATUS_READY_P2P) {
                    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
                    //ljp
                    //[[PAIOUnit sharedUnit] stopAudio];
                    [[P2PClient sharedClient] p2pHungUp];
                }
                
                
                
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                mainController.contactName = self.alarmContactId;
                
                Contact *contact = [[Contact alloc] init];//重新调整监控画面
                contact.contactId = self.alarmContactId;
                contact.contactName = self.alarmContactId;
                contact.contactPassword = [Utils GetTreatedPassword:inputPwd];
                [AppDelegate sharedDefault].contact = contact;
                [AppDelegate sharedDefault].mainController.contact = nil;
                [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];//在这为了获取设备类型,在监控界面区分门铃设备与其他设备
                
                
                if (self.isMonitoring) {//监控界面时，接收到推送
                    if (self.gApplicationDelegate && [self.gApplicationDelegate respondsToSelector:@selector(gApplicationWithId:password:callType:)]) {
                        [self.gApplicationDelegate gApplicationWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                    }
                    return;
                }
                
                [self.mainController dismissP2PView:^{
                    [self.mainController setUpCallWithId:self.alarmContactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                }];
                
                
            }else{
                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
            }
            
        }
            break;
        case ALERT_TAG_APP_UPDATE://app检查更新
        {
            if(buttonIndex == 1){
                //app的数字ID
                NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
                NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
                NSString *appleID = dic[@"AppleID"];
                
                //已经上架的APP的URL
                NSString *trackViewUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appleID];
                NSURL *url= [NSURL URLWithString:trackViewUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
            break;
    }
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_RECEIVE_MESSAGE:
        {
            NSString *contactId = [parameter valueForKey:@"contactId"];
            NSString *messageStr = [parameter valueForKey:@"message"];
            LoginResult *loginResult = [UDManager getLoginInfo];
            MessageDAO *messageDAO = [[MessageDAO alloc] init];
            Message *message = [[Message alloc] init];
            
            message.fromId = contactId;
            message.toId = loginResult.contactId;
            message.message = [NSString stringWithFormat:@"%@",messageStr];
            message.state = MESSAGE_STATE_NO_READ;
            message.time = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
            message.flag = -1;
            [messageDAO insert:message];
            int lastCount = [[FListManager sharedFList] getMessageCount:contactId];
            [[FListManager sharedFList] setMessageCountWithId:contactId count:lastCount+1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = @"message.mp3";
            notification.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,messageStr];
            notification.applicationIconBadgeNumber = 1;
            notification.alertAction = CustomLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
            break;
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON){
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
            }else{
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            DLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
            
        }
            break;
            
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSString *contactId = [parameter valueForKey:@"contactId"];
    switch(key){
        case ACK_RET_SET_STOP_DOORBELL_PUSH:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==2){
                    [[P2PClient sharedClient] stopDoorbellPushWithId:self.alarmContactId];
                }
            });
        }
            break;
        case ACK_RET_SET_DELETE_ALARM_PUSHID:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==2){
                    [[P2PClient sharedClient] deleteAlarmPushIDWithId:self.alarmContactId];
                }
            });
        }
            break;
        case ACK_RET_SEND_MESSAGE:
        {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int flag = [[parameter valueForKey:@"flag"] intValue];
                MessageDAO *messageDAO = [[MessageDAO alloc] init];
                if(result==0){
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_NO_READ];
                }else{
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_SEND_FAILURE];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                        object:self
                                                                      userInfo:nil];
                });
            });
            
            
            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_GET_DEFENCE_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                NSString *contactId = @"10000";
                if(result==1){
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:CustomLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else{
                    ContactDAO *contactDAO = [[ContactDAO alloc] init];
                    Contact *contact = [contactDAO isContact:contactId];
                    if(nil!=contact){
                        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                    }
                    
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
            
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken
{
    DLog(@"%@",pToken);
    NSString *deviceToken = [[pToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    //注册成功，将deviceToken保存到应用服务器数据库中
    DLog(@"%@",deviceToken);
    
    self.token = [NSString stringWithFormat:@"%@",deviceToken];
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DLog(@"%@%@",@"didFailToRegisterForRemoteNotificationsWithError:",[error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    DLog(@"userInfo %@", userInfo);
    // 处理推送消息
    //    NSLog(@"userinfo:%@",userInfo);
    //    NSArray *allKeys = [userInfo allKeys];
    //    for (NSString *aString in allKeys) {
    //        DLog(@"id %@ content is %@", aString, userInfo[aString]);
    //    }
    //    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    
}

#pragma mark - 前台收到本地通知、后台点击本地通知时，调用
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    DLog(@"%@",notification.alertBody);
}

#pragma mark - 方法1(异步请求)，APP检查更新
-(void)checkAppToUpdate{
    //app的数字ID
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSString *appleID = dic[@"AppleID"];
    
    //获取当前APP的版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    //已经上架的APP的版本号
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // All versions that have been uploaded to the AppStore
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    
                    return;
                    
                } else {
                    //已经上架的APP的版本号
                    NSString *versionInAppStore = [versionsInAppStore objectAtIndex:0];
                    
                    /*
                     *1. 不相等，说明有可更新的APP。此方式导致审核被拒绝，因为新版本与已发布版本不相等，弹出了更新提示框。
                     *2. “不相等”方式改为“小于”，再提示更新，只有上架的APP，才可检测更新并弹框。不过此方式只针对此类版本号（1或1.1），不适合此类版本号（1.1.1或1.1.1.x）
                     *3. 不过1.1~1.9，1.1~9.1，有81种，足够多的版本
                     *4. 改进1，若是1.1与1.1.1的比较（不同类比较），可以通过版本号的长度来提示更新，长度小于则提示。
                     *5. 改进2，若是1.1.1与1.1.2（即长度>=5）的比较（同类比较），取最后3位比较。
                     */
                    if([nowVersion floatValue] < [versionInAppStore floatValue]){
                        NSString *message=[[NSString alloc] initWithFormat:@"%@%@%@",CustomLocalizedString(@"can_update_to", nil),versionInAppStore,CustomLocalizedString(@"version", nil)];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"update", nil) message:message delegate:self cancelButtonTitle:CustomLocalizedString(@"next_time", nil)  otherButtonTitles:CustomLocalizedString(@"update_now", nil), nil];
                        alert.tag = ALERT_TAG_APP_UPDATE;
                        [alert show];
                    }
                }
                
            });
        }
        
    }];
    
}

#pragma mark - 报警铃声播放
-(NSString *)playAlarmMessageRingWithAlarmType:(int)alarmType isBeBackground:(BOOL)isBackground{
    NSURL *ringUrl = nil;
    //return @"default";//关闭前台铃声，恢复后台默认铃声
    switch(alarmType){
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        {
            return @"default";//关闭前台铃声，恢复后台默认铃声
            
            if(isBackground){
                return @"alarm_push_ring.caf";
            }
            
            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alarm_push_ring" ofType:@"caf"]];
        }
            break;
        case 13:
        {
            if(isBackground){
                return @"door_bell_ring.caf";
            }
            
            //门铃报警类型
            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"door_bell_ring" ofType:@"caf"]];
        }
            break;
        default:
        {
            return @"default";//关闭前台铃声，恢复后台默认铃声
            
            if(isBackground){
                return @"unknown_push_ring.caf";
            }
            
            //未知类型
            ringUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"unknown_push_ring" ofType:@"caf"]];
        }
            break;
    }
    
    //为什么从监控退出后，AVAudioPlayer的声音变小了
    //解决方法：
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //音频播放器加载音乐
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:ringUrl error:nil];
    self.alarmRingPlayer = player;
    //准备播放
    [self.alarmRingPlayer prepareToPlay];
    //设置声音
    self.alarmRingPlayer.volume = 1.0;
    //播放次数
    self.alarmRingPlayer.numberOfLoops = 0;
    //开始播放
    [self.alarmRingPlayer play];
    
    return nil;
}

#pragma mark - 停止播放报警铃声
-(void)stopToPlayAlarmRing{
    if(self.alarmRingPlayer.isPlaying){
        [self.alarmRingPlayer stop];
        
        
        P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
        if(p2pCallState!=P2PCALL_STATUS_NONE){//表示监控中
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
    }
}

#pragma mark - APP将返回登录界面时，注册新的token，登录时传给服务器
-(void)reRegisterForRemoteNotifications{
    if (CURRENT_VERSION>=9.3) {
        if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
        }else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
        }
    }
}

@end
