//
//  PrepareDevicesToConnectViewController.m
//  Yoosee
//
//  Created by apple on 16/10/14.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "PrepareDevicesToConnectViewController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "LocalDeviceListController.h"
#import "UDPManager.h"
#import "Utils.h"
#import "SetUpWiFiViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface PrepareDevicesToConnectViewController ()

@end

@implementation PrepareDevicesToConnectViewController

-(instancetype)init{
    self=[super init];
    if (self) {
        _shouldPopToRoot=NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareSetUpTopBar];
    [self PrepareSetUpImageViewAndButton];
    
}

#pragma mark  UI控件适配屏幕
-(void)viewDidLayoutSubviews{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)prepareSetUpTopBar{
    //view的背景色
    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    
    
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //导航栏
    self.navigationItem.title = CustomLocalizedString(@"make_camera_prepared", nil);
    
//    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
//    [topBar setTitle:CustomLocalizedString(@"make_camera_prepared",nil)];
//    [topBar setBackButtonHidden:NO];
//    [topBar.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:topBar];
//    self.prepareTopBar = topBar;
    
}

-(void)PrepareSetUpImageViewAndButton{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //获取图片 按钮frame 最好
    
    //图片以及按钮的高度
    CGFloat imageViewWidth = 564/2.2;
    CGFloat imageViewHeight = 305/2.2;
    CGFloat buttonWidth = 600/2.0;
    CGFloat buttonHeight = 95/2.0;
    
    
    //有线网络连接设备的图片文字提醒
    if(/* DISABLES CODE */ (1)==1){
        //原本设计无线 有线连接都有连接电源的图片提醒 现在只要有线了  if语句失效 但又不想删掉else语句代码
        
        //有线网络下 图片展示
        self.wiredPrepareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wiredPrepareDevicesToconnect.png"]];
        CGFloat wiredImageViewX = (width-imageViewWidth)/2.0;
        CGFloat wiiredImageViewY = CGRectGetMaxY(self.prepareTopBar.frame)+90/2.0;
        
        self.wiredPrepareImageView.frame = CGRectMake(wiredImageViewX, wiiredImageViewY, imageViewWidth, imageViewHeight);
        [self.view addSubview:self.wiredPrepareImageView];
        
        //文字提示
        CGFloat wiredLabelX = wiredImageViewX;
        CGFloat wiredLabelY = CGRectGetMaxY(self.wiredPrepareImageView.frame)+92/2.0;
        self.wiredPrepareLabel = [[UILabel alloc]  init];
        self.wiredPrepareLabel.frame = CGRectMake(wiredLabelX, wiredLabelY, imageViewWidth, 60);
        self.wiredPrepareLabel.font = [UIFont systemFontOfSize:14.0];
        self.wiredPrepareLabel.numberOfLines = 0;
        self.wiredPrepareLabel.textAlignment = NSTextAlignmentLeft;
        self.wiredPrepareLabel.text = CustomLocalizedString(@"wired_prepare_devices", nil);
        self.wiredPrepareLabel.textColor = UIColorFromRGB(0x312e2e);
        [self.view addSubview:self.wiredPrepareLabel];
        
        
        //有线网络下 下一步按钮
        CGFloat wiredAddButtonX = (width-buttonWidth)/2.0;
        CGFloat wiredAddButtonY = CGRectGetMaxY(self.view.frame)-112/2.0-buttonHeight - 64;
        
        self.wiredPrepareBtn = [self createButtonFrame:CGRectMake(wiredAddButtonX, wiredAddButtonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"next",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(nextButtPressToDeviceLists:)];
        self.wiredPrepareBtn.tag = WiredNetworkAddButtonNextTag;
        self.wiredPrepareBtn.backgroundColor = NavigationBarColor;
//        [self.wiredPrepareBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//        [self.wiredPrepareBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
        self.wiredPrepareBtn.layer.cornerRadius=20.0f;
        [self.view addSubview:self.wiredPrepareBtn];
        
        
    }else{
        //线网络下 图片展示
        self.wifiPrepareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifiPrepareDevicesToconnect.png"]];
        CGFloat wiredImageViewX = (width-imageViewWidth)/2.0;
        CGFloat wiiredImageViewY = CGRectGetMaxY(self.prepareTopBar.frame)+90/2.0;
        
        self.wifiPrepareImageView.frame = CGRectMake(wiredImageViewX, wiiredImageViewY, imageViewWidth, imageViewHeight);
        [self.view addSubview:self.wifiPrepareImageView];
        
        //文字提示
        CGFloat wiredLabelX = wiredImageViewX;
        CGFloat wiredLabelY = CGRectGetMaxY(self.wifiPrepareImageView.frame)+92/2.0;
        self.wifiPrepareLabel = [[UILabel alloc]  init];
        self.wifiPrepareLabel.frame = CGRectMake(wiredLabelX, wiredLabelY, imageViewWidth, 60);
        self.wifiPrepareLabel.font = [UIFont systemFontOfSize:14.0];
        self.wifiPrepareLabel.numberOfLines = 0;
        self.wifiPrepareLabel.textAlignment = NSTextAlignmentLeft;
        self.wifiPrepareLabel.text = CustomLocalizedString(@"switch_power_on", nil);
        self.wifiPrepareLabel.textColor = UIColorFromRGB(0x312e2e);
        [self.view addSubview:self.wifiPrepareLabel];
        
        
        //有线网络下 下一步按钮
        CGFloat wiredAddButtonX = (width-buttonWidth)/2.0;
        CGFloat wiredAddButtonY = CGRectGetMaxY(self.view.frame)-112/2.0-buttonHeight;
        
        self.wifiPrepareBtn = [self createButtonFrame:CGRectMake(wiredAddButtonX, wiredAddButtonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"next",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(nextButtPressToDeviceLists:)];
        self.wifiPrepareBtn.tag = WifiAddButtonNextTag;
        self.wifiPrepareBtn.backgroundColor = NavigationBarColor;
//        [self.wifiPrepareBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//        [self.wifiPrepareBtn setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
        self.wifiPrepareBtn.layer.cornerRadius=20.0f;
        [self.view addSubview:self.wifiPrepareBtn];
        
    }
    
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

#pragma mark - 按钮点击
-(void)nextButtPressToDeviceLists:(UIButton*)btn{
    
    switch (btn.tag) {
        case WifiAddButtonNextTag:
        {
            SetUpWiFiViewController *setUpWiFiCtl = [[SetUpWiFiViewController alloc ] init];
            [self.navigationController pushViewController:setUpWiFiCtl animated:YES];
        }
            break;
        case WiredNetworkAddButtonNextTag:
        {
            NSDictionary *ifs = [self fetchSSIDInfo];
            NSString *ssid = [ifs objectForKey:@"SSID"];
            if(ssid.length==0 ){
                UIAlertView *wifiAlertViwe = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"link_wifi", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
                    [wifiAlertViwe show];
                
                    return;
            }
            NSArray* lanDevicesArray = [[UDPManager sharedDefault]getLanDevices];
            NSArray* newDevicesArray = [Utils getNewDevicesFromLan:lanDevicesArray];
            LocalDeviceListController *localDeviceListController = [[LocalDeviceListController alloc] init];
            localDeviceListController.isNewDevicesArray = newDevicesArray;
            [self.navigationController pushViewController:localDeviceListController animated:YES];
            
        }
            break;
        default:
            break;
    }
    
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
- (void)backClick{
    if (_shouldPopToRoot) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
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
