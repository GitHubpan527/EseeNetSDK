//
//  SetupViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "SetupViewController.h"

#import "AppDelegate.h"

#import "SetupCell.h"
#import "SetupThreeCell.h"

#pragma mark - 意见反馈
#import "FeedBackViewController.h"

#pragma mark - 关于我们
#import "AboutUsViewController.h"

#pragma mark - 使用帮助
#import "UseHelpViewController.h"

#pragma mark - 使用协议
#import "UseAgreementViewController.h"
#import "JPUSHService.h"
//ljp
#import "AppDelegate.h"
#import "Constants.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "LoginController.h"
#import "P2PClient.h"
#import "AutoNavigation.h"
#import "CustomCell.h"
#import "TopBar.h"
#import "FListManager.h"
#import "AccountController.h"
#import "GlobalThread.h"
#import "YLLabel.h"
#import "Reachability.h"
#import "NetManager.h"
#import "Toast+UIView.h"

@interface SetupViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *setupTB;

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //CustomLocalizedString(@"mall", nil);
    self.navigationItem.title = CustomLocalizedString(@"setup0", nil);
}
#pragma mark - 返回事件
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 2) {
        static NSString *cellIde = @"cell";
        SetupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SetupCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        UILabel *centerLabel = (UILabel *)[cell viewWithTag:20];
        centerLabel.hidden = YES;
        
        if (indexPath.section == 0) {
            
            NSArray *arr = @[CustomLocalizedString(@"feedback", nil),CustomLocalizedString(@"aboutUs", nil),CustomLocalizedString(@"useHelp", nil)];
            titleLabel.text = arr[indexPath.row];
            /*
            if (HLLanguageIsEN) {
                NSArray *arr = @[@"feedback",@"aboutUs",@"useHelp"];
                titleLabel.text = arr[indexPath.row];
            } else {
                NSArray *arr = @[@"意见反馈",@"关于我们",@"使用帮助"];
                titleLabel.text = arr[indexPath.row];
            }
            */
        } else {
            
//            if (HLLanguageIsEN) {
//                NSArray *arr = @[@"cleanCache",@"switchLanguage",@"useAgreement"];
//                titleLabel.text = arr[indexPath.row];
//            } else {
//                NSArray *arr = @[@"清除缓存",@"切换语言",@"使用协议"];
//                titleLabel.text = arr[indexPath.row];
//            }
            NSArray *arr = @[CustomLocalizedString(@"cleanCache", nil),CustomLocalizedString(@"useAgreement", nil)];
            titleLabel.text = arr[indexPath.row];
            /*
            if (HLLanguageIsEN) {
                NSArray *arr = @[@"cleanCache",@"useAgreement"];
                titleLabel.text = arr[indexPath.row];
            } else {
                NSArray *arr = @[@"清除缓存",@"使用协议"];
                titleLabel.text = arr[indexPath.row];
            }
             */
            if (indexPath.row == 0) {
                centerLabel.hidden = NO;
                NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
                centerLabel.text = [NSString stringWithFormat:@"%.0fM",[self folderSizeAtPath:cachPath]];
            }
        }
        
        return cell;
    } else {
        static NSString *cellIde = @"cell";
        SetupThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SetupThreeCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UILabel *quitLabel = (UILabel *)[cell viewWithTag:69];
        quitLabel.text = CustomLocalizedString(@"Logout", nil);
        /*
        if (HLLanguageIsEN) {
            quitLabel.text = @"Logout";
        } else {
            quitLabel.text = @"退出登录";
        }
        */
        return cell;
    }
}

//缓存数据
- (float)folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)clearCacheSuccess
{
    [self.setupTB reloadData];
}

- (void)cleanCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        NSLog(@"files :%lu",(unsigned long)[files count]);
        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
        [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
    });
}

/** 切换语言 */
- (void)switchLanguage
{
    if (HLLanguageIsEN) {
        /** 切换成中文 */
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:AppLanguage];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Switch to Chinese" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        /** 切换成英文 */
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:AppLanguage];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"切换成英文" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1001) {

        if (buttonIndex == 1) {
            [self mb_normal];
            [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserFrontLogout parameters:nil successBlock:^(id successObject) {
                [self mb_stop];
                if ([successObject[@"result"] boolValue]) {
                    [self loginOutYoosee];
                } else {
                    [self mb_show:successObject[@"message"]];
                }
            } FailBlock:^(id failObject) {
                [self mb_stop];
            }];
        }
    }else {
        if (buttonIndex == 0) {
            [self.setupTB reloadData];
        } else {
            [self cleanCache];
        }
    }
}

- (void)loginOutYoosee
{
    LoginResult *loginResult = [UDManager getLoginInfo];
    [[NetManager sharedManager] logoutWithUserName:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON) {
        
        NSString *errorString = (NSString *)JSON;
        int error_code = errorString.intValue;
        switch (error_code) {
            case NET_RET_LOGOUT_SUCCESS:
            {
                //设置登录密码为空
                [JPUserDefaults jp_setObject:@"" forKey:@"LoginPassword"];
                
                UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
                BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
                AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [tempDelegate.window setRootViewController:loginNavi];
                
                //退出成功
                [UDManager setIsLogin:NO];
                
                [[GlobalThread sharedThread:NO] kill];
                [[FListManager sharedFList] setIsReloadData:YES];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                
                //APP将返回登录界面时，注册新的token，登录时传给服务器
                [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                
                [JPUSHService setTags:nil alias:@"" fetchCompletionHandle:nil];
                [JPUSHService setTags:nil alias:@"" callbackSelector:nil object:nil];
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
                [self mb_show:CustomLocalizedString(@"退出失败", nil)];
            }
                break;
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSArray *classArray = @[@"FeedBackViewController",@"AboutUsViewController",@"UseHelpViewController"];
        BaseViewController *vc = [[NSClassFromString(classArray[indexPath.row]) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            float fl = [self folderSizeAtPath:cachPath];
            
            if (fl < 0.5) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:CustomLocalizedString(@"No cache can be cleaned", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:nil, nil];
                [alert show];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:CustomLocalizedString(@"Whether to clear the cache", nil) message:nil delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"sure", nil), nil];
                [alert show];
            }
            
            /*
            if (HLLanguageIsEN) {
                if (fl < 0.5) {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"No cache can be cleaned" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Whether to clear the cache" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"sure", nil];
                    [alert show];
                }
            } else {
                if (fl < 0.5) {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"没有缓存可以清理" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"是否清除缓存" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert show];
                }
            }
            */
        }
//        else if (indexPath.row == 1) {
//            [self switchLanguage];
//        }
        else {
            UseAgreementViewController *vc = [[UseAgreementViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            //[self mb_show:@"使用协议"];
        }
    }
    if (indexPath.section == 2) {
        
        //CustomLocalizedString(@"是否确认退出当前账户?", nil);
        
        UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"exit", nil) message:CustomLocalizedString(@"If confirm the exit from the current account?", nil) delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
        logoutAlert.tag = 1001;
        
        [logoutAlert show];
        
        
    }
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
