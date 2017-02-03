//
//  AlarmPushViewController.m
//  AlarmPush
//
//  Created by apple on 16/7/8.
//  Copyright © 2016年 tangxingchen. All rights reserved.
//

#import "AlarmPushViewController.h"
#import "Constants.h"
#import "UIViewExt.h"
#import "P2PClient.h"
#import "AppDelegate.h"
#import "ContactDAO.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "Utils.h"
#import "FListManager.h"
#import "mesg.h"
#import "Toast+UIView.h"

#define TAG_UNBIND_ALARM_MESSAGE 1607121
#define TAG_CLOSE_DEVICE_ALARM_SOUND 1607191
#define TAG_INPUT_PWD_TO_MONITOR 1607192
#define TAG_INPUT_PWD_CLOSE_DEVICE_ALARM_SOUND 1607193

@interface AlarmPushViewController ()<UIAlertViewDelegate>
{
    UIImage *_backgroundImage;
    UIImageView *_imgViewAcount;
    
    
    // 最顶端
    UIButton *_cancelButton;
    UILabel *_deviceIDLabel;
    
    // 上面的
    UIView *_topView;
    UIImageView *_alarmSceneImageView;
    UIButton *_soundAlarmButton;
    
    
    // 下面的
    UIView *_downView;
    
    UIView *_dynamicAlarmView;
    UIImageView *_dynamicAlarmImageView;
    UIImageView *_rippleImageView;//波纹
    UIImageView *_doorbellImageView;//门铃
    UILabel *_alarmTypeNameLabel;
    UILabel *_alarmNameLabel;
    
    UIView *_buttonView;
    UIButton *_unbundlButton;
    UIButton *_checkButton;
    
    
    NSString* _curSaveFile;
    BOOL _isShowAlarmPushPic;
    BOOL _isGotAlarmPushPic;
    NSString *_alarmDeviceInCurController;
    
    
    NSTimer *_timer;
    
    MBProgressHUD *_progressAlert;//指示器
}
@end

@implementation AlarmPushViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[[AppDelegate sharedDefault] mainController] setIsShowingAlarmPushController:NO];
    [AppDelegate sharedDefault].lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
    [AppDelegate sharedDefault].isShowingDoorBellAlarm = NO;
    [[AppDelegate sharedDefault] stopToPlayAlarmRing];
    
    [[P2PClient sharedClient] stopDoorbellPushWithId:[AppDelegate sharedDefault].alarmContactId];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self prefersStatusBarHidden];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[[AppDelegate sharedDefault] mainController] setIsShowingAlarmPushController:YES];
    
    //定时，15秒后自动退出门铃推送界面
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(dismissAlarmController) userInfo:nil repeats:NO];
}

#pragma mark - 15秒后自动退出门铃推送界面
-(void)dismissAlarmController{
    [_timer setFireDate:[NSDate distantFuture]];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundImage = [UIImage imageNamed:@"alarmPush_background.png"];
    _imgViewAcount=[[UIImageView alloc]init];
    [_imgViewAcount setImage:_backgroundImage];
    [self.view addSubview:_imgViewAcount];
    
    [self initFalseTopBar];
    
    [self initTopView];
    
    [self initDownView];
    
    if ([_dic[@"isSupportAlarmPic"] boolValue]){
        [self downloadPicWithIndex:0];
    }
    
    //当前控制器显示的报警设备ID
    _alarmDeviceInCurController = _dic[@"contactId"];
    
    //提示
    _progressAlert = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressAlert];
}

#pragma mark - 下载第dwIndex张图片
-(void)downloadPicWithIndex:(NSInteger)dwIndex
{
    //图片获取的路径
    NSString* srcPath = [NSString stringWithFormat:@"%@%02d%02ld.jpg", _dic[@"sPicPath"], [_dic[@"capCount"] intValue], dwIndex+1];
    
    //_dic[@"sPicPath"]  mnt/disc1/npc/alarm/2017-01-22/G000020170122141257
    //_dic[@"alarmPicstPath"]  /var/mobile/Containers/Data/Application/52276459-222A-4C26-B614-32705E2D9EF8/Documents/alarmPushPic/03720080/1485065574.png
    //图片保存的路径
    
    NSString* dstPath = _dic[@"alarmPicstPath"];
    
    ContactDAO *contactDAO= [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:_dic[@"contactId"]];
    BOOL ret = [[P2PClient sharedClient] downloadPicWithId:contact.contactId password:contact.contactPassword srcPath:srcPath dstPath:dstPath];
    if (ret) {//YES表示获取成功
        _curSaveFile = [dstPath copy];//图片保存的路径
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[self.view makeToast:@"启动下载失败"];
            if ([_dic[@"isSupportAlarmPic"] boolValue]){
                [self downloadPicWithIndex:0];
            }
            sleep(2.0);
        });
    }
}


