//
//  JPTextView.h
//  JPInherit
//
//  Created by Ljp on 16/8/22.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPTextView : UITextView

@property (nonatomic,copy)JPTextView *(^textViewFrame)(CGRect frame);
@property (nonatomic,copy)JPTextView *(^textViewPlaceholder)(NSString *placeholder);
@property (nonatomic,copy)JPTextView *(^textViewKeyboardType)(UIKeyboardType keyboardType);
@property (nonatomic,copy)JPTextView *(^textViewReturnKeyType)(UIReturnKeyType returnKeyType);

+ (instancetype)jp_textViewInitWith:(void (^)(JPTextView *textView))block;

@end
