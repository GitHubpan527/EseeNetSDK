//
//  BindEmailController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ALERT_TAG_BIND_EMAIL_AFTER_INPUT_PASSWORD 0
#define ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD 1
@class TopBar;
@interface BindEmailController : BaseViewController<UIAlertViewDelegate>
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UIButton *unbindButton;
@property (nonatomic, strong) TopBar *topBar;
@end
