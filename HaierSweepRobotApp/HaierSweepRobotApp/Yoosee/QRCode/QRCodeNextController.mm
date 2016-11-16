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

//声波配网
#import "LSemTMFSet.h"

@interface QRCodeNextController ()<LSemTMFSetDelegate>{
    void *_context;
    
    //声波配网
    CGFloat _timeSendTotal;
    BOOL _needTiming;
}
@property (nonatomic,copy) NSString *contactID;
@property (nonatomic,assign) NSInteger flag;
@property (nonatomic,assign) NSInteger type;
@property (strong,nonatomic) NSMutableDictionary *addresses;

@property (nonatomic,copy) NSString *address;

@end

@implementation QRCodeNextController

/**
 声波发送不能无限时的发送,比较合理的方式是90秒之后若还没有成功就停止发送,
 且弹出声波配对失败的对话框,此处不涉及绚丽的界面,只用控制台输出
 **/
#pragma mark - 开始计时
-(void)startTiming{
    _timeSendTotal=0;
    _needTiming=YES;
    
    //_buttonSoundSendStart.enabled=NO;
    //_buttonSoundSendStop.enabled=YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (_needTiming) {
            _timeSendTotal+=0.1;
            if (_timeSendTotal>=90) {
                [self stopTiming];
                [self soundSendStop];
                NSLog(@"声波发送时间达上限,停止发送");
            }
            [NSThread sleepForTimeInterval:0.1];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //_buttonSoundSendStart.enabled=YES;
            //_buttonSoundSendStop.enabled=NO;
        });
        NSLog(@"计时已停止");
    });
}
#pragma mark - 停止计时
-(void)stopTiming{
    _needTiming=NO;
}
#pragma mark - 声波SDK初始化
-(void)soundInit{
    [[LSemTMFSet sharedInstance] setDelegate:self];
    
    int soundCode=[[LSemTMFSet sharedInstance]initSDK:@"gwelltimes"
                                               client:@"gwelltimes"
                                         productModel:@"gm8135s-8136"
                                              license:@"11625ae8060111e6b5123e1d05defe78"];
    NSLog(@"声波初始化的结果码:%d",soundCode);
    if (soundCode!=1) {//如果不能正常使用SDK,就不让发送SDK
        //_buttonSoundSendStart.enabled=NO;
        //_buttonSoundSendStop.enabled=NO;
    }
}
#pragma mark - 声波开始发送
-(void)soundSendStart{
    NSLog(@"开始发送声波");
    //NSString* strWiFiName=_textFieldWiFi.text;
    //NSString* strWiFiPwd=_textFieldWiFiPwd.text;
    
    NSString* strWiFiName=self.uuidString;
    NSString* strWiFiPwd=self.wifiPwd;
    NSLog(@"要发送的WiFi是:%@,其密码是:%@",strWiFiName,strWiFiPwd);
    [[LSemTMFSet sharedInstance] sendWiFiSet:strWiFiName password:strWiFiPwd];
}
#pragma mark - 声波停止发送
-(void)soundSendStop{
    NSLog(@"停止发送声波");
    [self stopTiming];
    [[LSemTMFSet sharedInstance] stopSend];
    [[LSemTMFSet sharedInstance] cancleConnectTimer];
}
#pragma mark - 声波SDK退出和释放
-(void)soundExit{
    NSLog(@"退出声波SDK");
    [self soundSendStop];
    [[LSemTMFSet sharedInstance] exitEMTMFSDK];
}
#pragma mark - 声波的几个协议
- (void)didSetWifiResultErrcode:(EMTMFErrcodeType*)errcode content:(NSString*)content{
    if (errcode==(EMTMFErrcodeType*)EMTMFErrcodeType_SUCESS){
        NSLog(@"声波配对成功");
        [self soundSendStop];
    }else{
        NSLog(@"声波配对失败,重新发送");
        [self soundSendStart];
    }
}
- (void)didFSKSendingComplete{
    [[LSemTMFSet sharedInstance] startConnectTimeOutListener:1];//暂停1秒,然后继续发送声波
}
-(void)didSDKErrcode:(int) errCode errMsg:(NSString*)errMsg{
    NSLog(@"声波初始化结果码:%d,结果码解释:%@",errCode,errMsg);
}









