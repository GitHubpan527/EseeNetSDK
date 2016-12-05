//
//  CameraTypeViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/10/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "CameraTypeViewController.h"

#import "AddFacilityCell.h"

#import "DeviceTypeModel.h"

#import "AddFacilityModel.h"

#import "DetailedItineraryHeaderView.h"

#import "QRCodeController.h"

#import "AddContactNextController.h"

@interface CameraTypeViewController ()

@property (nonatomic,strong)NSArray *typeArray;

@end

@implementation CameraTypeViewController

- (void)requestData
{
    [self mb_normal];

    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceTypeFrontFindAll parameters:nil successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            
            self.typeArray = [DeviceTypeModel mj_objectArrayWithKeyValuesArray:successObject[@"object"]];
            DeviceTypeModel *typeModel = self.typeArray[0];
            NSArray *deviceListArray = typeModel.deviceModelList;
            if (deviceListArray.count) {
                for (int i = 1; i < deviceListArray.count; i++) {
                    
                    AddFacilityModel *model = deviceListArray[i];
//                    if (![model.deviceModelName isEqualToString:@"套装 NVR"]) {
//                        
//                    }
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(10+90*(i - 1), 10, 80, 80);
                    [button sd_setImageWithURL:[NSURL URLWithString:model.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"海尔"]];
                    [button lc_block:^(UIButton *sender) {
                        
                        [[NSUserDefaults standardUserDefaults] setObject:model.id forKey:@"BindIdKey"];
                        [[NSUserDefaults standardUserDefaults] setObject:model.deviceModelName forKey:@"BindNameKey"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if (self.block) {
                            self.block(model.icon);
                        }
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    [self.view addSubview:button];
                }
            }
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"图片";

    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

@end
