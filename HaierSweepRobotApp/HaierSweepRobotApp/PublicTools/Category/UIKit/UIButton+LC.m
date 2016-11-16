//
//  UIButton+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/21.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UIButton+LC.h"

static const char *overviewKey = "buttonActionKey";

@implementation UIButton (LC)

- (void)lc_block:(ActionBlock)block{
    objc_setAssociatedObject(self, overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callActionBlock:(UIButton *)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, overviewKey);
    if (block) {
        block(sender);
    }
}

@end
