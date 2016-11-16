//
//  BaseTextView.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/26.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTextView : UITextView

@property (nonatomic,strong)UILabel *placeholderLabel;
@property (nonatomic,copy)NSString *placeholder;

@end
