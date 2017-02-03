//
//  YTheNaviBar.h
//  YTheNaviBar
//
//  Created by apple on 16/8/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "FounderButton.h"

NS_ASSUME_NONNULL_BEGIN
@interface YTheNaviBar : UIControl
@property(nonatomic,assign)NSInteger yTag;
@property(nonatomic,assign)CGFloat yBarLeftSpace;
@property(nonatomic,assign)CGFloat yBarRightSpace;
@property(nonatomic,strong,nullable)UIColor* yBarColor;
@property(nonatomic,strong,nullable)UIImage* yBarImage;
@property(nonatomic,strong,nullable)UIColor* yBarBottomLineColor;
@property(nonatomic,assign)CGFloat  yBarBottomLineHeight;
@property(nonatomic,copy,nullable)NSAttributedString* yBarTextLeft;
@property(nonatomic,copy,nullable)NSAttributedString* yBarTextCenter;
@property(nonatomic,copy,nullable)NSAttributedString* yBarTextRight;
/**传入的按钮必需有宽值*/
@property(nonatomic,copy,nullable)NSArray<FounderButton*>* yBarButtonsLeft;
/**传入的按钮必需有宽值*/
@property(nonatomic,copy,nullable)NSArray<FounderButton*>* yBarButtonsRight;
-(NSAttributedString*)gtTextWithString:(nullable NSString*)str
                             withColor:(nullable UIColor*)color
                              withFont:(nullable UIFont*)font
                         withAlignment:(NSTextAlignment)alig;
@end
NS_ASSUME_NONNULL_END