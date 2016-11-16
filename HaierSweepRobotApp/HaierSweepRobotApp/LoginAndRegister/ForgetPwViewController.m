//
//  ForgetPwViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ForgetPwViewController.h"

#pragma mark - 设置新密码
#import "ResetPwViewController.h"

@interface ForgetPwViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ForgetPwViewController
{
    NSInteger countDown;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"forgetPassword", nil);
    
    self.mobileTF.placeholder = CustomLocalizedString(@"inputMobile", nil);
    self.codeTF.placeholder = CustomLocalizedString(@"inputCode", nil);
    [self.getButton setTitle:CustomLocalizedString(@"getCode", nil) forState:UIControlStateNormal];
    [self.nextButton setTitle:CustomLocalizedString(@"nextStep", nil) forState:UIControlStateNormal];

    // Do any additional setup after loading the view.
}

#pragma mark - 获取验证码
- (IBAction)getCodeAction:(id)sender {
    if (!self.mobileTF.text.length) {
        [self mb_show:@"请输入手机号"];
        return;
    }
    [self  getcaptcha];
}

- (void)getcaptcha
{
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"smsTemplateCode":@"SMS_3095471"};
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
    __weak ForgetPwViewController *weakSelf = self;
    timer = [NSTimer lc_scheduledTimerWithTimeInterval:1.0 block:^{
        countDown--;
        NSLog(@"%ld",(long)countDown);
        ForgetPwViewController *strongSelf = weakSelf;
        [strongSelf.getButton setTitle:[NSString stringWithFormat:@"%lds",(long)countDown]forState:UIControlStateNormal];
        if (countDown == 0) {
            [timer invalidate];
            [strongSelf.getButton setTitle:@"重新发送" forState:UIControlStateNormal];
            strongSelf.getButton.enabled = YES;
        }
    } repeats:YES];
    self.getButton.enabled = NO;
}

- (IBAction)nextHandleAction:(id)sender {
    
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
    
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"mobileCode":self.codeTF.text};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:CheckMobileCode parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            ResetPwViewController *vc = [[ResetPwViewController alloc] init];
            vc.telephone = self.mobileTF.text;
            vc.mobileCode = self.codeTF.text;
            [self.navigationController pushViewController:vc animated:YES];
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
