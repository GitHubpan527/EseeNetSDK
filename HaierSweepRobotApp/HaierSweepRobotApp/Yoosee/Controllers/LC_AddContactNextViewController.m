//
//  LC_AddContactNextViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/10/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LC_AddContactNextViewController.h"

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

#import "CameraTypeViewController.h"

#import "UIBarButtonItem+LC.h"

@interface LC_AddContactNextViewController ()
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwLabel;
@property (weak, nonatomic) IBOutlet UITextField *idTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *pwTextfield;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoConstraint;
@end

@implementation LC_AddContactNextViewController

{
    NSString *facilityImageUrl;
}

- (IBAction)iconAction:(id)sender {
    CameraTypeViewController *vc = [[CameraTypeViewController alloc] init];
    __weak LC_AddContactNextViewController *weakSelf = self;
    vc.block = ^(NSString *imageUrl) {
        facilityImageUrl = imageUrl;
        [weakSelf.iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:imageUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"海尔"]];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveAction:(id)sender {
    [self onSavePress];
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
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.contactPasswordField];//password strength
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

-(void)initComponent{
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:@"保存" block:^{
        [self onSavePress];
    }];
    
    //ljp
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    if (self.isModifyContact) {//"修改"进入
        self.navigationItem.title = @"摄像头重命名";
    }
    else if (self.isInFromQRCodeNextController) {
        self.navigationItem.title = @"智能联机添加";
    }
    else if (self.isInFromLocalDeviceList) {
        self.navigationItem.title = @"添加摄像头";
    }
    else{//popover in
        //self.navigationItem.title = CustomLocalizedString(@"add_contact", nil);
        
        self.navigationItem.title = @"手动添加";
    }
    
    if(self.isModifyContact){
        self.nameTextfield.text = self.modifyContact.contactName;
        
        self.idTextField.enabled = NO;
        
        self.iconButton.enabled = NO;
        [self.iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:self.selectModel.modelImg] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"海尔"]];
        
    }else if(self.isInFromQRCodeNextController || self.isInFromLocalDeviceList){//缺少的
        //self.nameTextfield.text = [NSString stringWithFormat:@"Cam%@",self.contactId];//isInFromLocalDeviceList
    }
    
    
    //设备密码
    if([self.contactId characterAtIndex:0]!='0'){
        
        if(self.isModifyContact){
            self.pwTextfield.text = self.modifyContact.contactPassword;
        }
    }
    
    //多出的
    if (self.inType == 0) {//inType == 0表示 “修改”进入此界面
        if (self.isInFromQRCodeNextController) {
            self.topView.hidden = YES;
            self.iconButton.hidden = YES;
            
            self.twoConstraint.constant = 20;
        } else {
            self.idTextField.text = self.contactId;
            self.idTextField.enabled = NO;
            
            self.topConstraint.constant = 100;
            self.iconButton.hidden = NO;
        }
        
    }else{//inType == 1表示 “手动添加”进入此界面
        self.topConstraint.constant = 20;
        self.twoConstraint.constant = 70;
        self.iconButton.hidden = YES;
    }

    self.saveButton.layer.masksToBounds = YES;
    self.saveButton.layer.cornerRadius = 3.0;
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
        if(!self.idTextField||!(self.idTextField.text.length>0)){
            [self.view makeToast:CustomLocalizedString(@"input_contact_id", nil)];
            return;
        }
        for (NSInteger i = 0; i < self.idTextField.text.length; i++) {
            if ([self.idTextField.text characterAtIndex:i] < '0' || [self.idTextField.text characterAtIndex:i] > '9') {
                [self.view makeToast:CustomLocalizedString(@"device_id_zero_format_error", nil)];
                return;
            }
        }
        if([self.idTextField.text characterAtIndex:0]=='0'){
            [self.view makeToast:CustomLocalizedString(@"device_id_zero_format_error", nil)];
            return;
        }
        
        if(self.idTextField.text.length>9){
            [self.view makeToast:CustomLocalizedString(@"id_too_long", nil)];
            return;
        }
#pragma mark - 从数据库中查找判断是否存在该ID
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:self.idTextField.text];
        
        if(contact!=nil){
            [self.view makeToast:CustomLocalizedString(@"contact_already_exists", nil)];
            return;
        }
    }
    
    if(!self.nameTextfield||!(self.nameTextfield.text.length>0)){
        [self.view makeToast:CustomLocalizedString(@"input_contact_name", nil)];
        return;
    }
    
    if([self.contactId characterAtIndex:0]!='0'){
        if(!self.pwTextfield||!(self.pwTextfield.text.length>0)){
            [self.view makeToast:CustomLocalizedString(@"input_contact_password", nil)];
            return;
        }
    }
    
    
    if(self.isModifyContact){//修改密码
        self.modifyContact.contactName = self.nameTextfield.text;
        if([self.contactId characterAtIndex:0]!='0'){
            NSString *password = self.pwTextfield.text;
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
        contact.contactId = self.idTextField.text;//不同self.contactId;
        contact.contactName = self.nameTextfield.text;
        
        if([self.contactId characterAtIndex:0]!='0'){
            
            NSString *password = self.pwTextfield.text;
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
        
        if (self.inType == 0) {//inType == 0表示 “修改”进入此界面
            //[self.navigationController popToRootViewControllerAnimated:YES];
            
            if (self.isInFromQRCodeNextController) {
                [self bind:contact];
            } else {//inType == 1表示 “手动添加”进入此界面
                if (facilityImageUrl.length == 0) {
                    [self.view makeToast:@"请选择设备图片"];
                } else {
                    [self bind:contact];
                }
            }
            
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
                   @"name":self.nameTextfield.text,
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
    NSString *password = self.pwTextfield.text;
    NSDictionary *requestDic = [NSDictionary dictionary];
    if (self.contactId) {
        if (self.isFromHomePage) {
            requestDic = @{@"userId":userModel.id,
                           @"modelId":bindId,
                           @"deviceId":self.contactId,
                           @"name":self.nameTextfield.text,
                           @"devicepw":password};
        } else {
            requestDic = @{@"userId":userModel.id,
                           @"modelId":bindId,
                           @"deviceId":self.contactId,
                           @"name":self.nameTextfield.text,
                           @"devicepw":password};
        }
        
    } else {
        requestDic = @{@"userId":userModel.id,
                       @"modelId":bindId,
                       @"deviceId":self.idTextField.text,
                       @"name":self.nameTextfield.text,
                       @"devicepw":password};
    }
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        //接口走通之后再添加本地的设备
        if ([successObject[@"result"] integerValue]) {//添加成功
            [[FListManager sharedFList] myinsert:contact];
            
            [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self.view makeToast:successObject[@"message"]];
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
