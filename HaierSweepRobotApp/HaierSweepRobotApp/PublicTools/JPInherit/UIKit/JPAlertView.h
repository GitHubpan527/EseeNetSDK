//
//  JPAlertView.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPAlertView : UIAlertView<UIAlertViewDelegate>

+ (void)jp_alertViewInitWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton otherButton:(NSString *)otherButton actionBlock:(void (^)(NSInteger buttonIndex))actionBlock;

@end
