//
//  BaseViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //导航栏相关
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = NavigationBarColor;

//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIColor blackColor],UITextAttributeTextShadowColor,[UIFont boldSystemFontOfSize:20.0],UITextAttributeFont,CGSizeMake(0, -1.0),UITextAttributeTextShadowOffset, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 7, 30, 30);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 返回事件
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MBProgressHUD
- (void)mb_normal
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)mb_stop
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)mb_show:(NSString *)show
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = show;
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    
    [hud hideAnimated:YES afterDelay:1.f];
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
