//
//  MessageDetailViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "MessageDetailViewController.h"

#import "MessageDetailOneCell.h"
#import "MessageDetailTwoCell.h"

@interface MessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *detailTB;
@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"messageDetail", nil);
  
    [self mb_normal];
    NSDictionary *infoDic = @{@"messageId":self.messageId};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FindMessageDetail parameters:infoDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            
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
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIde = @"cell1";
        MessageDetailOneCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MessageDetailOneCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.typeLabel.text = self.messageTitle;
        cell.timeLabel.text = self.messageDate;
        
        return cell;
    } else {
        static NSString *cellIde = @"cell2";
        MessageDetailTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"MessageDetailTwoCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UILabel *detailL = (UILabel *)[cell viewWithTag:10];
        detailL.adjustsFontSizeToFitWidth = YES;
        detailL.text = self.messageContent;
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44;
    } else {
        CGFloat height = [NSString lc_calculateLabelHeight:self.messageContent labelSize:CGSizeMake(ScreenWidth-25, CGFLOAT_MAX) labelFont:15];
        return height+10;
    }
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
