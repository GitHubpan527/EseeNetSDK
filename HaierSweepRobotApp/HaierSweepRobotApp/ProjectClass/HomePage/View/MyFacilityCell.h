//
//  MyFacilityCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/12.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyFacilityModel.h"

@protocol PushRenameDelegate <NSObject>

- (void)pushRenameVC:(NSString *)facilityId facilityName:(NSString *)facilityName;
- (void)deleteAction:(NSString *)facilityId;

@end

@interface MyFacilityCell : UITableViewCell

@property (nonatomic,weak) id<PushRenameDelegate>delegate;

@property (nonatomic,strong)UIImageView *iconImageView;/**< 头像 */
@property (nonatomic,strong)UILabel *titleL;/**< 名称 */
@property (nonatomic,strong)UIButton *setButton;/**< 设置 */
@property (nonatomic,strong)UIView *detailView;/**< 详情 */

@property (nonatomic,strong)MyFacilityModel *model;

@end
