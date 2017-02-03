//
//  DevicesReadyViewController.m
//  Yoosee
//
//  Created by apple on 16/10/18.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "DevicesReadyViewController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "YMsgBox.h"
#import "WaitingForConnectViewController.h"

@interface DevicesReadyViewController ()

@end

@implementation DevicesReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
}

-(void)setUpUI{
    
    [self devicesReadySetUpTopbar];
    [self devicesReadySetUpTipsLb];
    [self devicesReadyImgViewAnimation];
    [self devicesReadySetUpBtn];
    
}

#pragma mark 导航栏
-(void)devicesReadySetUpTopbar{
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
//    [topBar.backButton addTarget:self action:@selector(devicesReadyGoBack) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:topBar];
//    self.devicesReadyTopbar = topBar;

}

#pragma mark 文字提示:当摄像机准备就绪后  会发出连接提示音
-(void)devicesReadySetUpTipsLb{
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    //当摄像机准备就绪后 提示文字
    CGFloat readyLbWidth = 280;
    CGFloat readyLbHeight = 30;
    CGFloat readyLbY = 65/2.0+CGRectGetMaxY(self.devicesReadyTopbar.frame);
    CGFloat readyLbX = (width-readyLbWidth)/2.0;
    
    self.readyTipsLb = [[UILabel alloc] init];
    self.readyTipsLb.frame = CGRectMake(readyLbX, readyLbY, readyLbWidth, readyLbHeight);
    self.readyTipsLb.text = CustomLocalizedString(@"when_camera_is_ready", nil);
    self.readyTipsLb.font = [UIFont boldSystemFontOfSize:21];
    self.readyTipsLb.textAlignment = NSTextAlignmentCenter;
    self.readyTipsLb.textColor = UIColorFromRGB(0x494949);
    [self.view addSubview:self.readyTipsLb];
    
    //当摄像机准备就绪后 提示文字
    CGFloat soundTipsLbWidth = 280;
    CGFloat soundTipsLbHeight = 30;
    CGFloat soundTipsLbY = 30/2.0+CGRectGetMaxY(self.readyTipsLb.frame);
    CGFloat soundTipsLbX = (width-soundTipsLbWidth)/2.0;
    
    self.soundTipsLb = [[UILabel alloc] init];
    self.soundTipsLb.frame = CGRectMake(soundTipsLbX, soundTipsLbY, soundTipsLbWidth, soundTipsLbHeight);
    self.soundTipsLb.text = CustomLocalizedString(@"it_releases_prompt_tone_for_connection", nil);
    self.soundTipsLb.numberOfLines = 2;
    self.soundTipsLb.font = [UIFont boldSystemFontOfSize:21];
    self.soundTipsLb.textAlignment = NSTextAlignmentCenter;
    self.soundTipsLb.textColor = NavigationBarColor;
    [self.view addSubview:self.soundTipsLb];
    
    
}

#pragma mark 中间动画控件
-(void)devicesReadyImgViewAnimation{
    
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    CGFloat animatedImgViewWidth = 295/2.0;
    CGFloat animatedImgViewHeight = 274/2.0;
    CGFloat animatedImgViewX = (width - animatedImgViewWidth)/2.0;
    CGFloat animatedImgViewY = 87/2.0+ CGRectGetMaxY(self.soundTipsLb.frame);

    
    self.animatedImgView = [[UIImageView alloc] init];
    self.animatedImgView.frame = CGRectMake(animatedImgViewX, animatedImgViewY, animatedImgViewWidth, animatedImgViewHeight);
    
    [self.animatedImgView setImage:[UIImage imageNamed:@"devices_already_imgViewGif_one.png"]];
    NSArray *doorbellImgsArray = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"devices_already_imgViewGif_one.png"],
                                 [UIImage imageNamed:@"devices_already_imgViewGif_two.png"],
                                 [UIImage imageNamed:@"devices_already_imgViewGif_three.png"],
                                  nil];
    self.animatedImgView.animationImages = doorbellImgsArray;
    self.animatedImgView.animationDuration = 2.4;
    [self.animatedImgView startAnimating];
    [self.view addSubview:self.animatedImgView];
    
}

