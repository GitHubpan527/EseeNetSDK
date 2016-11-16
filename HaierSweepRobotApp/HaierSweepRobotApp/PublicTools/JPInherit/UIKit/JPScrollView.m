
//
//  JPScrollView.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPScrollView.h"

@implementation JPScrollView

+ (instancetype)jp_scrollViewInitWith:(void (^)(JPScrollView *scrollView))block
{
    JPScrollView *scrollView = [[JPScrollView alloc] init];
    if (block) {
        block(scrollView);
    }
    return scrollView;
}

- (JPScrollView *(^)(CGRect))scrollViewFrame
{
    return ^JPScrollView *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPScrollView *(^)(CGSize))scrollViewContentSize
{
    return ^JPScrollView *(CGSize contentSize) {
        self.contentSize = contentSize;
        return self;
    };
}

- (JPScrollView *(^)(BOOL))scrollViewPageEnabled
{
    return ^JPScrollView *(BOOL pagingEnabled) {
        self.pagingEnabled = pagingEnabled;
        return self;
    };
}

- (JPScrollView *(^)(BOOL))scrollViewShowHor
{
    return ^JPScrollView *(BOOL showsHor) {
        self.showsHorizontalScrollIndicator = showsHor;
        return self;
    };
}

- (JPScrollView *(^)(BOOL))scrollViewShowVer
{
    return ^JPScrollView *(BOOL showsVer) {
        self.showsVerticalScrollIndicator = showsVer;
        return self;
    };
}

- (JPScrollView *(^)(id))scrollViewDelegate
{
    return ^JPScrollView *(id target) {
        self.delegate = target;
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
