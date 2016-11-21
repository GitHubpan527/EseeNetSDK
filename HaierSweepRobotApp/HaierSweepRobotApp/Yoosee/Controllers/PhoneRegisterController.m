//
//  PhoneRegisterController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "PhoneRegisterController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "RegisterResult.h"
#import "NetManager.h"
#import "Toast+UIView.h"
#import "LoginController.h"
@interface PhoneRegisterController ()

@end

@implementation PhoneRegisterController
-(void)dealloc{
    [self.field1 release];
    [self.field2 release];
    [self.countryCode release];
    [self.loginController release];
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

    
    self.navigationItem.title = CustomLocalizedString(@"register_account",nil);
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:CustomLocalizedString(@"next", nil) block:^{
        [self onNextPress];
    }];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = CustomLocalizedString(@"input_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.secureTextEntry = YES;
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
    field2.placeholder = CustomLocalizedString(@"confirm_input", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.secureTextEntry = YES;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field2 = field2;
    [self.view addSubview:field2];
    [field2 release];
    
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)onNextPress{

    NSString *password = self.field1.text;
    NSString *confirmPassword = self.field2.text;
    

    
    if(!password||!password.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_password", nil)];
        return;
    }
    
    if(password.length>30){
        [self.view makeToast:CustomLocalizedString(@"password_too_long", nil)];
        return;
    }
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![password isEqualToString:confirmPassword]){
        [self.view makeToast:CustomLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    [[NetManager sharedManager] registerWithVersionFlag:@"1" email:@"" countryCode:self.countryCode phone:self.phone password:password repassword:confirmPassword phoneCode:self.phoneCode callBack:^(id JSON) {
        
        RegisterResult *registerResult = (RegisterResult*)JSON;
        
        
        switch(registerResult.error_code){
            case NET_RET_REGISTER_SUCCESS:
            {
                
                if(self.loginController){
                    self.loginController.lastRegisterId = [NSString stringWithFormat:@"%@",registerResult.contactId];
                }
                UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"register_success_prompt", nil) message:[NSString stringWithFormat:@"ID:%@",registerResult.contactId] delegate:self cancelButtonTitle:CustomLocalizedString(@"ok", nil) otherButtonTitles:nil];
                promptAlert.tag = ALERT_TAG_REGISTER_SUCCESS;
                [promptAlert show];
                [promptAlert release];
            }
                break;
            case NET_RET_REGISTER_EMAIL_FORMAT_ERROR:
            {
                [self.view makeToast:CustomLocalizedString(@"email_format_error", nil)];
            }
                break;
            case NET_RET_REGISTER_EMAIL_USED:
            {
                [self.view makeToast:CustomLocalizedString(@"email_used", nil)];
            }
                break;
            case NET_RET_SYSTEM_MAINTENANCE_ERROR:
            {
                [self.view makeToast:CustomLocalizedString(@"system_maintenance", nil)];
            }
                break;
            default:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",CustomLocalizedString(@"unknown_error", nil),registerResult.error_code]];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_REGISTER_SUCCESS:
        {
            if(buttonIndex==0){
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
            break;
    }
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
