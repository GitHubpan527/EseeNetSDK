//
//  QRCodeNextController.m
//  Yoosee
//
//  Created by guojunyi on 14-9-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "QRCodeNextController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "QRCodeGenerator.h"
#import "YProgressView.h"
#import "FListManager.h"
#import "CreateInitPasswordController.h"
#import "AddContactNextController.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#import "elian.h"
#import "WaitingPageView.h"
#import "QRCodeController.h"
#import "RollingImage.h"
#import "UIViewExt.h"
#import "LSemTMFSet.h"
#import "NewAddDevicesViewController.h"
#import "YMsgBox.h"
#import "AddDevicesPopTipsView.h"
#import "SetUpWiFiViewController.h"
#import "PrepareDevicesToConnectViewController.h"

@interface QRCodeNextController ()<LSemTMFSetDelegate>{
    void *_context;
    int _index;
}
@property (nonatomic,copy) NSString *contactID;
@property (nonatomic,assign) NSInteger flag;
@property (nonatomic,assign) NSInteger type;
@property (strong,nonatomic) NSMutableDictionary *addresses;

@property (nonatomic,copy) NSString *address;

@end

@implementation QRCodeNextController
{
//    RollingImage* _rollingImage;
    
    UILabel *_timeLb;
    
    BOOL _shouldExit;
}

#pragma mark - 声波SDK
-(void)initSoundSDK
{
    int sdkResult=[[LSemTMFSet sharedInstance]initSDK:@"gwelltimes" client:@"gwelltimes" productModel:@"gm8135s-8136" license:@"11625ae8060111e6b5123e1d05defe78"];
    NSLog(@"声波SDK初始化代码:%d",sdkResult);
    [[LSemTMFSet sharedInstance] setDelegate:self];
}
-(void)exitSoundSDK{
    //NSLog(@"退出声波SDK");
    [[LSemTMFSet sharedInstance] setDelegate:nil];
    [[LSemTMFSet sharedInstance] exitEMTMFSDK];
    
}
-(void)soundStartSend
{
    [_smartKeyPromptView startWaitRolling];
    [[LSemTMFSet sharedInstance] sendWiFiSet:self.uuidString password:self.wifiPwd];
}
-(void)soundStopSend
{
    //NSLog(@"停止发送声波");
    [_smartKeyPromptView pauseWaitRolling];
    [[LSemTMFSet sharedInstance] stopSend];
    [[LSemTMFSet sharedInstance] cancleConnectTimer];
}
//声波协议
- (void)didSetWifiResultErrcode:(EMTMFErrcodeType*)errcode content:(NSString*)content
{
    if (errcode==(EMTMFErrcodeType*)EMTMFErrcodeType_SUCESS)
    {
        //NSLog(@"声波配对成功");
        _isWaiting=NO;
    }else
    {
        //NSLog(@"声波配对失败,重新发送");
        [self soundStartSend];
    }
    
}
- (void)didFSKSendingComplete
{
    //NSLog(@"声波发送完成,等待结果");
    [_smartKeyPromptView pauseWaitRolling];
    [[LSemTMFSet sharedInstance] startConnectTimeOutListener:1];
}
#pragma mark - 方法

-(void)dealloc{
 
    NSLog(@"声波界面被销毁");
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self exitSendAllData];
    if (!_shouldExit) {
        [self.navigationController popToViewController:_thePopViewController animated:NO];
    }
}

//修复了声波连接Socket未释放端口的问题

-(BOOL)prepareSocket{
    
//    NSLog(@"prepareSocket prepareSocket");
    
    if (self.socket) {
        [self.socket close];
        self.socket=nil;
    }
    
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    
    if (![socket bindToPort:9988 error:&error])
    {
        NSLog(@"Error binding: %@", [error localizedDescription]);
        [socket close];
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", [error localizedDescription]);
        [socket close];
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        [socket close];
        return NO;
    }
    
    self.socket = socket;
    self.isPrepared = YES;
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _index = 0;

    [self initSoundSDK];
    _shouldExit=NO;
    
    
    self.addresses = [[NSMutableDictionary alloc] initWithCapacity:1];
    [self initComponent];
    // Do any additional setup after loading the view.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)500*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self startSendData];
    });
}

