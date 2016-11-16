//
//  ModifyNameViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/15.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ModifyNameViewController.h"

#import "RenameCell.h"
#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface ModifyNameViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *modifyNameTB;
@end

@implementation ModifyNameViewController

{
    UITextField *cellTextField;
    NSString *saveStr;
    NSString *tipName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationItem.title = CustomLocalizedString(@"userName", nil);
    
    self.navigationItem.title = @"修改昵称";
    
    if (HLLanguageIsEN) {
        saveStr = @"save";
        tipName = @"Please enter your nickname";
    } else {
        saveStr = @"保存";
        tipName = @"请输入您的昵称";
    }
    
#pragma mark - 保存
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:saveStr block:^{
        [self saveAction];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)saveAction
{
    if (!cellTextField.text.length) {
        [self mb_show:tipName];
        return;
    }
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"id":userModel.id,
                                 @"realName":cellTextField.text};
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
    RenameCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"RenameCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cellTextField = (UITextField *)[cell viewWithTag:10];
    cellTextField.placeholder = @"请输入您的昵称";
    cellTextField.text = self.realName;
    
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
