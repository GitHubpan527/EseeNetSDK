//
//  BaseViewController.h
//  BaseViewController
//
//  Created by apple on 16/8/24.
//  Copyright © 2016年 YuanHongQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaseScrollView;
#import "YTheNaviBar.h"
@class FounderButton;
@interface BaseViewController : UIViewController
@property(nonatomic,strong,nullable,readonly)YTheNaviBar* naviBar;
-(void)fButtonBackBeClick:(nullable FounderButton*)fbt;
@end
