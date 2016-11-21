//
//  UIView+LC.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/8/16.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "UIView+LC.h"

@implementation UIView (LC)

static const char *tapKey = "tapKey";

- (void)lc_whenTapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block
{
    if (block) {
        UITapGestureRecognizer *tap = [self lc_recognizerWithHandle:^(UIGestureRecognizer *sender, UIGestureRecognizerState state) {
            if (state == UIGestureRecognizerStateRecognized) {
                block();
            }
        }];
        tap.numberOfTapsRequired = numberOfTaps;
        [self addGestureRecognizer:tap];
    }
}

- (UITapGestureRecognizer *)lc_recognizerWithHandle:(void (^)(UIGestureRecognizer *sender,UIGestureRecognizerState state))block
{
    if (block) {
        objc_setAssociatedObject(self, tapKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    return tap;
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    void (^handler)(UIGestureRecognizer *sender, UIGestureRecognizerState state) = (void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state))objc_getAssociatedObject(self, tapKey);
    handler(sender,sender.state);
}

@end
