//
//  AddContactNextController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AddContactNextController.h"
#import "TopBar.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "FListManager.h"
#import "MainController.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"//多出的
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"//缺少的
#import "RecommendInfo.h"//缺少的
#import "RecommendInfoDAO.h"//缺少的
#import "MD5Manager.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"
#import "MyFacilityModel.h"
@interface AddContactNextController ()

@end


@implementation AddContactNextController
-(void)dealloc{
    [self.contactId release];
    [self.contactNameField release];
    [self.contactPasswordField release];
    [self.modifyContact release];
    [self.pwdStrengthView release];//password strength
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //ljp
    self.isFromHomePage = NO;
    
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];//password strength
    
    /*
     *移除对键盘将要显示、收起的监听
     */
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];//password strength
    #warning 暂时先注释掉
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    /*
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:YES];//不同
//    [topBar setRightButtonText:CustomLocalizedString(@"save", nil)];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
//    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    if (self.isModifyContact || self.isInFromLocalDeviceList || self.isInFromQRCodeNextController) {//"修改"进入
        [topBar setTitle:self.contactId];
    }else{//popover in
        [topBar setTitle:CustomLocalizedString(@"add_contact", nil)];
    }
    
    [self.view addSubview:topBar];
    [topBar release];
    
    //多出的
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-50, 300, 34)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:CustomLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    [self.view setBackgroundColor:XBgColor];
    
    //多出的
    //设备ID
    UITextField *field0 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field0.layer.borderWidth = 1;
        field0.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field0.layer.cornerRadius = 5.0;
    }
    
    field0.textAlignment = NSTextAlignmentLeft;
    field0.placeholder = CustomLocalizedString(@"input_contact_id", nil);
    field0.borderStyle = UITextBorderStyleRoundedRect;
    field0.returnKeyType = UIReturnKeyDone;
    field0.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field0.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field0.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field0.tag = 10;//password strength
    field0.delegate = self;//password strength
    [self.view addSubview:field0];
    self.contactIdField = field0;
    [field0 release];
    
    //设备Name
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
   
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = CustomLocalizedString(@"input_contact_name", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if(self.isModifyContact){
        field1.text = self.modifyContact.contactName;
    }else if(self.isInFromQRCodeNextController || self.isInFromLocalDeviceList){//缺少的
        field1.text = [NSString stringWithFormat:@"Cam%@",self.contactId];//isInFromLocalDeviceList
    }
    field1.tag = 11;//password strength
    field1.delegate = self;//password strength
    [self.view addSubview:field1];
    self.contactNameField = field1;
    [field1 release];
    
    //设备密码
    if([self.contactId characterAtIndex:0]!='0'){
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = CustomLocalizedString(@"input_contact_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field2.secureTextEntry = YES;
    if(self.isModifyContact){
        field2.text = self.modifyContact.contactPassword;
    }
    field2.tag = 12;//password strength
    field2.delegate = self;//password strength
    [self.view addSubview:field2];
    self.contactPasswordField = field2;
    [field2 release];
    }
    
    //多出的
    if (self.inType == 0) {//inType == 0表示 “修改”进入此界面
        self.contactIdField.hidden = YES;//隐藏device ID Field
        self.contactIdField.text = self.contactId;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        
    }else{//inType == 1表示 “手动添加”进入此界面
        self.contactIdField.hidden = NO;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame =CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }
    
    //password strength
    //密码强度UI显示，红（弱）、橙（中）、绿（强）3种强度
    UIView *pwdStrengthView = [[UIView alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.contactPasswordField.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT/2)];
    [self.view addSubview:pwdStrengthView];
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
    
    //ljp
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;

    if (self.isModifyContact || self.isInFromLocalDeviceList || self.isInFromQRCodeNextController) {//"修改"进入
        self.navigationItem.title = self.contactId;
    }else{//popover in
        //self.navigationItem.title = CustomLocalizedString(@"add_contact", nil);
        
        self.navigationItem.title = @"手动添加";
    }
    
    //多出的
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-120, 300, 34)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    //[saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    //[saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    saveButton.backgroundColor = [UIColor colorWithRed:48/255.0 green:155/255.0 blue:228/255.0 alpha:1.0];
    saveButton.layer.masksToBounds = YES;
    saveButton.layer.cornerRadius = 5.0;
    [saveButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:CustomLocalizedString(@"save", nil) forState:UIControlStateNormal];
    [self.view addSubview:saveButton];
    
    [self.view setBackgroundColor:XBgColor];
    
    //多出的
    //设备ID
    UITextField *field0 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field0.layer.borderWidth = 1;
        field0.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field0.layer.cornerRadius = 5.0;
    }
    
    field0.textAlignment = NSTextAlignmentLeft;
    field0.placeholder = CustomLocalizedString(@"input_contact_id", nil);
    field0.borderStyle = UITextBorderStyleRoundedRect;
    field0.returnKeyType = UIReturnKeyDone;
    field0.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field0.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field0.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field0.tag = 10;//password strength
    field0.delegate = self;//password strength
    [self.view addSubview:field0];
    self.contactIdField = field0;
    [field0 release];
    
    //设备Name
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = CustomLocalizedString(@"input_contact_name", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if(self.isModifyContact){
        field1.text = self.modifyContact.contactName;
    }else if(self.isInFromQRCodeNextController || self.isInFromLocalDeviceList){//缺少的
        field1.text = [NSString stringWithFormat:@"Cam%@",self.contactId];//isInFromLocalDeviceList
    }
    field1.tag = 11;//password strength
    field1.delegate = self;//password strength
    [self.view addSubview:field1];
    self.contactNameField = field1;
    [field1 release];
    
    //设备密码
    if([self.contactId characterAtIndex:0]!='0'){
        UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
        
        if(CURRENT_VERSION>=7.0){
            field2.layer.borderWidth = 1;
            field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
            field2.layer.cornerRadius = 5.0;
        }
        field2.textAlignment = NSTextAlignmentLeft;
        field2.placeholder = CustomLocalizedString(@"input_contact_password", nil);
        field2.borderStyle = UITextBorderStyleRoundedRect;
        field2.returnKeyType = UIReturnKeyDone;
        field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field2.secureTextEntry = YES;
        if(self.isModifyContact){
            field2.text = self.modifyContact.contactPassword;
        }
        field2.tag = 12;//password strength
        field2.delegate = self;//password strength
        [self.view addSubview:field2];
        self.contactPasswordField = field2;
        [field2 release];
    }
    
    //多出的
    if (self.inType == 0) {//inType == 0表示 “修改”进入此界面
        self.contactIdField.hidden = YES;//隐藏device ID Field
        self.contactIdField.text = self.contactId;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+80, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        
    }else{//inType == 1表示 “手动添加”进入此界面
        self.contactIdField.hidden = NO;
        self.contactNameField.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
        self.contactPasswordField.frame =CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 80+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    }
    
    //password strength
    //密码强度UI显示，红（弱）、橙（中）、绿（强）3种强度
    UIView *pwdStrengthView = [[UIView alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.contactPasswordField.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT/2)];
    [self.view addSubview:pwdStrengthView];
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
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    //keyBoard frame
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.view.frame.size.height - self.pwdStrengthView.frame.origin.y - self.pwdStrengthView.frame.size.height;
                        
                        CGFloat finalOffset;
                        if(offset1-rect.size.height<0){
                            finalOffset = rect.size.height-offset1+10;
                        }else {
                            if(offset1-rect.size.height>=10){
                                finalOffset = 0;
                            }else{
                                finalOffset = 10-(offset1-rect.size.height);
                            }
                        }
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onBackPress{
    if(self.isPopRoot){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)onSavePress{
    
    if (self.isInFromManuallAdd) {//手动添加，判断id的有效性
        if(!self.contactIdField||!(self.contactIdField.text.length>0)){
            [self.view makeToast:CustomLocalizedString(@"input_contact_id", nil)];
            return;
        }
        
        for (NSInteger i = 0; i < self.contactIdField.text.length; i++) {
            if ([self.contactIdField.text characterAtIndex:i] < '0' || [self.contactIdField.text characterAtIndex:i] > '9') {
                [self.view makeToast:CustomLocalizedString(@"device_id_zero_format_error", nil)];
                return;
            }
        }
        if([self.contactIdField.text characterAtIndex:0]=='0'){
            [self.view makeToast:CustomLocalizedString(@"device_id_zero_format_error", nil)];
            return;
        }
        
        if(self.contactIdField.text.length>9){
            [self.view makeToast:CustomLocalizedString(@"id_too_long", nil)];
            return;
        }
        
        
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:self.contactIdField.text];
        
        if(contact!=nil){
            [self.view makeToast:CustomLocalizedString(@"contact_already_exists", nil)];
            return;
        }
    }
    
    if(!self.contactNameField||!self.contactNameField.text.length>0){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    if([self.contactId characterAtIndex:0]!='0'){
        if(!self.contactPasswordField||!self.contactPasswordField.text.length>0){
            [self.view makeToast:CustomLocalizedString(@"input_contact_password", nil)];
            return;
        }
    }
    
    
    if(self.isModifyContact){//修改密码
        self.modifyContact.contactName = self.contactNameField.text;
        if([self.contactId characterAtIndex:0]!='0'){
            NSString *password = self.contactPasswordField.text;
            if (![password isEqualToString:self.modifyContact.contactPassword]) {
                if([password characterAtIndex:0]=='0'){
                    [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
                    return;
                }
                
                if(password.length>30){
                    [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
                    return;
                }
                
                self.modifyContact.contactPassword = [Utils GetTreatedPassword:password];
            }
        }
        
        [self ModifyName];
    }else{//手动添加
        Contact *contact = [[Contact alloc] init];
        contact.contactId = self.contactIdField.text;//不同self.contactId;
        contact.contactName = self.contactNameField.text;
        
        if([self.contactId characterAtIndex:0]!='0'){
            
            NSString *password = self.contactPasswordField.text;
            if([password characterAtIndex:0]=='0'){
                [self.view makeToast:CustomLocalizedString(@"password_zero_format_error", nil)];
                return;
            }
            
            if(password.length>30){
                [self.view makeToast:CustomLocalizedString(@"device_password_too_long", nil)];
                return;
            }
            
            contact.contactPassword = [Utils GetTreatedPassword:password];
            contact.contactType = CONTACT_TYPE_UNKNOWN;
        }else{
            contact.contactType = CONTACT_TYPE_PHONE;
        }

        
        
        if (self.inType == 0) {
            //[self.navigationController popToRootViewControllerAnimated:YES];
            [self bind:contact];
        }else if (self.inType == 1){
            //[self.navigationController popToRootViewControllerAnimated:YES];
            [self bind:contact];
        }
        
    }
}
/**
 *  @author zhengju, 16-09-28 17:09:26
 *
 *  @brief 修改名称
 */
