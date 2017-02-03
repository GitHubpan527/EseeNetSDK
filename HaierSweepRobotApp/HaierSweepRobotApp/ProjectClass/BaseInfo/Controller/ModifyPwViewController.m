//
//  ModifyPwViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ModifyPwViewController.h"

#import "ModifyPwCell.h"
#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

#import "AppDelegate.h"
#import "UDManager.h"
#import "GlobalThread.h"
#import "FListManager.h"

#import "NetManager.h"
#import "LoginResult.h"

@interface ModifyPwViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *modifyTB;
@end

@implementation ModifyPwViewController

{
    NSString *oldPw;
    NSString *firstNewPw;
    NSString *secondNewPw;
    
    NSString *sure;
    NSString *enterPW;
    NSString *enterNewPw;
    NSString *enterAgainNewPW;
    NSString *unequalPW;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"modify_password", nil);
#pragma mark - 确定
    //CustomLocalizedString(@"Two new password is inconsistent", nil);
    sure = CustomLocalizedString(@"sure", nil);
    enterPW = CustomLocalizedString(@"Please enter the 6 ~ 16 original password", nil);
    enterNewPw = CustomLocalizedString(@"Please enter the 6 ~ 16 new password", nil);
    enterAgainNewPW = CustomLocalizedString(@"Please enter a new password 6 to 16 again", nil);
    unequalPW = CustomLocalizedString(@"Two new password is inconsistent", nil);
    /*
    if (HLLanguageIsEN) {
        sure = @"sure";
        enterPW = @"Please enter the 6 ~ 16 original password";
        enterNewPw = @"Please enter the 6 ~ 16 new password";
        enterAgainNewPW = @"Please enter a new password 6 to 16 again";
        unequalPW = @"Two new password is inconsistent";
    } else {
        sure = @"确定";
        enterPW = @"请输入6~16位原密码";
        enterNewPw = @"请输入6~16位新密码";
        enterAgainNewPW = @"请再次输入6~16位新密码";
        unequalPW = @"两次新密码输入不一致";
    }
     */
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:sure block:^{
        [self sureAction];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)sureAction
{
    if (oldPw.length<6 || oldPw.length>16) {
        [self mb_show:enterPW];
        return;
    }
    if (firstNewPw.length<6 || firstNewPw.length>16) {
        [self mb_show:enterNewPw];
        return;
    }
    if (secondNewPw.length<6 || secondNewPw.length>16) {
        [self mb_show:enterAgainNewPW];
        return;
    }
    if (![firstNewPw isEqualToString:secondNewPw]) {
        [self mb_show:unequalPW];
        return;
    }
    
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"userId":userModel.id,
                                 @"password":oldPw.jk_md5String,
                                 @"newPasswd":firstNewPw.jk_md5String};
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UpdatePassByPasswd parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            //提示
            [self mb_show:CustomLocalizedString(@"Successful modification", nil)];//
            [self exit];//;
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (void)exit
{
    LoginResult *loginResult = [UDManager getLoginInfo];
    [[NetManager sharedManager] logoutWithUserName:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON) {
        
        NSString *errorString = (NSString *)JSON;
        int error_code = errorString.intValue;
        switch (error_code) {
            case NET_RET_LOGOUT_SUCCESS:
            {
                //退出成功后设置账户密码为空
                [JPUserDefaults jp_setObject:@"" forKey:@"LoginMobile"];
                [JPUserDefaults jp_setObject:@"" forKey:@"LoginPassword"];
                
                //重新设置根视图
                UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
                BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
                AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [tempDelegate.window setRootViewController:loginNavi];
                
                //退出成功，yoosee设置
                [UDManager setIsLogin:NO];
                
                [[GlobalThread sharedThread:NO] kill];
                [[FListManager sharedFList] setIsReloadData:YES];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                
                //APP将返回登录界面时，注册新的token，登录时传给服务器
                [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                
                dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
                dispatch_async(queue, ^{
                    [[P2PClient sharedClient] p2pDisconnect];
                    DLog(@"p2pDisconnect.");
                });
            }
                break;
                
            default:
            {
                //退出失败
                [self mb_show:CustomLocalizedString(@"Failure of exit", nil)];//Failure of exit
            }
                break;
        }
    }];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cell1";
    ModifyPwCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ModifyPwCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITextField *pwTextField = (UITextField *)[cell viewWithTag:10];
    [pwTextField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSArray *arr = @[enterPW,enterNewPw,enterAgainNewPW];
    pwTextField.placeholder = arr[indexPath.row];
    
    return cell;
}

- (void)textFieldChange:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [self.modifyTB indexPathForCell:cell];
    
    if (indexPath.row == 0) {
        oldPw = textField.text;
    }
    else if (indexPath.row == 1) {
        firstNewPw = textField.text;
    }
    else if (indexPath.row == 2) {
        secondNewPw = textField.text;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
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