-(void)startSendData{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.conectType == conectType_qrcode) {
                self.qrcodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",self.uuidString,self.wifiPwd] imageSize:self.qrcodeImageView.frame.size.width];
            }
            else if (self.conectType == conectType_Intelligent)
            {
                self.qrcodeImageView.image = [UIImage imageNamed:@"Qcord0"];
                [self startSetWifiLoop];//给设备设置wifi
                //发送声波
                [self soundStartSend];
                
                [self onBottomButtom1Press];//直接调用，不用点击“听到了”按钮
            }
            self.isFinish = NO;
        });
    });
    
    self.isRun = YES;
    self.isPrepared = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.isRun){//不断广播获取设置好WIFI的设备
            if(!self.isPrepared){
                [self prepareSocket];
//                self.isPrepared = YES;
            }
            usleep(1000000);
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define QRCODE_IMAGE_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 450:250)
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 100
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 288
#define WAITING_CONTENT_VIEW_HEIGHT 300

//-(void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    [self layoutAuto];
//}
//-(void)layoutAuto
//{
//    CGFloat TempW=self.view.width;
//    CGFloat TempH=64;
//    CGFloat TempX=0;
//    CGFloat TempY=80;
//    CGRect newRect=CGRectMake(TempX, TempY, TempW, TempH);
//    _rollingImage.frame=newRect;
//
//}
-(void)initComponent{

    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //导航栏
    self.navigationItem.title = CustomLocalizedString(@"connecting_WiFi", nil);
    
//    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
//    [topBar setBackButtonHidden:NO];
//    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
//        [topBar setRightButtonHidden:NO];
//        [topBar setRightButtonText:CustomLocalizedString(@"help", nil)];
//        [topBar.rightButton addTarget:self action:@selector(onHelpPress) forControlEvents:UIControlEventTouchUpInside];
//    }
//    [topBar setTitle:CustomLocalizedString(@"connecting_WiFi",nil)];
//    [self.view addSubview:topBar];
//    self.topBar = topBar;
    
    
    [self.view setBackgroundColor:XBgColor];
    
    UIImageView *qrcodeImage = [[UIImageView alloc] initWithFrame:CGRectMake((width-QRCODE_IMAGE_WIDTH_HEIGHT)/2, 20+NAVIGATION_BAR_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT)];
    if (self.conectType == conectType_qrcode) {
        qrcodeImage.layer.cornerRadius = 5.0;
        qrcodeImage.layer.borderColor = [XBlack CGColor];
        qrcodeImage.layer.borderWidth = 1.0;
        qrcodeImage.backgroundColor = XWhite;
        [self.view addSubview:qrcodeImage];//set wifi to add device by qr
    }
    self.qrcodeImageView = qrcodeImage;
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20, width-40, (height-(self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20))/2);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = XBlack;
    label.font = XFontBold_16;
    label.backgroundColor = [UIColor clearColor];
    if (self.conectType == conectType_qrcode) {
        label.text = CustomLocalizedString(@"qrcode_prompt", nil);
        [self.view addSubview:label];//set wifi to add device by qr
    }
    else
    {
        label.text = CustomLocalizedString(@"qrcode_prompt01", nil);
    }
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, label.frame.origin.y+label.frame.size.height, width, height-(label.frame.origin.y+label.frame.size.height))];
    
    UIButton *bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton1 addTarget:self action:@selector(onBottomButtom1Press) forControlEvents:UIControlEventTouchUpInside];
    bottomButton1.frame = CGRectMake((bottomView.frame.size.width-SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH)/2, (bottomView.frame.size.height-SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT)/2, SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH, SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT);
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [bottomButton1 setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [bottomButton1 setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [bottomButton1 setTitle:CustomLocalizedString(@"heard", nil) forState:UIControlStateNormal];
   
    [bottomView addSubview:bottomButton1];

    if (self.conectType == conectType_qrcode) {
        [self.view addSubview:bottomView];//set wifi to add device by qr
    }
    WaitingPageView *smartKeyPromptView = [[WaitingPageView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT - 64, width, height-NAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:smartKeyPromptView];
    self.smartKeyPromptView = smartKeyPromptView;
   
    
    if (self.conectType == conectType_qrcode) {
//        NSLog(@"停止滚动声波");
        [self.smartKeyPromptView pauseWaitRolling];
        [self.smartKeyPromptView setHidden:YES];//set wifi to add device by qr
    }else{
//        NSLog(@"开始滚动声波");
        [self.smartKeyPromptView startWaitRolling];
        [self.smartKeyPromptView setHidden:NO];//直接显示“正在连接WIFI”界面
    }
    
    //二维码帮助引导视图
    //set wifi to add device by qr
    UIButton * promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    promptButton.frame = CGRectMake(0, 0, width, height);
    promptButton.backgroundColor = XBlack_128;
    [promptButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *helpContent = [[UIImageView alloc] initWithFrame:CGRectMake((smartKeyPromptView.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (smartKeyPromptView.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2+NAVIGATION_BAR_HEIGHT, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
//    helpContent.backgroundColor=[UIColor redColor];
    UIImage *helpContentImage = [UIImage imageNamed:@"bg_smart_key_prompt.png"];
    helpContentImage = [helpContentImage stretchableImageWithLeftCapWidth:helpContentImage.size.width*0.5 topCapHeight:helpContentImage.size.height*0.5];
    helpContent.image = helpContentImage;
    [promptButton addSubview:helpContent];
    
    UIImageView *helpContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, WAITING_CONTENT_VIEW_WIDTH-20*2, WAITING_CONTENT_VIEW_HEIGHT/2)];
//    helpContentTop.backgroundColor=[UIColor greenColor];
    helpContentTop.contentMode = UIViewContentModeScaleAspectFit;
    helpContentTop.image = [UIImage imageNamed:@"img_scanning_code.png"];
    [helpContent addSubview:helpContentTop];
    
    
    UILabel *helpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpContentTop.frame.origin.y+helpContentTop.frame.size.height+10, WAITING_CONTENT_VIEW_WIDTH-20*2, 50)];
    helpContentLabel.backgroundColor = [UIColor clearColor];
    helpContentLabel.numberOfLines = 0;
    helpContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    helpContentLabel.textColor = XBlack;
    helpContentLabel.textAlignment = NSTextAlignmentCenter;
    helpContentLabel.text = CustomLocalizedString(@"set_scanning_code_prompt", nil);
    helpContentLabel.font = XFontBold_14;
    [helpContent addSubview:helpContentLabel];
   
    
    [self.view addSubview:promptButton];
    self.promptButton = promptButton;
    [self.promptButton setHidden:YES];
    
    self.isShowSuccessAlert = NO;
    
    //声波移动图 SoundWaves.png
//    _rollingImage=[[RollingImage alloc] init];
//    _rollingImage.backgroundColor=[UIColor redColor];
//    _rollingImage.rollingImage=[UIImage imageNamed:@"SoundWaves.png"];
//    [_rollingImage startRolling];
//    [self.view addSubview:_rollingImage];
    //    [_rollingImage release];
    
    
    //倒计时 label
    UILabel *timeLb = [[UILabel alloc ] initWithFrame:CGRectMake((self.smartKeyPromptView.frame.size.width-38)/2, self.smartKeyPromptView.frame.size.height/2+20+20, 38, 38)];
    _timeLb.backgroundColor = [UIColor clearColor];
    _timeLb.text =CustomLocalizedString(@"110s", nil);
    timeLb.textAlignment = NSTextAlignmentCenter;
    timeLb.textColor = [UIColor blackColor];
    [self.view addSubview:timeLb];
    _timeLb = timeLb;
   
    _timeLb.frame = [self.smartKeyPromptView convertRect:_timeLb.frame toView:self.view];
    
}

-(void)onHelpPress{//set wifi to add device by qr
    [self.promptButton setHidden:NO];
}

-(void)dismissView{//set wifi to add device by qr
    [self.promptButton setHidden:YES];
}
- (void)backClick{
    if (self.conectType == conectType_qrcode){//set wifi to add device by qr
        self.qrCodeController.isSetWifiToAddDeviceByQR = YES;
    }else{ //智能连机 1-二维码扫描 0-智能联机
        [self qrCodeNextGoBack];
        return;
    }
    
}

#pragma mark 点击返回上一界面 提示是否退出添加
-(void)qrCodeNextGoBack{
    YMsgBox *yBox = [[YMsgBox alloc] init];
    yBox.yMsgTextField.secureTextEntry = YES;
    yBox.yMsgShowAeroGlass = YES;//高斯效果
    [yBox addTarget:self withAction:@selector(qrCodeVCEitherExitAddDevices:) forEvent:YMsgBoxMsgTypeButtonBeClick];
    yBox.yMsgTitle = [YFonc gtTextWithString:CustomLocalizedString(@"give_up_add_device", nil)
                                   withColor:[UIColor blackColor]
                                    withFont:[UIFont systemFontOfSize:18]
                               withAlignment:NSTextAlignmentCenter];
    yBox.yMsgTextFieldBorderColor=RGBA(62,156,254,1.0);
    yBox.yMsgTextFieldBottomLineColor=[UIColor clearColor];
    yBox.yMsgButtonBorderColor=RGBA(211,211,212,1.0);
    UIButton *exitBtn= [[UIButton alloc ]init];
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [exitBtn setTitle:CustomLocalizedString(@"cancel",nil) forState:UIControlStateNormal];
    [exitBtn setTitleColor:UIColorFromRGB(0xa9a9a9) forState:UIControlStateNormal];
    
    UIButton *goOnAddBtn= [[UIButton alloc ]init];
    goOnAddBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [goOnAddBtn setTitle:CustomLocalizedString(@"abandon",nil) forState:UIControlStateNormal];
    [goOnAddBtn setTitleColor:UIColorFromRGB(0x3e9cfe) forState:UIControlStateNormal];
    yBox.yMsgButtons = @[exitBtn,goOnAddBtn];
    [yBox showMsgBoxInViewController:self];
    [yBox showMsgBoxInViewController:self.navigationController];
    //YMsgBox hideBox
}

-(void)qrCodeVCEitherExitAddDevices:(YMsgBox*)yBox{
    
    if(yBox.yMsgButtonIndex ==-1 ){//点击空白处
        return;
    }else if(yBox.yMsgButtonIndex == 0){
        
        NSLog(@"取消");

        [yBox hideMsgBox]; //隐藏输入框  取消按钮被点击
        
    }else if(yBox.yMsgButtonIndex == 1){ // 放弃按钮被点击
        [yBox hideMsgBox]; //隐藏输入框
        self.view = nil;
        NSLog(@"放弃");
        _shouldExit=YES;
        [self exitSendAllData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)500*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSLog(@"popToRootViewControllerAnimated");
        });
    }
}

-(void)exitSendAllData{
    
    NSLog(@"exitSendAllData  Start");
    
    NSLog(@"exitSendAllData  111");
    if (self.conectType == conectType_Intelligent){//startSetWifiLoop
        if (_context){
            elianStop(_context);
            elianDestroy(_context);
            _context = NULL;
        }
    }
    NSLog(@"exitSendAllData  222");
    self.isFinish = YES;
    self.isRun = NO;
    self.isWaiting = NO;//isWaiting is NO
    if(self.socket){
        [self.socket close];
        self.socket=nil;
    }
    
    [self soundStopSend];
    NSLog(@"soundStopSend");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self exitSoundSDK];
        NSLog(@"exitSoundSDK");
    });
    NSLog(@"exitSendAllData  End");
}

