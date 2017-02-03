//
//  AddDevicesPopTipsView.m
//  Yoosee
//
//  Created by apple on 16/10/19.
//  Copyright © 2016年 lk. All rights reserved.
//

#import "AddDevicesPopTipsView.h"
#import "Constants.h"

@implementation AddDevicesPopTipsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews
{

    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGFloat whiteViewWidth = screenWidth-40;
    CGFloat whiteViewHeight = screenHeight-60;
    CGFloat whiteViewX = (screenWidth - whiteViewWidth)/2.0;
    CGFloat whiteViewY = (screenHeight - whiteViewHeight)/2.0;
    
    
    self.blackBgView.frame = self.frame;
    self.whiteBgView.frame = CGRectMake(whiteViewX, whiteViewY, whiteViewWidth, whiteViewHeight);
    
    self.topTitleLb.frame = CGRectMake(0, 20, whiteViewWidth-31-10, 30);
    self.closeBtn.frame = CGRectMake(whiteViewWidth-30-10,25, 31/1.5, 30/1.5);
    self.aLineView.frame = CGRectMake(0,CGRectGetMaxY(self.topTitleLb.frame)+10 , screenWidth, 1);
    
}

-(void)setUpUIWithTitle:(NSString*)title numberOfLabel:(int)lbNumber lbTextArr:(NSMutableArray*)lbArr numberOfBtn:(int)btnNumber btnTextArr:(NSMutableArray*)btnArr eitherHaveImgView:(BOOL)yes
{
    //背景view
    self.blackBgView = [[UIView alloc] init];
    self.blackBgView.hidden = YES;
    self.blackBgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self addSubview:self.blackBgView];
    
    self.whiteBgView = [[UIView alloc] init];
    self.whiteBgView.backgroundColor = [UIColor whiteColor];
    self.whiteBgView.layer.cornerRadius = 5;
    self.whiteBgView.layer.masksToBounds=YES;
    [self.blackBgView addSubview:self.whiteBgView];
    
    //顶部文字
    self.topTitleLb = [[UILabel alloc] init];
    self.topTitleLb.numberOfLines=0;
    self.topTitleLb.textAlignment=NSTextAlignmentCenter;
    self.topTitleLb.text=CustomLocalizedString(title, nil);
    self.topTitleLb.backgroundColor=[UIColor clearColor];
    self.topTitleLb.font=[UIFont boldSystemFontOfSize:17.0];
    self.topTitleLb.textColor=[UIColor blackColor];
    [self.whiteBgView addSubview:self.topTitleLb];
    
    //关闭按钮
    self.closeBtn = [[UIButton alloc] init];
    self.closeBtn.imageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"AddDevice_Close.png"]
                             forState:UIControlStateNormal];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"AddDevice_Close_down.png"]
                             forState:UIControlStateHighlighted];
    self.closeBtn.backgroundColor = [UIColor clearColor];
    
    [self.whiteBgView addSubview:self.closeBtn];

    
    //一根横线
    self.aLineView = [[UIView alloc] init];
    self.aLineView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    [self.whiteBgView addSubview:self.aLineView];

    //纯文字
    [self setUpLaebl:lbNumber  lbTitleArr:lbArr];
    
    //文字和图片  
    if(yes){
        //上面还有两行提示文字
        //可以尝试 的文字提醒
        CGFloat labelY = CGRectGetMaxY(self.aLineView.frame)+60+40*2+20;

        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(20, labelY, 100, 30);
        label.text = CustomLocalizedString(@"you_may_attempt", nil);
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textAlignment = NSTextAlignmentLeft;
        [self.whiteBgView addSubview:label];
        
        UILabel *resetLabel = [[UILabel alloc] init];
        resetLabel.frame = CGRectMake(20, CGRectGetMaxY(label.frame)+10, 250, 40);
        resetLabel.text = CustomLocalizedString(@"reset_text", nil);
        resetLabel.numberOfLines = 0;
        resetLabel.font = [UIFont systemFontOfSize:13.0];
        resetLabel.textAlignment = NSTextAlignmentLeft;
        [self.whiteBgView addSubview:resetLabel];
       //图片
        CGFloat screenWidth = self.frame.size.width;
        CGFloat screenHeight = self.frame.size.height;
        
        CGFloat whiteViewWidth = screenWidth-40;
        CGFloat whiteViewHeight = screenHeight-120;
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.frame = CGRectMake(0, CGRectGetMaxY(resetLabel.frame)+10, 517/3.0+40, 305/3.0);
        imgView.center = CGPointMake(whiteViewWidth/2.0, CGRectGetMaxY(resetLabel.frame)+10+305/3.0/2.0);
        [imgView setImage:[UIImage imageNamed:@"reset_imgView.png"]];
        
        [self.whiteBgView addSubview:imgView];
        
    
    }
    
    //按钮
    [self setUpButton:btnNumber btnTitle:btnArr];
    
    
}

-(void)setUpLaebl:(int)number lbTitleArr:(NSMutableArray*)arr
{
    
    for(int i=0;i<number;i++){
        
        CGFloat labelY = CGRectGetMaxY(self.aLineView.frame)+60;
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(20, i*40+20+labelY, 250, 40);
        NSString *str =(NSString*)arr[i];
        label.text = CustomLocalizedString(str, nil);
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        label.font =[UIFont systemFontOfSize:13.0];
        
        [self.whiteBgView addSubview:label];
        
    }
    
    
}

-(void)setUpButton:(int)number btnTitle:(NSMutableArray*)btnArr
{
    
    for(int i=0;i<number;i++){
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if(number == 1){
            
            button.frame = CGRectMake(40, 360+number*40, 200, 30);

        }else{
        
            button.frame = CGRectMake(40, 360+i*40, 200, 30);

        }
        
        NSString *str= (NSString*)btnArr[i];
        [button setTitle:CustomLocalizedString(str, nil) forState:UIControlStateNormal];
        [button setTitleColor:NavigationBarColor  forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonhasBeenPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i+2017;
        
        [self.whiteBgView addSubview:button];

    }
}

-(void)buttonhasBeenPressed:(UIButton*)btn{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(buttonBePressed:)]){
        
        [self.delegate buttonBePressed:btn];
        
    }
}


@end