-(void)dealloc{
    
    /*
    //声波配网
    [self stopTiming];
    [self soundExit];
    */
    
    
    
    [self.uuidString release];
    [self.wifiPwd release];
    [self.smartKeyPromptView release];
    [self.qrcodeImageView release];
    [self.addresses release];
    [self.promptButton release];//set wifi to add device by qr
    [self.topBar release];//set wifi to add device by qr
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated{
    if (self.conectType == conectType_Intelligent){//startSetWifiLoop
        if (_context){
            elianStop(_context);
            elianDestroy(_context);
            _context = NULL;
        }
    }
    
    self.isWaiting = NO;//isWaiting is NO
    self.isFinish = YES;
    self.isRun = NO;
    if(self.socket){
        [self.socket close];
        self.socket=nil;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if (self.conectType == conectType_qrcode) {
        self.qrcodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",self.uuidString,self.wifiPwd] imageSize:self.qrcodeImageView.frame.size.width];
    }
    else if (self.conectType == conectType_Intelligent)
    {
        self.qrcodeImageView.image = [UIImage imageNamed:@"Qcord0"];
        [self startSetWifiLoop];//给设备设置wifi
        
        [self onBottomButtom1Press];//直接调用，不用点击“听到了”按钮
    }
    self.isFinish = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    self.isRun = YES;
    self.isPrepared = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.isRun){//不断广播获取设置好WIFI的设备
            if(!self.isPrepared){
                [self prepareSocket];
            }
            usleep(1000000);
        }
    });
}

-(BOOL)prepareSocket{
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    
    if (![socket bindToPort:9988 error:&error])
    {
        //NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;
    self.isPrepared = YES;
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addresses = [[NSMutableDictionary alloc] initWithCapacity:1];
    [self initComponent];

    
    /*
    //声波配网
    [self soundInit];

    [self startTiming];
    [self soundSendStart];
     */
    
    // Do any additional setup after loading the view.
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

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //ljp
    /*
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        [topBar setRightButtonHidden:NO];
        [topBar setRightButtonText:CustomLocalizedString(@"help", nil)];
        [topBar.rightButton addTarget:self action:@selector(onHelpPress) forControlEvents:UIControlEventTouchUpInside];
    }
    [topBar setTitle:CustomLocalizedString(@"add_new_device",nil)];
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
     */
    
    self.navigationItem.title = CustomLocalizedString(@"add_new_device",nil);
    
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:CustomLocalizedString(@"help", nil) block:^{
            [self onHelpPress];
        }];
    }
    
    
    [self.view setBackgroundColor:XBgColor];
    
    UIImageView *qrcodeImage = [[UIImageView alloc] initWithFrame:CGRectMake((width-QRCODE_IMAGE_WIDTH_HEIGHT)/2, 20, QRCODE_IMAGE_WIDTH_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT)];
    if (self.conectType == conectType_qrcode) {
        qrcodeImage.layer.cornerRadius = 5.0;
        qrcodeImage.layer.borderColor = [XBlack CGColor];
        qrcodeImage.layer.borderWidth = 1.0;
        qrcodeImage.backgroundColor = XWhite;
        [self.view addSubview:qrcodeImage];//set wifi to add device by qr
    }
    self.qrcodeImageView = qrcodeImage;
    [qrcodeImage release];
    
    
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
    
    [label release];
    [bottomView release];
    
    UIView *smartKeyPromptView = [[WaitingPageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:smartKeyPromptView];
    self.smartKeyPromptView = smartKeyPromptView;
    [smartKeyPromptView release];
    
    if (self.conectType == conectType_qrcode) {
        [self.smartKeyPromptView setHidden:YES];//set wifi to add device by qr
    }else{
        [self.smartKeyPromptView setHidden:NO];//直接显示“正在连接WIFI”界面
    }
    
    //二维码帮助引导视图
    //set wifi to add device by qr
    UIButton * promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    promptButton.frame = CGRectMake(0, 0, width, height);
    promptButton.backgroundColor = XBlack_128;
    [promptButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *helpContent = [[UIImageView alloc] initWithFrame:CGRectMake((smartKeyPromptView.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (smartKeyPromptView.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2+NAVIGATION_BAR_HEIGHT, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    UIImage *helpContentImage = [UIImage imageNamed:@"bg_smart_key_prompt.png"];
    helpContentImage = [helpContentImage stretchableImageWithLeftCapWidth:helpContentImage.size.width*0.5 topCapHeight:helpContentImage.size.height*0.5];
    helpContent.image = helpContentImage;
    [promptButton addSubview:helpContent];
    
    UIImageView *helpContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, WAITING_CONTENT_VIEW_WIDTH-20*2, WAITING_CONTENT_VIEW_HEIGHT/2)];
    helpContentTop.contentMode = UIViewContentModeScaleAspectFit;
    helpContentTop.image = [UIImage imageNamed:@"img_scanning_code.png"];
    [helpContent addSubview:helpContentTop];
    [helpContentTop release];
    
    UILabel *helpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpContentTop.frame.origin.y+helpContentTop.frame.size.height+10, WAITING_CONTENT_VIEW_WIDTH-20*2, 50)];
    helpContentLabel.backgroundColor = [UIColor clearColor];
    helpContentLabel.numberOfLines = 0;
    helpContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    helpContentLabel.textColor = XBlack;
    helpContentLabel.textAlignment = NSTextAlignmentCenter;
    helpContentLabel.text = CustomLocalizedString(@"set_scanning_code_prompt", nil);
    helpContentLabel.font = XFontBold_14;
    [helpContent addSubview:helpContentLabel];
    [helpContentLabel release];
    [helpContent release];
    
    [self.navigationController.view addSubview:promptButton];
    self.promptButton = promptButton;
    [self.promptButton setHidden:YES];
    
    self.isShowSuccessAlert = NO;
}

-(void)onHelpPress{//set wifi to add device by qr
    [self.promptButton setHidden:NO];
}

-(void)dismissView{//set wifi to add device by qr
    [self.promptButton setHidden:YES];
}

-(void)onBackPress{
    if (self.conectType == conectType_qrcode){//set wifi to add device by qr
        self.qrCodeController.isSetWifiToAddDeviceByQR = YES;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 使用90秒来进行空中发包，给设备设置wifi
-(void)onBottomButtom1Press{
    [self.smartKeyPromptView setHidden:NO];
    if (self.conectType == conectType_qrcode) {//set wifi to add device by qr
        [self.topBar setRightButtonHidden:YES];
    }
    
    self.isWaiting = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int index = 0;
        while(self.isWaiting){
            DLog(@"%i",index);
            index++;
            if (self.conectType == conectType_Intelligent){//startSetWifiLoop
                if (index >= 21 && index <= 30)
                {
                    if (index == 21)
                    {
                        elianStop(_context);
                    }
                }
                else if (index >= 51 && index <= 60)
                {
                    if (index == 51)
                    {
                        elianStop(_context);
                    }
                }
                else if (index >= 81)
                {
                    if (index == 81)
                    {
                        elianStop(_context);
                    }
                }
                else
                {
                    if (index==31 || index==61)
                    {
                        elianStart(_context);
                    }
                }
                if(index>=90)
                {//90
                    break;
                }
            }
            else
            {
                if(index>=60)
                {//60
                    break;
                }
            }
            sleep(1.0);
        }
        
        
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
                
                //QRCodeController *qrcodeController = [self.navigationController.viewControllers objectAtIndex:1];
                
                
                for (UIViewController *viewController in self.navigationController.viewControllers) {
                    if ([viewController isKindOfClass:[QRCodeController class]]) {
                        QRCodeController *qrVC = (QRCodeController *)viewController;
                        qrVC.isFailForConnectingWIFI = YES;
                        [self.navigationController popToViewController:qrVC  animated:YES];
                        break;
                    }
                }
                
//                AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                QRCodeController *qrVC = tempDelegate.qrVC;
//
//                qrVC.isFailForConnectingWIFI = YES;
//                [self.navigationController popToViewController:qrVC animated:YES];
                self.isWaiting = NO;//isWaiting is NO
            });
            
        }
    });
}

