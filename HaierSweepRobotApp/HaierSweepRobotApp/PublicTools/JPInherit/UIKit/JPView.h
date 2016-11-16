//
//  JPView.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPView : UIView

@property (nonatomic,copy)JPView *(^viewFrame)(CGRect frame);
@property (nonatomic,copy)JPView *(^viewBackgroundColor)(UIColor *backgroundColor);

#pragma mark - tapBlock决定是否需要给所创建的view添加单击手势
+ (instancetype)jp_viewInitWith:(void (^)(JPView *view))block tapBlock:(void (^)(void))tapBlock;

@end