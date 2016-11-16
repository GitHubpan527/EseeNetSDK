//
//  JPLabel.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPLabel.h"

@implementation JPLabel

+ (instancetype)jp_labelInitWith:(void (^)(JPLabel *label))block
{
    JPLabel *label = [[JPLabel alloc] init];
    if (block) {
        block(label);
    }
    return label;
}

- (JPLabel *(^)(CGRect))labelFrame
{
    return ^JPLabel *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPLabel *(^)(UIColor *))labelBackgroundColor
{
    return ^JPLabel *(UIColor *backgroundColor) {
        self.backgroundColor = backgroundColor;
        return self;
    };
}

- (JPLabel *(^)(NSString *))labelText
{
    return ^JPLabel *(NSString *text) {
        self.text = text;
        return self;
    };
}

- (JPLabel *(^)(UIColor *))labelTextColor
{
    return ^JPLabel *(UIColor *textColor) {
        self.textColor = textColor;
        return self;
    };
}

- (JPLabel *(^)(NSTextAlignment))labelTextAlignment
{
    return ^JPLabel *(NSTextAlignment textAlignment) {
        self.textAlignment = textAlignment;
        return self;
    };
}

- (JPLabel *(^)(CGFloat))labelFont
{
    return ^JPLabel *(CGFloat fontSize) {
        self.font = [UIFont systemFontOfSize:fontSize];
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
