//
//  JPWebView.h
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPWebView : UIWebView

@property (nonatomic,copy)JPWebView *(^webViewFrame)(CGRect frame);
@property (nonatomic,copy)JPWebView *(^webViewUrlLink)(NSString *urlLink);
@property (nonatomic,copy)JPWebView *(^webViewBounces)(BOOL bounces);
@property (nonatomic,copy)JPWebView *(^webViewDelegate)(id target);

+ (instancetype)jp_webViewInitWith:(void (^)(JPWebView *webView))block;

@end
