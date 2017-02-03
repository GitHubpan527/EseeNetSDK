//
//  BaseViewController.m
//  BaseViewController
//
//  Created by apple on 16/8/24.
//  Copyright © 2016年 YuanHongQiang. All rights reserved.
//
#import "NewBaseViewController.h"

//#import "BaiduMobStat.h"
@interface NewBaseViewController ()
@end
@implementation NewBaseViewController
-(instancetype)init{
    self=[super init];
    if (self) {
        _naviBar=[[YTheNaviBar alloc] init];
        _naviBar.yBarColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"YNaviBar_bg.png"]];
        _naviBar.yBarBottomLineColor=[UIColor clearColor];
        
        FounderButton* fButtonBack=[[FounderButton alloc] init];
        fButtonBack.buttonImageViewSize=CGSizeMake(20, 20);
        [fButtonBack addTarget:self action:@selector(fButtonBackBeClick:) forControlEvents:UIControlEventTouchUpInside];
        fButtonBack.tag=0;
        fButtonBack.backgroundColor=[UIColor clearColor];
        fButtonBack.frame=CGRectMake(0, 0, 40, 40);
        [fButtonBack setImage:[UIImage imageNamed:@"YNavi_back_black_up.png"] forState:UIControlStateNormal];
        [fButtonBack setImage:[UIImage imageNamed:@"YNavi_back_black_down.png"] forState:UIControlStateHighlighted];
        
        _naviBar.yBarButtonsLeft=@[fButtonBack];

    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
}
-(void)fButtonBackBeClick:(FounderButton*)fbt{
    [self.navigationController popViewControllerAnimated:YES];
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat TempW=self.view.width;
    CGFloat TempH=[[UIApplication sharedApplication] isStatusBarHidden]?25:64;
    CGFloat TempX=0;
    CGFloat TempY=0;
    CGRect newRect=CGRectMake(TempX, TempY, TempW, TempH);
    _naviBar.frame=newRect;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)200*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self.naviBar setNeedsLayout];
        [self.naviBar layoutIfNeeded];
    });
}
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    //百度统计 访问页面
//    NSString* cName=NSStringFromClass([self class]);
//    [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
//}
//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    //百度统计 访问页面
//    NSString* cName=NSStringFromClass([self class]);
//    [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
//}
@end
