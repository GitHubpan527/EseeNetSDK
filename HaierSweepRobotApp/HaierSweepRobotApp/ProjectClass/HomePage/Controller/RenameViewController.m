//
//  RenameViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "RenameViewController.h"

#import "RenameCell.h"
#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface RenameViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *renameTB;
@end

@implementation RenameViewController

{
    UITextField *cellTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"重命名";
#pragma mark - 保存
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:@"保存" block:^{
        [self saveAction];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)saveAction
{
    if (!cellTextField.text.length) {
        [self mb_show:@"请输入设备名称"];
        return;
    }
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *requestDic = @{@"userId":userModel.id,
                                 @"id":self.facilityId,
                                 @"name":cellTextField.text};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceUpdate parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
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
    cellTextField.text = self.facilityName;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
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
