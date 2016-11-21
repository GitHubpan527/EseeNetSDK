//
//  UseHelpViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/10.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UseHelpViewController.h"

@interface UseHelpViewController ()<UIWebViewDelegate>

@end

@implementation UseHelpViewController

{
    UIWebView *webView;
    NSInteger startLoad;
    NSInteger endLoad;
    NSInteger failLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startLoad = 1;
    endLoad = 1;
    failLoad = 1;
    
    self.navigationItem.title = CustomLocalizedString(@"useHelp", nil);
    
    //[self requestData];
    
    [self customUI];
}

- (void)requestData
{
    [self mb_normal];
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UseHelpFront parameters:nil successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}
- (void)customUI {
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.haierwireless.cn/faq.html"]];
    webView.delegate = self;
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

/** 开始加载的时候执行该方法 */
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    if (startLoad == 1) {
        NSLog(@"开始");
        [self mb_normal];
    }
    startLoad++;
}
/** 加载完成的时候执行该方法。 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (endLoad == 1) {
        NSLog(@"完成");
        [self mb_stop];
    }
    endLoad++;
}
/** 加载出错的时候执行该方法。 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (failLoad == 1) {
        NSLog(@"失败");
        [self mb_stop];
    }
    failLoad++;
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
