//
//  VedioTableViewCell.h
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/18.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#define LibCachesNVRVideoPath [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],@"/Caches/NVRVideo"]

@interface VedioTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView * myImageView;
@property (nonatomic,strong) UIView *pauseView;
@property (nonatomic,strong) UIButton *pauseBtn;
@property (nonatomic,strong) UILabel *dateLabel;


@end