#pragma mark - 搜索到设备，弹出添加设备提示
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (alertView.tag==ALERT_TAG_SET_FAILED) {
        if(buttonIndex==0){
            
        }
    }else if(alertView.tag==ALERT_TAG_SET_SUCCESS){
        if(buttonIndex==0){
            self.address = [self.addresses objectForKey:self.contactID];
            NSArray *stringArray = [self.address componentsSeparatedByString:@"."];
            NSString *targetAdress = [NSString stringWithFormat:@"%@",[stringArray lastObject]];
            
            if (self.flag == 0) {//设备未初始化过密码
                CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
                [createInitPasswordController setContactId:self.contactID];
                createInitPasswordController.isPopRoot = YES;
                createInitPasswordController.contactIp = targetAdress;
                [createInitPasswordController setAddress:self.address];
                [self.navigationController pushViewController:createInitPasswordController animated:YES];
                [createInitPasswordController release];
                
            }else{
//                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//                [addContactNextController setContactId:self.contactID];
//                addContactNextController.isPopRoot = YES;
//                addContactNextController.isInFromQRCodeNextController = YES;
//                addContactNextController.inType = 0;
//                [self.navigationController pushViewController:addContactNextController animated:YES];
//                [addContactNextController release];
                
                LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
                [addContactNextController setContactId:self.contactID];
                addContactNextController.isPopRoot = YES;
                addContactNextController.isInFromQRCodeNextController = YES;
                addContactNextController.inType = 0;
                [self.navigationController pushViewController:addContactNextController animated:YES];
                [addContactNextController release];
            }
        }
    }
}


#pragma mark - GCDAsyncUdpSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"error %@", error);
}

#pragma mark 搜索设备
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if (data) {
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
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"set_wifi_success_title", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                        alert.tag = ALERT_TAG_SET_SUCCESS;
                        [alert show];
                        [alert release];
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
