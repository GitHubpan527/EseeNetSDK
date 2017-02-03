//
//  UseAgreementViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/22.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UseAgreementViewController.h"

@interface UseAgreementViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *useWebView;

@end

@implementation UseAgreementViewController

{
    NSInteger startLoad;
    NSInteger endLoad;
    NSInteger failLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    startLoad = 1;
    endLoad = 1;
    failLoad = 1;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = CustomLocalizedString(@"useAgreement", nil);
    
    //加载本地文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"APP使用协议" ofType:@"docx"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.useWebView.scalesPageToFit = YES;
    [self.useWebView loadRequest:[NSURLRequest requestWithURL:url]];
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
