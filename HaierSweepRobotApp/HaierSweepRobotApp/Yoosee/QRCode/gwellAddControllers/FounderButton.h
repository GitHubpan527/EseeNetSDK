//
//  FounderButton.h
//  P2PPlayingbackVC
//
//  Created by apple on 16/7/19.
//  Copyright © 2016年 yuanHongQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"

@interface FounderButton : UIButton
@property(nonatomic,assign)NSInteger yTag;
@property(nonatomic,assign)CGSize buttonImageViewSize;
@property(nonatomic,assign)CGFloat buttonImageLeftOffset;
@property(nonatomic,assign)CGFloat buttonImageUpOffset;
/**这个方法建议不要使用,会出现布局的问题,请使用 setImage的方法*/
-(void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state NS_DEPRECATED_IOS(2_0, 3_0);
@end
