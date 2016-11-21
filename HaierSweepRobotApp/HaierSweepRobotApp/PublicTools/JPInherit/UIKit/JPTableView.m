//
//  JPTableView.m
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "JPTableView.h"

@implementation JPTableView

+ (instancetype)jp_tableViewInitWith:(void (^)(JPTableView *tableView))block style:(UITableViewStyle)style
{
    JPTableView *tableView = [[JPTableView alloc] initWithFrame:CGRectZero style:style];
    if (block) {
        block(tableView);
    }
    return tableView;
}

- (JPTableView *(^)(CGRect))tableViewFrame
{
    return ^JPTableView *(CGRect frame) {
        self.frame = frame;
        return self;
    };
}

- (JPTableView *(^)(id))tableViewDelegate
{
    return ^JPTableView *(id target) {
        self.delegate = target;
        return self;
    };
}

- (JPTableView *(^)(id))tableViewDataSource
{
    return ^JPTableView *(id target) {
        self.dataSource = target;
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
