//
//  JPTextField.h
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPTextField : UITextField

@property (nonatomic,copy)JPTextField *(^textFieldFrame)(CGRect frame);
@property (nonatomic,copy)JPTextField *(^textFieldBorderStyle)(UITextBorderStyle borderStyle);
@property (nonatomic,copy)JPTextField *(^textFieldPlaceholder)(NSString *placeholder);
@property (nonatomic,copy)JPTextField *(^textFieldSecureTextEntry)(BOOL secureTextEntry);
@property (nonatomic,copy)JPTextField *(^textFieldKeyboardType)(UIKeyboardType keyboardType);
@property (nonatomic,copy)JPTextField *(^textFieldReturnKeyType)(UIReturnKeyType returnKeyType);

+ (instancetype)jp_textFieldInitWith:(void (^)(JPTextField *textField))block;

@end
