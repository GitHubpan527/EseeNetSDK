//
//  BaseTextView.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/26.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseTextView.h"

@implementation BaseTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textChanged:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
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
    _placeholderLabel.frame = CGRectMake(5, 7, self.frame.size.width-10, bounds.size.height);
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
