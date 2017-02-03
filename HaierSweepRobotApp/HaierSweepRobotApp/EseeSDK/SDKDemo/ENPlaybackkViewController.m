//
//  ENPlaybackkViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/20.
//  Copyright © 2016年 Wynton. All rights reserved.
//  该版本目前从后台进入前台，1、self.navigationController问题，2、横屏时，从后台进入前台后变成了竖屏

#import "ENPlaybackkViewController.h"
#import "EseeNetRecord.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

#define SecondDistance (_timeLineView.frame.size.width/86400)

#define WIDTH1              [UIScreen mainScreen].bounds.size.width
#define HEIGHT1             [UIScreen mainScreen].bounds.size.height
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
#define ChangeTime 1212
#define GongNeng 1314

#define PlayerOrientationIsLandscape      UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define PlayerOrientationIsPortrait       UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)



@interface ENPlaybackkViewController ()<EseeNetRecordDelegate>
{
    NSDictionary *deviceInfo;/**< 设备信息*/
    
    EseeNetRecord *_recordVideo;
    
    BOOL _didConnected;
    
    BOOL _isHavePlay;//当前的状态
    
    int _fromTime;
    int _toTime;
    
    int _fromTime1;
    int _toTime1;
    
    UIView *btnView;//btn的承载view
    
    NSMutableArray *recordTimer;
    
    NSDate *startDate;//当前起始日期
    NSDate *endDate;//结束日期
    
    float starTime;//当前秒数
    float timerAll;//总秒数
    
    UIView *bottomView;//底部View
    UIButton *btnA;//
    UILabel *startLabel;//起始时间
    UILabel *endLabel;//总时间
    UISlider *slider;//滑块
    UIButton *btnB;//全屏按钮
    
    BOOL isFullScreen;
    UIDeviceOrientation orientation;
    
    UIView *contentView;
    UIDatePicker *datePicker;
    
    int isStartOrendLabel;
    UILabel *toolbarLabel;
    
    int isWitch;//哪种方式进入
    
    UIButton *qiShiBtn;
    UIButton *jieShuBtn;
    UIButton *jieTuBtn;
    UIButton *luXiangBtn;
    float juli;
    
    int isFirstShuScreen;
    
