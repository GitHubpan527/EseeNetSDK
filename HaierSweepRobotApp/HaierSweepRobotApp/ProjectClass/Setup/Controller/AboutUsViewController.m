//
//  AboutUsViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/10.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController
{
    NSString *detail;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = CustomLocalizedString(@"aboutUs", nil);
    
    [self requestData];
    // Do any additional setup after loading the view from its nib.
}

- (void)requestData
{
    [self mb_normal];
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:AboutFrontPage parameters:nil successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
          
            NSString *analyHtml = [[self flattenHTML:[successObject[@"object"] firstObject][@"content"]]stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            NSString *string = [analyHtml stringByReplacingOccurrencesOfString:@"海尔集团简介" withString:@"海尔集团简介\n"];
            
            self.aboutTextView.text = string;
            self.aboutTextView.editable = NO;
            
            [self.view setNeedsDisplay];
            
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

/**
 *  处理HTML标签
 *
 *  @param html HTML字符串
 *
 *  @return 处理好的字符串
 */
- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
        
        html = [html stringByReplacingOccurrencesOfString:@" "
                                               withString:@" "];
        
        html = [html stringByReplacingOccurrencesOfString:@" "
                                               withString:@" "];
        
        html = [html stringByReplacingOccurrencesOfString:@"\\n\\n"
                                               withString:@"\\n"];
        
        html = [html stringByReplacingOccurrencesOfString:@"\\n"
                                               withString:@"\r\r"];
    }
    return html;
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
