//
//  NewAddDevicesViewController.m
//  Yoosee
//
//  Created by apple on 16/10/11.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "NewAddDevicesViewController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "PrepareDevicesToConnectViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SetUpWiFiViewController.h"

@interface NewAddDevicesViewController ()

@end


@implementation NewAddDevicesViewController

#pragma mark  UI控件适配屏幕
-(void)viewDidLayoutSubviews{
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpTopBar]; //创建topbar导航栏
    [self setUpImageViewAndButton];//创建图片和选择连接网络方式的按钮
}

#pragma mark  提示需要先连接上WiFi网络
-(void)setUpNeedWiFiNetworkTips{
    if(self.fromWiFiConnectFail){
        UIAlertView *wifiAlertViwe = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"connection_failed_please_reconnect", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        
        [wifiAlertViwe show];
        
    }else{
        UIAlertView *wifiAlertViwe = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"link_wifi", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        
        [wifiAlertViwe show];
        
    }
}

-(void)setUpTopBar{
    //view的背景色
    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    //导航栏
    self.navigationItem.title = CustomLocalizedString(@"access_way", nil);
    
}
-(void)setUpImageViewAndButton{

    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //获取图片 按钮frame 最好
    
    //图片 按钮高度
    CGFloat imageViewWidth = 517/2.2;
    CGFloat imageViewHeight = 305/2.2;
    CGFloat buttonWidth = 600/2.0;
    CGFloat buttonHeight = 95/2.0;
    
    //通过WiFi添加设备の图片
    self.wifiAddImageVeiw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewAddDevices_WiFi.png"]];
    CGFloat wifiImageViewX = (width-imageViewWidth)/2.0;
    CGFloat wifiImageViewY = CGRectGetMaxY(self.addDevicesTopbar.frame)+75/2.0;
    
    self.wifiAddImageVeiw.frame = CGRectMake(wifiImageViewX, wifiImageViewY, imageViewWidth, imageViewHeight);
    [self.view addSubview:self.wifiAddImageVeiw];
    //通过WiFi添加设备按钮
    CGFloat wifiAddButtonX = (width-buttonWidth)/2.0;
    CGFloat wifiAddButtonY = CGRectGetMaxY(self.wifiAddImageVeiw.frame)+35/2.0;
    
    self.wifiAddButton = [self createButtonFrame:CGRectMake(wifiAddButtonX, wifiAddButtonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"connect_via_wifi",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(addDevices:)];//使用WiFi连接
    self.wifiAddButton.tag = WifiAddButtonTag;
    self.wifiAddButton.backgroundColor = NavigationBarColor;
//    self.wifiAddButton.backgroundColor = [UIColor cyanColor];
//    [self.wifiAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//    [self.wifiAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
    self.wifiAddButton.layer.cornerRadius=20.0f;
    [self.view addSubview:self.wifiAddButton];
    
    //通过有线网络添加设备の图片
    CGFloat wiredNetworkAddImageVeiwX = wifiImageViewX;
    CGFloat wiredNetworkAddImageVeiwY = CGRectGetMaxY(self.wifiAddButton.frame)+65/2.0;
    
    self.wiredNetworkAddImageVeiw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewAddDevices_Wired.png"]];
    self.wiredNetworkAddImageVeiw.frame = CGRectMake(wiredNetworkAddImageVeiwX, wiredNetworkAddImageVeiwY, 517/2.2, 305/2.2);
    [self.view addSubview:self.wiredNetworkAddImageVeiw];
    
    //通过有线网络添加设备按钮
    CGFloat wiredNetworkAddButtonX = wifiAddButtonX;
    CGFloat wiredNetworkAddButtonY = CGRectGetMaxY(self.wiredNetworkAddImageVeiw.frame)+35/2.0;
    
    self.wiredNetworkAddButton = [self createButtonFrame:CGRectMake(wiredNetworkAddButtonX, wiredNetworkAddButtonY, buttonWidth, buttonHeight) title:CustomLocalizedString(@"use_wired_connection",nil) titleColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15.0] target:self action:@selector(addDevices:)];//使用有线连接
    self.wiredNetworkAddButton.tag =  WiredNetworkAddButtonTag;
//    [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//    [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
    self.wiredNetworkAddButton.layer.cornerRadius=20.0f;
    [self.view addSubview:self.wiredNetworkAddButton];
    
    if (self.type == 1) {
        //云台机
        self.wiredNetworkAddButton.enabled = NO;
        self.wiredNetworkAddButton.backgroundColor = [UIColor lightGrayColor];
//        self.wifiAddButton.backgroundColor = [UIColor lightGrayColor];
//        [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"black_loginBtnImage.png"] forState:UIControlStateNormal];
//        [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"black_loginBtnImage.png"] forState:UIControlStateHighlighted];
        
    }else{
        
        self.wiredNetworkAddButton.backgroundColor = NavigationBarColor;
//        self.wifiAddButton.backgroundColor = [UIColor cyanColor];
//        [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage.png"] forState:UIControlStateNormal];
//        [self.wiredNetworkAddButton setBackgroundImage:[UIImage imageNamed:@"loginBtnImage_p.png"] forState:UIControlStateHighlighted];
        
        
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

-(void)addDevices:(UIButton*)btn{
    
    PrepareDevicesToConnectViewController *prepareVC = [[PrepareDevicesToConnectViewController alloc] init];
    
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    if(ssid.length==0 ){
        UIAlertView *wifiAlertViwe = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"link_wifi", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
//        去掉网络判断
//        [wifiAlertViwe show];
//        
//        return;
    }
    
    switch (btn.tag) {
            //设备在有线网络下 首次连接设备
        case WiredNetworkAddButtonTag:
        {
           
            prepareVC.connectType = ViaWired;
            [AppDelegate sharedDefault].isWiredConnectOrNot = YES;
            [self.navigationController pushViewController:prepareVC animated:YES];
        }
            break;
        //设备在无线网络下 首次连接设备
        case WifiAddButtonTag:
        {
            
            SetUpWiFiViewController *setUpWiFiCtl = [[SetUpWiFiViewController alloc ] init];
            [self.navigationController pushViewController:setUpWiFiCtl animated:YES];
            [AppDelegate sharedDefault].isWiredConnectOrNot = NO;
            
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
//    btn.backgroundColor = UIColorFromRGB(0x5586f6);
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
