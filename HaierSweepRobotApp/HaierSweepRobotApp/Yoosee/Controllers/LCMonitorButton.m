//
//  LCMonitorButton.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LCMonitorButton.h"

@implementation LCMonitorButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.frame.size.width/2.0-12.5, self.frame.size.height/2.0-12.5, 25, 25);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
