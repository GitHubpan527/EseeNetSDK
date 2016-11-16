//
//  RegisterViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "RegisterViewController.h"

#pragma mark - 使用协议
#import "UseAgreementViewController.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *passTF;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation RegisterViewController
{
    NSInteger countDown;
    NSTimer *timer;
}

/*
//设置横屏
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
}

//设置竖屏
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

//iOS8之后横屏的情况下默认会隐藏状态栏，重写以下方法会重新显示
//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationNone;
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"register", nil);
    
    self.mobileTF.placeholder = CustomLocalizedString(@"inputMobile", nil);
    self.codeTF.placeholder = CustomLocalizedString(@"inputCode", nil);
    self.passTF.placeholder = CustomLocalizedString(@"inputPw", nil);
    [self.getButton setTitle:CustomLocalizedString(@"getCode", nil) forState:UIControlStateNormal];
    [self.agreeButton setTitle:CustomLocalizedString(@"userAgree", nil) forState:UIControlStateNormal];
    [self.registerButton setTitle:CustomLocalizedString(@"register", nil) forState:UIControlStateNormal];

    self.selectButton.selected = NO;
    // Do any additional setup after loading the view.
}

#pragma mark - 获取验证码
- (IBAction)getCodeAction:(id)sender {
    if (!self.mobileTF.text.length) {
        [self mb_show:@"请输入手机号"];
        return;
    }
    [self getcaptcha];
}

- (void)getcaptcha
{
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"smsTemplateCode":@"SMS_3095473"};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:SendCode parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self lazyLoadingTimer];
        } else {
            [self mb_show:successObject[@"message"]];
            [timer invalidate];
            [self.getButton setTitle:@"重新发送" forState:UIControlStateNormal];
            self.getButton.enabled = YES;
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (void)lazyLoadingTimer
{
    countDown = 60;
    __weak RegisterViewController *weakSelf = self;
    timer = [NSTimer lc_scheduledTimerWithTimeInterval:1.0 block:^{
        countDown--;
        NSLog(@"%ld",(long)countDown);
        RegisterViewController *strongSelf = weakSelf;
        [strongSelf.getButton setTitle:[NSString stringWithFormat:@"%lds",(long)countDown]forState:UIControlStateNormal];
        if (countDown == 0) {
            [timer invalidate];
            [strongSelf.getButton setTitle:@"重新发送" forState:UIControlStateNormal];
            strongSelf.getButton.enabled = YES;
        }
    } repeats:YES];
    self.getButton.enabled = NO;
}

#pragma mark - 协议选中
- (IBAction)selectAction:(id)sender {
    if (self.selectButton.selected == NO) {
        self.selectButton.selected = YES;
    } else {
        self.selectButton.selected = NO;
    }
}

#pragma mark - 用户协议
- (IBAction)agreeAction:(id)sender {
    UseAgreementViewController *vc = [[UseAgreementViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 注册应用
- (IBAction)registerAction:(id)sender {
    if (!self.mobileTF.text.length) {
        [self mb_show:@"请输入手机号"];
        return;
    }
    if (![NSString lc_isValidateMobile:self.mobileTF.text]) {
        [self mb_show:@"手机号格式不正确"];
        return;
    }
    if (!self.codeTF.text.length) {
        [self mb_show:@"请输入验证码"];
        return;
    }
    if (self.passTF.text.length<6 || self.passTF.text.length>16) {
        [self mb_show:@"请输入6~16位密码"];
        return;
    }
    if (!self.selectButton.selected) {
        [self mb_show:@"必须同意用户注册协议才能注册"];
        return;
    }
    
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"mobileCode":self.codeTF.text};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:CheckMobileCode parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self registApp];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (void)registApp
{
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"mobileCode":self.codeTF.text,
                                 @"password":[NSString lc_md5String:self.passTF.text]};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserFrontRegister parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self mb_show:@"注册成功"];
            self.block(self.mobileTF.text,self.passTF.text);
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
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