#pragma mark - 收到全局消息的处理
-(void)receiveRemoteMessage:(NSNotification*)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    if (key == RET_SET_PUSH_SOUND) {
        int result = [[parameter valueForKey:@"result"] intValue];
        if(result==0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [_progressAlert hide:YES];
                [_soundAlarmButton setHidden:YES];//关闭成功，则隐藏按钮
            });
        }
    }
}

//[远程获取文件结果回调]
//-dwDesID:    目标设备ID
//-pFilename:  文件名字（包含完整路径）
//-dwErrorCode: 返回的错误代码 见上述枚举
/*
 //dwErrorCode
 enum
 {
 GET_FILE_CMD_ERR_NONE,          //0 成功
 GET_FILE_CMD_ERR_PW_INCRRECT,   //1 密码不对
 GET_FILE_CMD_ERR_IP_FREEZE,     //2 密码被冻结
 GET_FILE_CMD_ERR_NO_SUCH_FILE,  //3 没有这个文件
 GET_FILE_CMD_ERR_NOT_ALLOWED,   //4 权限
 GET_FILE_CMD_ERR_READ_FILE_FAIL,//5 读取文件失败
 GET_FILE_CMD_ERR_BUZY,          //6 设备繁忙
 GET_FILE_CMD_ERR_MEMORY_LIMITED,//7 内存限制
 GET_FILE_CMD_ERR_TIMEOUT,       //8 超时
 };
 */
- (void)ack_receiveRemoteMessage:(NSNotification *)notification
{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    
    if (key == ACK_RET_SET_PUSH_SOUND_DEFENCE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(result==2){
                DLog(@"resend settings");
                [_progressAlert hide:YES];
                [self.view makeToast:NSLocalizedString(@"net_exception", nil)];
//                [[P2PClient sharedClient] setPushDefenceWithId:contactId password:contactPassword pushState:1];
            }
        });
    }
    
    if (key == ACK_RET_GET_ALARM_PUSH_PIC)
    {
        //NSLog(@"报警图片获取的错误码为：%d",result);
        if (result == GET_FILE_CMD_ERR_NONE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSFileManager* manager = [NSFileManager defaultManager];
                if ([manager fileExistsAtPath:_curSaveFile])
                {
                    //
                    UIImage *img = [UIImage imageWithContentsOfFile:_curSaveFile];
                    _alarmSceneImageView.image = img;
                    
                    _isGotAlarmPushPic = YES;
                    [self viewDidLayoutSubviews];
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result==GET_FILE_CMD_ERR_READ_FILE_FAIL || result==GET_FILE_CMD_ERR_TIMEOUT || result==GET_FILE_CMD_ERR_BUZY) {
                    if ([_dic[@"isSupportAlarmPic"] boolValue]){
                        [self downloadPicWithIndex:0];
                    }
                }else{
                    //刷新view的布局
                    _isGotAlarmPushPic = NO;
                    [self viewDidLayoutSubviews];
                }
                
            });
        }
    }
}

