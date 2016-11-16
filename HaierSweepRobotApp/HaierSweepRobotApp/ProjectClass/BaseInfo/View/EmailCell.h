//
//  EmailCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EmailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *emailImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageH;

@property (weak, nonatomic) IBOutlet UITextField *emailText;

@end