    UIView *jiangeview;
    
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
    _toTime = _fromTime + 86399;
    
}
#pragma mark - 观察者、通知
- (void)addNotifications
{
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

//前台
- (void)appDidEnterPlayground{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRFullScreen"] isEqualToString:@"NVRNoFull"]) {
        if (self.view.frame.origin.y == 0) {
            
            _recordVideo.frame = CGRectMake(0, (HEIGHT1 - WIDTH1) / 2, WIDTH1, WIDTH1);
            bottomView.frame = CGRectMake(0, HEIGHT1 - 50, WIDTH, 50);
            contentView.frame = CGRectMake(0, HEIGHT1 - 158, WIDTH1, 158);
        }else if (self.view.frame.origin.y == 64){
            
            _recordVideo.frame = CGRectMake(0, (HEIGHT1 - WIDTH1) / 2 - 64, WIDTH1, WIDTH1);
            bottomView.frame = CGRectMake(0, HEIGHT1 - 50 - 64, WIDTH, 50);
            contentView.frame = CGRectMake(0, HEIGHT1 - 158 - 64, WIDTH1, 158);
        }
        
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NVRFullScreen"] isEqualToString:@"NVRFull"]){
        
        NSLog(@"hengping");
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        [self jinruFullScreen];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:@"NVRNoFull" forKey:@"NVRFullScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self addNotifications];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;//iOS7及以后的版本支持，self.view.frame.origin.y会下移64像素
    
    jiangeview = [[UIView alloc] init];
    jiangeview.backgroundColor = [UIColor redColor];
    [bottomView addSubview:jiangeview];
    
    isFirstShuScreen = 0;
    _fromTime1 = 0;
    _toTime1 = 0;
    isStartOrendLabel = 0;
    isWitch = 0;
    _isHavePlay = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
    [self.view addGestureRecognizer:tap];
    [self layoutRecordVideo];
    [self btnView];
    [self playAndPauseView];
    
    [self gongNengView];

    orientation = [UIDevice currentDevice].orientation;
}
- (void)layoutRecordVideo
{
    _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:CGRectMake(0, (HEIGHT1 - WIDTH1) / 2 , WIDTH1, WIDTH1)];
    isFirstShuScreen = 1;
    NSLog(@"wwwwwwwwwwwwww%f---%f",self.view.frame.size.height,self.view.frame.size.width);
    _recordVideo.delegate = self;
    
    [_recordVideo setDeviceInfoWithDeviceID:deviceInfo[@"devIDOrIP"] Passwords:deviceInfo[@"password"] UserName:deviceInfo[@"userName"] Channel:[deviceInfo[@"channel"] intValue] Port:[deviceInfo[@"port"] intValue]];
    [self.view addSubview:_recordVideo];
    
    /*
     @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
     */
    
    [_recordVideo initOSDText:@{@"connecting":CustomLocalizedString(@"connecting", nil),@"connectFail":CustomLocalizedString(@"connectFail", nil),@"logining":CustomLocalizedString(@"logining", nil),@"loginFail":CustomLocalizedString(@"loginFail", nil),@"timeOut":CustomLocalizedString(@"timeOut", nil),@"loading":CustomLocalizedString(@"loading", nil),@"searching":CustomLocalizedString(@"searching", nil),@"searchFail":CustomLocalizedString(@"searchFail", nil),@"searchNull":CustomLocalizedString(@"searchNull", nil),@"playFail":CustomLocalizedString(@"playFail", nil)}];
    
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 27, 30, 30);
    //    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.title = [NSString stringWithFormat:@"%@:%@",CustomLocalizedString(@"playback", nil),deviceInfo[@"playTime"]];
    //刷新按钮
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(WIDTH - 30, 27, 30, 30);
    //    vedioButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [refreshButton setImage:[UIImage imageNamed:@"更新-(1)"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
}
- (void)refreshBtn:(UIButton *)sender
{
    [self play];
}
- (void)btnView
{
    isWitch = 1;
    btnView = [[UIView alloc] initWithFrame:CGRectMake((_recordVideo.bounds.size.width - 64 ) / 2, (_recordVideo.bounds.size.height - 64 ) / 2, 64, 64)];
    [_recordVideo addSubview:btnView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 64, 64);
    [btn setImage:[UIImage imageNamed:@"pausew.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:btn];
    
}
- (void)gongNengView{
    juli = ViewH(_recordVideo) / 4;
    qiShiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qiShiBtn.frame = CGRectMake(0, juli - 15, 30, 30);
    [qiShiBtn setTitle:@"起始时间" forState:UIControlStateNormal];
    [qiShiBtn setImage:[UIImage imageNamed:@"NVRqishiTime.png"] forState:UIControlStateNormal];
    qiShiBtn.tag = ChangeTime + 1;
    [qiShiBtn addTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordVideo addSubview:qiShiBtn];
    jieShuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    jieShuBtn.frame = CGRectMake(WIDTH1 - 30, juli - 15, 30, 30);
    [jieShuBtn setImage:[UIImage imageNamed:@"NVRjieshuTime.png"] forState:UIControlStateNormal];
    jieShuBtn.tag = ChangeTime + 2;
    [jieShuBtn addTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordVideo addSubview:jieShuBtn];
    
    jieTuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    jieTuBtn.frame = CGRectMake(0, juli * 3 - 15, 30, 30);
    [jieTuBtn setImage:[UIImage imageNamed:@"NVR截图.png"] forState:UIControlStateNormal];
    jieTuBtn.tag = GongNeng + 1;
    [jieTuBtn addTarget:self action:@selector(gongNengClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordVideo addSubview:jieTuBtn];
    luXiangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    luXiangBtn.frame = CGRectMake(WIDTH1 - 30, juli * 3 - 15, 30, 30);
    [luXiangBtn setImage:[UIImage imageNamed:@"NVR录像.png"] forState:UIControlStateNormal];
    luXiangBtn.tag = GongNeng + 2;
    [luXiangBtn addTarget:self action:@selector(gongNengClick:) forControlEvents:UIControlEventTouchUpInside];
    [_recordVideo addSubview:luXiangBtn];
    qiShiBtn.alpha = 0;
    jieShuBtn.alpha = 0;
    jieTuBtn.alpha = 0;
    luXiangBtn.alpha = 0;
}
- (void)gongNengClick:(UIButton *)sender
{
    if (sender.tag == GongNeng + 1) {
        NSLog(@"截图");
        [_recordVideo captureImage:@"HaierWireless" Completion:^(int result) {
            if (result == 0) {
//                0:成功, 1:无录像画面可截, 2:无相册访问权限, 3:相册名空, 4:保存到相册失败
                [self showAlertWithAlertString:CustomLocalizedString(@"This image has been saved to the photo album", nil)];
            }else{
                [self showAlertWithAlertString:CustomLocalizedString(@"screenshot_failure", nil)];
            }
        }];
        
    }else if (sender.tag == GongNeng + 2){
        NSLog(@"录像");
        static BOOL isRecord = YES;
        if (isRecord) {
            [_recordVideo beginRecord];
            [sender setImage:[UIImage imageNamed:@"NVR结束"] forState:UIControlStateNormal];
            isRecord = NO;
        }else{
            [_recordVideo endRecordAndSave:@"HaierWireless" Completion:^(int result) {
                //0:成功, 1:录像文件未生产(可能录制时间为0), 2:无相册访问权限, 3:相册名空, 4:保存到相册失败
                if (result == 0) {
                    [self showAlertWithAlertString:CustomLocalizedString(@"This image has been saved to the photo album", nil)];
                }else{
                    [self showAlertWithAlertString:CustomLocalizedString(@"Failure of the video", nil)];
                }
            }];
            [sender setImage:[UIImage imageNamed:@"NVR录像"] forState:UIControlStateNormal];
            isRecord = YES;
        }
    }
}
- (void)playAndPauseView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT1 - 50, WIDTH, 50)];
    bottomView.backgroundColor = [UIColor darkGrayColor];
    bottomView.alpha = 0;
    [self.view addSubview:bottomView];
    //
    btnA = [UIButton buttonWithType:UIButtonTypeCustom];
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    [btnA setImage:[UIImage imageNamed:@"NVRpause.png"] forState:UIControlStateNormal];
    [btnA addTarget:self action:@selector(played:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btnA];
    //
    btnB = [UIButton buttonWithType:UIButtonTypeCustom];
    btnB.frame = CGRectMake(WIDTH - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    [btnB setImage:[UIImage imageNamed:@"NVRquanping.png"] forState:UIControlStateNormal];
    [btnB addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btnB];
    isFullScreen = NO;
    //
    startLabel = [[UILabel alloc] init];
    startLabel.frame = CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30);
    startLabel.text = @"00:00:00";
    startLabel.font = [UIFont systemFontOfSize:9];
    startLabel.textColor = [UIColor whiteColor];
    [bottomView addSubview:startLabel];
    //
    endLabel = [[UILabel alloc] init];
    endLabel.frame = CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30);
//    endLabel.text = [self getAllTime];
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
- (void)changeTimeClick:(UIButton *)sender
{
    if (sender.tag == ChangeTime + 1) {
        NSLog(@"起始时间");
        isStartOrendLabel = 1;
        [self datePicker];
        toolbarLabel.text = CustomLocalizedString(@"Sets the initial time", nil);
        
    }else if (sender.tag == ChangeTime + 2){
        NSLog(@"结束时间");
        isStartOrendLabel = 2;
        [self datePicker];
        toolbarLabel.text = CustomLocalizedString(@"Sets the end time", nil);
    }
}
#pragma mark - 显示一个DatePicker
- (void)datePicker
{
    //
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT1 - 158, WIDTH1, 158)];
    if (self.view.frame.origin.y == 0) {
        
        contentView.frame = CGRectMake(0, HEIGHT1 - 158, WIDTH1, 158);
        
    }else if (self.view.frame.origin.y == 64){
        
        contentView.frame = CGRectMake(0, HEIGHT1 - 158 - 64, WIDTH1, 158);
        
    }
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    //
    //创建工具条
    UIToolbar *toolbar=[[UIToolbar alloc]init];
    //设置工具条的颜色
    toolbar.barTintColor=[UIColor grayColor];
    
    //设置工具条的frame
    toolbar.frame=CGRectMake(0, 0, WIDTH, 44);
    //给工具条添加按钮
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 5, 50, 44 - 10);
    [btn1 setTitle:CustomLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [btn1 setTintColor:[UIColor whiteColor]];
    btn1.layer.borderColor = [UIColor whiteColor].CGColor;
    btn1.layer.borderWidth = 1;
    btn1.layer.cornerRadius = 4;
//    btn1.backgroundColor = [UIColor cyanColor];
    [btn1 addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(WIDTH - 60, 5, 50, 44 - 10);
    [btn2 setTitle:CustomLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [btn2 setTintColor:[UIColor whiteColor]];
    btn2.layer.borderColor = [UIColor whiteColor].CGColor;
    btn2.layer.borderWidth = 1;
    btn2.layer.cornerRadius = 4;
    [btn2 addTarget:self action:@selector(clickOK:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btn2];

    toolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH1 - 150)/2, 0, 150, 44)];
    [toolbarLabel setTextColor:[UIColor whiteColor]];
    toolbarLabel.alpha = 0.8;
    toolbarLabel.textAlignment = NSTextAlignmentCenter;
    [toolbar addSubview:toolbarLabel];
    
//    toolbar.items = @[item0,item1];
    //设置文本输入框键盘的辅助视图
    //    self.textfield.inputAccessoryView=toolbar;
    [contentView addSubview:toolbar];
    //
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, WIDTH, 158 - 44)];
    // 设置当前显示