#pragma mark - 使用110秒来进行空中发包，给设备设置wifi
-(void)onBottomButtom1Press{
    [self.smartKeyPromptView setHidden:NO];
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        [self.topBar setRightButtonHidden:YES];
    }
    self.isWaiting = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        _isWaiting=NO;
//        [NSThread sleepForTimeInterval:2.0];
        
        while(self.isWaiting){
            NSLog(@"%i",_index);
            dispatch_async(dispatch_get_main_queue(), ^{
                _timeLb.text = [NSString stringWithFormat:@"%zds",(110-_index)];
            });
            _index++;
            if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                if (_index >= 21 && _index <= 30)
                {
                    if (_index == 21)
                    {
                        elianStop(_context);
                    }
                }
                else if (_index >= 51 && _index <= 60)
                {
                    if (_index == 51)
                    {
                        elianStop(_context);
                    }
                }
                else if (_index >= 81)
                {
                    if (_index == 81)
                    {
                        elianStop(_context);
                    }
                }
                else
                {
                    if (_index==31 || _index==61)
                    {
                        elianStart(_context);
                    }
                }
                if(_index>=110)
                {//110
                    break;
                }
            }
            else
            {
                if(_index>=60)
                {//60
                    break;
                }
            }
            [NSThread sleepForTimeInterval:1.0];
        }
