//
//  MessageListViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "MessageListViewController.h"

#import "MessageListCell.h"
#import "MessageListModel.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

#pragma mark - 消息详情
#import "MessageDetailViewController.h"

@interface MessageListViewController ()<UITableViewDelegate,UITableViewDataSource,RequestDataDelegate>

@property (weak, nonatomic) IBOutlet BaseTableView *messageListTB;

@end

@implementation MessageListViewController

- (void)requestDataWithRefresh:(BOOL)isRefresh
{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"page":LCStrValue(self.messageListTB.pageIndex),
                              //@"pageSize":LCStrValue(self.messageListTB.pageSize),
                              @"recId":userModel.id,
                              @"bsType":self.type};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FindMessagePage parameters:infoDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            if (isRefresh) {
                [self.messageListTB.dataArray removeAllObjects];
            }
            NSArray *array = [MessageListModel mj_objectArrayWithKeyValuesArray:successObject[@"object"][@"page"][@"recordList"]];
            [self.messageListTB.dataArray addObjectsFromArray:array];
            [self.messageListTB loadSuccess];
        } else {
            [self mb_show:successObject[@"message"]];
            [self.messageListTB loadFailure];
        }
        [self.messageListTB loadSuccess];
    } FailBlock:^(id failObject) {
        [self mb_stop];
        [self.messageListTB loadFailure];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationItem.title = CustomLocalizedString(@"message_item", nil);
    self.navigationItem.title = @"系统消息";

    self.messageListTB.requestDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestData];
}

- (void)requestData
{
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"page":@"1",//LCStrValue(self.messageListTB.pageIndex),
                              //@"pageSize":LCStrValue(self.messageListTB.pageSize),
                              @"recId":userModel.id,
                              @"bsType":self.type};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FindMessagePage parameters:infoDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            //if (isRefresh) {
                [self.messageListTB.dataArray removeAllObjects];
            //}
            NSArray *array = [MessageListModel mj_objectArrayWithKeyValuesArray:successObject[@"object"][@"page"][@"recordList"]];
            [self.messageListTB.dataArray addObjectsFromArray:array];
            [self.messageListTB loadSuccess];
        } else {
            [self mb_show:successObject[@"message"]];
            [self.messageListTB loadFailure];
        }
        [self.messageListTB loadSuccess];
    } FailBlock:^(id failObject) {
        [self mb_stop];
        [self.messageListTB loadFailure];
    }];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.messageListTB.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIde = @"cell1";
    MessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MessageListCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    MessageListModel *model = self.messageListTB.dataArray[indexPath.section];
    cell.titleLabel.text = model.messageText.title;
    cell.contentLabel.text = model.messageText.content;
    if ([model.status isEqualToString:@"1"]) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.contentLabel.textColor = [UIColor blackColor];
    } else {
        cell.titleLabel.textColor = [UIColor lightGrayColor];
        cell.contentLabel.textColor = [UIColor lightGrayColor];
    }
    
    return cell;
  
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageDetailViewController *vc = [[MessageDetailViewController alloc] init];
    MessageListModel *model = self.messageListTB.dataArray[indexPath.section];
    vc.messageId = model.messageId;
    vc.messageTitle = model.messageText.title;
    vc.messageContent = model.messageText.content;
    vc.messageDate = model.messageText.createDate;

    [self.navigationController pushViewController:vc animated:YES];
}

/** 删除信息 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /** 删除 */
        [self mb_normal];
        MessageListModel *model = self.messageListTB.dataArray[indexPath.section];
        NSDictionary *infoDic = @{@"messageId":model.messageId};
        [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:MessageFrontDelete parameters:infoDic successBlock:^(id successObject) {
            [self mb_stop];
            if ([successObject[@"result"] boolValue]) {
                [self.messageListTB.dataArray removeObjectAtIndex:indexPath.section];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self mb_show:successObject[@"message"]];
            }
        } FailBlock:^(id failObject) {
            [self mb_stop];
        }];
    }
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
