//
//  JPBarButtonItem.h
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPBarButtonItem : UIBarButtonItem

+ (instancetype)jp_barButtonItemInitWithImageName:(NSString *)imageName actionBlock:(void (^)(UIButton *button))actionBlock;
+ (instancetype)jp_barButtonItemInitWithTitle:(NSString *)title actionBlock:(void (^)(UIButton *button))actionBlock;

@end
