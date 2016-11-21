//
//  FeedBackViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "FeedBackViewController.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

@interface FeedBackViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mobileTF;
@property (weak, nonatomic) IBOutlet BaseTextView *feedBackTV;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation FeedBackViewController
{
    NSString *str1;
    NSString *str2;
    NSString *str3;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"feedBack", nil);
#pragma mark - textField
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    self.mobileTF.text = userModel.telephone;
#pragma mark - textView
    if (HLLanguageIsEN) {
        self.feedBackTV.placeholder = @"Please enter your valuable opinions and Suggestions";
        [self.nextBtn setTitle:@"next" forState:UIControlStateNormal];
        str1 = @"Please enter the phone number";
        str2 = @"Phone number format is not correct";
        str3 = @"Please enter your valuable opinions and Suggestions";
    } else {
        self.feedBackTV.placeholder = @"请输入您宝贵的意见和建议";
        [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        str1 = @"请输入手机号";
        str2 = @"手机号格式不正确";
        str3 = @"请输入您宝贵的意见和建议";
    }
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 下一步
- (IBAction)nextHandle:(id)sender {
    if (!self.mobileTF.text.length) {
        [self mb_show:str1];
        return;
    }
    if (![NSString lc_isValidateMobile:self.mobileTF.text]) {
        [self mb_show:str2];
        return;
    }
    if (!self.feedBackTV.text.length) {
        [self mb_show:str3];
        return;
    }
    [self mb_normal];
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    
    NSDictionary *requestDic = @{@"userId":userModel.id,
                                 @"content":self.feedBackTV.text,
                                 @"phone":self.mobileTF.text};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FeedBackAdd parameters:requestDic successBlock:^(id successObject) {
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
