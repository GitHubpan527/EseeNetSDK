//
//  P2PCallController.h
//  Yoosee
//
//  Created by guojunyi on 14-3-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PClient.h"
@interface P2PCallController : BaseViewController
@property (nonatomic) BOOL isReject;
@property (nonatomic) BOOL isAccept;
@property (strong, nonatomic) NSString *contactName;
@end
