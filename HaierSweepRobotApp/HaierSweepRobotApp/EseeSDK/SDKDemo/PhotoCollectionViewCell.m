//
//  PhotoCollectionViewCell.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/17.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.bounds.size.width, self.bounds.size.height - 20)];
        [self.contentView addSubview:self.myImageView];
    }
    return self;
}
@end