//        elianStop(_context);
        [self soundStopSend];
        if(!self.isFinish){
            if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                if (_context){
                    elianStop(_context);
                    elianDestroy(_context);
                    _context = NULL;
                }//设置WIFI失败，停止
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smartKeyPromptView setHidden:NO];
                [self popTipsView];//弹出连接失败的提示
                //弹出添加失败的提示
                self.isWaiting = NO;//isWaiting is NO
            });
            
        }
    });
}

#pragma mark  添加失败 提示
-(void)popTipsView{
    
    self.addDevicesPopTipsView = [[AddDevicesPopTipsView alloc] init];
    self.addDevicesPopTipsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.addDevicesPopTipsView.delegate = self;
    //文字
    NSArray *arr = @[CustomLocalizedString(@"1. Please confirm that the entered WiFi password is correct",nil),CustomLocalizedString(@"2. Camera doesn't support 5G network",nil),CustomLocalizedString(@"3. Current environment is more noisy and affecting sonic wave",nil),CustomLocalizedString(@"4. The current network environment is poor.",nil)];
    NSMutableArray *strArr = [NSMutableArray arrayWithArray:arr];
    
    NSArray *btnArr = @[CustomLocalizedString(@"try_again",nil),CustomLocalizedString(@"To use wired connection",nil)];
    NSMutableArray *btnArray = [NSMutableArray arrayWithArray:btnArr];
    
    [self.addDevicesPopTipsView setUpUIWithTitle:CustomLocalizedString(@"connection_failed",nil) numberOfLabel:(int)strArr.count lbTextArr:strArr numberOfBtn:(int)btnArray.count btnTextArr:btnArray eitherHaveImgView:NO];
    
    [self.addDevicesPopTipsView.closeBtn addTarget:self action:@selector(qrClosePopView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addDevicesPopTipsView];
    
    self.addDevicesPopTipsView.blackBgView.hidden=NO;
    self.addDevicesPopTipsView.blackBgView.alpha=0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.addDevicesPopTipsView.blackBgView.alpha=1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)qrClosePopView{
    
    self.addDevicesPopTipsView.blackBgView.alpha=1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.addDevicesPopTipsView.blackBgView.alpha=0.0;
    } completion:^(BOOL finished) {
        self.addDevicesPopTipsView.blackBgView.hidden=YES;
    }];
    [self.addDevicesPopTipsView removeFromSuperview];
}

