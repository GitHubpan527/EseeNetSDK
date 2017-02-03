//
//  RollingImage.h
//  RollingImage
//
//  Created by MAC on 16/5/24.
//  Copyright © 2016年 yhq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"

@interface RollingImage : UIView
@property(nullable,nonatomic,strong)UIImage* rollingImage;
-(void)startRolling;
-(void)stopRolling;
-(void)pauseRolling;
-(BOOL)isRuning;
@end
