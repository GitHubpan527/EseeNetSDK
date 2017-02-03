//
//  WaitingPageView.m
//  Yoosee
//
//  Created by wutong on 15-2-4.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "WaitingPageView.h"
#import "Constants.h"
#import "YProgressView.h"
#import "RollingImage.h"
#import "UIViewExt.h"

@implementation WaitingPageView
{
    RollingImage* _rollingImage;
    UIImageView *waitingContentTop;
    UIView *waitingContent;
}
-(void)startWaitRolling{
    //NSLog(@"开始声波移动");
    [_rollingImage startRolling];
}
-(void)pauseWaitRolling{
    //NSLog(@"暂停声波移动");
    [_rollingImage pauseRolling];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [_rollingImage stopRolling];
}

-(void)dealloc
{

    

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat TempW=self.width;
    CGFloat TempH=64;
    CGFloat TempX=0;
    CGFloat TempY=(waitingContentTop.height-TempH)/2.0+waitingContentTop.top;
    CGRect newRect=CGRectMake(TempX, TempY, TempW, TempH);
    _rollingImage.frame=newRect;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initCompnents];
    }
    return self;
}

#define QRCODE_IMAGE_WIDTH_HEIGHT 200
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 100
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 288
#define WAITING_CONTENT_VIEW_HEIGHT 300

-(void)initCompnents
{
    self.backgroundColor = XBgColor;
//    self.backgroundColor=[UIColor greenColor];
    
    //WAITING CONTENT
    waitingContent = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-self.frame.size.width)/2, (self.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2, self.frame.size.width, WAITING_CONTENT_VIEW_HEIGHT)];
//    waitingContent.backgroundColor=[UIColor blueColor];
    [self addSubview:waitingContent];

//    waitingContent.backgroundColor = [UIColor orangeColor];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, waitingContent.frame.size.width, 30)];
    titleLable.textColor = XBlack;
    titleLable.textAlignment = NSTextAlignmentCenter;
//    titleLable.text = CustomLocalizedString(@"waiting_content_prompt01", nil);
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.font = XFontBold_18;
    [waitingContent addSubview:titleLable];

    //声波移动图 SoundWaves.png
    _rollingImage=[[RollingImage alloc] init];
    _rollingImage.backgroundColor=[UIColor clearColor];
    _rollingImage.rollingImage=[UIImage imageNamed:@"SoundWaves.png"];
//    [_rollingImage startRolling];
    [waitingContent addSubview:_rollingImage];

    
    
    waitingContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, waitingContent.frame.size.width-20*2, waitingContent.frame.size.height*0.4)];
//    waitingContentTop.backgroundColor=[UIColor purpleColor];
    waitingContentTop.contentMode = UIViewContentModeScaleAspectFit;
    waitingContentTop.image = [UIImage imageNamed:@"SoundWaite_add.png"];
    [waitingContent addSubview:waitingContentTop];

    
    
    YProgressView *yProgress = [[YProgressView alloc] initWithFrame:CGRectMake((waitingContent.frame.size.width-38)/2, waitingContent.frame.size.height/2+20+20, 38, 38)];
    yProgress.backgroundView.image = [UIImage imageNamed:@"ic_progress_blue.png"];
    yProgress.hidden=YES;
    [yProgress start];
    [waitingContent addSubview:yProgress];
 
    
    
    UILabel *waitingContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yProgress.frame.origin.y+yProgress.frame.size.height+10, waitingContent.frame.size.width-10*2, 60)];
    waitingContentLabel.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    waitingContentLabel.numberOfLines = 0;
    waitingContentLabel.backgroundColor = [UIColor clearColor];
    waitingContentLabel.textColor = XBlack;
    waitingContentLabel.textAlignment = NSTextAlignmentLeft;
    waitingContentLabel.text = CustomLocalizedString(@"waiting_content_prompt02", nil);
    waitingContentLabel.font = XFontBold_16;
    [waitingContent addSubview:waitingContentLabel];

}

@end