#pragma mark 底部两个button
-(void)devicesReadySetUpBtn{
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //下方对wifi要求文字提示
    self.notListenedBtn=[[UIButton alloc] init];
    self.notListenedBtn.frame = CGRectMake((width-200)/2.0, 160/2.0+CGRectGetMaxY(self.animatedImgView.frame),200, 30);
    
    [self.notListenedBtn addTarget:self
                     action:@selector(notListenedVoice)
           forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString* maStr=[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"i_did_not_hear_connection_prompt_tone",nil)];
    NSRange maStrRange=NSMakeRange(0, maStr.length);
    [maStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:maStrRange];
    
    [maStr addAttribute:NSForegroundColorAttributeName
                  value:NavigationBarColor
                  range:maStrRange];
    [maStr addAttribute:NSUnderlineStyleAttributeName
                  value:@1.0
                  range:maStrRange];
    self.notListenedBtn.backgroundColor=[UIColor clearColor];
    [self.notListenedBtn setAttributedTitle:maStr forState:UIControlStateNormal];
    [self.view addSubview:self.notListenedBtn];
    
    
    
    //我已听到提示音 按钮
    CGFloat buttonWidth = 600/2.0;
    CGFloat buttonHeight = 95/2.0;
    CGFloat buttonX = (width-buttonWidth)/2.0;
    CGFloat buttonY = CGRectGetMaxY(self.notListenedBtn.frame)+35/2.0;
    
    self.alreadyListenedBtn = [self createButtonFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"i_heard_prompt_tone",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(devicesAlreadyConnectNextStep)];
    self.alreadyListenedBtn.backgroundColor = NavigationBarColor;
//    [self.alreadyListenedBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//    [self.alreadyListenedBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
    self.alreadyListenedBtn.layer.cornerRadius=20.0f;
    [self.view addSubview:self.alreadyListenedBtn];

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

#pragma mark 没有听到声音的弹框提示
-(void)notListenedVoice{

    [self popTipsView];
}

#pragma mark  添加失败 提示
-(void)popTipsView{
    
    
    self.readyAddDevicesPopTipsView = [[AddDevicesPopTipsView alloc] init];
    self.readyAddDevicesPopTipsView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.readyAddDevicesPopTipsView.delegate = self;
    //文字
    NSArray *arr = @[CustomLocalizedString(@"devicesready_text1",nil),
                     CustomLocalizedString(@"devicesready_text2",nil),
                    ];
    NSMutableArray *strArr = [NSMutableArray arrayWithArray:arr];
    
    NSArray *btnArr = @[CustomLocalizedString(@"i_know",nil)];
    NSMutableArray *btnArray = [NSMutableArray arrayWithArray:btnArr];
    
    [self.readyAddDevicesPopTipsView setUpUIWithTitle:CustomLocalizedString(@"no_connection_prompt_tone_is_heard",nil) numberOfLabel:(int)strArr.count lbTextArr:strArr numberOfBtn:(int)btnArr.count btnTextArr:btnArray eitherHaveImgView:YES];
    
    [self.readyAddDevicesPopTipsView.closeBtn addTarget:self action:@selector(qrClosePopView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.readyAddDevicesPopTipsView];
    
    
    
    self.readyAddDevicesPopTipsView.blackBgView.hidden=NO;
    self.readyAddDevicesPopTipsView.blackBgView.alpha=0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.readyAddDevicesPopTipsView.blackBgView.alpha=1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)qrClosePopView{
    
    self.readyAddDevicesPopTipsView.blackBgView.alpha=1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.readyAddDevicesPopTipsView.blackBgView.alpha=0.0;
    } completion:^(BOOL finished) {
        self.readyAddDevicesPopTipsView.blackBgView.hidden=YES;
    }];
    [self.readyAddDevicesPopTipsView removeFromSuperview];
}

#pragma mark -
-(void)buttonBePressed:(UIButton*)btn{
    //再试一次
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


#pragma mark 我已听到提示音
-(void)devicesAlreadyConnectNextStep{
    
    WaitingForConnectViewController *waitingForConnectVC = [[WaitingForConnectViewController alloc] init];
    [self.navigationController pushViewController:waitingForConnectVC animated:YES];
}

#pragma mark  返回
//-(void)devicesReadyGoBack{
//    [self drVCGoBackTo];
//}
- (void)backClick
{
    [self drVCGoBackTo];
}

#pragma mark 点击返回上一界面 提示是否退出添加
-(void)drVCGoBackTo{
    [self.navigationController popViewControllerAnimated:YES];
    return;
    YMsgBox *yBox = [[YMsgBox alloc] init];
    yBox.yMsgTextField.secureTextEntry = YES;
    [yBox addTarget:self withAction:@selector(drVCEitherExitAddDevices:) forEvent:YMsgBoxMsgTypeButtonBeClick];
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

-(void)drVCEitherExitAddDevices:(YMsgBox*)yBox{
    
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
