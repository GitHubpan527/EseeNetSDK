//
//  CameraTypeViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/10/14.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CameraImageBlock)(NSString *imageUrl);

@interface CameraTypeViewController : BaseViewController

@property (nonatomic,copy)CameraImageBlock block;

@end
