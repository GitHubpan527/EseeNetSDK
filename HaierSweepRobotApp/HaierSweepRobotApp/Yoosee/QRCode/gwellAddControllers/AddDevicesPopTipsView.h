//
//  AddDevicesPopTipsView.h
//  Yoosee
//
//  Created by apple on 16/10/19.
//  Copyright © 2016年 lk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddDevicesPopTipsViewDelegate;

@protocol AddDevicesPopTipsViewDelegate <NSObject>
@optional
-(void)buttonBePressed:(UIButton*)btn;

@end

@interface AddDevicesPopTipsView : UIView

@property(strong,nonatomic) UIView *blackBgView; //背景view
@property(strong,nonatomic) UIView *whiteBgView;


@property(strong,nonatomic) UILabel *topTitleLb; //顶部居中文字
@property(strong,nonatomic) UIButton *closeBtn;//右上角关闭按钮
@property(strong,nonatomic) UIView *aLineView; //一根线条


@property(nonatomic,weak)id<AddDevicesPopTipsViewDelegate> delegate;


-(void)setUpUIWithTitle:(NSString*)title numberOfLabel:(int)lbNumber lbTextArr:(NSMutableArray*)lbArr numberOfBtn:(int)btnNumber btnTextArr:(NSMutableArray*)btnArr eitherHaveImgView:(BOOL)yes;

@end



