//
//  BaseTableView.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/26.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RequestDataDelegate <NSObject>

- (void)requestDataWithRefresh:(BOOL)isRefresh;

@end

@interface BaseTableView : UITableView

@property (nonatomic,weak)id<RequestDataDelegate>requestDelegate;

@property (nonatomic,assign)int pageIndex;
@property (nonatomic,assign)int pageSize;
@property (nonatomic,strong)NSMutableArray *dataArray;

- (void)loadSuccess;

- (void)loadFailure;

@end