#pragma mark -
-(void)buttonBePressed:(UIButton*)btn{
    //再试一次
    switch (btn.tag-2017) {
        case 0:
        {
        
         SetUpWiFiViewController *setUpVC =(SetUpWiFiViewController*)[self.navigationController.viewControllers objectAtIndex:2];
            _shouldExit=YES;
            [self.navigationController popToViewController:setUpVC animated:YES];

        }
            
            break;
            //尝试有线连接
        case 1:
        {
            PrepareDevicesToConnectViewController *prepareVC = [[PrepareDevicesToConnectViewController alloc] init];
            prepareVC.shouldPopToRoot=YES;
            _shouldExit=YES;
            [self.navigationController pushViewController:prepareVC animated:YES];
        
        }
            
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - 搜索到设备，弹出添加设备提示
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    
//    
//    if (alertView.tag==ALERT_TAG_SET_FAILED) {
//        if(buttonIndex==0){
//            
//        }
//    }else if(alertView.tag==ALERT_TAG_SET_SUCCESS){
//        if(buttonIndex==0){
//            self.address = [self.addresses objectForKey:self.contactID];
//            
//            if (self.flag == 0) {//设备未初始化过密码
//                CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
//                [createInitPasswordController setContactId:self.contactID];
//                createInitPasswordController.isPopRoot = YES;
//                [createInitPasswordController setAddress:self.address];
//                [self.navigationController pushViewController:createInitPasswordController animated:YES];
//                [createInitPasswordController release];
//                
//            }else{
//                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//                [addContactNextController setContactId:self.contactID];
//                addContactNextController.isPopRoot = YES;
//                addContactNextController.isInFromQRCodeNextController = YES;
//                addContactNextController.inType = 0;
//                [self.navigationController pushViewController:addContactNextController animated:YES];
//                [addContactNextController release];
//            }
//        }
//    }
//}


#pragma mark - GCDAsyncUdpSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"udpSocket did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose error %@", error);
}

#pragma mark 搜索设备
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if (data) {
        
        NSLog(@"udpSocket  收到数据");
        
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0]==1){
            NSString *host = nil;
            uint16_t port = 0;
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            
            int contactId = *(int*)(&receiveBuffer[16]);
            int type = *(int*)(&receiveBuffer[20]);
            int flag = *(int*)(&receiveBuffer[24]);
            
            self.contactID = [NSString stringWithFormat:@"%d",contactId];
            self.type = type;
            self.flag = flag;
            [self.addresses setObject:host forKey:[NSString stringWithFormat:@"%i",contactId]];
            
            
            if(self.isShowSuccessAlert){
                return;
            }
            
            
            if(self.isWaiting){
                self.isWaiting = NO;//isWaiting is NO
                self.isShowSuccessAlert = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isFinish = YES;
                    [self.smartKeyPromptView setHidden:NO];
                    if (!self.isNotFirst) {
                        if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                            if (_context){
                                elianStop(_context);
                                elianDestroy(_context);
                                _context = NULL;
                            }//设置WIFI成功，停止
                        }
                        
                        self.address = [self.addresses objectForKey:self.contactID];
                        
                        if (self.flag == 0) {//设备未初始化过密码
                            CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
                            [createInitPasswordController setContactId:self.contactID];
                            createInitPasswordController.isPopRoot = YES;
                            [createInitPasswordController setAddress:self.address];
                            _shouldExit=YES;
                            [self.navigationController pushViewController:createInitPasswordController animated:YES];
                            
                            
                        }else{ //初始化过 或者有默认密码
                            AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
                            [addContactNextController setContactId:self.contactID];
                            addContactNextController.isPopRoot = YES;
                            addContactNextController.isInFromQRCodeNextController = YES;
                            addContactNextController.inType = 0;
                            _shouldExit=YES;
                            [self.navigationController pushViewController:addContactNextController animated:YES];
                            
                        }
                    
                        self.isNotFirst = YES;
                    }
                });
                
            }
        }
    }
}


#pragma mark - 空中发包，给设备设置wifi
- (void)startSetWifiLoop
{
    //ssid
    const char *ssid = [self.uuidString cStringUsingEncoding:NSUTF8StringEncoding];
    //authmode
    int authmode = 9;//delete
    //pwd
    const char *password = [self.wifiPwd cStringUsingEncoding:NSUTF8StringEncoding];//NSASCIIStringEncoding
    //target
    unsigned char target[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    
    
    _context = elianNew(NULL, 0, target, ELIAN_SEND_V1 | ELIAN_SEND_V4);
    elianPut(_context, TYPE_ID_AM, (char *)&authmode, 1);//delete
    elianPut(_context, TYPE_ID_SSID, (char *)ssid, strlen(ssid));
    elianPut(_context, TYPE_ID_PWD, (char *)password, strlen(password));
    
    elianStart(_context);
}


#pragma mark - 无用
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


#pragma mark - 屏幕
-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
