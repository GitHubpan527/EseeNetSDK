//
//  JPTextField.m
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPTextField.h"

@implementation JPTextField

+ (instancetype)jp_textFieldInitWith:(void (^)(JPTextField *textField))block
{
    JPTextField *textField = [[JPTextField alloc] init];
    if (block) {
        block(textField);
    }
    return textField;
}

- (JPTextField *(^)(CGRect))textFieldFrame
{
    return ^JPTextField *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPTextField *(^)(UITextBorderStyle))textFieldBorderStyle
{
    return ^JPTextField *(UITextBorderStyle borderStyle) {
        self.borderStyle = borderStyle;
        return self;
    };
}

- (JPTextField *(^)(NSString *))textFieldPlaceholder
{
    return ^JPTextField *(NSString *placeholder) {
        self.placeholder = placeholder;
        return self;
    };
}

- (JPTextField *(^)(BOOL))textFieldSecureTextEntry
{
    return ^JPTextField *(BOOL secureTextEntry) {
        self.secureTextEntry = secureTextEntry;
        return self;
    };
}

- (JPTextField *(^)(UIKeyboardType))textFieldKeyboardType
{
    return ^JPTextField *(UIKeyboardType keyboardType) {
        self.keyboardType = keyboardType;
        return self;
    };
}

- (JPTextField *(^)(UIReturnKeyType))textFieldReturnKeyType
{
    return ^JPTextField *(UIReturnKeyType returnKeyType) {
        self.returnKeyType = returnKeyType;
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
