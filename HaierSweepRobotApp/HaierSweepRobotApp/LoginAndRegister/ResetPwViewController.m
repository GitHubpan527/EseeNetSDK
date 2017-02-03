//
//  ResetPwViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/8.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ResetPwViewController.h"

@interface ResetPwViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstTF;
@property (weak, nonatomic) IBOutlet UITextField *secondTF;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation ResetPwViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"setNew", nil);
    self.firstTF.placeholder = CustomLocalizedString(@"firstPw", nil);
    self.secondTF.placeholder = CustomLocalizedString(@"secondPw", nil);
    [self.sureButton setTitle:CustomLocalizedString(@"sure", nil) forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
}
//CustomLocalizedString(@"The two passwords is different", nil)
- (IBAction)sureAction:(id)sender {
    if (!self.firstTF.text.length) {
        [self mb_show:CustomLocalizedString(@"input_password", nil)];//input_password
        return;
    }
    if (self.firstTF.text.length<6 || self.firstTF.text.length>16) {
        [self mb_show:CustomLocalizedString(@"inputPw", nil)];
        return;
    }
    if (!self.secondTF.text.length) {
        [self mb_show:CustomLocalizedString(@"again_input_password", nil)];
        return;
    }
    if (self.secondTF.text.length<6 || self.secondTF.text.length>16) {
        [self mb_show:CustomLocalizedString(@"Please enter 6 ~ 16 password again", nil)];
        return;
    }
    if (![self.firstTF.text isEqualToString:self.secondTF.text]) {
        [self mb_show:CustomLocalizedString(@"The two passwords is different", nil)];
        return;
    }
    [self mb_normal];
    NSDictionary *requestDic = @{@"telephone":self.telephone,
                                 @"mobileCode":self.mobileCode,
                                 @"password":[NSString lc_md5String:self.firstTF.text]};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UpdatePasswd parameters:requestDic successBlock:^(id successObject) {
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
