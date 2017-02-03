//
//  AddIDDeviceViewController.m
//  HaierSweepRobotApp
//
//  Created by lichao pan on 2016/11/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AddIDDeviceViewController.h"
#import "FListManager.h"
#import "LoginUserDefaults.h"
#import "MyFacilityModel.h"
#import "DeviceTypeModel.h"
#import "AddFacilityModel.h"

@interface AddIDDeviceViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yunIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *yunIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *AllChannelLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *AllChannelSegment;
/* 总的通道数 */
@property (nonatomic,strong) NSString *AllChannelString;

/* 该ID是否存在 */
@property (nonatomic,assign) BOOL isExit;

@end

@implementation AddIDDeviceViewController

{
    NSString *NVRID;
}

- (IBAction)AllChannelSegmentEvent:(id)sender {
    UISegmentedControl * segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0) {
        _AllChannelString = @"4";
    }else{
        _AllChannelString = @"8";
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _AllChannelString = @"4";
    _passwordTextField.secureTextEntry = YES;
    _isExit = NO;
    [self getID];
    self.navigationItem.title = CustomLocalizedString(@"addNVRDevice", nil);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem lc_itemWithIcon:@"返回-（导航）" block:^{
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithTitle:@"保存" block:^{
        [self saveBtn];
    }];
}
- (void)getID
{
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceTypeFrontFindAll parameters:nil successBlock:^(id successObject) {
        if ([successObject[@"result"] boolValue]) {
            
            NSArray *array = [DeviceTypeModel mj_objectArrayWithKeyValuesArray:successObject[@"object"]];
            DeviceTypeModel *modelID = array[0];
            NSArray *arr = modelID.deviceModelList;
            for (AddFacilityModel *facilityID in arr) {
                if ([facilityID.deviceModelName isEqualToString: @"套装 NVR"]) {
                    NVRID = facilityID.id;
                }
            }
        }
    } FailBlock:^(id failObject) {
        
    }];
}
- (void)saveBtn
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"userId":userModel.id};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserDeviceFindPage parameters:infoDic successBlock:^(id successObject) {
        if ([successObject[@"result"] boolValue]) {
            NSArray *array = [MyFacilityModel mj_objectArrayWithKeyValuesArray:successObject[@"object"][@"page"][@"recordList"]];
            for (MyFacilityModel *model in array) {
                if ([model.res2 isEqualToString:_yunIDTextField.text]) {
                    _isExit = YES;
                    break;
                }
            }
        }
    } FailBlock:^(id failObject) {
        
    }];
    if (_isExit == YES) {
        HL_ALERT(CustomLocalizedString(@"prompt", nil), CustomLocalizedString(@"contact_already_exists", nil));
    }else{
        if (_yunIDTextField.text.length == 0) {
            HL_ALERT(CustomLocalizedString(@"prompt", nil), _yunIDTextField.placeholder);
        }else if (_deviceNameTextField.text.length == 0){
            HL_ALERT(CustomLocalizedString(@"prompt", nil), _deviceNameTextField.placeholder);
        }else if (_userNameTextField.text.length == 0){
            HL_ALERT(CustomLocalizedString(@"prompt", nil), _userNameTextField.placeholder);
        }else
        {
            /*
             requestDic = @{
             @"userId":userModel.id,
             @"modelId":bindId,
             @"deviceId":self.contactId,
             @"name":self.nameTextfield.text,
             @"devicepw":password};
             */
            //HL_ALERT(@"提示", @"相关操作");
            NSDictionary *requestDic = [NSDictionary dictionary];
            
//            NSDictionary *dict = @{@"NVRAllChannel":_AllChannelString,
//                                  @"NVRUserName":_userNameTextField.text};
//            NSError *error;
//            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
//                                                               options:NSJSONWritingPrettyPrinted
//                                                                 error:&error];
//            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            requestDic = @{@"userId":userModel.id,//_userNameTextField.text
                           @"modelId":NVRID,//NVR:358113623439362//云台:349655620622338
                           @"deviceId":_yunIDTextField.text,
                           @"name":_deviceNameTextField.text,
                           @"devicepw":_passwordTextField.text,
                           @"res3":_AllChannelString,
                           @"res4":_userNameTextField.text
                           };//res3：通道数，res4：_userNameTextField.text
            
            [[NSUserDefaults standardUserDefaults] setObject:_yunIDTextField.text forKey:@"NVRDeviceID"];
            [[NSUserDefaults standardUserDefaults] setObject:_deviceNameTextField.text forKey:@"NVRDeviceName"];
            [[NSUserDefaults standardUserDefaults] setObject:_userNameTextField.text forKey:@"NVRUserName"];
            [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"NVRDevicepw"];
            [[NSUserDefaults standardUserDefaults] setObject:_AllChannelString forKey:@"NVRAllChannel"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            NSLog(@"NVRNVRNVRNVRNVRNVR%@------%@------%@------%@-----%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDeviceID"],[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDeviceName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRUserName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDevicepw"],[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRAllChannel"]);
            [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
                NSLog(@"success");
                if ([successObject[@"result"] integerValue]) {//添加成功
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNVR" object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } FailBlock:^(id failObject) {
                HL_ALERT(CustomLocalizedString(@"prompy", nil), failObject[@"message"]);
            }];
            
            /*
             [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
             [self mb_stop];
             //接口走通之后再添加本地的设备
             if ([successObject[@"result"] integerValue]) {//添加成功
             //                [[FListManager sharedFList] myinsert:contact];
             
             //                [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
             //                [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
             
             [self.navigationController popToRootViewControllerAnimated:YES];
             }else {
             HL_ALERT(CustomLocalizedString(@"prompt", nil), successObject[@"message"]);
             }
             
             } FailBlock:^(id failObject) {
             [self mb_stop];
             }];
             */
        }
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
