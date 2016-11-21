//
//  JPButton.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPButton.h"
#import <objc/runtime.h>

static const char *buttonActionKey = "buttonActionKey";

@implementation JPButton

+ (instancetype)jp_buttonInitWith:(void (^)(JPButton *button))block actionBlock:(void (^)(JPButton *button))actionBlock
{
    JPButton *button = [JPButton buttonWithType:UIButtonTypeCustom];
    if (block) {
        block(button);
    }
    if (actionBlock) {
        [button association:button actionBlock:actionBlock];
    }
    return button;
}

- (void)association:(JPButton *)button actionBlock:(void (^)(JPButton *button))actionBlock
{
    objc_setAssociatedObject(self, buttonActionKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(callActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callActionBlock:(JPButton *)sender {
    void (^actionBlock)(JPButton *button) = (void (^)(JPButton *button))objc_getAssociatedObject(self, buttonActionKey);
    if (actionBlock) {
        actionBlock(sender);
    }
}

- (JPButton *(^)(CGRect))buttonFrame
{
    return ^JPButton *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPButton *(^)(UIColor *))buttonBackgroundColor
{
    return ^JPButton *(UIColor *backgroundColor) {
        self.backgroundColor = backgroundColor;
        return self;
    };
}

- (JPButton *(^)(NSString *))buttonTitle
{
    return ^JPButton *(NSString *title) {
        [self setTitle:title forState:UIControlStateNormal];
        return self;
    };
}

- (JPButton *(^)(UIColor *))buttonTitleColor
{
    return ^JPButton *(UIColor *titleColor) {
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        return self;
    };
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
