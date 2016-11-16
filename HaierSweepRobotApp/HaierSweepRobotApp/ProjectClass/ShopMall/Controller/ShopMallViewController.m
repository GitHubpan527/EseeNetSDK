//
//  ShopMallViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ShopMallViewController.h"

@interface ShopMallViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *shopMallView;
@end

@implementation ShopMallViewController

{
    NSInteger startLoad;
    NSInteger endLoad;
    NSInteger failLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    startLoad = 1;
    endLoad = 1;
    failLoad = 1;
    
    self.navigationItem.title = @"商城";
    
    //[self requestLinkAddress];
    
    NSString * urlString ;
    if (self.isfromAd) {
        urlString = self.AdUrlString;
    }else {
        urlString = @"http://www.haierwireless.cn/page/market.mhtml";
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.shopMallView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestLinkAddress
{
    [self mb_normal];
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:LinkFrontPage parameters:nil successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            NSURL *url;
            NSString *link = successObject[@"object"][@"page"][@"recordList"][0][@"linkAddress"];
            if ([link hasPrefix:@"http://"]) {
                url = [[NSURL alloc] initWithString:link];
            } else {
                url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@",link]];
            }
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            self.shopMallView.scrollView.bounces = NO;
            [self.shopMallView loadRequest:request];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
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
