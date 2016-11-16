//
//  JPLabel.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPLabel : UILabel

@property (nonatomic,copy)JPLabel *(^labelFrame)(CGRect frame);
@property (nonatomic,copy)JPLabel *(^labelBackgroundColor)(UIColor *backgroundColor);
@property (nonatomic,copy)JPLabel *(^labelText)(NSString *text);
@property (nonatomic,copy)JPLabel *(^labelTextColor)(UIColor *textColor);
@property (nonatomic,copy)JPLabel *(^labelTextAlignment)(NSTextAlignment textAlignment);
@property (nonatomic,copy)JPLabel *(^labelFont)(CGFloat fontSize);

+ (instancetype)jp_labelInitWith:(void (^)(JPLabel *label))block;

@end
