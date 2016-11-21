//
//  GuidePageViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "GuidePageViewController.h"

#import "AppDelegate.h"

@interface GuidePageViewController ()<UIScrollViewDelegate>
{
    UIScrollView *guideScrollView;
    UIPageControl *guidePageControl;
}

@end

@implementation GuidePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //引导页
    [self setupScrollViewAndPageControl];
    // Do any additional setup after loading the view from its nib.
}

//引导图
- (void)setupScrollViewAndPageControl
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    guideScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    guideScrollView.contentSize = CGSizeMake(ScreenWidth*3, ScreenHeight);
    guideScrollView.pagingEnabled = YES;
    guideScrollView.showsHorizontalScrollIndicator = NO;
    guideScrollView.showsVerticalScrollIndicator = NO;
    guideScrollView.delegate = self;
    [self.view addSubview:guideScrollView];
    
    for (int i = 0; i < 3; i++) {
        NSArray *imageArray = [NSArray array];
        if (ScreenHeight == 480) {
            imageArray = @[@"640-960-1.png",@"640-960-2.png",@"640-960-3.png"];
        }
        else if (ScreenHeight == 568) {
            imageArray = @[@"640-1136-1.png",@"640-1136-2.png",@"640-1136-3.png"];
        }
        else if (ScreenHeight == 667) {
            imageArray = @[@"750-1334-1.png",@"750-1334-2.png",@"750-1334-3.png"];
        }
        else if (ScreenHeight == 736) {
            imageArray = @[@"1242-2208-1.png",@"1242-2208-2.png",@"1242-2208-3.png"];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*i, 0, ScreenWidth, ScreenHeight)];
        imageView.image = LCImage(imageArray[i]);
        [guideScrollView addSubview:imageView];
    }
    
    guidePageControl = [[UIPageControl alloc] init];
    guidePageControl.center = CGPointMake(ScreenWidth/2, ScreenHeight-30);
    guidePageControl.numberOfPages = 3;
    guidePageControl.currentPage = 0;
    guidePageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    guidePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [guidePageControl addTarget:self action:@selector(pageChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:guidePageControl];
}

/**
 *  pageControl
 *
 *  @param scrollView 滑动时page的变化
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger pageNumber = offset.x / scrollView.bounds.size.width;
    guidePageControl.currentPage = pageNumber;
}

- (void)pageChangedAction:(id)sender
{
    CGFloat offsetx = guideScrollView.bounds.size.width * guidePageControl.currentPage;
    [guideScrollView setContentOffset:CGPointMake(offsetx, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (guidePageControl.currentPage == 2) {
        if (scrollView.contentOffset.x >= ScreenWidth*2) {
            UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
            BaseNaviViewController *loginNavi = [loginSB instantiateViewControllerWithIdentifier:@"LoginViewController"];
            AppDelegate *tempApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [tempApp.window setRootViewController:loginNavi];
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