//    [datePicker setDate:[NSDate date] animated:YES];
    [datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
    [datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
//    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+0800"]];//UTC GMT
    // 显示模式
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    // 回调的方法由于UIDatePicker 是UIControl的子类 ,可以在UIControl类的通知结构中挂接一个委托
    //    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview:datePicker];
}
- (void)clickCancel:(UIBarButtonItem *)item{
    [contentView removeFromSuperview];
    contentView = nil;
}
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}
- (void)clickOK:(UIBarButtonItem *)item{
//    [datePicker date];
//    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+0800"]];//UTC GMT
//    [datePicker setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    NSDate *selected = [datePicker date];
    
    NSDate *nowDated = [self getNowDateFromatAnDate:selected];
    
    NSLog(@"date: %@", nowDated);//2016-12-07 05:50:18 +0000
    NSString *selectedDate = deviceInfo[@"playTime"];
    NSString *selectedTime = [[NSString stringWithFormat:@"%@",nowDated] componentsSeparatedByString:@" "][1];
    NSString *selectedDateAndTime = [NSString stringWithFormat:@"%@ %@",selectedDate,selectedTime];
    if (isStartOrendLabel == 1) {
        //起始时间
        NSDate *date1 = [self dateFromString:selectedTime];
        NSDate *date2 = [self dateFromString:endLabel.text];
        if ([date1 compare:date2] >= 0) {
            [self showAlertWithAlertString:CustomLocalizedString(@"Start time should be less than end time", nil)];
        }else{
            isWitch = 2;
            _fromTime1 = [self toGMT:selectedDateAndTime];
            __weak ENPlaybackkViewController *weakSelf = self;
            [_recordVideo stop:^(BOOL success) {
                if (success == YES) {
                    _didConnected = NO;
                    [weakSelf play];
                }
            }];
            startLabel.text = selectedTime;
        }
    }else if (isStartOrendLabel == 2){
        //结束时间
        NSDate *date1 = [self dateFromString:startLabel.text];
        NSDate *date2 = [self dateFromString:selectedTime];
        if ([date2 compare:date1] <= 0) {
            [self showAlertWithAlertString:CustomLocalizedString(@"End time should be greater than start time", nil)];
        }else{
            isWitch = 3;
            _toTime1 = [self toGMT:selectedDateAndTime];
            __weak ENPlaybackkViewController *weakSelf = self;
            [_recordVideo stop:^(BOOL success) {
                if (success == YES) {
                    _didConnected = NO;
                    [weakSelf play];
                }
            }];
            endLabel.text = selectedTime;
        }
    }
    slider.value = 0;
    [contentView removeFromSuperview];
    contentView = nil;
}
- (NSDate *)dateFromString:(NSString *)string{
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
//    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"]];
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *inputDate = [inputFormatter dateFromString:string];
     return inputDate;
}
#pragma mark - EseeNetRecordDelegate
- (void)eseeNetRecordCurTime:(int)curTime
{
    NSString *endText = [[[recordTimer firstObject][@"endTime"] componentsSeparatedByString:@" "] lastObject];
    endLabel.text = endText;
    
//    endLabel.text = [self getAllTime];
    
    NSLog(@"%d,%@",curTime,[self TimeStamp:[NSString stringWithFormat:@"%d",curTime]]);
    //recordTimer的startTime
    NSString *time1 = [[recordTimer lastObject][@"startTime"] componentsSeparatedByString:@" "][1];
    NSArray *arr1 = [time1 componentsSeparatedByString:@":"];
    int aa = [arr1[0] intValue] * 3600 + [arr1[1] intValue] * 60 + [arr1[2] intValue];
    //当前时间
    NSString *string = [[self TimeStamp:[NSString stringWithFormat:@"%d",curTime]] componentsSeparatedByString:@" "][1];
    NSArray *arr2 = [string  componentsSeparatedByString:@":"];
    int bb = [arr2[0] intValue] * 3600 + [arr2[1] intValue] * 60 + [arr2[2] intValue];
    
    startLabel.text = string;
    NSString *firstTime = nil;
    if (bb <= aa) {
        firstTime = string;
    }else{
        firstTime = time1;
    }
    NSArray *endArr = [endText componentsSeparatedByString:@":"];
    NSArray *firstArr = [firstTime componentsSeparatedByString:@":"];
    NSArray *shiShiArr = [startLabel.text componentsSeparatedByString:@":"];
    
    int ATime = [firstArr[0] intValue] * 3600 + [firstArr[1] intValue] * 60 + [firstArr[2] intValue];//起始秒数
    int BTime = [endArr[0] intValue] * 3600 + [endArr[1] intValue] * 60 + [endArr[2] intValue];//结束秒数
    int CTime = [shiShiArr[0] intValue] * 3600 + [shiShiArr[1] intValue] * 60 + [shiShiArr[2] intValue];//当前秒数
    float BBtime = BTime - ATime;//当前的总时长
    timerAll = BBtime;
    float AAtime = CTime - ATime;//当前时长
    float scale = AAtime / BBtime;//占比
    slider.value = scale;
    
    if (recordTimer.count > 1) {
        for (int i = 0; i < recordTimer.count - 1; i ++) {
            NSArray *endTimeArr = [[recordTimer[i][@"startTime"] componentsSeparatedByString:@" "][1] componentsSeparatedByString:@":"];
            NSArray *startTimeArr = [[recordTimer[i + 1][@"endTime"] componentsSeparatedByString:@" "][1] componentsSeparatedByString:@":"];
            int startTime = [startTimeArr[0] intValue] * 3600 + [startTimeArr[1] intValue] * 60 + [startTimeArr[2] intValue];//间隔段起始时间秒数
            int endTime = [endTimeArr[0] intValue] * 3600 + [endTimeArr[1] intValue] * 60 + [endTimeArr[2] intValue];//间隔段结束时间秒数
            if (endTime - startTime != 1 && endTime > startTime) {
                //出现时间间隔了 有没有录的区间
                float jiangeStart = (startTime - ATime) / BBtime;//间隔时间的起始占比
                float jiangeEnd = (endTime - ATime) / BBtime;//间隔时间的结束占比
                
                float viewStart = ViewX(slider) + ViewW(slider) * jiangeStart;
                float viewWidth = ViewW(slider) * (jiangeEnd - jiangeStart);
                
                jiangeview.frame = CGRectMake(viewStart, ViewY(slider) + ViewH(slider) / 2 - 0.25, viewWidth, 0.5);
                
//                jiangeview = [[UIView alloc] initWithFrame:CGRectMake(viewStart, ViewY(slider) + ViewH(slider) / 2 - 0.25, viewWidth, 0.5)];
//                jiangeview.backgroundColor = [UIColor redColor];
//                [bottomView addSubview:jiangeview];
            }
        }
    }
}
- (void)slidered:(UISlider *)sliderNow
{
    NSString *day = deviceInfo[@"playTime"];
    NSArray *array = [[[recordTimer lastObject][@"startTime"] componentsSeparatedByString:@" "][1] componentsSeparatedByString:@":"];
    unsigned int hour = sliderNow.value * timerAll / 3600;
    unsigned int minute = (sliderNow.value * timerAll - hour * 3600) / 60;
    unsigned int second = sliderNow.value * timerAll - hour * 3600 - minute * 60;
    hour = hour + [array[0] intValue];
    minute = minute + [array[1] intValue];
    second = second + [array[2] intValue];
    NSString *timeStr = [NSString stringWithFormat:@"%@ %02d:%02d:%02d",day,hour,minute,second];
    [self changeTime:timeStr];
    
    slider.value = sliderNow.value;
    
}
- (void)changeTime:(NSString *)timeStr
{
    int newTime = [self toGMT:timeStr];

    NSLog(@"--change Time GMT to --> %d -- %@",newTime,timeStr);
    [self playRecordWithIndex:newTime];
}
- (void)playRecordWithIndex:(int)index
{
    if (isWitch == 3) {
        [_recordVideo playWithStartTime:index ToTime:_toTime1];
    }else{
        [_recordVideo playWithStartTime:index ToTime:_toTime];
    }
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
        [[NSUserDefaults standardUserDefaults] setObject:@"NVRFull" forKey:@"NVRFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isFullScreen = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        if (orientation == UIDeviceOrientationPortrait) {
            NSLog(@"当前竖屏模式");
            [self rightHengpinAction];
            
        }else if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            NSLog(@"当前左横屏模式");
            [self shupinAction];
            
        }else if(orientation == UIDeviceOrientationLandscapeRight)
        {
            NSLog(@"当前右横屏模式");
            [self shupinAction];
        }
        isOrientation = NO;
        
        [sender setImage:[UIImage imageNamed:@"NVRnoquanping.png"] forState:UIControlStateNormal];
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        
//        // 获取旋转状态条需要的时间:
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.3];
//        // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
//        // 给你的播放视频的view视图设置旋转
//        self.view.transform = CGAffineTransformIdentity;
//        self.view.transform = [self getTransformRotationAngle];
//        // 开始旋转
//        [UIView commitAnimations];
   
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NVRNoFull" forKey:@"NVRFullScreen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isFullScreen = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [self shupinAction];
        [sender setImage:[UIImage imageNamed:@"NVRquanping.png"] forState:UIControlStateNormal];
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
        isOrientation = YES;
    }
}
/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle
{
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
//竖屏
-(void)shupinAction
{
    self.navigationController.navigationBar.hidden = NO;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    NSLog(@"%f - %f - %f - %f",WIDTH1,HEIGHT1,WIDTH,HEIGHT);
    self.automaticallyAdjustsScrollViewInsets = NO;
    _recordVideo.frame = CGRectMake(0, (WIDTH1 - HEIGHT1) / 2 - 64, HEIGHT1, HEIGHT1);
    isFirstShuScreen = 2;
    bottomView.frame = CGRectMake(0, WIDTH1 - 50 - 64, HEIGHT1, 50);
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    //change
    btnB.frame = CGRectMake(HEIGHT1 - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    startLabel.frame = CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30);
    endLabel.frame = CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30);
    slider.frame = CGRectMake(ViewRightX(startLabel) + Jianju, (ViewH(bottomView) - 30) / 2, ViewX(endLabel) - Jianju * 2 - ViewRightX(startLabel), 30);
    
    juli = ViewH(_recordVideo) / 4;
    qiShiBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli - 15 - 60, 30, 30);
    jieShuBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli - 15 - 60, 30, 30);
    jieTuBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli * 3 - 15 - 60, 30, 30);
    luXiangBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli * 3 - 15 - 60, 30, 30);
    
}
//横屏
-(void)rightHengpinAction
{
    NSLog(@"%f - %f - %f - %f",WIDTH1,HEIGHT1,WIDTH,HEIGHT);
    _recordVideo.frame = CGRectMake(0, 0, HEIGHT1, WIDTH1);
    bottomView.frame = CGRectMake(0, WIDTH1 - 50, HEIGHT1, 50);
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    //change
    btnB.frame = CGRectMake(HEIGHT1 - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    startLabel.frame = CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30);
    endLabel.frame = CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30);
    slider.frame = CGRectMake(ViewRightX(startLabel) + Jianju, (ViewH(bottomView) - 30) / 2, ViewX(endLabel) - Jianju * 2 - ViewRightX(startLabel), 30);
    
    juli = ViewH(_recordVideo) / 3;
    qiShiBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieShuBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieTuBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    luXiangBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    self.navigationController.navigationBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
