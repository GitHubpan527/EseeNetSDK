//
//  LoginViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LoginViewController.h"

//我的设备
#import "MyFacilityViewController.h"
//注册
#import "RegisterViewController.h"
//忘记密码
#import "ForgetPwViewController.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"
#import "JPUSHService.h"
//ljp
#import "Constants.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "NetManager.h"
#import "MainController.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "AccountResult.h"
#import "Toast+UIView.h"
#import "ChooseCountryController.h"
#import "EmailRegisterController.h"
#import "BindPhoneController.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "Message.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "ContactDAO.h"
#import "NewRegisterController.h"
#import "RegisterResult.h"

#import "NSString+Hashing.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIButton *goRegisterButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mobileTF.placeholder = CustomLocalizedString(@"inputMobile", nil);
    self.passwordTF.placeholder = CustomLocalizedString(@"inputPw", nil);
    self.showLabel.text = CustomLocalizedString(@"life", nil);
    [self.goRegisterButton setTitle:CustomLocalizedString(@"goRegister", nil) forState:UIControlStateNormal];
    [self.forgetPwButton setTitle:CustomLocalizedString(@"forgetPw", nil) forState:UIControlStateNormal];
    [self.loginButton setTitle:CustomLocalizedString(@"login", nil) forState:UIControlStateNormal];
    
    //获取账户密码
    self.mobileTF.text = [JPUserDefaults jp_objectForKey:@"LoginMobile"];
    self.passwordTF.text = [JPUserDefaults jp_objectForKey:@"LoginPassword"];
    
#pragma mark - 背景图
    UIImageView *backIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backIV.image = LCImage(@"背景");
    [self.view addSubview:backIV];
    [self.view sendSubviewToBack:backIV];
    
    // Do any additional setup after loading the view.
    
}

#pragma mark - 登录事件
- (IBAction)loginAction:(id)sender {
    if (!self.mobileTF.text.length) {
        [self mb_show:@"请输入手机号"];
        return;
    }
    if (![NSString lc_isValidateMobile:self.mobileTF.text]) {
        [self mb_show:@"手机号格式不正确"];
        return;
    }
    if (self.passwordTF.text.length<6 || self.passwordTF.text.length>16) {
        [self mb_show:@"请输入6~16位密码"];
        return;
    }
    
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.mobileTF.text,
                                 @"password":[NSString lc_md5String:self.passwordTF.text]};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:AuthLogin parameters:requestDic successBlock:^(id successObject) {
        
        if ([successObject[@"result"] boolValue]) {
            //保存用户信息
            LoginUserModel *userModel = [[LoginUserModel alloc] initWithDic:successObject[@"object"]];
            [LoginUserDefaults setLoginUserModel:userModel forKey:[LoginUserDefaults getLoginUserModelKey]];
            //保存头像、姓名
            [JPUserDefaults jp_setObject:userModel.headUrl forKey:@"HeadUrlKey"];
            [JPUserDefaults jp_setObject:userModel.realName forKey:@"RealNameKey"];
            //获取邮箱用于注册摄像头
            [self getYooseeEmail];
        } else {
            [self mb_stop];
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - 获取邮箱
- (void)getYooseeEmail
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    //注册极光,MD5加密
    NSString * idstring = [NSString stringWithFormat:@"%@",userModel.id];
    NSLog(@"%@-----%@---",idstring,[idstring MD5Hash]);
    
    [JPUSHService setTags:nil alias:[idstring MD5Hash] fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        NSLog(@"%d----%@---",iResCode,iAlias);
    }];
    
    [JPUSHService setTags:nil alias:[idstring MD5Hash] callbackSelector:nil object:nil];
   
    NSDictionary *requestDic = @{@"userId":userModel.id};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:GetExternalAccount parameters:requestDic successBlock:^(id successObject) {
        if ([successObject[@"result"] boolValue]) {
            if ([successObject[@"object"][@"status"] integerValue] == 3) {//已注册
                [self loginYooseeWithEmail:successObject[@"object"][@"email"] password:successObject[@"object"][@"password"]];
            } else {
                [self registYooseeWithEmail:successObject[@"object"][@"email"] password:successObject[@"object"][@"password"] yooseeId:successObject[@"object"][@"id"]];
            }
        } else {
            [self mb_stop];
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - 注册摄像头
- (void)registYooseeWithEmail:(NSString *)email password:(NSString *)password yooseeId:(NSString *)yooseeId
{
    [[NetManager sharedManager] registerWithVersionFlag:@"1" email:email countryCode:@"" phone:@"" password:password repassword:password phoneCode:@"" callBack:^(id JSON) {
        
        RegisterResult *registerResult = (RegisterResult*)JSON;
        
        switch(registerResult.error_code){
            case NET_RET_REGISTER_SUCCESS:
            {
                [self registYooseeSuccessWithEmail:email password:password yooseeId:yooseeId];
            }
                break;

            default:
            {
                [self mb_stop];
                [self mb_show:@"登录失败"];
            }
                break;
        }
    }];
}

#pragma mark - 通知外部帐号注册通知
- (void)registYooseeSuccessWithEmail:(NSString *)email password:(NSString *)password yooseeId:(NSString *)yooseeId
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"userId":userModel.id,
                                 @"id":yooseeId};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:RegisterExternalAccount parameters:requestDic successBlock:^(id successObject) {
        if ([successObject[@"result"] boolValue]) {
            [self loginYooseeWithEmail:email password:password];
        } else {
            [self mb_stop];
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        
    }];
}

#pragma mark - 登录摄像头
- (void)loginYooseeWithEmail:(NSString *)email password:(NSString *)password
{
    [[NetManager sharedManager] loginWithUserName:email password:password token:[AppDelegate sharedDefault].token callBack:^(id result){
        
        [self mb_stop];
        
        LoginResult *loginResult = (LoginResult*)result;

        switch(loginResult.error_code){
            case NET_RET_LOGIN_SUCCESS:
            {
                //re-registerForRemoteNotifications
                if (CURRENT_VERSION<9.3) {
                    if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
                        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                        
                    }else{
                        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
                    }
                }

                [UDManager setIsLogin:YES];
                [UDManager setLoginInfo:loginResult];
                
                [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                    AccountResult *accountResult = (AccountResult*)JSON;
                    loginResult.email = accountResult.email;
                    loginResult.phone = accountResult.phone;
                    loginResult.countryCode = accountResult.countryCode;
                    [UDManager setLoginInfo:loginResult];
                }];
                
                //跳转
                MyFacilityViewController *vc = [[MyFacilityViewController alloc] init];
                BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:vc];
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self presentViewController:navi animated:YES completion:nil];
                });
            
                AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                tempDelegate.mainVC = vc;
                
                //保存账户密码
                [JPUserDefaults jp_setObject:self.mobileTF.text forKey:@"LoginMobile"];
                [JPUserDefaults jp_setObject:self.passwordTF.text forKey:@"LoginPassword"];
            }
                break;
                
            default:
            {
                [self mb_show:@"登录失败"];
            }
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboar00d-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"Register"]) {
        RegisterViewController *vc = segue.destinationViewController;
        __weak LoginViewController *weakSelf = self;
        vc.block = ^(NSString *mobile,NSString *password) {
            weakSelf.mobileTF.text = mobile;
            weakSelf.passwordTF.text = password;
        };
    }
}

@end
