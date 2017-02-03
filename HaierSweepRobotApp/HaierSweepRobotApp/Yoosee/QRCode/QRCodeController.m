//
//  QRCodeController.m
//  Yoosee
//
//  Created by guojunyi on 14-8-28.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//
#import "AddContactNextController.h"
#import "QRCodeController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"
#import "QRCodeGenerator.h"
#import "QRCodeNextController.h"
#import "MainController.h"
#import "ParamDao.h"
#import "ConnectFailurePromptView.h"
#import "QRCodeSetWIFINextController.h"//set wifi to add device by qr
#import "Utils.h"

#import "TopBar.h"
#import "AppDelegate.h"
#import "PopoverTableViewController.h"
#import "DXPopover.h"

@interface QRCodeController ()<PopoverViewDelegate>
{
    BOOL _bShowTip;
    int _tipIndex;
    
    QRCodeGuardFirst* _guardView00;
    QRCodeGuardSecond* _guardView01;//第一个，连接好电源
    UIView* _guardView02;
    
    UILabel* _textLable;
    UIImageView* _imageView;
    
    int _conectType;
    
    BOOL _bQuit;
    BOOL _bInitWif;
}
@end

@implementation QRCodeController

-(void)dealloc{
    [self.connectFailurePromptView release];
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

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
    [self erweima];
    
}
/**
 *  @author zhengju, 16-09-27 13:09:25
 *
 *  @brief 二维码扫描
 */
