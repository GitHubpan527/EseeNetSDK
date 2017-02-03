//
//  WaitingForConnectViewController.m
//  Yoosee
//
//  Created by apple on 16/10/18.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "WaitingForConnectViewController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "QRCodeNextController.h"
#import "YMsgBox.h"
#import "YYNetCheck.h"
#import <SystemConfiguration/CaptiveNetwork.h>


@interface WaitingForConnectViewController ()

@end

@implementation WaitingForConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self watingForVCSetUpTopbar];
    [self watingForVCTipsLb];
    [self waitingForImgViewSetUp];
    [self waitingForVCSetUpBtn];
    
}

#pragma mark 导航栏
-(void)watingForVCSetUpTopbar{
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
//    [topBar.backButton addTarget:self action:@selector(waitingForGoBack) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:topBar];
//    self.waitingForTopbar = topBar;
    
}

#pragma mark 文字提示
-(void)watingForVCTipsLb{
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    // 提示文字
    CGFloat readyLbWidth = 280;
    CGFloat readyLbHeight = 30;
    CGFloat readyLbY = 65/2.0+CGRectGetMaxY(self.waitingForTopbar.frame);
    CGFloat readyLbX = (width-readyLbWidth)/2.0;
    
    self.voiceBigTipsLb = [[UILabel alloc] init];
    self.voiceBigTipsLb.frame = CGRectMake(readyLbX, readyLbY, readyLbWidth, readyLbHeight);
    self.voiceBigTipsLb.text = CustomLocalizedString(@"please_turn_louder_handset_volume", nil);
    self.voiceBigTipsLb.font = [UIFont boldSystemFontOfSize:14];
    self.voiceBigTipsLb.textAlignment = NSTextAlignmentCenter;
    self.voiceBigTipsLb.textColor = [UIColor blackColor];
    [self.view addSubview:self.voiceBigTipsLb];
    
    //当摄像机准备就绪后 提示文字
    CGFloat soundTipsLbWidth = 280;
    CGFloat soundTipsLbHeight = 30;
    CGFloat soundTipsLbY = 30/2.0+CGRectGetMaxY(self.voiceBigTipsLb.frame);
    CGFloat soundTipsLbX = (width-soundTipsLbWidth)/2.0;
    
    self.keep30cmTipsLb = [[UILabel alloc] init];
    self.keep30cmTipsLb.frame = CGRectMake(soundTipsLbX, soundTipsLbY, soundTipsLbWidth, soundTipsLbHeight);
    self.keep30cmTipsLb.text = CustomLocalizedString(@"keep_30cm_distance_away_from_camera", nil);
    self.keep30cmTipsLb.font = [UIFont boldSystemFontOfSize:14];
    self.keep30cmTipsLb.textAlignment = NSTextAlignmentCenter;
    self.keep30cmTipsLb.textColor = [UIColor blackColor];
    [self.view addSubview:self.keep30cmTipsLb];
    
}

#pragma mark 中间图片
-(void)waitingForImgViewSetUp{
    
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    CGFloat animatedImgViewWidth = 546/2.0;
    CGFloat animatedImgViewHeight = 395/2.0;
    CGFloat animatedImgViewX = (width - animatedImgViewWidth)/2.0;
    CGFloat animatedImgViewY = 80/2.0+ CGRectGetMaxY(self.keep30cmTipsLb.frame);
    
    
    self.waitingForImgView = [[UIImageView alloc] init];
    self.waitingForImgView.frame = CGRectMake(animatedImgViewX, animatedImgViewY, animatedImgViewWidth, animatedImgViewHeight);
    
    [self.waitingForImgView setImage:[UIImage imageNamed:@"waiting_connect_pic.png"]];
    
    [self.view addSubview:self.waitingForImgView];
    
}

#pragma mark 底部button
-(void)waitingForVCSetUpBtn{
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //我已听到提示音 按钮
    CGFloat buttonWidth = 600/2.0;
    CGFloat buttonHeight = 95/2.0;
    CGFloat buttonX = (width-buttonWidth)/2.0;
    CGFloat buttonY = CGRectGetMaxY(self.waitingForImgView.frame)+100/2.0;
    
    self.waitingNextStepBtn = [self createButtonFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"next",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(waitingForNextStep)];
    
    self.waitingNextStepBtn.backgroundColor = NavigationBarColor;
//    [self.waitingNextStepBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//    [self.waitingNextStepBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
    self.waitingNextStepBtn.layer.cornerRadius=20.0f;
    [self.view addSubview:self.waitingNextStepBtn];
    
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

-(void)waitingForNextStep{
    
    QRCodeNextController *qrcodeNextController = [[QRCodeNextController alloc] init];
    
    qrcodeNextController.uuidString = [AppDelegate sharedDefault].appWifiName;
    qrcodeNextController.wifiPwd = [AppDelegate sharedDefault].appWiFiPassword;
    qrcodeNextController.conectType = conectType_Intelligent;//智能连接
    qrcodeNextController.thePopViewController=self;
    [self.navigationController pushViewController:qrcodeNextController animated:YES];
}

#pragma mark - 创建按钮的方法
-(UIButton *)createButtonFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font target:(id)target action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = NavigationBarColor;
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

#pragma mark 点击返回上一界面 提示是否退出添加
- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
    return;
    YMsgBox *yBox = [[YMsgBox alloc] init];
    yBox.yMsgTextField.secureTextEntry = YES;
    [yBox addTarget:self withAction:@selector(wfVCEitherExitAddDevices:) forEvent:YMsgBoxMsgTypeButtonBeClick];
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

-(void)wfVCEitherExitAddDevices:(YMsgBox*)yBox{
    
    if(yBox.yMsgButtonIndex ==-1 ){//点击空白处
        return;
    }else if(yBox.yMsgButtonIndex == 1){
        [yBox hideMsgBox]; //隐藏输入框 继续添加按钮被点击
        
    }else if(yBox.yMsgButtonIndex == 0){ // 退出按钮被点击
        [yBox hideMsgBox]; //隐藏输入框
        [self.navigationController popToRootViewControllerAnimated:YES];
        
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
