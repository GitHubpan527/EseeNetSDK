//
//  SetUpWiFiViewController.m
//  Yoosee
//
//  Created by apple on 16/10/17.
//  Copyright © 2016年 lk. All rights reserved.
//

//使用WiFi连接

#import "SetUpWiFiViewController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "CustomTextField.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "DevicesReadyViewController.h"
#import "YMsgBox.h"
#import "AddDevicesPopTipsView.h"
#import "QRCodeNextController.h"

@interface SetUpWiFiViewController ()

@end

@implementation SetUpWiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];

}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupWiFiNetWorkChange:) name:NET_WORK_CHANGE object:nil];
    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NET_WORK_CHANGE object:nil];
}

-(void)setupWiFiNetWorkChange:(NSNotification*)notification{
    
    NSDictionary *parameter = [notification userInfo];
    int status = [[parameter valueForKey:@"status"] intValue];
    NSString *ssid = [parameter valueForKey:@"AppWifiName"];
        if(ssid.length != 0){
            self.aWiFiNameLb.text= ssid;
            self.passwordTF.text=[self wifiReadWiFiPwdWithName:ssid];
            self.passwordTF.secureTextEntry = YES;
        }else{
            
            self.aWiFiNameLb.text= @"";
            self.passwordTF.text = @"";
        }
        
}

