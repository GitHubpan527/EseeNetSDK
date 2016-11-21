//
//  BaseTableView.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/26.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseTableView.h"

@implementation BaseTableView

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        self.pageIndex = 1;
        self.pageSize = 10;
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self loadData:YES];
        }];
        [self.mj_header beginRefreshing];
        self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self loadData:NO];
        }];
    }
    return self;
}

- (void)awakeFromNib
{
    self.pageIndex = 1;
    self.pageSize = 10;
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:YES];
    }];
    [self.mj_header beginRefreshing];
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadData:NO];
    }];
}

- (void)loadData:(BOOL)isRefresh
{
    if (isRefresh) {
        self.pageIndex = 1;
    } else {
        self.pageIndex ++;
    }
    if ([self.requestDelegate respondsToSelector:@selector(requestDataWithRefresh:)]) {
        [self.requestDelegate requestDataWithRefresh:isRefresh];
    }
}

- (void)loadSuccess
{
    [self reloadData];
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

- (void)loadFailure
{
    self.pageIndex --;
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