- (void)ModifyName{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = [NSDictionary dictionary];
    requestDic = @{@"userId":userModel.id,
                   @"name":self.contactNameField.text,
                   @"id":self.selectModel.id
                   };
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:@"userDeviceFront/update" parameters:requestDic successBlock:^(id successObject) {
         [self mb_stop];
        
        if ([successObject[@"result"] integerValue]) {//修改成功
            [[FListManager sharedFList] getDefenceStates];
            [[FListManager sharedFList] myupdate:self.modifyContact];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
       
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}
- (void)bind:(Contact *)contact {
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSString *bindId = [[NSUserDefaults standardUserDefaults] objectForKey:@"BindIdKey"];
    NSString *bindName = [[NSUserDefaults standardUserDefaults] objectForKey:@"BindNameKey"];
    NSString *password = self.contactPasswordField.text;
    NSDictionary *requestDic = [NSDictionary dictionary];
    if (self.contactId) {
        if (self.isFromHomePage) {
            requestDic = @{@"userId":userModel.id,
                           @"modelId":bindId,
                           @"deviceId":self.contactId,
                           @"name":self.contactNameField.text,
                           @"devicepw":password};
        } else {
            requestDic = @{@"userId":userModel.id,
                           @"modelId":bindId,
                           @"deviceId":self.contactId,
                           @"name":self.contactNameField.text,
                           @"devicepw":password};
        }
        
    } else {
        requestDic = @{@"userId":userModel.id,
                      @"modelId":bindId,
                     @"deviceId":self.contactIdField.text,
                       @"name":self.contactNameField.text,
                     @"devicepw":password};
    }
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        //接口走通之后再添加本地的设备
        if ([successObject[@"result"] integerValue]) {//添加成功
            [[FListManager sharedFList] myinsert:contact];
            
            [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
            
            [contact release];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self.view makeToast:successObject[@"message"]];
        }
        
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{//password strength
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
- (void)textFieldChanged:(id)sender//password strength
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

#pragma mark -
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
