//
//  JPAlertView.m
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPAlertView.h"
#import <objc/runtime.h>

static const char *UIAlertViewKey = "UIAlertViewKey";

@implementation JPAlertView

+ (void)jp_alertViewInitWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton otherButton:(NSString *)otherButton actionBlock:(void (^)(NSInteger buttonIndex))actionBlock
{
    JPAlertView *alert = [[JPAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButton otherButtonTitles:otherButton, nil];
    alert.delegate = alert;
    [alert show];
    if (actionBlock) {
        [alert associationActionBlock:actionBlock];
    }
}

- (void)associationActionBlock:(void (^)(NSInteger buttonIndex))actionBlock
{
    objc_setAssociatedObject(self, UIAlertViewKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^actionBlock)(NSInteger buttonIndex) = (void (^)(NSInteger buttonIndex))objc_getAssociatedObject(self, UIAlertViewKey);
    if (actionBlock) {
        actionBlock(buttonIndex);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