-(void)setUpUI{
    //view的背景色
    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //导航栏
    self.navigationItem.title = CustomLocalizedString(@"ready_for_connecting_WiFi", nil);
    
//    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
//    [topBar setTitle:CustomLocalizedString(@"ready_for_connecting_WiFi",nil)];
//    [topBar setBackButtonHidden:NO];
//    [topBar.backButton addTarget:self action:@selector(goBackTo) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:topBar];
//    self.setUpWiFiTopbar = topBar;
    
    //摄像机需要连接的WiFi提示文字
    CGFloat WiFiLbWidth = 280;
    CGFloat WiFiLbHeight = 30;
    CGFloat WiFiLbY = 65/2.0+CGRectGetMaxY(self.setUpWiFiTopbar.frame);
    CGFloat WiFiLbX = (width-WiFiLbWidth)/2.0;

    self.needWiFiTipsLb = [[UILabel alloc] init];
    self.needWiFiTipsLb.frame = CGRectMake(WiFiLbX, WiFiLbY, WiFiLbWidth, WiFiLbHeight);
    self.needWiFiTipsLb.text = CustomLocalizedString(@"camera_needs_to_connect_to_WIFI", nil);
    self.needWiFiTipsLb.font = [UIFont boldSystemFontOfSize:21];
    self.needWiFiTipsLb.textAlignment = NSTextAlignmentCenter;
    self.needWiFiTipsLb.textColor = UIColorFromRGB(0x494949);
    [self.view addSubview:self.needWiFiTipsLb];
    
    
    //显示不支持5G的label
    CGFloat no5GNameWidth = 200;
    CGFloat no5GNameHeight = 30;
    CGFloat no5GNameY = 20/2.0 +CGRectGetMaxY(self.needWiFiTipsLb.frame);
    CGFloat no5GNameX = (width - no5GNameWidth)/2.0;
    
    self.no5GWiFiTipsLb = [[UILabel alloc] init];
    self.no5GWiFiTipsLb.textAlignment = NSTextAlignmentCenter;
    self.no5GWiFiTipsLb.frame = CGRectMake(no5GNameX,no5GNameY, no5GNameWidth, no5GNameHeight);
    self.no5GWiFiTipsLb.textColor = UIColorFromRGB(0x000000);
    self.no5GWiFiTipsLb.font = [UIFont systemFontOfSize:12];
    self.no5GWiFiTipsLb.text = CustomLocalizedString(@"not_support_5G_network", nil);
    [self.view addSubview:self.no5GWiFiTipsLb];
    
    //显示WiFi名字的label
    CGFloat wifiNameWidth = 200;
    CGFloat wifiNameHeight = 30;
    CGFloat wifiNameY = 30/2.0 +CGRectGetMaxY(self.no5GWiFiTipsLb.frame);
    CGFloat wifiNameX = (width - wifiNameWidth)/2.0;
    
    self.aWiFiNameLb = [[UILabel alloc] init];
    self.aWiFiNameLb.textAlignment = NSTextAlignmentCenter;
    self.aWiFiNameLb.text = [AppDelegate sharedDefault].appWifiName;
    self.aWiFiNameLb.frame = CGRectMake(wifiNameX, wifiNameY, wifiNameWidth, wifiNameHeight);
    self.aWiFiNameLb.textColor = NavigationBarColor;
    self.aWiFiNameLb.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.aWiFiNameLb];
   
    
    //密码输入框
    CGFloat passwordTFWidth = 600/2.0;
    CGFloat passwordTFHeight = 97/2.0;
    CGFloat passwordTFY = 20/2.0 +CGRectGetMaxY(self.aWiFiNameLb.frame);
    CGFloat passwordTFX = (width - passwordTFWidth)/2.0;
    
    self.passwordTF = [[CustomTextField alloc] init];
    self.passwordTF.frame = CGRectMake(passwordTFX,passwordTFY, passwordTFWidth, passwordTFHeight);
    self.passwordTF.textColor = UIColorFromRGB(0xa9a9a9);
    self.passwordTF.font = [UIFont systemFontOfSize:15];
    self.passwordTF.placeholder = CustomLocalizedString(@"input_wifi_password", nil);
    self.passwordTF.secureTextEntry = YES;
    self.passwordTF.delegate = self;
    [self.view addSubview:self.passwordTF];

    self.passwordTF.adjustsFontSizeToFitWidth = YES;
    self.passwordTF.layer.borderColor=[UIColorFromRGB(0x5586f6) CGColor];
    self.passwordTF.layer.borderWidth= 1.0f;
    
    CGFloat leftImageViewWidth = 30/2.0;
    CGFloat leftImageViewHeight = 34/2.0;

    //输入框左边图片
    UIImageView *leftImg = [[UIImageView  alloc] init];
    leftImg.frame = CGRectMake(0, 0, leftImageViewWidth, leftImageViewHeight);
    leftImg.image = [UIImage imageNamed:@"password_cannot_see_key.png"];
    self.passwordTF.leftView = leftImg;
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways;
    
    //输入框右边图片
    UIButton *rightBtn = [[UIButton  alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 47/2.0, 27/2.0);
    [rightBtn setImage:[UIImage imageNamed:@"password_cannot_see.png"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(seePassword:) forControlEvents:UIControlEventTouchUpInside];
    self.passwordTF.rightView = rightBtn;
    self.passwordTF.rightViewMode = UITextFieldViewModeAlways;
   
    //下方对wifi要求文字提示
    self.tipsBtn=[[UIButton alloc] init];
    self.tipsBtn.frame = CGRectMake((width-200)/2.0, 220/2.0+CGRectGetMaxY(self.passwordTF.frame),200, 40);
    
    [self.tipsBtn addTarget:self
                          action:@selector(wantedWhichWiFi)
                forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString* maStr=[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"what_requirement_on_WiFi_does_camera_have",nil)];
    NSRange maStrRange=NSMakeRange(0, maStr.length);
    [maStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:maStrRange];
    
    [maStr addAttribute:NSForegroundColorAttributeName
                  value:NavigationBarColor
                  range:maStrRange];
    [maStr addAttribute:NSUnderlineStyleAttributeName
                  value:@1.0
                  range:maStrRange];
    self.tipsBtn.backgroundColor=[UIColor clearColor];
    [self.tipsBtn setAttributedTitle:maStr forState:UIControlStateNormal];
    [self.view addSubview:self.tipsBtn];
    
    
    
    //下一步按钮
    CGFloat buttonWidth = 600/2.0;
    CGFloat buttonHeight = 95/2.0;
    CGFloat wiredAddButtonX = (width-buttonWidth)/2.0;
    CGFloat wiredAddButtonY = CGRectGetMaxY(self.view.frame)-112/2.0-buttonHeight - 64;
//    CGFloat wiredAddButtonY = CGRectGetMaxY(self.tipsBtn.frame)+35/2.0;
    
    self.nextStepBtn = [self createButtonFrame:CGRectMake(wiredAddButtonX, wiredAddButtonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"next",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(nextStep)];
    self.nextStepBtn.backgroundColor = NavigationBarColor;
//    [self.nextStepBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//    [self.nextStepBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
    self.nextStepBtn.layer.cornerRadius=20.0f;
    [self.view addSubview:self.nextStepBtn];
    
    //获取wifi名字和上一次输入过的密码
    [self getWifiNameAndPassword];

}

//获取手机已连接wifi
-(void)getWifiNameAndPassword{
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    if(ssid.length!=0){
        self.aWiFiNameLb.text = ssid;
        self.passwordTF.text=[self wifiReadWiFiPwdWithName:ssid];
        self.passwordTF.secureTextEntry = YES;

    }else{
        
        self.aWiFiNameLb.text = @"";
        self.passwordTF.text = @"";
    }

}

#pragma mark - WIFI历史读取
-(NSString*)wifiReadWiFiPwdWithName:(NSString*)name{
    NSUserDefaults* udt=[NSUserDefaults standardUserDefaults];
    NSDictionary* dic=[udt objectForKey:@"WIFI_History"];
    NSString* wifiPwd=@"";
    if (dic) {
        wifiPwd=dic[name];
        if (!wifiPwd) {
            wifiPwd=@"";
        }
    }
    return wifiPwd;
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)ifnam));
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

