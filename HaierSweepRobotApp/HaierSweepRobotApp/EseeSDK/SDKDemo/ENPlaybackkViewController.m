//
//  ENPlaybackkViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/20.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "ENPlaybackkViewController.h"
#import "EseeNetRecord.h"
#import "AppDelegate.h"

#define SecondDistance (_timeLineView.frame.size.width/86400)

#define WIDTH              self.view.frame.size.width
#define HEIGHT             self.view.frame.size.height
#define ViewX(view)        view.frame.origin.x
#define ViewY(view)        view.frame.origin.y
#define ViewW(view)        view.frame.size.width
#define ViewH(view)        view.frame.size.height
#define ViewBtmY(view)     (view.frame.size.height+view.frame.origin.y)
#define ViewRightX(view)   (view.frame.size.width+view.frame.origin.x)
#define BoundsCenter(view) (CGPoint){view.center.x-view.frame.origin.x,view.center.y-view.frame.origin.y}
#define Jianju 3

@interface ENPlaybackkViewController ()<EseeNetRecordDelegate>
{
    NSDictionary *deviceInfo;/**< 设备信息*/
    
    EseeNetRecord *_recordVideo;
    
    BOOL _didConnected;
    
    BOOL _isHavePlay;//当前的状态
    
    int _fromTime;
    int _toTime;
    
    UIView *btnView;//btn的承载view
    
    NSMutableArray *recordTimer;
    
    UIView *bottomView;//底部View
    UILabel *startLabel;//起始时间
    UILabel *endLabel;//总时间
    UISlider *slider;//滑块
    
    NSDate *startDate;//当前起始日期
    NSDate *endDate;//结束日期
    
    float starTime;//当前秒数
    float timerAll;//总秒数
    
}
@end

@implementation ENPlaybackkViewController

