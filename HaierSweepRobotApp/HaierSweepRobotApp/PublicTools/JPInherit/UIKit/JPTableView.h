//
//  JPTableView.h
//  JPInherit
//
//  Created by Ljp on 16/8/18.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPTableView : UITableView

@property (nonatomic,copy)JPTableView *(^tableViewFrame)(CGRect frame);
@property (nonatomic,copy)JPTableView *(^tableViewDelegate)(id target);
@property (nonatomic,copy)JPTableView *(^tableViewDataSource)(id target);

+ (instancetype)jp_tableViewInitWith:(void (^)(JPTableView *tableView))block style:(UITableViewStyle)style;

@end
