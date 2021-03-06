//
//  AccountController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AccountController.h"
#import "MainController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"

#import "AccountCell.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "ModifyLoginPasswordController.h"
#import "NetManager.h"
#import "Toast+UIView.h"
#import "BindEmailController.h"
#import "BindPhoneController.h"
@interface AccountController ()

@end

@implementation AccountController

-(void)dealloc{
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
    if(self.tableView){
        [self.tableView reloadData];
    }
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
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];

    
    self.navigationItem.title = CustomLocalizedString(@"account_info",nil);

    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height)  style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 3;
    }else if(section==1){
        return 1;
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"AccountCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
        
        
        
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg = nil;
    UIImage *backImg_p = nil;
    

    [cell setRightIcon:@"ic_arrow.png"];
    
    LoginResult *loginResult = [UDManager getLoginInfo];
    switch (section) {
        case 0:
        {
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];

                [cell setLabelText:CustomLocalizedString(@"account", nil)];
                [cell setIsHiddenRightIcon:YES];
                [cell setIsHiddenRightLabel:NO];
                [cell setRightText:loginResult.contactId];
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];

                [cell setLabelText:CustomLocalizedString(@"email", nil)];
                [cell setIsHiddenRightIcon:NO];
                [cell setIsHiddenRightLabel:NO];
                [cell setRightText:loginResult.email];
            }else {
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];

                [cell setLabelText:CustomLocalizedString(@"phone_number", nil)];
                [cell setIsHiddenRightIcon:NO];
                [cell setIsHiddenRightLabel:NO];
                if(loginResult.countryCode&&loginResult.countryCode.length>0&&loginResult.phone&&loginResult.phone.length>0){
                    [cell setRightText:[NSString stringWithFormat:@"+%@-%@",loginResult.countryCode,loginResult.phone]];
                }else{
                    [cell setRightText:@""];
                }
                
            }
        }
            break;
        case 1:
        {
            
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            [cell setLabelText:CustomLocalizedString(@"modify_login_password", nil)];
            [cell setIsHiddenRightIcon:YES];
            [cell setIsHiddenRightLabel:YES];
            
        }
            break;
            
    }
    
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch(indexPath.section){
        case 0:
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            if(indexPath.row==1){
                BindEmailController *bindEmailController = [[BindEmailController alloc] init];
                [self.navigationController pushViewController:bindEmailController animated:YES];
                [bindEmailController release];
            }else if(indexPath.row==2){
                if(loginResult.phone&&loginResult.phone.length>0){
                    UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"sure_to_unbind_phone", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
                    unBindEmailAlert.tag = ALERT_TAG_UNBIND_PHONE;
                    [unBindEmailAlert show];
                    [unBindEmailAlert release];
                }else{
                    BindPhoneController *bindPhoneController = [[BindPhoneController alloc] init];
                    bindPhoneController.accountController = self;
                    [self.navigationController pushViewController:bindPhoneController animated:YES];
                    [bindPhoneController release];
                }
            }
        }
            break;
        case 1:
        {
            if(indexPath.row==0){
                ModifyLoginPasswordController *modifyLoginPasswordController = [[ModifyLoginPasswordController alloc] init];
                [self.navigationController pushViewController:modifyLoginPasswordController animated:YES];
                [modifyLoginPasswordController release];
            }
        }
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_UNBIND_PHONE:
        {
            if(buttonIndex==1){
                
                UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
                inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                //UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                inputAlert.tag = ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD;
                [inputAlert show];
                [inputAlert release];
            }
        }
            break;
        case ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:@"" email:loginResult.email countryCode:@"" phoneCheckCode:@"" flag:@"1" sessionId:loginResult.sessionId callBack:^(id JSON){
                    NSInteger error_code = (NSInteger)JSON;
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.phone = @"";
                            loginResult.countryCode = @"";
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:CustomLocalizedString(@"operator_success", nil)];
                            
                            [self.tableView reloadData];
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:CustomLocalizedString(@"password_error", nil)];
                        }
                            break;
                        case NET_RET_SYSTEM_MAINTENANCE_ERROR:
                        {
                            [self.view makeToast:CustomLocalizedString(@"system_maintenance", nil)];
                        }
                            break;
                        default:
                        {
                            [self.view makeToast:[NSString stringWithFormat:@"%@:%i",CustomLocalizedString(@"unknown_error", nil),error_code]];
                        }
                            break;
                    }
                }];
            }
        }
            
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
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
