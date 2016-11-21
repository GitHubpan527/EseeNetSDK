//
//  JPTextView.m
//  JPInherit
//
//  Created by Ljp on 16/8/22.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPTextView.h"

static CGFloat const left = 5.0;
static CGFloat const top = 6.0;

@implementation JPTextView

{
    UILabel *_placeholderLabel;
    NSString *_placeholder;
}

+ (instancetype)jp_textViewInitWith:(void (^)(JPTextView *textView))block
{
    JPTextView *textView = [[JPTextView alloc] init];
    if (block) {
        block(textView);
    }
    return textView;
}

- (JPTextView *(^)(CGRect))textViewFrame
{
    return ^JPTextView *(CGRect frame) {
        self.frame = frame;
        [self setLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        return self;
    };
}

- (JPTextView *(^)(NSString *))textViewPlaceholder
{
    return ^JPTextView *(NSString *placeholder) {
        [self setPlaceholder:placeholder];
        return self;
    };
}

- (JPTextView *(^)(UIKeyboardType))textViewKeyboardType
{
    return ^JPTextView *(UIKeyboardType keyboardType) {
        self.keyboardType = keyboardType;
        return self;
    };
}

- (JPTextView *(^)(UIReturnKeyType))textViewReturnKeyType
{
    return ^JPTextView *(UIReturnKeyType returanKeyType) {
        self.returnKeyType = returanKeyType;
        return self;
    };
}

- (void)setLabel
{
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.adjustsFontSizeToFitWidth = YES;
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = [UIFont systemFontOfSize:14];
    _placeholderLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_placeholderLabel];
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    _placeholderLabel.text = placeholder;
    
    //设置_placeholderLabel  frame
    CGRect bounds = [placeholder boundingRectWithSize:CGSizeMake(self.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName] context:nil];
    _placeholderLabel.frame = CGRectMake(left, top, bounds.size.width, bounds.size.height);
}

- (void)textChanged:(NSNotification *)notification {
    if (self.text.length == 0) {
        _placeholderLabel.text = _placeholder;
    } else {
        _placeholderLabel.text = @"";
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