//横屏
-(void)leftHengpinAction
{
    _recordVideo.frame = CGRectMake(0, 0, HEIGHT1, WIDTH1);
    bottomView.frame = CGRectMake(0, WIDTH1 - 50, HEIGHT1, 50);
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    //change
    btnB.frame = CGRectMake(HEIGHT1 - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    startLabel.frame = CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30);
    endLabel.frame = CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30);
    slider.frame = CGRectMake(ViewRightX(startLabel) + Jianju, (ViewH(bottomView) - 30) / 2, ViewX(endLabel) - Jianju * 2 - ViewRightX(startLabel), 30);
    
    juli = ViewH(_recordVideo) / 3;
    qiShiBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieShuBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieTuBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    luXiangBtn.frame = CGRectMake(HEIGHT1 - 30, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    self.navigationController.navigationBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)jinruFullScreen
{
    //        [self rightHengpinAction];
    NSLog(@"%f - %f - %f - %f",WIDTH1,HEIGHT1,WIDTH,HEIGHT);
    _recordVideo.frame = CGRectMake(0, 0, WIDTH1, HEIGHT1);
    bottomView.frame = CGRectMake(0, HEIGHT1 - 50, WIDTH1, 50);
    btnA.frame = CGRectMake(Jianju, (ViewH(bottomView) - 32) / 2, 32, 32);
    //change
    btnB.frame = CGRectMake(WIDTH1 - Jianju - 32, (ViewH(bottomView) - 32) / 2, 32, 32);
    startLabel.frame = CGRectMake(ViewRightX(btnA) + Jianju, (ViewH(bottomView) - 30) / 2, 43, 30);
    endLabel.frame = CGRectMake(ViewX(btnB) - Jianju - 43, (ViewH(bottomView) - 30) / 2, 43, 30);
    slider.frame = CGRectMake(ViewRightX(startLabel) + Jianju, (ViewH(bottomView) - 30) / 2, ViewX(endLabel) - Jianju * 2 - ViewRightX(startLabel), 30);
    
    juli = ViewH(_recordVideo) / 3;
    qiShiBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieShuBtn.frame = CGRectMake(WIDTH1 - 30, ViewY(_recordVideo) + juli - 15, 30, 30);
    jieTuBtn.frame = CGRectMake(0, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    luXiangBtn.frame = CGRectMake(WIDTH1 - 30, ViewY(_recordVideo) + juli * 2 - 15, 30, 30);
    self.navigationController.navigationBar.hidden = YES;
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
    self.navigationController.navigationBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.backgroundColor = [UIColor grayColor];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.backgroundColor = [UIColor whiteColor];
    
}
- (void)taped:(UITapGestureRecognizer *)tap
{
    static BOOL isTap;
    if (isTap) {
        bottomView.alpha = 0.8;
        if (_isHavePlay == NO) {
            bottomView.userInteractionEnabled = NO;
        }else{
            bottomView.userInteractionEnabled = YES;
            qiShiBtn.alpha = 1.0;
            jieShuBtn.alpha = 1.0;
            jieTuBtn.alpha = 1.0;
            luXiangBtn.alpha = 1.0;
        }
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //iOS7及以后的版本支持，self.view.frame.origin.y会下移64
        
        self.navigationController.navigationBar.hidden = NO;
//        [self.navigationController setNavigationBarHidden:NO animated:NO];
        isTap = NO;
    }else{
        bottomView.alpha = 0;
        qiShiBtn.alpha = 0;
        jieShuBtn.alpha = 0;
        jieTuBtn.alpha = 0;
        luXiangBtn.alpha = 0;
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        self.navigationController.navigationBar.hidden = YES;
//        [self.navigationController setNavigationBarHidden:YES animated:NO];
        isTap = YES;
    }
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        self.navigationController.navigationBar.hidden = YES;
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
}
- (void)play
{
    if (isWitch == 1) {
        int a = _fromTime;
        int b = _toTime;
        [self play:a and:b];
    }else if (isWitch == 2){
        if (_toTime1 == 0) {
            _toTime1 = _toTime;
        }
        int a = _fromTime1;
        int b = _toTime1;
        [self play:a and:b];
    }else if (isWitch == 3){
        if (_fromTime1 == 0) {
            _fromTime1 = _fromTime;
        }
        int a = _fromTime1;
        int b = _toTime1;
        [self play:a and:b];
    }
}
//播放
- (void)play:(int)fromTiem and:(int)toTime{
    _isHavePlay = YES;
    [btnView removeFromSuperview];
    
    if (_didConnected == NO) {
        [_recordVideo connectDevice:^(RecordConnectResult result) {
            switch (result) {
                case RecordConnectSuccess:
                {
                    _didConnected = YES;
                    NSLog(@"--- Connect Success --- ");
                    [_recordVideo searchRecordWithFromTime:fromTiem ToTime:toTime Completion:^(NSArray *recordTimesArr) {
                        
                        if (recordTimesArr.count > 0)
                        {
                            NSLog(@"--- Search Success -->%@",recordTimesArr);
                            //将时间戳转换为时间点
                            
                            [_recordVideo playWithStartTime:fromTiem ToTime:toTime];
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
//提示框封装
- (void)showAlertWithAlertString:(NSString *)alertString
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:CustomLocalizedString(@"prompt", nil) message:alertString delegate:nil cancelButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
    
    [alert show];
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
