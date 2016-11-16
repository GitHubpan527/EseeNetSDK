//
//  MessageTypeViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/13.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "MessageTypeViewController.h"

#pragma mark - 系统消息
#import "MessageListViewController.h"

#pragma mark - 摄像头消息
#import "MessageController.h"

#pragma mark - 扫地机消息
#import "RobotMessageViewController.h"

#import "MessageTypeCell.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface MessageTypeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *messageTypeTB;
@end

@implementation MessageTypeViewController
{
    NSString *systomCount;
    NSString *cameraCount;
    NSString *robotCount;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self requestMessageCount:@"1"];
    [self requestMessageCount:@"2"];
    [self requestMessageCount:@"3"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"AppMessage", nil);
    
    // Do any additional setup after loading the view from its nib.
}

- (void)requestMessageCount:(NSString *)type
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"recId":userModel.id,
                              @"status":@"1",
                              @"bsType":type};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FindMessageCount parameters:infoDic successBlock:^(id successObject) {
        if (LCStrEqual(type, @"1")) {
            systomCount = [successObject[@"object"][@"count"] stringValue];
        }
        if (LCStrEqual(type, @"2")) {
            robotCount = [successObject[@"object"][@"count"] stringValue];
        }
        if (LCStrEqual(type, @"3")) {
            cameraCount = [successObject[@"object"][@"count"] stringValue];
        }
        [self.messageTypeTB reloadData];
    } FailBlock:^(id failObject) {
        //失败
    }];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 3;
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cell";
    MessageTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MessageTypeCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIView *iconView = (UIView *)[cell viewWithTag:30];
    if (indexPath.section == 0) {
        iconView.backgroundColor = [UIColor lc_colorWithR:233 G:58 B:66 alpha:1.0];
    }
    else if (indexPath.section == 1) {
        iconView.backgroundColor = [UIColor lc_colorWithR:246 G:165 B:24 alpha:1.0];
    }
    /*
    else if (indexPath.section == 2) {
        iconView.backgroundColor = [UIColor lc_colorWithR:100 G:180 B:45 alpha:1.0];
    }
     */
    
    //NSArray *titleArray = @[@"系统消息",@"摄像头",@"扫地机"];
    NSArray *titleArray = @[@"系统消息",@"摄像头"];

    UILabel *typeLabel = (UILabel *)[cell viewWithTag:20];
    typeLabel.text = titleArray[indexPath.section];

    //NSArray *imageArray = @[@"系统消息-0",@"摄像机消息-0",@"扫地机消息-0"];
    NSArray *imageArray = @[@"系统消息-0",@"摄像机消息-0"];

    UIImageView *iconImageView = (UIImageView *)[iconView viewWithTag:10];
    iconImageView.image = LCImage(imageArray[indexPath.section]);
    
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 20, 20, 20)];
    countLabel.layer.masksToBounds = YES;
    countLabel.layer.cornerRadius = 10.0;
    countLabel.backgroundColor = [UIColor redColor];
    countLabel.font = [UIFont systemFontOfSize:12];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:countLabel];
    if (indexPath.section == 0) {
        if (LCStrEqual(systomCount, @"0")) {
            countLabel.hidden = YES;
        } else {
            countLabel.text = systomCount;
        }
    }
    if (indexPath.section == 1) {
        if (LCStrEqual(cameraCount, @"0")) {
            countLabel.hidden = YES;
        } else {
            countLabel.text = cameraCount;
        }
    }
    /*
    if (indexPath.section == 2) {
        if (LCStrEqual(robotCount, @"0")) {
            countLabel.hidden = YES;
        } else {
            countLabel.text = robotCount;
        }
    }
     */
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//系统消息
        MessageListViewController *vc = [[MessageListViewController alloc] init];
        vc.type = @"1";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 1) {//摄像头消息
        MessageController *vc = [[MessageController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    /*
    else if (indexPath.section == 2) {//扫地机消息
        RobotMessageViewController *vc = [[RobotMessageViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
     */
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
