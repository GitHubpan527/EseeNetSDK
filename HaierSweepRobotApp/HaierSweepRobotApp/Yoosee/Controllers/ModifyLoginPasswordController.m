//
//  ModifyLoginPasswordController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ModifyLoginPasswordController.h"
#import "MainController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "NetManager.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "ModifyLoginPasswordResult.h"
#import "FListManager.h"//修改登录密码
#import "LoginController.h"//修改登录密码
#import "AutoNavigation.h"//修改登录密码
#import "GlobalThread.h"//修改登录密码
@interface ModifyLoginPasswordController ()

@end

@implementation ModifyLoginPasswordController

-(void)dealloc{
    [self.field1 release];
    [self.field2 release];
    [self.field3 release];
 
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    //CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:CustomLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:CustomLocalizedString(@"modify_password",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = CustomLocalizedString(@"input_original_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = CustomLocalizedString(@"input_new_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field2 = field2;
    [self.view addSubview:field2];
    [field2 release];
    
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20*3+TEXT_FIELD_HEIGHT*2, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field3.layer.borderWidth = 1;
        field3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field3.layer.cornerRadius = 5.0;
    }
    field3.textAlignment = NSTextAlignmentLeft;
    field3.placeholder = CustomLocalizedString(@"confirm_input", nil);
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.returnKeyType = UIReturnKeyDone;
    field3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field3 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field3 = field3;
    [self.view addSubview:field3];
    [field3 release];

}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSavePress{
    NSString *originalPassword = self.field1.text;
    NSString *newPassword = self.field2.text;
    NSString *confirmPassword = self.field3.text;
    
    if(!originalPassword||!originalPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_original_password", nil)];
        return;
    }
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_new_password", nil)];
        return;
    }
    
    if(newPassword.length>30){
        [self.view makeToast:CustomLocalizedString(@"password_too_long", nil)];
        return;
    }
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![newPassword isEqualToString:confirmPassword]){
        [self.view makeToast:CustomLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    [[NetManager sharedManager] modifyLoginPasswordWithUserName:loginResult.contactId sessionId:loginResult.sessionId oldPwd:originalPassword newPwd:newPassword rePwd:confirmPassword callBack:^(id JSON){
        ModifyLoginPasswordResult *modifyLoginPasswordResult = (ModifyLoginPasswordResult*)JSON;

        
        switch(modifyLoginPasswordResult.error_code){
            case NET_RET_MODIFY_LOGIN_PASSWORD_SUCCESS:
            {
                [self.view makeToast:CustomLocalizedString(@"operator_success", nil)];
                loginResult.sessionId = modifyLoginPasswordResult.sessionId;
                [UDManager setLoginInfo:loginResult];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    sleep(1.0);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self.navigationController popViewControllerAnimated:YES];
                        
                        [UDManager setIsLogin:NO];//修改登录密码
                        [[GlobalThread sharedThread:NO] kill];
                        [[FListManager sharedFList] setIsReloadData:YES];
                        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                        LoginController *loginController = [[LoginController alloc] init];
                        AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
                        
                        self.view.window.rootViewController = mainController;
                        [loginController release];
                        [mainController release];
                        
                        //APP将返回登录界面时，注册新的token，登录时传给服务器
                        [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                        
                        dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
                        dispatch_async(queue, ^{
                            [[P2PClient sharedClient] p2pDisconnect];
                            DLog(@"p2pDisconnect.");
                        });//修改登录密码
                    });
                });
                
            }
                break;
            case NET_RET_MODIFY_LOGIN_PASSWORD_NOT_MATCH:
            {
                [self.view makeToast:CustomLocalizedString(@"two_passwords_not_match", nil)];
            }
                break;
            case NET_RET_MODIFY_LOGIN_PASSWORD_ORIGINAL_PASSWORD_ERROR:
            {
                [self.view makeToast:CustomLocalizedString(@"original_password_error", nil)];
            }
                break;
            case NET_RET_SYSTEM_MAINTENANCE_ERROR:
            {
                [self.view makeToast:CustomLocalizedString(@"system_maintenance", nil)];
            }
                break;
            default:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",CustomLocalizedString(@"unknown_error", nil),modifyLoginPasswordResult.error_code]];
            }
        }
    }];
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
