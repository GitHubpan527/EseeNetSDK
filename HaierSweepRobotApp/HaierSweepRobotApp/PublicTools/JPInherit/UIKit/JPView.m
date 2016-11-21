//
//  JPView.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPView.h"
#import <objc/runtime.h>

static const char *tapKey = "tapKey";

@implementation JPView

+ (instancetype)jp_viewInitWith:(void (^)(JPView *view))block  tapBlock:(void (^)(void))tapBlock
{
    JPView *view = [[JPView alloc] init];
    if (block) {
        block(view);
    }
    if (tapBlock) {
        UITapGestureRecognizer *tap = [view jp_recognizerWithHandle:^(UIGestureRecognizer *sender, UIGestureRecognizerState state) {
            if (state == UIGestureRecognizerStateRecognized) {
                tapBlock();
            }
        }];
        [view addGestureRecognizer:tap];
        
    }
    return view;
}

- (UITapGestureRecognizer *)jp_recognizerWithHandle:(void (^)(UIGestureRecognizer *sender,UIGestureRecognizerState state))block
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

- (JPView *(^)(CGRect))viewFrame
{
    return ^JPView *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPView *(^)(UIColor *))viewBackgroundColor
{
    return ^JPView *(UIColor *backgroundColor) {
        self.backgroundColor = backgroundColor;
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