#pragma mark - 声音按钮四种图片切换
-(void)updateTheButtonImage:(BOOL)flag{
    if (flag) {
        UIImage *backButtonImg = [UIImage imageNamed:@"alarmPush_no_sound_btn.png"];
        UIImage *backButtonImg_p = [UIImage imageNamed:@"alarmPush_no_sound_btn_p.png"];
        [_soundAlarmButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
        [_soundAlarmButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];
    }else{
        UIImage *backButtonImg = [UIImage imageNamed:@"alarmPush_sound_btn.png"];
        UIImage *backButtonImg_p = [UIImage imageNamed:@"alarmPush_sound_btn_p.png"];
        [_soundAlarmButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
        [_soundAlarmButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];
    }
}

#pragma mark - 做一个假的导航条
-(void)initFalseTopBar
{
    //设备名称
    _deviceIDLabel = [[UILabel alloc] init];
    _deviceIDLabel.text = _dic[@"contactName"];
    [_deviceIDLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    _deviceIDLabel.textAlignment = NSTextAlignmentCenter;
    _deviceIDLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_deviceIDLabel];
    
    
    //关闭按钮
    _cancelButton = [[UIButton alloc] init];
    UIImage *backButtonImg = [UIImage imageNamed:@"alarmPush_cancel_btn.png"];
    UIImage *backButtonImg_p = [UIImage imageNamed:@"alarmPush_cancel_btn.png_p.png"];
    [_cancelButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
    [_cancelButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(onCancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
}

#pragma mark - 初始化上面的界面
-(void)initTopView
{
    //以下控件的父视图
    _topView = [[UIView alloc] init];
    [self.view addSubview:_topView];
    
    
    //报警推送图片
    _alarmSceneImageView = [[UIImageView alloc] init];
    _alarmSceneImageView.backgroundColor = [UIColor grayColor];
    [_topView addSubview:_alarmSceneImageView];
    
    
    //关闭报警声音按钮
    _soundAlarmButton = [[UIButton alloc] init];
    [self updateTheButtonImage:YES];
    [_soundAlarmButton addTarget:self action:@selector(onSoundAlarmButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_soundAlarmButton];
}



#pragma mark - 初始化下面的界面
-(void)initDownView
{
    //以下控件的父视图
    _downView = [[UIView alloc] init];
    [self.view addSubview:_downView];
    
    
    //红色图片
    _dynamicAlarmView = [[UIView alloc] init];
    [_downView addSubview:_dynamicAlarmView];
    
    _dynamicAlarmImageView = [[UIImageView alloc] init];
    [_dynamicAlarmImageView setImage:[UIImage imageNamed:@"alarmPush_dynamicAlarm_imageView.png"]];
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"alarmPush_dynamicAlarm_imageView.png"],[UIImage imageNamed:@"alarmPush_dynamicAlarm_imageView_p.png"],nil];
    _dynamicAlarmImageView.animationImages = imagesArray;
    _dynamicAlarmImageView.animationDuration = 0.38;
    [_dynamicAlarmImageView startAnimating];
    [_dynamicAlarmView addSubview:_dynamicAlarmImageView];
    //波纹
    _rippleImageView = [[UIImageView alloc] init];
    [_rippleImageView setImage:[UIImage imageNamed:@"alarm_doorbell_left1.png"]];
    NSArray *rippleImgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"alarm_doorbell_left1.png"],[UIImage imageNamed:@"alarm_doorbell_left2.png"],[UIImage imageNamed:@"alarm_doorbell_left3.png"], nil];
    _rippleImageView.animationImages = rippleImgArray;
    _rippleImageView.animationDuration = 0.38;
    [_rippleImageView startAnimating];
    [_dynamicAlarmView addSubview:_rippleImageView];
    //门铃
    _doorbellImageView = [[UIImageView alloc] init];
    [_doorbellImageView setImage:[UIImage imageNamed:@"doorbell_m.png"]];
    NSArray *doorbellImgsArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"doorbell_l.png"],[UIImage imageNamed:@"doorbell_m.png"],[UIImage imageNamed:@"doorbell_r.png"], nil];
    _doorbellImageView.animationImages = doorbellImgsArray;
    _doorbellImageView.animationDuration = 0.38;
    [_doorbellImageView startAnimating];
    [_dynamicAlarmView addSubview:_doorbellImageView];
    

    //报警类型
    _alarmTypeNameLabel = [[UILabel alloc] init];
    _alarmTypeNameLabel.textColor = [UIColor whiteColor];
    _alarmTypeNameLabel.font = [UIFont systemFontOfSize:14.0];
    _alarmTypeNameLabel.text = _dic[@"typeStr"];
    _alarmTypeNameLabel.textAlignment = NSTextAlignmentCenter;
    [_dynamicAlarmView addSubview:_alarmTypeNameLabel];
    //获取报警的传感器名称或者是报警的防区、通道
    _alarmNameLabel = [[UILabel alloc] init];
    _alarmNameLabel.textColor = [UIColor whiteColor];
    _alarmNameLabel.font = [UIFont systemFontOfSize:14.0];
    _alarmNameLabel.text = _dic[@"alarmName"];
    _alarmNameLabel.textAlignment = NSTextAlignmentCenter;
    [_dynamicAlarmView addSubview:_alarmNameLabel];

    
    
    _buttonView = [[UIView alloc] init];
    [self.view addSubview:_buttonView];
    
    //解除绑定
    _unbundlButton = [[UIButton alloc] init];
    UIImage *unbundlButtonImg = [UIImage imageNamed:@"alarmPush_unbundl_btn.png"];
    UIImage *unbundlButtonImg_p = [UIImage imageNamed:@"alarmPush_unbundl_btn_p.png"];
    [_unbundlButton setBackgroundImage:unbundlButtonImg forState:UIControlStateNormal];
    [_unbundlButton setBackgroundImage:unbundlButtonImg_p forState:UIControlStateHighlighted];
    [_unbundlButton addTarget:self action:@selector(onUnbundlButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:_unbundlButton];
    
    
    //监控
    _checkButton = [[UIButton alloc] init];
    UIImage *backButtonImg = [UIImage imageNamed:@"alarmPush_check_btn.png"];
    UIImage *backButtonImg_p = [UIImage imageNamed:@"alarmPush_check_btn_p.png"];
    [_checkButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
    [_checkButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];
    [_checkButton addTarget:self action:@selector(onCheckButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:_checkButton];
}

#pragma mark - 响应事件
#pragma mark 取消按钮操作方法
-(void)onCancelButtonPress:(UIButton*)button
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[AppDelegate sharedDefault].mainController.view makeToast:[NSString stringWithFormat:NSLocalizedString(@"not_receive_alarm_information", nil)]];
}

#pragma mark 关闭报警声音方法
-(void)onSoundAlarmButtonPress:(UIButton *)button
{
    [self updateTheButtonImage:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"comfirm_mute_the_alarm", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    alertView.tag = TAG_CLOSE_DEVICE_ALARM_SOUND;
    [alertView show];
}

#pragma mark 解绑按钮方法
-(void)onUnbundlButtonPress:(UIButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"confirm_unbind", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    alertView.tag = TAG_UNBIND_ALARM_MESSAGE;
    [alertView show];
}

#pragma mark 查看按钮方法
-(void)onCheckButtonPress:(UIButton *)button
{
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:_dic[@"contactId"]];
    
    if(nil!=contact){
        AppDelegate * appDdelegate = [AppDelegate sharedDefault];
        
        appDdelegate.mainController.contactName = contact.contactName;
        [AppDelegate sharedDefault].contact = nil;
        NSArray *contactArr = [[FListManager sharedFList] getContacts];
        for (Contact *device in contactArr) {
            if ([device.contactId isEqualToString:appDdelegate.alarmContactId]) {
                //为了获取设备的布防状态（如布防、撤防、无权限...）
                //应用于监控界面的判断条件
                appDdelegate.mainController.contact = device;
            }
        }
        
        
        [appDdelegate.mainController dismissP2PView:^{
            [appDdelegate.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
        }];
        
    }else{
        [AppDelegate sharedDefault].isInputtingPwdToMonitor = YES;
        UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        inputAlert.tag = TAG_INPUT_PWD_TO_MONITOR;
        inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        UITextField *passwordField = [inputAlert textFieldAtIndex:0];
        passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [inputAlert show];
    }
}

#pragma mark - alertView代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(alertView.tag){
        case TAG_INPUT_PWD_TO_MONITOR:
        {
            AppDelegate *appDdelegate = [AppDelegate sharedDefault];
            appDdelegate.isInputtingPwdToMonitor = NO;
            
            if(buttonIndex==1){//确定
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                
                if(!inputPwd||inputPwd.length==0){
                    appDdelegate.isInputtingPwdToMonitor = YES;
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.tag = TAG_INPUT_PWD_TO_MONITOR;
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    [inputAlert show];
                    return;
                }
                
                MainController *mainController = appDdelegate.mainController;
                mainController.contactName = _dic[@"contactId"];
                
                Contact* contact = [[Contact alloc]init];
                contact.contactId = _dic[@"contactId"];
                contact.contactName = _dic[@"contactId"];
                contact.contactPassword = inputPwd;
                
                [AppDelegate sharedDefault].contact = contact;
                [AppDelegate sharedDefault].mainController.contact = nil;
                [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];//在这为了获取设备类型,在监控界面区分门铃设备与其他设备
                
                [appDdelegate.mainController dismissP2PView:^{
                    [appDdelegate.mainController setUpCallWithId:_dic[@"contactId"] password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                }];
                
            }
        }
            break;
        case TAG_CLOSE_DEVICE_ALARM_SOUND:
        {
            if (buttonIndex==1) {
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:_dic[@"contactId"]];
                if(nil!=contact){
                    _progressAlert.dimBackground = YES;
                    [_progressAlert show:YES];
                    [[P2PClient sharedClient] setPushDefenceWithId:contact.contactId password:contact.contactPassword pushState:1];
                    
                }else{
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = TAG_INPUT_PWD_CLOSE_DEVICE_ALARM_SOUND;
                    [inputAlert show];
                }
            }
        }
            break;
        case TAG_INPUT_PWD_CLOSE_DEVICE_ALARM_SOUND:
        {
            if (buttonIndex==1) {
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                
                if(!inputPwd||inputPwd.length==0){
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = TAG_INPUT_PWD_CLOSE_DEVICE_ALARM_SOUND;
                    [inputAlert show];
                    return;
                }
                
                
                _progressAlert.dimBackground = YES;
                [_progressAlert show:YES];
                [[P2PClient sharedClient] setPushDefenceWithId:_dic[@"contactId"] password:inputPwd pushState:1];
            }
        }
            break;
        case TAG_UNBIND_ALARM_MESSAGE:
        {
            if (buttonIndex==1) {
                [[P2PClient sharedClient] deleteAlarmPushIDWithId:_dic[@"contactId"]];
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }
            break;
    }
}

#pragma mark - layoutSubviews屏幕适配方法
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // _imgViewAcount适配代码
    CGFloat tempW=self.view.width;
    CGFloat tempH=self.view.height;
    CGFloat tempX=0;
    CGFloat tempY=0;
    CGRect newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _imgViewAcount.frame = newRect;
    //从下面开始布局
    tempW=self.view.width;
    tempH=250.0;
    tempX=(self.view.width -  tempW) / 2.0;
    tempY= self.view.height - tempH ;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _downView.frame = newRect;
    
    
    tempW = _downView.width;
    tempH = 130.0;
    tempX=(_downView.width - tempW) / 2.0;
    tempY=0.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _dynamicAlarmView.frame = newRect;
    
    
    //报警图片类型
    UIImage *alarmTypeImage = [UIImage imageNamed:@"alarmPush_dynamicAlarm_imageView.png"];
    tempW = 70.0;
    tempH = tempW*(alarmTypeImage.size.height/alarmTypeImage.size.width);
    tempX=(_dynamicAlarmView.width - tempW) / 2.0;
    tempY=0.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _dynamicAlarmImageView.frame = newRect;
    //波纹
    UIImage *rippleImage = [UIImage imageNamed:@"alarm_doorbell_left1.png"];
    tempW = 70.0+40.0;
    tempH = tempW*(rippleImage.size.height/rippleImage.size.width);
    tempX=(_dynamicAlarmView.width - tempW) / 2.0;
    tempY=0.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _rippleImageView.frame = newRect;
    //门铃
    UIImage *doorbellImage = [UIImage imageNamed:@"doorbell_l.png"];
    tempW = 70.0;
    tempH = tempW*(doorbellImage.size.height/doorbellImage.size.width);
    tempX=(_dynamicAlarmView.width - tempW) / 2.0;
    tempY=(_rippleImageView.height-tempH) / 2.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _doorbellImageView.frame = newRect;
    if ([_dic[@"type"] intValue] == ALARM_TYPE_DOORBELL_PUSH) {
        [_rippleImageView setHidden:NO];
        [_doorbellImageView setHidden:NO];
        [_dynamicAlarmImageView setHidden:YES];
    }else{
        [_rippleImageView setHidden:YES];
        [_doorbellImageView setHidden:YES];
        [_dynamicAlarmImageView setHidden:NO];
    }
    
    
    //报警类型
    tempW =_downView.width;;
    tempH =30.0;
    tempX=(_downView.width - tempW) / 2.0;
    tempY=_dynamicAlarmImageView.bottom;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _alarmTypeNameLabel.frame = newRect;
    
    
    //获取报警的传感器名称或者是报警的防区、通道
    tempW =_downView.width;;
    tempH =30.0;
    tempX=(_downView.width - tempW) / 2.0;
    tempY=_alarmTypeNameLabel.bottom;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _alarmNameLabel.frame = newRect;
    
    
    tempW = 146.0;
    tempH = 62.0;
    tempX=(_downView.width - tempW) / 2.0;
    tempY=_dynamicAlarmView.bottom  + 30.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _buttonView.frame = newRect;
    CGRect buttonViewRect = [_downView convertRect:_buttonView.frame toView:self.view];
    _buttonView.frame = buttonViewRect;
    
    
    
    tempW = 62.0;
    tempH = tempW;
    tempX= 0.0;
    tempY=0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _unbundlButton.frame = newRect;
    
    
    tempW = 62.0;
    tempH = tempW;
    tempX= _unbundlButton.right + 22.0;
    tempY=0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _checkButton.frame = newRect;
    
    
    tempW=self.view.width;
    tempH=22.0;
    tempX=0;
    tempY = 31.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _deviceIDLabel.frame = newRect;
    
    tempW = 22.0;
    tempH = tempW;
    tempX = self.view.width - 16.0 - tempW;
    tempY = 16.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _cancelButton.frame = newRect;
    
    
    
    
    tempW = self.view.width - 34.0 * 2.0;
    tempX=(self.view.width -  tempW) / 2.0;
    tempY = _deviceIDLabel.bottom + 30.0;
    tempH = self.view.height - tempY - _downView.height - 10.0;
    if (tempH > 222.0) {
        tempH = 222.0;
    }
    
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _topView.frame = newRect;
    
    
    tempW = _topView.width;
    tempH = _topView.height;
    tempX = 0.0;
    tempY = 0.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _alarmSceneImageView.frame = newRect;
    
    
    tempW = 40.0;
    tempH = tempW;
    tempX = self.view.width -  tempW - 34.0 - 5.0;
    tempY = _topView.top + 5.0;
    newRect=CGRectMake(tempX, tempY, tempW, tempH);
    _soundAlarmButton.frame = newRect;
    
    
    
    
    _downView.top=_topView.bottom + 20.0;
    
    if (![_dic[@"isSupportAlarmPic"] boolValue] || !_isGotAlarmPushPic || ![_alarmDeviceInCurController isEqualToString:_dic[@"contactId"]]) {
        //当前控制器显示的报警设备ID
        _alarmDeviceInCurController = _dic[@"contactId"];
        [_topView setHidden:YES];
        _downView.center=self.view.center;//_downView居中
    }else{
        [_topView setHidden:NO];
    }
    
    if (![_dic[@"isSupportDelAlarmPushId"] boolValue]) {
        [_unbundlButton setHidden:YES];
        tempW = _checkButton.width;
        tempH = _checkButton.height;
        tempX = (_buttonView.width-tempW)/2.0;
        tempY = _checkButton.top;
        newRect=CGRectMake(tempX, tempY, tempW, tempH);
        _checkButton.frame = newRect;
    }else{
        [_unbundlButton setHidden:NO];
    }
}

#pragma mark - 刷新views
-(void)refreshViewsWithDic:(NSDictionary *)alarmInfoDic{
    _dic = alarmInfoDic;
    
    //设备名称
    _deviceIDLabel.text = _dic[@"contactName"];
    
    //报警类型
    _alarmTypeNameLabel.text = _dic[@"typeStr"];
    //获取报警的传感器名称或者是报警的防区、通道
    _alarmNameLabel.text = _dic[@"alarmName"];
    
    //报警推送图片
    if ([_dic[@"isSupportAlarmPic"] boolValue]){
        [self downloadPicWithIndex:0];
    }
    
    //有报警推送进来，则显示关闭报警声音按钮
    [_soundAlarmButton setHidden:NO];
    
    //刷新view的布局
    [self viewDidLayoutSubviews];
}

#pragma mark - 隐藏导航栏最上面的20像素高度
-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
