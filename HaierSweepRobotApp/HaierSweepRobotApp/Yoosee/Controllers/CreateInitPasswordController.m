//
//  CreateInitPasswordController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "CreateInitPasswordController.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "MainController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "FListManager.h"
#import "Toast+UIView.h"
#import "TopBar.h"
//#import "ParingSettingViewController.h" //useless
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"
#import "MD5Manager.h"

#import "LoginUserModel.h"

#import "LoginUserDefaults.h"

#import "UIBarButtonItem+LC.h"
@interface CreateInitPasswordController ()

@end

@implementation CreateInitPasswordController
-(void)dealloc{
    [self.address release];
    [self.contactId release];
    [self.contactNameField release];
    [self.contactPasswordField release];
    [self.contentView release];
    [self.pwdStrengthView release];//password strength1
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
-(void)viewDidAppear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];//password strength1
   
}

-(void)viewWillDisappear:(BOOL)animated{
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];//password strength1
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key = [[parameter valueForKey:@"key"] intValue];
    switch(key){
       
        case RET_SET_INIT_PASSWORD:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            if(result==0){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:self.contactId];
                [contactDAO release];
                
                if(contact!=nil){
                    contact.contactName = self.contactNameField.text;
                    contact.contactPassword = self.lastSetPassword;//updatepwd
                    
                    [[FListManager sharedFList] update:contact];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:CustomLocalizedString(@"operator_success", nil)];
			
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            usleep(800000);
                            dispatch_async(dispatch_get_main_queue(), ^{
			    //不同
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            });
                        });
                    });
                }else{
                    
                    #warning 添加
                    [self add];
                }
            }else if(result==43){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:CustomLocalizedString(@"device_already_exist_password", nil)];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:CustomLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
    }
    
}
- (void)add{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSString *bindId = [[NSUserDefaults standardUserDefaults] objectForKey:@"BindIdKey"];
    
    NSDictionary *requestDic = [NSDictionary dictionary];
    if (self.contactId) {
        requestDic = @{@"userId":userModel.id,
                       @"modelId":bindId,
                       @"deviceId":self.contactId,
                       @"name":self.contactNameField.text,
                       @"devicepw":self.lastSetPassword};
    } else {
        requestDic = @{@"userId":userModel.id,
                       @"modelId":bindId,
                       @"deviceId":self.contactId,
                       @"name":self.contactNameField.text,
                       @"devicepw":self.lastSetPassword};
    }
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        //接口走通之后再添加本地的设备
        if ([successObject[@"result"] integerValue]) {//添加成功
            Contact *contact = [[Contact alloc] init];
            contact.contactId = self.contactId;
            contact.contactName = self.contactNameField.text;
            
            contact.contactPassword = self.lastSetPassword;
            contact.contactType = CONTACT_TYPE_UNKNOWN;
            [[FListManager sharedFList] myinsert:contact];
            
            [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
            [contact release];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:CustomLocalizedString(@"operator_success", nil)];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    usleep(800000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //不同
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                });
            });
            
            //[self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self mb_stop];
            [self.view makeToast:successObject[@"message"]];
        }
        
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];

}
- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_SET_INIT_PASSWORD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:CustomLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    [[P2PClient sharedClient] setInitPasswordWithId:self.contactId initPassword:self.lastSetPassword];
                }
            });
            DLog(@"ACK_RET_SET_INIT_PASSWORD:%i",result);
        }
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

