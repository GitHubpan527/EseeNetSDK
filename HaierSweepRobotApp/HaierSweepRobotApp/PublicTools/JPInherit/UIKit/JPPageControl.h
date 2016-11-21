//
//  JPPageControl.h
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPPageControl : UIPageControl

@property (nonatomic,copy)JPPageControl *(^pageControlFrame)(CGRect frame);
@property (nonatomic,copy)JPPageControl *(^pageControlNumberOfPages)(NSInteger numberOfPages);
@property (nonatomic,copy)JPPageControl *(^pageControlCurrentPage)(NSInteger currentPage);
@property (nonatomic,copy)JPPageControl *(^pageControlCurrentColor)(UIColor *currentPageIndicatorTintColor);
@property (nonatomic,copy)JPPageControl *(^pageControlPageColor)(UIColor *pageIndicatorTintColor);

+ (instancetype)jp_pageControlInitWith:(void (^)(JPPageControl *pageControl))block;

@end
