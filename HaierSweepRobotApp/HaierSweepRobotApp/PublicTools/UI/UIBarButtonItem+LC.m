//
//  UIBarButtonItem+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/7.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UIBarButtonItem+LC.h"

static const char *barButtonKey = "barButtonKey";

@implementation UIBarButtonItem (LC)

+ (UIBarButtonItem *)lc_itemWithIcon:(NSString *)icon block:(BarButtonBlock)block
{
    objc_setAssociatedObject(self, barButtonKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 7, 30, 30);
    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    if (block) {
        [item association:button actionBlock:block];
    }
    return item;
}

+ (UIBarButtonItem *)lc_itemWithTitle:(NSString *)title block:(BarButtonBlock)block
{
    objc_setAssociatedObject(self, barButtonKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 7, 50, 30);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    if (block) {
        [item association:button actionBlock:block];
    }
    return item;
}

- (void)association:(UIButton *)button actionBlock:(BarButtonBlock)actionBlock
{
    objc_setAssociatedObject(self, barButtonKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(barAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)barAction:(UIButton *)sender
{
    BarButtonBlock block = (BarButtonBlock)objc_getAssociatedObject(self, barButtonKey);
    if (block) {
        block();
    }
}

@end
