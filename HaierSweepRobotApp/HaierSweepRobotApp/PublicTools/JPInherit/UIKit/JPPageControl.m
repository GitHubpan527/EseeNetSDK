//
//  JPPageControl.m
//  JPInherit
//
//  Created by Ljp on 16/8/19.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPPageControl.h"

@implementation JPPageControl

+ (instancetype)jp_pageControlInitWith:(void (^)(JPPageControl *pageControl))block
{
    JPPageControl *pageControl = [[JPPageControl alloc] init];
    if (block) {
        block(pageControl);
    }
    return pageControl;
}

- (JPPageControl *(^)(CGRect))pageControlFrame
{
    return ^JPPageControl *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPPageControl *(^)(NSInteger))pageControlNumberOfPages
{
    return ^JPPageControl *(NSInteger numberOfPages) {
        self.numberOfPages = numberOfPages;
        return self;
    };
}

- (JPPageControl *(^)(NSInteger))pageControlCurrentPage
{
    return ^JPPageControl *(NSInteger currentPage) {
        self.currentPage = currentPage;
        return self;
    };
}

- (JPPageControl *(^)(UIColor *))pageControlCurrentColor
{
    return ^JPPageControl *(UIColor *currentPageIndicatorTintColor) {
        self.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
        return self;
    };
}

- (JPPageControl *(^)(UIColor *))pageControlPageColor
{
    return ^JPPageControl *(UIColor *pageIndicatorTintColor) {
        self.pageIndicatorTintColor = pageIndicatorTintColor;
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
