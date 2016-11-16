//
//  BaseNaviViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseNaviViewController.h"

@interface BaseNaviViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //侧滑返回
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    // Do any additional setup after loading the view.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //注意：只有非根控制器才有滑动返回功能，根控制器没有
    if (self.childViewControllers.count == 1) {
        return NO;
    } else {
//        //指定哪个控制器关闭侧滑手势
//        if ([self.topViewController isKindOfClass:[OperateViewController class]]) {
//            return NO;
//        } else {
//            return YES;
//        }
        return YES;
    }
}

//hidesBottomBarWhenPushed
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count>0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
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