//多余的
/*
#pragma mark 配对传感器
-(void)paringSetting{
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    NSString *newPassword = self.contactPasswordField.text;
    NSString *confirmPassword = self.confirmPasswordField.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_password", nil)];
        return;
    }
    
    
    if([predicate evaluateWithObject:newPassword]==NO){
        [self.view makeToast:CustomLocalizedString(@"password_number_format_error", nil)];
        return;
    }
    
    if([newPassword characterAtIndex:0]=='0'){
        [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
        return;
    }
    
    if(newPassword.length>10){
        [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
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
    
    self.lastSetPassword = self.contactPasswordField.text;
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    
    if(self.address&&[self.address length]>0){
        NSArray *array = [self.address componentsSeparatedByString:@"."];
        
        [[P2PClient sharedClient] setInitPasswordWithId:[array objectAtIndex:3] initPassword:self.lastSetPassword];
    }else{
        [[P2PClient sharedClient] setInitPasswordWithId:self.contactId initPassword:self.lastSetPassword];
    }
    
    Contact *contact = [[Contact alloc] init];
    contact.contactId = self.contactId;
    contact.contactName = self.contactNameField.text;
    contact.contactPassword = self.contactPasswordField.text;
    
    if([self.contactId characterAtIndex:0]!='0'){
        
        NSString *password = self.contactPasswordField.text;
        if([password characterAtIndex:0]=='0'){
            [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
            return;
        }
        
        if(password.length>10){
            [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
            return;
        }
        
        contact.contactPassword = password;
        contact.contactType = CONTACT_TYPE_UNKNOWN;
    }else{
        contact.contactType = CONTACT_TYPE_PHONE;
    }
    [[FListManager sharedFList] insert:contact];
    
    [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
    [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
    [contact release];
//    ParingSettingViewController *paringSetting = [[ParingSettingViewController alloc] init];
//    [paringSetting setContactId:contact.contactId];
//    [paringSetting setContactPassword:contact.contactPassword];
//    [self.navigationController pushViewController:paringSetting animated:YES];
//    [paringSetting release];

}
//未知用处
#pragma mark 点击完成
-(void)finishedClick{
    NSString *newPassword = self.contactPasswordField.text;
    NSString *confirmPassword = self.confirmPasswordField.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_password", nil)];
        return;
    }
    
    if([predicate evaluateWithObject:newPassword]==NO){
        [self.view makeToast:CustomLocalizedString(@"password_number_format_error", nil)];
        return;
    }
    
    if([newPassword characterAtIndex:0]=='0'){
        [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
        return;
    }
    
    if(newPassword.length>10){
        [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
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
    
    Contact *contact = [[Contact alloc] init];
    contact.contactId = self.contactId;
    contact.contactName = self.contactNameField.text;

    
    if([self.contactId characterAtIndex:0]!='0'){
        
        NSString *password = self.contactPasswordField.text;
        if([password characterAtIndex:0]=='0'){
            [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
            return;
        }
        
        if(password.length>10){
            [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
            return;
        }
        
        contact.contactPassword = password;
        contact.contactType = CONTACT_TYPE_UNKNOWN;
    }else{
        contact.contactType = CONTACT_TYPE_PHONE;
    }
    [[FListManager sharedFList] insert:contact];
    
    [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
    [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
    [contact release];
    [self.navigationController popViewControllerAnimated:YES];
} 
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;

    
    self.navigationItem.title = @"智能联机添加";
    
    self.view.userInteractionEnabled = YES;//多出
    

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    self.contentView = contentView;
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
//    field1.placeholder = CustomLocalizedString(@"input_contact_name", nil);
//    field1.text = [NSString stringWithFormat:@"Cam%@", self.contactId];//多出的
    field1.placeholder = @"请设置一个摄像头名称";
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:self.contactId];
    [contactDAO release];
    if(contact!=nil){
        field1.text = contact.contactName;
    //}else{//缺少的
    //    field1.text = [NSString stringWithFormat:@"Cam%@",self.contactId];
    }
    field1.tag = 11;//password strength1
    field1.delegate = self;//password strength1
    [contentView addSubview:field1];
    self.contactNameField = field1;
    [field1 release];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, field1.frame.origin.y+20+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    promptLabel.backgroundColor = XBGAlpha;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = XFontBold_16;
    promptLabel.textColor = [UIColor redColor];
    promptLabel.text = CustomLocalizedString(@"create_init_password_prompt", nil);
    promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
    promptLabel.numberOfLines = 0;
//    [contentView addSubview:promptLabel];
    [promptLabel release];
    
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, field1.frame.origin.y+20+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
//    field2.placeholder = CustomLocalizedString(@"input_contact_password", nil);
    field2.placeholder = @"至少6位的字母和数字的密码";
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field2.secureTextEntry = YES;
    field2.tag = 12;//password strength1
    field2.delegate = self;//password strength1
    [contentView addSubview:field2];
    self.contactPasswordField = field2;
    
    
    
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, field2.frame.origin.y+20+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field3.layer.borderWidth = 1;
        field3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field3.layer.cornerRadius = 5.0;
    }
    field3.textAlignment = NSTextAlignmentLeft;
//    field3.placeholder = CustomLocalizedString(@"confirm_input", nil);
    field3.placeholder = @"请确认输入";
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.returnKeyType = UIReturnKeyDone;
    
    field3.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    field3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field3.secureTextEntry = YES;
    field3.tag = 13;//password strength1
    field3.delegate = self;//password strength1
    [contentView addSubview:field3];
    self.confirmPasswordField = field3;
    [field3 release];
    
    [field2 release];
    
    /*
    //password strength1
    //密码强度UI显示，红（弱）、橙（中）、绿（强）3种强度
    UIView *pwdStrengthView = [[UIView alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.confirmPasswordField.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT/2)];
    [contentView addSubview:pwdStrengthView];
    [pwdStrengthView setHidden:YES];
    self.pwdStrengthView = pwdStrengthView;
    [pwdStrengthView release];
    //
    CGFloat indicatorViewWidth = (self.pwdStrengthView.frame.size.width-4-60.0)/3;
    for (int i = 0; i < 3; i++) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(i*(indicatorViewWidth+2), (self.pwdStrengthView.frame.size.height-progressView.frame.size.height)/2, indicatorViewWidth, 20.0);
        //更改进度条高度
        //progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
        progressView.tag = 100+i;
        [self.pwdStrengthView addSubview:progressView];
        [progressView release];
    }
    //弱、中、强文字
    UILabel *pwdStrengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(3*(indicatorViewWidth+2), (self.pwdStrengthView.frame.size.height-20.0)/2, 60.0, 20.0)];
    pwdStrengthLabel.text = CustomLocalizedString(@"weak", nil);
    pwdStrengthLabel.textColor = XBlack_128;
    pwdStrengthLabel.textAlignment = NSTextAlignmentLeft;
    pwdStrengthLabel.tag = 1111;
    pwdStrengthLabel.backgroundColor = XBGAlpha;
    [pwdStrengthLabel setFont:XFontBold_14];
    [self.pwdStrengthView addSubview:pwdStrengthLabel];
    [pwdStrengthLabel release];
    */
    
    [self.view addSubview:contentView];
    [contentView release];