- (void)erweima{
    if (self.isFailForConnectingWIFI) {
        [self.connectFailurePromptView setHidden:NO];
        [_guardView01 setHidden:NO];
        [_guardView02 setHidden:YES];
        _tipIndex = QRGuard_index01;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    _bQuit = YES;
}

-(void)getWifiLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_bQuit)
        {
            NSDictionary *ifs = [self fetchSSIDInfo];
            NSString *ssid = [ifs objectForKey:@"SSID"];
            if(nil != ssid)
            {
                if (!_bInitWif) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ssidField.text = ssid;
                        self.pwdField.userInteractionEnabled = YES;
                        _bInitWif = YES;
                        return ;
                    });
                }
            }
            else
            {
                if (_bInitWif) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ssidField.text = @"";
                        self.pwdField.text = @"";
                        self.pwdField.userInteractionEnabled = NO;
                        _bInitWif = NO;
                        return ;
                    });
                }
            }
            sleep(2);
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ParamDao* dao = [[ParamDao alloc]init];
    _bShowTip = [dao getGuardValue];
    [dao release];
    
    //增加添加方式
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithIcon:@"添加-(1)" block:^{
        //[self onAddPress];
        
//        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//        addContactNextController.inType = 1;
//        addContactNextController.isInFromManuallAdd = YES;
//        [self.navigationController pushViewController:addContactNextController animated:YES];
//        [addContactNextController release];
        
        LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
    }];
    
    /*
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:@"手动添加" block:^{
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
        
        LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
    }];
     */
    
    [self initComponent];
    [self getWifiLoop];
    // Do any additional setup after loading the view.
}
-(void) onAddPress{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PopoverTableViewController *popoverTableViewController = [[PopoverTableViewController alloc] init];
        popoverTableViewController.navigationController = self.navigationController;
        
        //内存泄漏
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverTableViewController];
        popoverController.popoverContentSize = CGSizeMake(200, 136);
        [popoverController presentPopoverFromRect:CGRectMake(self.topBar.rightButton.frame.size.width/2.0, self.topBar.rightButton.frame.size.height, 5, 5) inView:self.topBar.rightButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverTableViewController.popover = popoverController;
        
        //[popoverTableViewController release];
    }
    else
        {
        UIImage *image = [UIImage imageNamed:@"添加背景"];
        PopoverView *popoverView = [[PopoverView alloc] init];
        
        popoverView.frame = CGRectMake(0, 0, 140, 140*(image.size.height/image.size.width));
        popoverView.delegate = self;
        popoverView.backgroundImage = image;
        
        DXPopover *popover = [DXPopover popover];
        
        popover.betweenAtViewAndArrowHeight = 30.0f;
        
        self.popover = popover;
        popover.arrowSize = CGSizeMake(0.0, 0.0);
        [popover showAtView:self.navigationItem.rightBarButtonItem.customView withContentView:popoverView];
        [popoverView release];
        }
}
-(void)didSelectedPopoverViewRow:(NSInteger)row{
    [self.popover dismiss];//去掉泡沫
    if (row == 1) {//二维码
//        QRCodeController *qecodeController = [[QRCodeController alloc] init];
//        
//        [self.navigationController pushViewController:qecodeController animated:YES];
//        [qecodeController release];
        self.isFailForConnectingWIFI = YES;
        [self connectFailurePromptViewSetWifiToAddDeviceByQR];
    }else if (row == 2){
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
        
//        LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
//        addContactNextController.inType = 1;
//        addContactNextController.isInFromManuallAdd = YES;
//        [self.navigationController pushViewController:addContactNextController animated:YES];
//        [addContactNextController release];
    }else if (row == 3)
        {
        //        ApModeViewController *apModeController = [[ApModeViewController alloc] init];
        //        [self.navigationController pushViewController:apModeController animated:YES];
        // [apModeController release];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

#define QRCODE_IMAGE_WIDTH_HEIGHT 200
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat heightNextBtn = 34;
    CGFloat heightTab = 40;
    
    self.navigationItem.title = CustomLocalizedString(@"add_new_device",nil);

    
    [self.view setBackgroundColor:XBgColor];

    //subview-1 2 ================================================
    if (_bShowTip) {
        _guardView00 = [[QRCodeGuardFirst alloc]initWithFrame:CGRectMake(0, 0, width, height-heightNextBtn)];
        _guardView00.delegate = self;
        [self.view addSubview:_guardView00];
        [_guardView00 setHidden:YES];//i added
        [_guardView00 release];
        _tipIndex = QRGuard_index00;
        
        _guardView01 = [[QRCodeGuardSecond alloc]initWithFrame:CGRectMake(0, 0, width, height-heightNextBtn)];
        [self.view addSubview:_guardView01];
        [_guardView01 release];
        [_guardView01 setHidden:NO];
        _tipIndex = QRGuard_index01;//i added
    }
    else
    {
        _tipIndex = QRGuard_index02;
    }
    
    
    //subview-3 ================================================
    _guardView02 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height-heightNextBtn)];
    [self.view addSubview:_guardView02];
    [_guardView02 release];
    
    TabView* tabView = [[TabView alloc]init];
    tabView.frame = CGRectMake(0, 0, width, heightTab);
    [tabView setBtnIndex:0 text:CustomLocalizedString(@"add_tab_title00", nil)];
    [tabView setBtnIndex:1 text:CustomLocalizedString(@"add_tab_title01", nil)];
    tabView.delegate = self;
    [_guardView02 addSubview:tabView];
    [tabView setHidden:YES];//隐藏，不显示
    [tabView release];

    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 15+heightTab, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = CustomLocalizedString(@"link wifi", nil);
    field1.font = XFontBold_16;
    field1.userInteractionEnabled = NO;  //只读
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_guardView02 addSubview:field1];
    self.ssidField = field1;
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.ssidField.frame.origin.y+self.ssidField.frame.size.height+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = CustomLocalizedString(@"input_wifi_password", nil);
    field2.font = XFontBold_16;
    field2.userInteractionEnabled = NO;  //只读
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_guardView02 addSubview:field2];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"WiFiPassword"];
    if (str.length != 0) {
        field2.text = str;
    }
    
    self.pwdField = field2;
    [field2 release];
    
    CGFloat textLable_w = [Utils getStringWidthWithString:CustomLocalizedString(@"scan_prompt01", nil) font:XFontBold_16 maxWidth:width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2];
    CGFloat textLable_h = [Utils getStringHeightWithString:CustomLocalizedString(@"scan_prompt01", nil) font:XFontBold_16 maxWidth:width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2];
    _textLable = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.ssidField.frame.origin.y-textLable_h-5.0, textLable_w, textLable_h)];
    _textLable.text = CustomLocalizedString(@"scan_prompt01", nil);
    _textLable.font = XFontBold_16;
    _textLable.numberOfLines = 0;
    _textLable.backgroundColor = [UIColor clearColor];
    [_guardView02 addSubview:_textLable];
    [_textLable release];
    
    UIImage *image = [UIImage imageNamed:@"Qcord.png"];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-image.size.width*0.8)/2, CGRectGetMaxY(_textLable.frame)+10, image.size.width*0.8, image.size.height*0.8)];
    _imageView.image = image;
    [_imageView setHidden:YES];
    [_guardView02 addSubview:_imageView];
    [_imageView release];
    
    if (_bShowTip) {
        [_guardView02 setHidden:YES];
    }
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-120, 300, heightNextBtn)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(onMakePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:CustomLocalizedString(@"next", nil) forState:UIControlStateNormal];
    [self.view  addSubview:saveButton];
    
    ConnectFailurePromptView *connectFailurePromptView = [[ConnectFailurePromptView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    connectFailurePromptView.delegate = self;
    [self.navigationController.view addSubview:connectFailurePromptView];
    [connectFailurePromptView setHidden:YES];
    self.connectFailurePromptView = connectFailurePromptView;
    [connectFailurePromptView release];
}

-(void)connectOnceAgainButtonClick{
    self.pwdField.text = @"";
    [self.connectFailurePromptView setHidden:YES];
    self.isFailForConnectingWIFI = NO;
}

-(void)connectFailurePromptViewSetWifiToAddDeviceByQR{//set wifi to add device by qr
    self.pwdField.text = @"";
    [self.connectFailurePromptView setHidden:YES];
    self.isFailForConnectingWIFI = NO;
    
    [_guardView01 setHidden:YES];
    [_guardView02 setHidden:NO];
    _tipIndex = QRGuard_index02;
    self.isSetWifiToAddDeviceByQR = YES;
}

-(void)onKeyBoardDown:(id)sender{
    [self.ssidField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertWithAlertString:(NSString *)alertString
{
    //提示框
    UIAlertController * alertCtr = [UIAlertController alertControllerWithTitle:nil message:alertString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setObject:self.pwdField.text forKey:@"WiFiPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self btnClick];
    }];
    [alertCtr addAction:action1];
    [alertCtr addAction:action2];
    [self presentViewController:alertCtr animated:YES completion:nil];
}
/*
 NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"WiFiPassword"];
 if (str.length != 0) {
 self.pwdField.text = str;
 }
 */
-(void)onMakePress{
    if (_tipIndex == QRGuard_index01)
    {
        [_guardView01 setHidden:YES];
        [_guardView02 setHidden:NO];
        _tipIndex = QRGuard_index02;
    }
    else
    {
        if (self.pwdField.text.length == 0) {
            [self showAlertWithAlertString:@"确定此WiFi没有设置密码？"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:self.pwdField.text forKey:@"WiFiPassword"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self btnClick];
        }
    }
}
- (void)btnClick
{
    NSString *ssidString = self.ssidField.text;
    NSString *pwdString = self.pwdField.text;
    if (!pwdString) {//ios<7.0
        pwdString = @"";
    }
    if(ssidString.length<=0){
        [self.view makeToast:CustomLocalizedString(@"link_wifi", nil)];
        return;
    }
    [self onKeyBoardDown:nil];
    
    QRCodeNextController *qrcodeNextController = [[QRCodeNextController alloc] init];
    qrcodeNextController.uuidString = ssidString;
    qrcodeNextController.wifiPwd = pwdString;
    if (self.isSetWifiToAddDeviceByQR) {//set wifi to add device by qr
        self.isSetWifiToAddDeviceByQR = NO;
        qrcodeNextController.conectType = 1;
        qrcodeNextController.qrCodeController = self;
    }else{
        qrcodeNextController.conectType = 0;
    }
    [self.navigationController pushViewController:qrcodeNextController animated:YES];
    [qrcodeNextController release];
}
-(void)setQRGuard:(BOOL)bEnable
{
    _bShowTip = bEnable;
}

-(void)tabViewSetPage:(int)index
{
    if (index == 0) {
        _textLable.text = CustomLocalizedString(@"scan_prompt01", nil);
        [_imageView setHidden:YES];
    }
    else
    {
        _textLable.text = CustomLocalizedString(@"scan_prompt", nil);
        [_imageView setHidden:NO];
    }
    
    _conectType = index;
}

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
