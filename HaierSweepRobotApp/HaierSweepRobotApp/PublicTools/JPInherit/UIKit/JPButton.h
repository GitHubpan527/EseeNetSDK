//
//  JPButton.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPButton : UIButton

@property (nonatomic,copy)JPButton *(^buttonFrame)(CGRect frame);
@property (nonatomic,copy)JPButton *(^buttonBackgroundColor)(UIColor *backgroundColor);
@property (nonatomic,copy)JPButton *(^buttonTitle)(NSString *title);
@property (nonatomic,copy)JPButton *(^buttonTitleColor)(UIColor *titleColor);

+ (instancetype)jp_buttonInitWith:(void (^)(JPButton *button))block actionBlock:(void (^)(JPButton *button))actionBlock;

@end
