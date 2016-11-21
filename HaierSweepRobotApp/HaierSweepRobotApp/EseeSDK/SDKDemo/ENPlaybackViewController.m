//
//  PlaybackSDKDemoViewController.m
//  EseeNet
//
//  Created by Wynton on 15/9/12.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//

#import "ENPlaybackViewController.h"
#import "EseeNetRecord.h"

#define SecondDistance (_timeLineView.frame.size.width/86400)

@interface ENPlaybackViewController ()<EseeNetRecordDelegate>
{
    NSTimeInterval searchTime;
    NSString *_devceID;//设备ID
    NSString *_userName;
    NSString *_password;
    int _channel;
    
    int _fromTime;
    int _toTime;
    NSInteger _curTime;
    
    EseeNetRecord *_recordVideo;
    
    BOOL _didConnected;
    
    BOOL _isPlay;
//    BOOL _isMovingTimeLive;
    
    NSString *_playDay;
    
}


@property (weak, nonatomic) IBOutlet UIView *vdieoBaseView;

@property (nonatomic, assign) NSTimeInterval *recordDate;

@property (weak, nonatomic) IBOutlet UITextField *changeH;


@property (weak, nonatomic) IBOutlet UITextField *changeMin;

@property (weak, nonatomic) IBOutlet UITextField *changeS;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;


@end

@implementation ENPlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [_recordVideo.subviews[0] addSubview:_playBtn];
    _playBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _playBtn.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    
}

-(void)viewDidAppear:(BOOL)animated
{ 
    [super viewDidAppear:animated];
    
    _recordVideo = [[EseeNetRecord alloc]initEseeNetRecordVideoWithFrame:_vdieoBaseView.bounds];
    _recordVideo.delegate = self;
    
    int port = 0;
    
    [_recordVideo setDeviceInfoWithDeviceID:_devceID Passwords:_password UserName:_userName Channel:_channel Port:port];
    
    [_vdieoBaseView addSubview:_recordVideo];
    
    [_recordVideo addSubview:_playBtn];
    /*
     @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
     */
    [_recordVideo initOSDText:@{@"connecting":@"连接中",@"connectFail":@"连接失败",@"logining":@"登录中",@"loginFail":@"登录失败",@"timeOut":@"超时",@"loading":@"登录中",@"searching":@"搜索中",@"searchFail":@"搜索失败",@"searchNull":@"没有视频",@"playFail":@"播放失败"}];
    
}

-(void)eseeNetRecordCurTime:(int)curTime
{
    NSLog(@"--- current time --> %d",curTime);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPlayBackInfoWithDevIDOrIP:(NSString *)devIDOrIP
                            UserName:(NSString *)userName
                           Passwords:(NSString *)passwords
                             Channel:(int)channel
                                Port:(int)port
                            PlayTime:(NSString *)playTime
{
    _devceID = devIDOrIP;
    _userName = userName;
    _password = passwords;
    _channel = port;
    _playDay = playTime;
    
    _fromTime = [self toGMT:[NSString stringWithFormat:@"%@ 00:00:00",playTime]];
    _toTime = _fromTime + 86400;
    searchTime = _fromTime;
    
}

#pragma mark - --- Play And Pause ---
//播放
- (IBAction)playBtn:(UIButton *)sender {
    sender.hidden = YES;
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

- (IBAction)playBtnAction:(UIButton *)sender {
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
- (IBAction)pauseRecord:(id)sender {
    
    _recordVideo.pause = YES;
    
}
//继续
- (IBAction)continue:(id)sender {
    _recordVideo.pause = NO;
}
//导航返回
- (IBAction)backBtnAction:(UIBarButtonItem *)sender {
    [_recordVideo stop:^(BOOL success) {
        
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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



- (void)playRecordWithIndex:(int)index
{
    [_recordVideo playWithStartTime:index ToTime:_toTime];
}
//停止
- (IBAction)stopRecord:(UIButton *)sender {
    [_recordVideo stop:^(BOOL success) {
        _didConnected = NO;
    }];
}
//changeTime
- (IBAction)changeTimeBtnAction:(UIButton *)sender {
    NSString *timeStr = [NSString stringWithFormat:@"%@ %02d:%02d:%02d",_playDay,[_changeH.text intValue],[_changeMin.text intValue],[_changeS.text intValue]];
    int newTime = [self toGMT:timeStr];
    
    NSLog(@"--change Time GMT to --> %d -- %@",newTime,timeStr);
    [self playRecordWithIndex:newTime];
    
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
