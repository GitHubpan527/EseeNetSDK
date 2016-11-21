//
//  ENPlaybackkViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/20.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "ENPlaybackkViewController.h"
#import "EseeNetRecord.h"

#define SecondDistance (_timeLineView.frame.size.width/86400)

@interface ENPlaybackkViewController ()<EseeNetRecordDelegate>
{
    NSDictionary *deviceInfo;/**< 设备信息*/
    
    EseeNetRecord *_recordVideo;
    
    BOOL _didConnected;
    
    BOOL _isPlay;
    
    int _fromTime;
    int _toTime;
    
    UIView *btnView;//btn的承载view
    
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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
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
    
    _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.width) / 2, self.view.frame.size.width, self.view.frame.size.width)];
    
    _recordVideo.delegate = self;
    
    [_recordVideo setDeviceInfoWithDeviceID:deviceInfo[@"devIDOrIP"] Passwords:deviceInfo[@"password"] UserName:deviceInfo[@"userName"] Channel:[deviceInfo[@"channel"] intValue] Port:[deviceInfo[@"port"] intValue]];
    [self.view addSubview:_recordVideo];
    
    /*
     @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
     */
    [_recordVideo initOSDText:@{@"connecting":@"连接中",@"connectFail":@"连接失败",@"logining":@"登录中",@"loginFail":@"登录失败",@"timeOut":@"超时",@"loading":@"登录中",@"searching":@"搜索中",@"searchFail":@"搜索失败",@"searchNull":@"没有视频",@"playFail":@"播放失败"}];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnAction:)];
    self.navigationItem.leftBarButtonItem = left;
    
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
}
- (void)taped:(UITapGestureRecognizer *)tap
{
    static BOOL isTap;
    if (isTap) {
        [self play];
        self.navigationController.navigationBar.hidden = NO;
        isTap = NO;
    }else{
        
        self.navigationController.navigationBar.hidden = YES;
        isTap = YES;
    }
    
}
//播放
- (void)play{
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
                            [_recordVideo playWithStartTime:_fromTime ToTime:_toTime];
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
-(void)eseeNetRecordCurTime:(int)curTime
{
    NSLog(@"--- current time --> %d",curTime);
}
/*
- (void)viewWillLayoutSubviews
{
    [self _shouldRotateToOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
}
*/
/*
-(void)_shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    if (orientation == UIDeviceOrientationPortrait ||orientation ==
        UIDeviceOrientationPortraitUpsideDown) { // 竖屏
        _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.width) / 2, self.view.frame.size.width, self.view.frame.size.width)];
        
    } else { // 横屏
        _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
}
*/


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