#pragma mark - WIFI历史保存
-(void)wifiSaveWiFiHistoryWithName:(NSString*)name withPwd:(NSString*)pwd{
    NSUserDefaults* udt=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dic=[[NSMutableDictionary alloc] initWithDictionary:[udt objectForKey:@"WIFI_History"]];
    if (!dic) {
        dic=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    NSString* wifiName=name;
    if (!wifiName) {
        wifiName=@"";
    }
    
    NSString* wifiPwd=pwd;
    if (!wifiPwd) {
        wifiPwd=@"";
    }
    [dic setObject:wifiPwd forKey:wifiName];
    
    [udt setObject:dic forKey:@"WIFI_History"];
}

#pragma mark - 创建按钮的方法
-(UIButton *)createButtonFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font target:(id)target action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = UIColorFromRGB(0x5586f6);
    btn.frame=frame;
    
    if (font)
    {
        btn.titleLabel.font=font;
    }
    
    if (title)
    {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (color)
    {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
    if (target&&action)
    {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    return btn;
}

//摄像机对wifi的要求 弹框文字提示
-(void)wantedWhichWiFi{
    
    [self popTipsView];
}

#pragma mark  添加失败 提示
-(void)popTipsView{
    
    self.setWiFiAddDevicesPopTipsView = [[AddDevicesPopTipsView alloc] init];
    self.setWiFiAddDevicesPopTipsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.setWiFiAddDevicesPopTipsView.delegate = self;
    //文字
    NSArray *arr = @[CustomLocalizedString(@"setupWiFi_text1",nil),
                     CustomLocalizedString(@"setupWiFi_text2",nil),
                     CustomLocalizedString(@"setupWiFi_text3",nil),
                     CustomLocalizedString(@"setupWiFi_text4",nil),
                    ];
    NSMutableArray *strArr = [NSMutableArray arrayWithArray:arr];
    
    NSArray *btnArr = @[CustomLocalizedString(@"i_know",nil)];
    NSMutableArray *btnArray = [NSMutableArray arrayWithArray:btnArr];
    
    [self.setWiFiAddDevicesPopTipsView setUpUIWithTitle:CustomLocalizedString(@"what_requirement_on_WiFi_does_camera_have",nil) numberOfLabel:(int)strArr.count lbTextArr:strArr numberOfBtn:(int)btnArray.count btnTextArr:btnArray eitherHaveImgView:NO];
    
    [self.setWiFiAddDevicesPopTipsView.closeBtn addTarget:self action:@selector(qrClosePopView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.setWiFiAddDevicesPopTipsView];
    
    self.setWiFiAddDevicesPopTipsView.blackBgView.hidden=NO;
    self.setWiFiAddDevicesPopTipsView.blackBgView.alpha=0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.setWiFiAddDevicesPopTipsView.blackBgView.alpha=1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)qrClosePopView{
    
    self.setWiFiAddDevicesPopTipsView.blackBgView.alpha=1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.setWiFiAddDevicesPopTipsView.blackBgView.alpha=0.0;
    } completion:^(BOOL finished) {
        self.setWiFiAddDevicesPopTipsView.blackBgView.hidden=YES;
    }];
    [self.setWiFiAddDevicesPopTipsView removeFromSuperview];
}

#pragma mark -
-(void)buttonBePressed:(UIButton*)btn{
    
    switch (btn.tag-2017) {
        case 0:
        {
            [self qrClosePopView];
        }
            break;
        default:
            break;
    }
    
}

//下一步 去到设备就绪页面
-(void)nextStep{
    
    //保存WiFi历史记录
    NSString *ssidString = self.aWiFiNameLb.text;
    NSString *pwdString = self.passwordTF.text;
    [AppDelegate sharedDefault].appWifiName = ssidString;
    if(ssidString.length<=0 ){
        [self setUpNeedWiFiNetworkTips:NO_CONNECTED_WIFI];
        return;
    }
    if (pwdString.length<=0) {
        [self setUpNeedWiFiNetworkTips:NO_WIFI_PASSWORD];
        return;
    }
    
    [self wifiSaveWiFiHistoryWithName:ssidString withPwd:pwdString];
    [AppDelegate sharedDefault].appWiFiPassword = pwdString;
    DevicesReadyViewController *devicesReadyCtl = [[DevicesReadyViewController alloc] init];
    [self.navigationController pushViewController:devicesReadyCtl animated:YES];
    
}

#pragma mark  提示需要先连接上WiFi网络
-(void)setUpNeedWiFiNetworkTips:(int)tipType{
    switch (tipType) {
        case NO_CONNECTED_WIFI:
        {
            
            UIAlertView *wifiAlertViwe = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"link_wifi", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            [wifiAlertViwe show];
        }
            
            break;
        case NO_WIFI_PASSWORD:
        {
            UIAlertView *notInputWiFiPwdAlertViw = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"are_you_sure_there_is_no_WiFi_password", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"no", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
            notInputWiFiPwdAlertViw.delegate =self;
            [notInputWiFiPwdAlertViw show];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 调到系统设置页面
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 0){//否
        
    }else{//确定wifi没有设置密码
        
        //保存WiFi历史记录
        NSString *ssidString = self.aWiFiNameLb.text;
        NSString *pwdString = @"";//没有密码的Wifi
        
        if(ssidString.length<=0 ){
            [self setUpNeedWiFiNetworkTips:NO_CONNECTED_WIFI];
            return;
        }
        
        [self wifiSaveWiFiHistoryWithName:ssidString withPwd:pwdString];
        [AppDelegate sharedDefault].appWiFiPassword = pwdString;
        DevicesReadyViewController *devicesReadyCtl = [[DevicesReadyViewController alloc] init];
        [self.navigationController pushViewController:devicesReadyCtl animated:YES];
        
        
    }

}

//密码是否可见
-(void)seePassword:(UIButton*)btn{
    
    self.eitherPasswordSee = !self.eitherPasswordSee;
    if(self.eitherPasswordSee){
        self.passwordTF.secureTextEntry = NO;
        [btn setImage:[UIImage imageNamed:@"password_can_see.png"] forState:UIControlStateNormal];
        
    }else {
        [btn setImage:[UIImage imageNamed:@"password_cannot_see.png"] forState:UIControlStateNormal];

        self.passwordTF.secureTextEntry = YES;
    }
    
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    //keyBoard frame
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
//                        self.view.transform = CGAffineTransformMakeTranslation(0, -20);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [self.passwordTF resignFirstResponder];
    return YES;
}

#pragma mark  UI控件适配屏幕
-(void)viewDidLayoutSubviews{
    
    
    
    
}

- (void)backClick{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    return;
    
    YMsgBox *yBox = [[YMsgBox alloc] init];
    yBox.yMsgTextField.secureTextEntry = YES;
    [yBox addTarget:self withAction:@selector(eitherExitAddDevices:) forEvent:YMsgBoxMsgTypeButtonBeClick];
    yBox.yMsgTitle = [YFonc gtTextWithString:CustomLocalizedString(@"are_you_sure_to_exit_adding_camera", nil)
                                   withColor:[UIColor blackColor]
                                    withFont:[UIFont systemFontOfSize:18]
                               withAlignment:NSTextAlignmentCenter];
    yBox.yMsgTextFieldBorderColor=RGBA(62,156,254,1.0);
    yBox.yMsgTextFieldBottomLineColor=[UIColor clearColor];
    yBox.yMsgButtonBorderColor=RGBA(211,211,212,1.0);
    UIButton *exitBtn= [[UIButton alloc ]init];
    exitBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    [exitBtn setTitle:CustomLocalizedString(@"confirm",nil) forState:UIControlStateNormal];
    [exitBtn setTitleColor:UIColorFromRGB(0xa9a9a9) forState:UIControlStateNormal];
    
    UIButton *goOnAddBtn= [[UIButton alloc ]init];
    goOnAddBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [goOnAddBtn setTitle:CustomLocalizedString(@"continue_to_add",nil) forState:UIControlStateNormal];
    [goOnAddBtn setTitleColor:UIColorFromRGB(0x3e9cfe) forState:UIControlStateNormal];
    yBox.yMsgButtons = @[exitBtn,goOnAddBtn];
    [yBox showMsgBoxInViewController:self];
    
}

-(void)eitherExitAddDevices:(YMsgBox*)yBox{

    if(yBox.yMsgButtonIndex ==-1 ){//点击空白处
        return;
    }else if(yBox.yMsgButtonIndex == 1){
        [yBox hideMsgBox]; //隐藏输入框 继续添加按钮被点击
        
    }else if(yBox.yMsgButtonIndex == 0){ // 退出按钮被点击
        [yBox hideMsgBox]; //隐藏输入框
        [self.navigationController popToRootViewControllerAnimated:YES];
        //保存WIFI历史记录
        NSString *ssidString = self.aWiFiNameLb.text;
        NSString *pwdString = self.passwordTF.text;
        if (!pwdString) {
            pwdString = @"";
        }
        if(ssidString.length<=0){
//            [self.view makeToast:CustomLocalizedString(@"link_wifi", nil)];
            return;
        }
        [self wifiSaveWiFiHistoryWithName:ssidString withPwd:pwdString];
       
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
