//
//  EmailViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "EmailViewController.h"

#import "EmailCell.h"
#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface EmailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *emailTB;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation EmailViewController
{
    NSString *email;
    
    NSString *save;
    NSString *plemail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"userEmail", nil);
    
    if (HLLanguageIsEN) {
        save = @"save";
        plemail = @"Please enter the email address";
    } else {
        save = @"保存";
        plemail = @"请输入邮箱";
    }
#pragma mark - 保存
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:save block:^{
        [self saveAction];
    }];
   
}

- (void)saveAction
{
    if (LCStrIsEmpty(email)) {
        [self mb_show:plemail];
        return;
    }
    
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"id":userModel.id,
                                 @"email":email};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserFrontUpdate parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    email = textField.text;
}


#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cell1";
    EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EmailCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.emailText.delegate = self;
    cell.emailImg.image = [UIImage imageNamed:@"邮箱"];
    cell.emailText.placeholder = plemail;
    cell.imageW.constant = 25.0f;
    cell.imageH.constant = 20.0f;
    
    return cell;
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
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.footerView;
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