//    UIImageView *btnBGView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 37)];
//    btnBGView.userInteractionEnabled = YES;
//    btnBGView.image = [UIImage imageNamed:@"add_camera_bgView.png"];
//    [self.view addSubview:btnBGView];
//    
//    UIButton *addSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [addSettingBtn setFrame:CGRectMake(10, 2, 300, 32)];
//    [addSettingBtn setTitle:@"添加共享设备" forState:UIControlStateNormal];
//    [addSettingBtn addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
//    [addSettingBtn setBackgroundImage:[UIImage imageNamed:@"add_camera_bg.png"] forState:UIControlStateNormal];
//    [btnBGView addSubview:addSettingBtn];
    
    
    /*
    //多出的
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-120, 300, 32)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [finishButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [finishButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [finishButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [finishButton setTitle:CustomLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [self.view addSubview:finishButton];
     */
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:@"保存" block:^{
        [self onSavePress];
    }];
    
    [self.view setBackgroundColor:XBgColor];
    
}

//-(void)onKeyBoardWillShow:(NSNotification*)notification{
//    NSDictionary *userInfo = [notification userInfo];
//    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    DLog(@"%f",rect.size.height);
//    
//    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
//                    animations:^{
//                        CGFloat offset1 = self.contentView.frame.size.height-(self.confirmPasswordField.frame.origin.y+self.confirmPasswordField.frame.size.height);
//                        CGFloat finalOffset;
//                        if(offset1-rect.size.height<0){
//                            finalOffset = rect.size.height-offset1+30;
//                        }else if(offset1-rect.size.height>=0){
//                            if(offset1-rect.size.height>=30){
//                                finalOffset = 0;
//                            }else{
//                                finalOffset = 30-(offset1-rect.size.height);
//                            }
//                            
//                        }
//                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
//                    }
//                    completion:^(BOOL finished) {
//                        
//                    }
//     ];
//}

