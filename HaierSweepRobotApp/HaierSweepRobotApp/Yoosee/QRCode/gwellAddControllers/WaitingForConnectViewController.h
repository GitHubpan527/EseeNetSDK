//
//  WaitingForConnectViewController.h
//  Yoosee
//
//  Created by apple on 16/10/18.
//  Copyright © 2016年 guojunyi. All rights reserved.
//

#import "BaseViewController.h"
@class TopBar;
@interface WaitingForConnectViewController : BaseViewController

@property(strong,nonatomic) TopBar *waitingForTopbar;
@property(strong,nonatomic) UILabel *voiceBigTipsLb;
@property(strong,nonatomic) UILabel *keep30cmTipsLb;
@property(strong,nonatomic) UIImageView *waitingForImgView;
@property(strong,nonatomic) UIButton *waitingNextStepBtn;

@end
