//
//  JPWebView.m
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPWebView.h"

@implementation JPWebView

+ (instancetype)jp_webViewInitWith:(void (^)(JPWebView *webView))block
{
    JPWebView *webView = [[JPWebView alloc] init];
    if (block) {
        block(webView);
    }
    return webView;
}

- (JPWebView *(^)(CGRect))webViewFrame
{
    return ^JPWebView *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPWebView *(^)(NSString *))webViewUrlLink
{
    return ^JPWebView *(NSString *urlLink) {
        NSURL *url = [[NSURL alloc] init];
        if ([urlLink hasPrefix:@"http://"]) {
            url = [[NSURL alloc] initWithString:urlLink];
        } else {
            url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@",urlLink]];
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self loadRequest:request];
        return self;
    };
}

- (JPWebView *(^)(BOOL))webViewBounces
{
    return ^JPWebView *(BOOL bounces) {
        self.scrollView.bounces = bounces;
        return self;
    };
}

- (JPWebView *(^)(id))webViewDelegate
{
    return ^JPWebView *(id target) {
        self.delegate = target;
        return self;
    };
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
