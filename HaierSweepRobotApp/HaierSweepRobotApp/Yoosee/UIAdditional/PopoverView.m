//
//  PopoverView.m
//  Yoosee
//
//  Created by gwelltime on 15-3-20.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverView.h"
#import "PopoverButton.h"
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
@implementation PopoverView

-(void)dealloc{
    [self.backgroundImage release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
/*
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    //backgroud image
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.image = self.backgroundImage;
    [self addSubview:backgroundView];
    [backgroundView release];
    
    //智能联机
    int dwTopInterval = 12;
    int dwLineHeight = 1;
    int dwBtnHeight = (self.frame.size.height-dwTopInterval-dwLineHeight)/3.0;
    
    PopoverButton *button1 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, dwTopInterval, self.frame.size.width, dwBtnHeight);
    [button1 setImage:[UIImage imageNamed:@"img_radar_add.png"] forState:UIControlStateNormal];
    [button1 setTitle:CustomLocalizedString(@"qrcode_add", nil) forState:UIControlStateNormal];
    button1.tag = 1;
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    
    //分割线
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.frame = CGRectMake(0, dwTopInterval+dwBtnHeight, self.frame.size.width, dwLineHeight);
    lineView1.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView1];
    [lineView1 release];
    
    //手动添加
    PopoverButton *button2 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, dwTopInterval+dwBtnHeight+dwLineHeight, self.frame.size.width, dwBtnHeight);
    [button2 setImage:[UIImage imageNamed:@"ic_add_contact_manually.png"] forState:UIControlStateNormal];
    [button2 setTitle:CustomLocalizedString(@"manually_add", nil) forState:UIControlStateNormal];
    button2.tag = 2;
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    
    //分割线
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.frame = CGRectMake(0, dwTopInterval+dwBtnHeight*2+dwLineHeight, self.frame.size.width, dwLineHeight);
    lineView2.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView2];
    [lineView2 release];
    
    //手动添加
    PopoverButton *button3 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(0, dwTopInterval+dwBtnHeight*2+dwLineHeight*2, self.frame.size.width, dwBtnHeight);
    [button3 setImage:[UIImage imageNamed:@"ic_add_contact_manually.png"] forState:UIControlStateNormal];
    [button3 setTitle:CustomLocalizedString(@"ap_mode_text", nil) forState:UIControlStateNormal];
    button3.tag = 3;
    button3.backgroundColor = [UIColor clearColor];
    [button3 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button3];
}
*/
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    //backgroud image
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.image = self.backgroundImage;
    [self addSubview:backgroundView];
    [backgroundView release];
    
    //智能联机
    PopoverButton *button1 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, 12.0, self.frame.size.width, (self.frame.size.height-13)/2.0);
    //[button1 setImage:[UIImage imageNamed:@"二维码-"] forState:UIControlStateNormal];
  //  [button1 setTitle:CustomLocalizedString(@"add_tab_title01", nil) forState:UIControlStateNormal];
    button1.tag = 1;
   // button1.titleLabel.font = [UIFont systemFontOfSize:15];
   // [button1 setTitleColor:RGBACOLOR(85, 85, 85, 1.0) forState:UIControlStateNormal];
    
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    
    UIImageView * img1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, button1.frame.size.height-10, button1.frame.size.height-10)];
    img1.image = [UIImage imageNamed:@"二维码-"];
    [button1 addSubview:img1];
    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img1.frame)+5, 0, self.frame.size.width-CGRectGetMaxX(img1.frame)-8, button1.frame.size.height)];
    label1.text = CustomLocalizedString(@"add_tab_title01", nil);
    label1.textColor = RGBACOLOR(85, 85, 85, 1.0);
    label1.textAlignment = NSTextAlignmentCenter;
    [button1 addSubview:label1];
    
    
    //分割线
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, (self.frame.size.height-13)/2.0+12.0, self.frame.size.width, 1);
    lineView.backgroundColor = RGBACOLOR(85, 85, 85, 1.0);
    [self addSubview:lineView];
    [lineView release];
    
    //手动添加
    PopoverButton *button2 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, (self.frame.size.height-13)/2.0+13.0, self.frame.size.width, (self.frame.size.height-13)/2.0);
   // [button2 setImage:[UIImage imageNamed:@"书写-"] forState:UIControlStateNormal];
   // [button2 setTitle:CustomLocalizedString(@"manually_add", nil) forState:UIControlStateNormal];
    button2.tag = 2;
   // button2.titleLabel.font = [UIFont systemFontOfSize:15];
    // [button2 setTitleColor:RGBACOLOR(85, 85, 85, 1.0) forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    
    UIImageView * img2 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, button2.frame.size.height-10, button2.frame.size.height-10)];
    img2.image = [UIImage imageNamed:@"书写-"];
    [button2 addSubview:img2];
    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(img2.frame)+5, 0, self.frame.size.width-CGRectGetMaxX(img2.frame)-8, button2.frame.size.height)];
    label2.text = CustomLocalizedString(@"manually_add", nil);
    label2.textColor = RGBACOLOR(85, 85, 85, 1.0);
    label2.textAlignment = NSTextAlignmentCenter;
    [button2 addSubview:label2];
}

-(void)buttonBeClicked:(UIButton *)sender{
    if (self.delegate) {
        [self.delegate didSelectedPopoverViewRow:sender.tag];
    }
}
@end
