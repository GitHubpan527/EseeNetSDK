//
//  JPScrollView.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPScrollView : UIScrollView

@property (nonatomic,copy)JPScrollView *(^scrollViewFrame)(CGRect frame);
@property (nonatomic,copy)JPScrollView *(^scrollViewContentSize)(CGSize contentSize);
@property (nonatomic,copy)JPScrollView *(^scrollViewPageEnabled)(BOOL pagingEnabled);
@property (nonatomic,copy)JPScrollView *(^scrollViewShowHor)(BOOL showsHor);
@property (nonatomic,copy)JPScrollView *(^scrollViewShowVer)(BOOL showsVer);
@property (nonatomic,copy)JPScrollView *(^scrollViewDelegate)(id target);

+ (instancetype)jp_scrollViewInitWith:(void (^)(JPScrollView *scrollView))block;

@end
