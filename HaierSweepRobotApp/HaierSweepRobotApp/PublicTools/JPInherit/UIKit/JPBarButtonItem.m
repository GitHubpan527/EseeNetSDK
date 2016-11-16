//
//  JPBarButtonItem.m
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPBarButtonItem.h"
#import <objc/runtime.h>

static const char *barButtonKey = "barButtonKey";

@implementation JPBarButtonItem

+ (instancetype)jp_barButtonItemInitWithImageName:(NSString *)imageName actionBlock:(void (^)(UIButton *button))actionBlock
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 7, 30, 30);
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    JPBarButtonItem *item = [[JPBarButtonItem alloc] initWithCustomView:button];
    if (actionBlock) {
        [item association:button actionBlock:actionBlock];
    }
    return item;
}

+ (instancetype)jp_barButtonItemInitWithTitle:(NSString *)title actionBlock:(void (^)(UIButton *button))actionBlock
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 7, 50, 30);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    JPBarButtonItem *item = [[JPBarButtonItem alloc] initWithCustomView:button];
    if (actionBlock) {
        [item association:button actionBlock:actionBlock];
    }
    return item;
}

- (void)association:(UIButton *)button actionBlock:(void (^)(UIButton *button))actionBlock
{
    objc_setAssociatedObject(self, barButtonKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(barAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)barAction:(UIButton *)sender
{
    void (^actionBlock)(UIButton *button) = (void (^)(UIButton *button))objc_getAssociatedObject(self, barButtonKey);
    if (actionBlock) {
        actionBlock(sender);
    }
}

@end