//-(void)onKeyBoardWillHide:(NSNotification*)notification{
//    DLog(@"onKeyBoardWillHide");
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
//                    animations:^{
//                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
//                    }
//                    completion:^(BOOL finished) {
//                        
//                    }
//     ];
//}

-(void)onBackPress{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    if(self.isPopRoot){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)onSavePress{
    //密码过于简单，请重新输入
    int pwdStrength = [Utils pwdStrengthWithPwd:self.contactPasswordField.text];
    if (pwdStrength == password_weak) {//弱（红）
        [self.view makeToast:CustomLocalizedString(@"pwd_too_simple", nil)];
        return;        
    }
    
    
    NSString *newPassword = self.contactPasswordField.text;
    NSString *confirmPassword = self.confirmPasswordField.text;
    
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_password", nil)];
        return;
    }
    
    if([newPassword characterAtIndex:0]=='0'){
        [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
        return;
    }
    
    if(newPassword.length>30){
        [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
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
    
    self.lastSetPassword = [Utils GetTreatedPassword:newPassword];
    
    
    [[P2PClient sharedClient] setInitPasswordWithId:self.contactId initPassword:self.lastSetPassword];
    

}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{//password strength1
    if (textField.tag == 12) {
        //开始进入编辑状态，显示密码强度
        [self.pwdStrengthView setHidden:NO];
    }else{
        //隐藏密码强度
        [self.pwdStrengthView setHidden:YES];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //隐藏密码强度
    [self.pwdStrengthView setHidden:YES];
    
    return YES;
}

#pragma mark - UITextFieldTextDidChangeNotification
//已经开始编辑
- (void)textFieldChanged:(id)sender//password strength1
{
    //显示密码的强度
    UIProgressView *progressView100 = (UIProgressView *)[self.pwdStrengthView viewWithTag:100];
    UIProgressView *progressView101 = (UIProgressView *)[self.pwdStrengthView viewWithTag:101];
    UIProgressView *progressView102 = (UIProgressView *)[self.pwdStrengthView viewWithTag:102];
    UILabel *pwdStrengthLabel = (UILabel *)[self.pwdStrengthView viewWithTag:1111];
    
    int pwdStrength = [Utils pwdStrengthWithPwd:self.contactPasswordField.text];
    if (pwdStrength == password_weak) {//弱（红）
        progressView100.progress = 1.0;
        progressView101.progress = 0.0;
        progressView102.progress = 0.0;
        progressView100.progressTintColor = [UIColor colorWithRed:249/255.0 green:0.0 blue:6/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = CustomLocalizedString(@"weak", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:249/255.0 green:0.0 blue:6/255.0 alpha:1.0];
    }else if (pwdStrength == password_middle){//中（橙）
        progressView100.progress = 1.0;
        progressView101.progress = 1.0;
        progressView102.progress = 0.0;
        progressView100.progressTintColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
        progressView101.progressTintColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = CustomLocalizedString(@"general", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
    }else if (pwdStrength == password_strong){//强（绿）
        progressView102.progress = 1.0;
        progressView101.progress = 1.0;
        progressView102.progress = 1.0;
        progressView100.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        progressView101.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        progressView102.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = CustomLocalizedString(@"strong", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
    }else{
        progressView100.progress = 0.0;
        progressView101.progress = 0.0;
        progressView102.progress = 0.0;
        //文字
        pwdStrengthLabel.text = CustomLocalizedString(@"weak", nil);
        pwdStrengthLabel.textColor = XBlack_128;
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
