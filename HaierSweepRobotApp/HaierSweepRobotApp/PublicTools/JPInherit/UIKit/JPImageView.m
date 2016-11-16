//
//  JPImageView.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPImageView.h"
#import <objc/runtime.h>

static const char *tapKey = "tapKey";

@implementation JPImageView

+ (instancetype)jp_imageViewInitWith:(void (^)(JPImageView *imageView))block tapBlock:(void (^)(void))tapBlock
{
    JPImageView *imageView = [[JPImageView alloc] init];
    if (block) {
        block(imageView);
    }
    if (tapBlock) {
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [imageView jp_recognizerWithHandle:^(UIGestureRecognizer *sender, UIGestureRecognizerState state) {
            if (state == UIGestureRecognizerStateRecognized) {
                tapBlock();
            }
        }];
        [imageView addGestureRecognizer:tap];
        
    }
    return imageView;
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

- (JPImageView *(^)(CGRect))imageViewFrame
{
    return ^JPImageView *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPImageView *(^)(UIColor *))imageViewBackgroundColor
{
    return ^JPImageView *(UIColor *backgroundColor) {
        self.backgroundColor = backgroundColor;
        return self;
    };
}

- (JPImageView *(^)(NSString *))imageViewName
{
    return ^JPImageView *(NSString *imageName) {
        self.image = [UIImage imageNamed:imageName];
        return self;
    };
}

- (JPImageView *(^)(BOOL))imageViewUserInteractionEnabled
{
    return ^JPImageView *(BOOL userInteractionEnabled) {
        self.userInteractionEnabled = userInteractionEnabled;
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
