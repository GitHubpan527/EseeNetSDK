//
//  CustomTextField.m
//  Yoosee
//
//  Created by apple on 16/10/17.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect leftIconRect = [super leftViewRectForBounds:bounds];
    leftIconRect.origin.x += 10;
    return leftIconRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    
    CGRect rightIconRect = [super rightViewRectForBounds:bounds];
    rightIconRect.origin.x -= 15;
    return rightIconRect;
}

//  重写占位符的x值
- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    placeholderRect.origin.x += 15/2.0;
    return placeholderRect;
}

//重写输入内容的x值
- (CGRect)textRectForBounds:(CGRect)bounds{
    CGRect textRect = [super editingRectForBounds:bounds];
    textRect.origin.x += 15/2.0;
    return textRect;
    
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGRect editingRect = [super editingRectForBounds:bounds];
    editingRect.origin.x += 15/2.0;
    return editingRect;
    
}

@end
