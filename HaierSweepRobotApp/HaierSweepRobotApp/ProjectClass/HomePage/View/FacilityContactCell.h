//
//  FacilityContactCell.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Contact.h"

#import "MyFacilityModel.h"

@protocol ContactRenameDelegate <NSObject>

- (void)ContactRenameVC:(Contact *)facilityContact;
- (void)ContactDeleteAction:(Contact *)facilityContact;

@end

@interface FacilityContactCell : UITableViewCell

@property (nonatomic,weak) id<ContactRenameDelegate>delegate;

@property (nonatomic,strong)UIImageView *iconImageView;/**< 头像 */
@property (nonatomic,strong)UILabel *titleL;/**< 名称 */
@property (nonatomic,strong)UIButton *setButton;/**< 设置 */
@property (nonatomic,strong)UIView *detailView;/**< 详情 */

@property (nonatomic,strong)Contact *contactModel;

@property (nonatomic,strong)MyFacilityModel *model;

@end