- (void)setPlayBackInfoWithDevIDOrIP:(NSString *)devIDOrIP UserName:(NSString *)userName Passwords:(NSString *)passwords Channel:(int)channel Port:(int)port PlayTime:(NSString *)playTime
{
    deviceInfo = @{
                   @"devIDOrIP":devIDOrIP,//设备ID或IP
                   @"password":passwords,
                   @"userName":userName,
                   @"channel":[NSNumber numberWithInteger:channel],
                   @"port":[NSNumber numberWithInt:port],
                   @"playTime":playTime
                   };
    _fromTime = [self toGMT:[NSString stringWithFormat:@"%@ 00:00:00",playTime]];
    _toTime = _fromTime + 86400;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isHavePlay = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
    [self.view addGestureRecognizer:tap];
    [self layoutRecordVideo];
    [self btnView];

}
- (void)layoutRecordVideo
{
//    [self _shouldRotateToOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
    
    _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:CGRectMake(0, (HEIGHT - WIDTH) / 2, WIDTH, WIDTH)];
    NSLog(@"wwwwwwwwwwwwww%f---%f",self.view.frame.size.height,self.view.frame.size.width);
    _recordVideo.delegate = self;
    
    [_recordVideo setDeviceInfoWithDeviceID:deviceInfo[@"devIDOrIP"] Passwords:deviceInfo[@"password"] UserName:deviceInfo[@"userName"] Channel:[deviceInfo[@"channel"] intValue] Port:[deviceInfo[@"port"] intValue]];
    [self.view addSubview:_recordVideo];
    
    /*
     @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
     */
    [_recordVideo initOSDText:@{@"connecting":@"连接中",@"connectFail":@"连接失败",@"logining":@"登录中",@"loginFail":@"登录失败",@"timeOut":@"超时",@"loading":@"登录中",@"searching":@"搜索中",@"searchFail":@"搜索失败",@"searchNull":@"没有视频",@"playFail":@"播放失败"}];
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 27, 30, 30);
    //    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.title = [NSString stringWithFormat:@"%@:%@",@"回放",deviceInfo[@"playTime"]];
    
}
- (void)btnView
{
    btnView = [[UIView alloc] initWithFrame:CGRectMake((_recordVideo.bounds.size.width - 64 ) / 2, (_recordVideo.bounds.size.height - 64 ) / 2, 64, 64)];
    [_recordVideo addSubview:btnView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 64, 64);
    [btn setImage:[UIImage imageNamed:@"pausew.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:btn];
    
}
- (void)playAndPauseView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 50, WIDTH, 50)];
    bottomView.backgroundColor = [UIColor darkGrayColor];
    bottomView.alpha = 0.8;
    [self.view addSubview:bottomView];
    //
    UIButton *btnA = [UIButton buttonWithType:UIButtonTypeCustom];
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    [btnA setImage:[UIImage imageNamed:@"NVRpause.png"] forState:UIControlStateNormal];
    [btnA addTarget:self action:@selector(played:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btnA];
    //
    UIButton *btnB = [UIButton buttonWithType:UIButtonTypeCustom];
    btnB.frame = CGRectMake(WIDTH - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    [btnB setImage:[UIImage imageNamed:@"NVRquanping.png"] forState:UIControlStateNormal];
    [btnB addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btnB];
    //
    startLabel = [[UILabel alloc] initWithFrame:CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30)];
    startLabel.text = @"00:00:00";
    startLabel.font = [UIFont systemFontOfSize:9];
    startLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:startLabel];
    //
    endLabel = [[UILabel alloc] initWithFrame:CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30)];
    endLabel.text = [self getAllTime];
    endLabel.font = [UIFont systemFontOfSize:9];
    endLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:endLabel];
    //
    slider = [[UISlider alloc] initWithFrame:CGRectMake(ViewRightX(startLabel) + Jianju, (ViewH(bottomView) - 30) / 2, ViewX(endLabel) - Jianju * 2 - ViewRightX(startLabel), 30)];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    slider.minimumTrackTintColor = [UIColor whiteColor];
    slider.maximumTrackTintColor = [UIColor blackColor];
    [slider addTarget:self action:@selector(slidered:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:slider];
    
}
#pragma mark - EseeNetRecordDelegate
- (void)eseeNetRecordCurTime:(int)curTime
{
    NSLog(@"%d,%@",curTime,[self TimeStamp:[NSString stringWithFormat:@"%d",curTime]]);
    NSString *string = [self TimeStamp:[NSString stringWithFormat:@"%d",curTime]];
    startLabel.text = [string componentsSeparatedByString:@" "][1];//00:01:11
    
    NSArray *arrStar = [startLabel.text componentsSeparatedByString:@":"];
    starTime = [arrStar[0] floatValue] * 3600.0 + [arrStar[1] floatValue] * 60.0 + [arrStar[2] floatValue] * 1.0;
    
    NSArray *arrEnd = [endLabel.text componentsSeparatedByString:@":"];
    timerAll = [arrEnd[0] floatValue] * 3600.0 + [arrEnd[1] floatValue] * 60.0 + [arrEnd[2] floatValue] * 1.0;
    
    float scale = starTime / timerAll;
    slider.value = scale;
    
}
- (void)slidered:(UISlider *)sliderNow
{
    NSString *day = deviceInfo[@"playTime"];
    int hour = sliderNow.value * timerAll / 3600;
    int minute = (sliderNow.value * timerAll - hour * 3600) / 60;
    int second = sliderNow.value * timerAll - hour * 3600 - minute * 60;
    NSString *timeStr = [NSString stringWithFormat:@"%@ %02d:%02d:%02d",day,hour,minute,second];
    [self changeTime:timeStr];
}
- (void)changeTime:(NSString *)timeStr
{
    int newTime = [self toGMT:timeStr];

    NSLog(@"--change Time GMT to --> %d -- %@",newTime,timeStr);
    [self playRecordWithIndex:newTime];
}
- (void)playRecordWithIndex:(int)index
{
    [_recordVideo playWithStartTime:index ToTime:_toTime];
}
//播放、暂停
- (void)played:(UIButton *)sender
{
    static BOOL isPause = YES;
    if (isPause) {
        _recordVideo.pause = YES;
        [sender setImage:[UIImage imageNamed:@"NVRplay.png"] forState:UIControlStateNormal];
        isPause = NO;
    }else{
        _recordVideo.pause = NO;
        [sender setImage:[UIImage imageNamed:@"NVRpause.png"] forState:UIControlStateNormal];
        isPause = YES;
    }
}
//全屏
- (void)fullScreen:(UIButton *)sender
{
    static BOOL isOrientation = YES;
    
    if (isOrientation == YES) {
        _recordVideo.frame = CGRectMake(0, -32, HEIGHT, WIDTH);
        bottomView.frame = CGRectMake(0, WIDTH - 50 - 32, HEIGHT, 50);
        [sender setImage:[UIImage imageNamed:@"NVRnoquanping.png"] forState:UIControlStateNormal];
        AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.isForcePortrait = NO;
        [self forceOrientationLandscape]; //强制横屏
        isOrientation = NO;
    }else{
        _recordVideo.frame = CGRectMake(0, (HEIGHT - WIDTH) / 2, WIDTH, WIDTH);
        bottomView.frame = CGRectMake(0, HEIGHT - 50, WIDTH, 50);
        [sender setImage:[UIImage imageNamed:@"NVRquanping.png"] forState:UIControlStateNormal];
        AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.isForceLandscape = NO;
        [self forceOrientationPortrait];//强制竖屏
        isOrientation = YES;
    }
}
#pragma mark - 强制横屏&竖屏
//强制横屏
-(void)forceOrientationLandscape{
    //这段代码，只能旋转屏幕不能达到强制横屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    //加上代理类里的方法，旋转屏幕可以达到强制横屏的效果
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}
//强制竖屏
-(void)forceOrientationPortrait{
    
    //这段代码，只能旋转屏幕不能达到强制竖屏的效果
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationMaskPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
}
//得到所有的时间
- (NSString *)getAllTime
{
    NSInteger hour = 0;NSInteger minute = 0;NSInteger second = 0;
    NSInteger hourTmp = 0;NSInteger minuteTmp = 0;NSInteger secondTmp = 0;
    for (int i = 0; i < recordTimer.count; i ++) {
        NSDictionary *dic = recordTimer[i];
        
        NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
        dateFomatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDate = [dateFomatter dateFromString:dic[@"startTime"]];
        endDate = [dateFomatter dateFromString:dic[@"endTime"]];
        
        // 当前日历
        NSCalendar *calendar = [NSCalendar currentCalendar];
        // 需要对比的时间数据
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
        | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        // 对比时间差
        NSDateComponents *dateCom = [calendar components:unit fromDate:startDate toDate:endDate options:0];
        
        //小时差额 = dateCom.hour, 分钟差额 = dateCom.minute, 秒差额 = dateCom.second
        hourTmp = dateCom.hour;
        minuteTmp = dateCom.minute;
        secondTmp = dateCom.second;
        if (secondTmp >= 59) {
            secondTmp = 0;
            minuteTmp ++;
            hourTmp = hourTmp;
        }
        if (minuteTmp > 59) {
            secondTmp = secondTmp;
            minuteTmp = 0;
            hourTmp ++;
        }
        //
        second = second + secondTmp;
        minute = minute + minuteTmp;
        hour = hour + hourTmp;
        if (second > 59) {
            second = 0;
            minute ++;
            hour = hour;
        }
        if (minute > 59) {
            second = second;
            minute = 0;
            hour ++;
        }
    }
    NSMutableArray *timeArr = [[NSMutableArray alloc] init];
    [timeArr insertObject:@(hour) atIndex:0];
    [timeArr insertObject:@(minute) atIndex:1];
    [timeArr insertObject:@(second) atIndex:2];
    NSString *str = nil;
    if (hour == 24) {
        str = @"24:00:00";
        return str;
    }else{
        NSString *timeStr = [NSString stringWithFormat:@"%@:%@:%@",timeArr[0],timeArr[1],timeArr[2]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSDate *date = [formatter dateFromString:timeStr];
        str = [formatter stringFromDate:date];
        return str;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self orientationToPortrait:UIInterfaceOrientationLandscapeRight];
    self.navigationController.navigationBar.hidden = YES;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait = NO;
    appdelegate.isForceLandscape = NO;
    
}
- (void)taped:(UITapGestureRecognizer *)tap
{
    static BOOL isTap;
    if (isTap) {
        [self playAndPauseView];
        if (_isHavePlay == NO) {
            bottomView.userInteractionEnabled = NO;
        }else{
            bottomView.userInteractionEnabled = YES;
        }
        self.navigationController.navigationBar.hidden = NO;
        isTap = NO;
    }else{
        [bottomView removeFromSuperview];
        self.navigationController.navigationBar.hidden = YES;
        isTap = YES;
    }
}
//播放
- (void)play{
    _isHavePlay = YES;
    [btnView removeFromSuperview];
    if (_didConnected == NO) {
        [_recordVideo connectDevice:^(RecordConnectResult result) {
            switch (result) {
                case RecordConnectSuccess:
                {
                    _didConnected = YES;
                    NSLog(@"--- Connect Success --- ");
                    [_recordVideo searchRecordWithFromTime:_fromTime ToTime:_toTime Completion:^(NSArray *recordTimesArr) {
                        
                        if (recordTimesArr.count > 0)
                        {
                            NSLog(@"--- Search Success -->%@",recordTimesArr);
                            //将时间戳转换为时间点
                            
                            [_recordVideo playWithStartTime:_fromTime ToTime:_toTime];
                            dispatch_sync(dispatch_get_main_queue(), ^(){
                                // 这里的代码会在主线程执行
                                recordTimer = [[NSMutableArray alloc] init];
                                
                                for (int i = 0; i < recordTimesArr.count; i ++) {
                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                    [dict setObject:[self TimeStamp:recordTimesArr[i][@"startTime"]] forKey:@"startTime"];
                                    [dict setObject:[self TimeStamp:recordTimesArr[i][@"endTime"]] forKey:@"endTime"];
                                    [recordTimer insertObject:dict atIndex:i];
                                }
                                NSLog(@"recordTimer----------------------------------------%@",recordTimer);
                            });
                        }else{
                            NSLog(@"--- No Reocrd ---");
                        }
                        
                    }];
                }
                    break;
                    
                case RecordConnectFile:
                {
                    NSLog(@"----- 连接失败");
                }
                    break;
                    
                case RecordConnectLoginFile:
                {
                    
                    NSLog(@"----- 登陆失败");
                }
                    break;
                    
                case RecordConnectTimeOut:
                {
                    
                    NSLog(@"----- 连接超时");
                }
                    break;
                    
                default:
                    break;
            }
        }];
    }
}
#pragma mark - iOS转时间戳
- (NSString *)TimeStamp:(NSString *)strTime
{
    NSString *str= strTime;//时间戳
    NSTimeInterval time = [str doubleValue];//因为时差问题要加8小时 == 28800 sec   + 28800
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSLog(@"date:%@",[detaildate description]);
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    return currentDateStr;
}
//暂停
- (void)pause{
    _recordVideo.pause = YES;
}
//继续
- (void)continuee{
    _recordVideo.pause = NO;
}
//导航返回
- (void)backBtnAction:(UIBarButtonItem *)sender {
    [_recordVideo stop:^(BOOL success) {
    }];
//    [self orientationToPortrait:UIInterfaceOrientationPortrait];
    [self.navigationController popViewControllerAnimated:YES];
}
- (int)toGMT:(NSString *)timeStr
{
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *locale    = [NSLocale currentLocale];
    df.locale           = locale;
    NSDate *mydate      = [df dateFromString:timeStr];
    int GMT             = [mydate timeIntervalSince1970];
    return GMT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
