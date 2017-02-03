//
//  AddFacilityViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AddFacilityViewController.h"

#import "AddFacilityCell.h"

#import "DeviceTypeModel.h"

#import "AddFacilityModel.h"

#import "DetailedItineraryHeaderView.h"

#import "QRCodeController.h"

#import "AddContactNextController.h"

#import "AddIDDeviceViewController.h"

#import "NewAddDevicesViewController.h"


#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface AddFacilityViewController ()<UITableViewDelegate,UITableViewDataSource,RequestDataDelegate>

@property (weak, nonatomic) IBOutlet BaseTableView *facilityTB;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic,strong) DetailedItineraryHeaderView * detailedItineraryHeaderView;
@end

@implementation AddFacilityViewController

- (void)requestDataWithRefresh:(BOOL)isRefresh
{
    [self mb_normal];
    NSDictionary *infoDic = @{@"pageNum":LCStrValue(self.facilityTB.pageIndex),
                              @"pageSize":LCStrValue(self.facilityTB.pageSize)};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceTypeFrontFindAll parameters:nil successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            if (isRefresh) {
                //[self.facilityTB.dataArray removeAllObjects];
            }
            [self.facilityTB.dataArray removeAllObjects];
            
            NSArray *array = [DeviceTypeModel mj_objectArrayWithKeyValuesArray:successObject[@"object"]];
            [self.facilityTB.dataArray addObjectsFromArray:array];
            [self.facilityTB loadSuccess];
        } else {
            [self mb_show:successObject[@"message"]];
            [self.facilityTB loadFailure];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
        [self.facilityTB loadFailure];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"addDevice", nil);
    [self.facilityTB registerClass:[DetailedItineraryHeaderView class] forHeaderFooterViewReuseIdentifier:@"DetailedItineraryHeaderView"];
    self.facilityTB.requestDelegate = self;
    self.facilityTB.mj_footer.hidden = YES;
#pragma mark - 刷新按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithIcon:@"更新-(1)" block:^{
        //[self.facilityTB.mj_header beginRefreshing];
        [self requestDataWithRefresh:YES];
    }];
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - tableView/delegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.facilityTB.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    DeviceTypeModel * model = self.facilityTB.dataArray[section];
    
    return model.isExpanded ?  model.deviceModelList.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cell";
    AddFacilityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"AddFacilityCell" owner:self options:nil].firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    DeviceTypeModel * deviceTypeModel = self.facilityTB.dataArray[indexPath.section];
    AddFacilityModel * model = deviceTypeModel.deviceModelList[indexPath.row];
    
    
    cell.listModel = model;
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DeviceListViewController *vc = [[DeviceListViewController alloc] init];
//    DeviceTypeModel *model = self.facilityTB.dataArray[indexPath.row];
//    vc.typeId = model.id;
//    vc.typeName = model.deviceTypeName;
//    vc.sortBy = model.sortBy;
//    [self.navigationController pushViewController:vc animated:YES];
    
    DeviceTypeModel * deviceTypeModel = self.facilityTB.dataArray[indexPath.section];
    AddFacilityModel * model = deviceTypeModel.deviceModelList[indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:model.id forKey:@"BindIdKey"];
    [[NSUserDefaults standardUserDefaults] setObject:model.deviceModelName forKey:@"BindNameKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.isHomePage) {
//        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//        addContactNextController.isPopRoot = NO;//isPopRoot
//        addContactNextController.isInFromLocalDeviceList = YES;
//        [addContactNextController setContactId:self.contactId];
//        //ljp
//        addContactNextController.isFromHomePage = YES;
//        [self.navigationController pushViewController:addContactNextController animated:YES];
        
        LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
        addContactNextController.isPopRoot = NO;//isPopRoot
        addContactNextController.isInFromLocalDeviceList = YES;
        [addContactNextController setContactId:self.contactId];
        //ljp
        addContactNextController.isFromHomePage = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
    } else {
        
        if ([deviceTypeModel.sortBy isEqualToString:@"2"]) {//摄像头
            
            if (indexPath.row == 0) {
                NSLog(@"久安摄像头");
                //HL_ALERT(CustomLocalizedString(@"prompt", nil), @"久安摄像头");
                
                AddIDDeviceViewController *device = [[AddIDDeviceViewController alloc] init];
                [self.navigationController pushViewController:device animated:YES
                 ];
                
            }else{//技威方案
                NewAddDevicesViewController *newadddDevicesVC = [[NewAddDevicesViewController alloc] init];
//                QRCodeController *qrcodeController = [[QRCodeController alloc] init];
                if (indexPath.row == 1) {
                    //云台机
                    newadddDevicesVC.type = 1;
                }else if (indexPath.row == 2){
                    //570-W
                    newadddDevicesVC.type = 2;
                }
                [self.navigationController pushViewController:newadddDevicesVC animated:YES];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    __weak typeof (self)myself = self;
    _detailedItineraryHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DetailedItineraryHeaderView"];
    
    _detailedItineraryHeaderView.contentView.backgroundColor = [UIColor whiteColor];
    DeviceTypeModel *model = self.facilityTB.dataArray[section];
    _detailedItineraryHeaderView.model1 = model;
    
    _detailedItineraryHeaderView.expandCallback = ^(BOOL isExpanded) {
    
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
             withRowAnimation:UITableViewRowAnimationFade];
    };
    
    return _detailedItineraryHeaderView;
}

@end
