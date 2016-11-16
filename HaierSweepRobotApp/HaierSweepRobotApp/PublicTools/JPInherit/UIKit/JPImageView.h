//
//  JPImageView.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPImageView : UIImageView

@property (nonatomic,copy)JPImageView *(^imageViewFrame)(CGRect frame);
@property (nonatomic,copy)JPImageView *(^imageViewBackgroundColor)(UIColor *backgroundColor);
@property (nonatomic,copy)JPImageView *(^imageViewName)(NSString *imageName);
@property (nonatomic,copy)JPImageView *(^imageViewUserInteractionEnabled)(BOOL userInteractionEnabled);

#pragma mark - tapBlock决定是否需要给所创建的imageView添加单击手势
+ (instancetype)jp_imageViewInitWith:(void (^)(JPImageView *imageView))block tapBlock:(void (^)(void))tapBlock;

@end
