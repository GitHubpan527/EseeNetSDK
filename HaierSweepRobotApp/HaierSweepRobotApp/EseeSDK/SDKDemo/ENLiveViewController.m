//
//  IndependentViewController.m
//  EseeNet
//
//  Created by Wynton on 15/8/4.
//  Copyright (c) 2015年 CORSEE Intelligent Technology. All rights reserved.
//

#import "ENLiveViewController.h"
#import "EseeNetLive.h"
#import "UIColor+LC.h"
#import "ENPlaybackkViewController.h"
#import "PhotoViewController.h"
#import "VedioViewController.h"
#import "AFNetworking.h"
#import "Toast+UIView.h"
#import "HDManager.h"

//获取流量信息的类
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>


//截图保存在沙盒路径Library下的Caches文件下NVRPhoto中
#define LibCachesNVRPhotoPath [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],@"/Caches/NVRPhoto"]
//录像保存在沙盒路径Library下的Caches文件下NVRVideo中
#define LibCachesNVRVideoPath [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],@"/Caches/NVRVideo"]

#define WIDTH_SCREEN       [UIScreen mainScreen].bounds.size.width
#define HEIGHT_SCREEN      [UIScreen mainScreen].bounds.size.height
#define WIDTH              self.view.bounds.size.width
#define HEIGHT             self.view.bounds.size.height
#define ViewX(view)        view.frame.origin.x
#define ViewY(view)        view.frame.origin.y
#define ViewW(view)        view.frame.size.width
#define ViewH(view)        view.frame.size.height
#define ViewBtmY(view)     (view.frame.size.height+view.frame.origin.y)
#define ViewRightX(view)   (view.frame.size.width+view.frame.origin.x)
#define BoundsCenter(view) (CGPoint){view.center.x-view.frame.origin.x,view.center.y-view.frame.origin.y}

#define NumBtnNormalColor [UIColor grayColor]
#define NumBtnSelectColor [UIColor redColor]
#define BackgroundColor [UIColor grayColor]
//[UIColor grayColor]
//[UIColor colorWithRed:56/255 green:56/255 blue:56/255 alpha:1.0]
#define LiveCount 8 //视频最大数量
//#define DefaultLiveCount 4 // 初次进入视频个数

#define GlodScale 0.618
#define LiveTag    100
#define NumBtnTag  200
#define CtrlBtnTag 300
#define PTZBtnTag  400
#define BitrateActionSheetTag 500
#define BottomBase 600
#define NetHeight 23
#define ControlBtnTag  700

//CustomLocalizedString(@"playFail", nil)

@interface ENLiveViewController () <UIActionSheetDelegate,EseeNetLiveDelegate>
{
    UIView *navBaseView;/**< 导航栏BaseView*/
    UILabel *netState;//网速标签
    UIView *videoSubBaseView;/**< 视频窗口2级BaseView*/
    UIView *videoBaseView;/**< 视频窗口部分的BaseView*/
    UIView *videoNumHub;/**< 数字按钮BaseView*/
    UIView *ctrlHub;/**< 视频控制按钮BaseView*/
    UIView *bottomBaseView;/**< 云台控制底部view*/
    
    NSDictionary *deviceInfo;/**< 设备信息*/
    NSArray *videoFrameArr;/**< 存放视频的frame数组*/
    
    BOOL videoIsSelect[LiveCount];/**< 视频是否为选中状态*/
    BOOL numbtnSelect[LiveCount];/**< 数字按钮是否为选中状态*/
    int indexALL;//定义选中的哪个
    
    EseeNetLive *liveVideo[LiveCount];/**< 直播视频窗口*/
    
    NSFileManager *_fileManager;//文件管理类
    
    UIDatePicker *datePicker;
    
    UIView *contentView;
    
//    NSInteger LiveCount;
    NSDictionary *deviceChanelDic;
    EseeNetLive *liveVideo1;/**< 直播视频窗口*/
    
    UIImageView *liuliangImageView;//流量
    
    int DefaultLiveCount;
//    int LiveCount;
    
    BOOL isLuXiang;
    
    int lvXiangIndex;//录像中的索引
}


@end

@implementation ENLiveViewController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    //初始化UI
    [self _initViewStyle];
    //初始化视频窗口,并开始播放
    [self _initVideo];
    
}
- (void)initView
{
    //屏蔽侧边右滑返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    isLuXiang = NO;
    DefaultLiveCount = [deviceInfo[@"AllChannel"] intValue];
    //    LiveCount = [deviceInfo[@"AllChannel"] intValue];
    // Do any additional setup after loading the view.
    _fileManager = [NSFileManager defaultManager];
    self.view.backgroundColor = BackgroundColor;//magentaColor grayColor
    self.view.userInteractionEnabled = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taped:)];
    [self.view addGestureRecognizer:tap];
    
    //    //初始化UI
    //    [self _initViewStyle];
    //    //初始化视频窗口,并开始播放
    //    [self _initVideo];
    
    NSLog(@"===================%d=====================",indexALL);
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self initView];
//    //初始化UI
//    [self _initViewStyle];
//    //初始化视频窗口,并开始播放
//    [self _initVideo];
    
    for (int i = 0; i < videoFrameArr.count; i++)
    {
//        if (i  < DefaultLiveCount) {
            [liveVideo[i] videoResume];
//        }
    }
}
- (void)exit
{
    for (int i = 0; i < videoFrameArr.count; i++)
    {
        if (liveVideo[i])
        {
            //先关闭音频
            [liveVideo[i] audioClose];
            //代理设置为nil
            liveVideo[i].delegate = nil;
            //关闭视频,并断开连接
            [liveVideo[i] stop];
            //UI上移除该Video
            [liveVideo[i] removeFromSuperview];
//            for (int i = 0; i < self.view.subviews.count; i ++) {
//                [self.view.subviews[i] removeFromSuperview];
//            }
            //内存释放
            liveVideo[i] = nil;
        }
    }
}
- (void)exit1
{
    for (int i = 0; i < videoFrameArr.count; i++)
    {
        if (liveVideo[i])
        {
            //先关闭音频
//            [liveVideo[i] audioClose];
            //关闭视频,并断开连接
            [liveVideo[i] videoPause];
        }
    }
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (int i = 0; i < LiveCount; i++)
    {
        if (liveVideo[i])
        {
            //先关闭音频
            [liveVideo[i] audioClose];
            //代理设置为nil
            liveVideo[i].delegate = nil;
            //关闭视频,并断开连接
            [liveVideo[i] stop];
            //UI上移除该Video
//            [liveVideo[i] removeFromSuperview];
            //内存释放
            liveVideo[i] = nil;
            
        }
    }

}
 */

- (void)setDeviceInfoWithDeviceIDOrIP:(NSString *)IDOrIP
                             UserName:(NSString *)userName
                            Passwords:(NSString *)passwords
                                 Port:(int)port
                              Channel:(int)channel
{
    deviceInfo = @{
                   @"devID":IDOrIP,//设备ID或IP
                   @"password":passwords,
                   @"userName":userName,
                   @"port":[NSNumber numberWithInt:port],
                   @"AllChannel":[NSNumber numberWithInt:channel]
                   };
    
    /*
    liveVideo1 = [[EseeNetLive alloc]initEseeNetLiveVideoWithFrame:self.view.frame];
    [liveVideo1 setDeviceInfoWithDeviceID:deviceInfo[@"devID"]
                                      Passwords:deviceInfo[@"password"]
                                       UserName:deviceInfo[@"userName"]
                                        Channel:0
                                           Port:[deviceInfo[@"port"] intValue]];
    deviceChanel = liveVideo1.deviceInfo;
    */
}

//初始化视频窗口
- (void)_initVideo
{
    for (int i = 0; i <videoFrameArr.count; i++)
    {
        if (i  < DefaultLiveCount) {
            [self createVideoAndPlayWithIndex:i Select:NO];
        }
    }
}

//开始播放
- (void)createVideoAndPlayWithIndex:(int)index Select:(BOOL)select
{
    //直播视频窗口初始化
    /*
    UIView *view[LiveCount];
    view[index]= [[UIView alloc] initWithFrame:[videoFrameArr[index] CGRectValue]];
//    view[index].backgroundColor = [UIColor whiteColor];
    view[index].layer.cornerRadius = 30;
    view[index].layer.masksToBounds = YES;
    [videoSubBaseView addSubview:view[index]];
     
    liveVideo[index] = [[EseeNetLive alloc] initEseeNetLiveVideoWithFrame:view[index].frame];
    [view[index] addSubview:liveVideo[index]];
    */
    liveVideo[index] = [[EseeNetLive alloc]initEseeNetLiveVideoWithFrame:[videoFrameArr[index] CGRectValue]];
    //圆角效果
    /*
    liveVideo[index].layer.cornerRadius = 10;
    liveVideo[index].layer.masksToBounds = YES;
    liveVideo[index].subviews[0].layer.cornerRadius = 10;
    liveVideo[index].subviews[0].layer.masksToBounds = YES;
    */
    //添加设备信息
    [liveVideo[index] setDeviceInfoWithDeviceID:deviceInfo[@"devID"]
                                      Passwords:deviceInfo[@"password"]
                                       UserName:deviceInfo[@"userName"]
                                        Channel:index
                                           Port:[deviceInfo[@"port"] intValue]];
    
    deviceChanelDic = liveVideo[index].deviceInfo;
    
//    if (DefaultLiveCount == 8) {
//        if (index != 3 && index != 4) {
//            liveVideo[index].layer.cornerRadius = 10;
//            liveVideo[index].layer.masksToBounds = YES;
//        }
//    }
    //设置代理
    liveVideo[index].delegate = self;
    //添加到视频BaseView窗口上
    [videoSubBaseView addSubview:liveVideo[index]];
    liveVideo[index].tag = LiveTag+index;
    //单击手势
    UITapGestureRecognizer *tapone = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(liveTapActionOne:)];
    [liveVideo[index] addGestureRecognizer:tapone];
    //双击手势
    UITapGestureRecognizer *taptwo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(liveTapActionTwo:)];
    taptwo.numberOfTapsRequired = 2;
    [liveVideo[index] addGestureRecognizer:taptwo];
    
    //视频窗口连接并且播放
    [liveVideo[index] connectAndPlay];
    //选中某一个视频窗口
    if (select) {
        //视频播放窗口的状态
        liveVideo[index].videoSelect = YES;
        //对应的数字的状态
        numbtnSelect[index] = YES;
        //UI上对选中的数字按钮的处理
        UIButton *numBtn1 = (UIButton *)[self.view viewWithTag:NumBtnTag+index];
        numBtn1.tintColor = NumBtnSelectColor;
        numBtn1.layer.borderColor = NumBtnSelectColor.CGColor;
    }
    /**
     *  设置提示文字
     *
     *  @param ErrorText'key: @"connecting", @"connectFail", @"logining", @"loginFail", @"timeOut", @"loading", @"searching", @"searchFail", @"searchNull", @"playFail"
     */
    [liveVideo[index] initOSDText:@{@"connecting":CustomLocalizedString(@"connecting", nil),@"connectFail":CustomLocalizedString(@"connectFail", nil),@"logining":CustomLocalizedString(@"logining", nil),@"loginFail":CustomLocalizedString(@"loginFail", nil),@"timeOut":CustomLocalizedString(@"timeOut", nil),@"loading":CustomLocalizedString(@"loading", nil),@"searching":@"搜索中",@"searchFail":CustomLocalizedString(@"searchFail", nil),@"searchNull":CustomLocalizedString(@"searchNull", nil),@"playFail":CustomLocalizedString(@"playFail", nil)}];
}


//Btn的点击事件：添加、移除、暂停、继续、停止、码流
#pragma mark - --- Add ---
- (void)addLive:(NSArray *)changeLiveArr
{
    NSLog(@"Add Live Contain == %@",changeLiveArr);
    for (NSNumber *index in changeLiveArr)
    {
        [self createVideoAndPlayWithIndex:[index intValue] Select:YES];
    }
}

#pragma mark - --- Remove ---
- (void)removeLive:(NSArray *)changeLiveArr
{
    NSLog(@"Remove Live Contain == %@",changeLiveArr);
    for (NSNumber *index in changeLiveArr)
    {
        //移除该视频
        //先停止
        [liveVideo[[index intValue]] stop];
        //UI上移除
        [liveVideo[[index intValue]] removeFromSuperview];
        liveVideo[[index intValue]] = nil;
    }
}

#pragma mark - --- Pause ---
- (void)pauseOrContinueLiveWithToPause:(BOOL)toPause ChangeLiveArr:(NSArray *)changeLiveArr
{
    NSLog(@"Pause Live Contain == %@",changeLiveArr);
    for (NSNumber *index in changeLiveArr)
    {
        //暂停或继续播放画面
        
        if (toPause) {
            [liveVideo[[index intValue]] videoPause];
        }else{
            [liveVideo[[index intValue]] videoResume];
        }
    }
}

#pragma mark - --- Stop  ---
- (void)stopLive:(NSArray *)changeLiveArr
{
    NSLog(@"Stop Live Contain == %@",changeLiveArr);
    for (NSNumber *index in changeLiveArr)
    {
        [liveVideo[[index intValue]] stop];
    }
    
    //    static BOOL isBegin;
    
    //    [liveVideo[0] saveCurrentImageToAlbumWithAlbumName:@"kakaka" Completion:^(BOOL success) {
    //       NSLog(@"----%@",success?@"截图成功":@"截图失败");
    //    }];
    
    //    if (isBegin == YES) {
    //        isBegin = NO;
    //        [liveVideo[0] endRecordAndSaveToAlbum:@"hehehe" Completion:^(BOOL success) {
    //            NSLog(@"----%@",success?@"录像成功":@"录像失败");
    //        }];
    //    }else{
    //        [liveVideo[0] beginRecord];
    //        isBegin = YES;
    //    }
    
}

#pragma mark - --- Bitrate ---

- (void)changeLiveBitrateWithType:(BITREAT)type ChangeLiveArr:(NSArray *)changeLiveArr
{
    [HDManager startLoading];
    NSLog(@"Change Bitrate Live Contain == %@",changeLiveArr);
    for (NSNumber *index in changeLiveArr)
    {
        [liveVideo[[index intValue]] changeBitrate:type];
    }
//    [HDManager stopLoading];
}
//云台控制部分      -----  摇头机
#pragma mark - --- PTZ ---

- (void)PTZControlWithType:(PTZ_CONTROL)type
{
    int index = [[[self getExistenceLiveAndSelectNumBtnContain:YES] firstObject] intValue];
    
    [liveVideo[index] ptzControlWithType:type];
}



#pragma mark - --- EseeNetLive Error Delegate ---
/**
 *  错误信息回调
 *
 *  @param live        发生错误EseeNetLive对象
 *  @param description 错误信息描述
 */
- (void)eseeNetLiveErrorWithLive:(EseeNetLive *)live Description:(NSDictionary *)description
{
    NSLog(@"Live %d Error : %@",(int)live.tag-LiveTag,description);
}
#pragma mark - 清晰度回调
- (void)eseeNetLive:(EseeNetLive *)live BitrateChanged:(BITREAT)bitrate
{
    //[HDManager stopLoading];
    NSLog(@"%@-----%lu",live,(unsigned long)bitrate);
    if (bitrate == 0) {
        [self showAlertWithAlertString:@"当前为高清"];
    }else if (bitrate == 1){
        [self showAlertWithAlertString:@"当前为标清"];
    }
}
#pragma mark - 数字按钮的点击事件
- (void)vedioSelected:(int)index
{
    for (int i = 0; i < DefaultLiveCount; i ++) {
        if (i == index)
        {
            //添加红色边框,表示为选中状态
            liveVideo[i].videoSelect = YES;
        }else{
            liveVideo[i].videoSelect = NO;
        }
    }
}
/*
- (void)numBarBtnAction:(UIButton *)sender
{
    NSInteger index = sender.tag-NumBtnTag;
    //
    if (numbtnSelect[index])
    {
        sender.tintColor = NumBtnNormalColor;
        sender.layer.borderColor = NumBtnNormalColor.CGColor;
    }
    else
    {
        sender.tintColor = NumBtnSelectColor;
        sender.layer.borderColor = NumBtnSelectColor.CGColor;
    }
    
    //改变视频是否为:红色边框选中状态
    numbtnSelect[index] = !numbtnSelect[index];
    
//    if (DefaultLiveCount == 8) {
//        if (index != 3 && index != 4) {
//            sender.layer.cornerRadius = 10;
//            sender.layer.masksToBounds = YES;
//        }
//    }
    
    if (liveVideo[index])
    {
        //添加红色边框,表示为选中状态
        liveVideo[index].videoSelect = numbtnSelect[index];
        
    }
    
}
 */
#pragma mark - 单击手势的点击事件
//UIView上的
- (void)taped:(UITapGestureRecognizer *)sender
{
    [contentView removeFromSuperview];
}
//liveVideo[]上的
- (void)liveTapActionOne:(UITapGestureRecognizer *)sender
{
    int index = (int)sender.view.tag-LiveTag;
    NSLog(@"============================%d========================",indexALL);
    for (int i = 0; i < LiveCount; i++)
    {
        if (i == index)
        {
            numbtnSelect[i] = NO;//此处表示要将其变成选择状态
            indexALL = index;
            [liveVideo[i] audioOpen];//打开选中视频音频
        }
        else
        {
            numbtnSelect[i] = YES;//此处表示要将其变成非选择状态
        }
        
        [self vedioSelected:index];
//        NSInteger numBtnTag = i + NumBtnTag;
//        UIButton *btn = (UIButton *)[self.view viewWithTag:numBtnTag];
//        [self numBarBtnAction:btn];
    }
    NSLog(@"============================%d========================",indexALL);
    
}
#pragma mark - 双击手势点击事件
- (void)liveTapActionTwo:(UITapGestureRecognizer *)sender
{
    int index = (int)sender.view.tag-LiveTag;
    [self oneAndFourView:nil];
}
#pragma mark - 全屏和小屏
- (void)oneAndFourView:(UIButton *)sender
{
    static BOOL isOne = YES;
    if (isOne) {
        //双击变成单窗口
        [sender setTitle:@"小屏" forState:UIControlStateNormal];
        for (int i = 0; i < LiveCount; i ++) {
            [liveVideo[i] removeFromSuperview];
        }
        float margin_top   = 0;
        float margin_btm   = 0;
        float margin_left  = 0;
        float margin_right = 0;
        
        if (self.view.frame.size.height < 504) {//4寸以下
            margin_top = 0;
            margin_btm = 0;
        }
        
        liveVideo[indexALL].frame = CGRectMake(0, 0, videoBaseView.bounds.size.width - margin_left - margin_right, videoBaseView.bounds.size.height - margin_top - margin_btm);
        liveVideo[indexALL].layer.cornerRadius = 0;
        [videoSubBaseView addSubview:liveVideo[indexALL]];
        videoSubBaseView.userInteractionEnabled = YES;
        [self gestureRecognizer];
        isOne = NO;
    }else{
        //双击变成小窗口
        [sender setTitle:@"全屏" forState:UIControlStateNormal];
        [liveVideo[indexALL] removeFromSuperview];
        for (int i = 0; i < videoFrameArr.count; i ++) {
            liveVideo[i].frame = [videoFrameArr[i] CGRectValue];
            [videoSubBaseView addSubview:liveVideo[i]];
            
//            if (DefaultLiveCount == 8) {
//                if (i != 3 && i != 4) {
//                    liveVideo[i].layer.cornerRadius = 10;
//                    liveVideo[i].layer.masksToBounds = YES;
//                }
//            }
        }
        
        isOne = YES;
    }
}
#pragma mark - 左滑右滑手势
- (void)gestureRecognizer
{
    //添加左滑手势
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftAndRightSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    [liveVideo[indexALL] addGestureRecognizer:leftSwipe];
    [videoSubBaseView addGestureRecognizer:leftSwipe];
//    for (int i = 0; i <videoFrameArr.count; i++)
//    {
//        [liveVideo[i] addGestureRecognizer:leftSwipe];
//    }
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftAndRightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//    [liveVideo[indexALL] addGestureRecognizer:rightSwipe];
    [videoSubBaseView addGestureRecognizer:rightSwipe];
//    for (int i = 0; i <videoFrameArr.count; i++)
//    {
//        [liveVideo[i] addGestureRecognizer:rightSwipe];
//    }
    
}
- (void)leftAndRightSwipe:(UISwipeGestureRecognizer *)swipe
{
    int index = (int)swipe.view.tag-LiveTag;
    //NSLog(@"%d",index);
    index = indexALL;
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        //NSLog(@"左滑");
        if (index < DefaultLiveCount - 1) {
            //视频播放窗口的状态
            liveVideo[index].videoSelect = NO;
            //对应的数字的状态
            numbtnSelect[index] = NO;
            //UI上对选中的数字按钮的处理
            UIButton *numBtn1 = (UIButton *)[self.view viewWithTag:NumBtnTag+index];
            numBtn1.tintColor = NumBtnNormalColor;
            numBtn1.layer.borderColor = NumBtnNormalColor.CGColor;
            
            [liveVideo[index] removeFromSuperview];
            float margin_top   = 0;
            float margin_btm   = 0;
            float margin_left  = 0;
            float margin_right = 0;
            
            if (self.view.bounds.size.height < 504) {//4寸以下
                margin_top = 0;
                margin_btm = 0;
            }
            
            liveVideo[index + 1].frame = CGRectMake(0, 0, videoBaseView.bounds.size.width - margin_left - margin_right, videoBaseView.bounds.size.height - margin_top - margin_btm);
            [videoSubBaseView addSubview:liveVideo[index + 1]];
            
            //视频播放窗口的状态
            liveVideo[index + 1].videoSelect = YES;
            //对应的数字的状态
            numbtnSelect[index + 1] = YES;
            
            indexALL = index + 1;
            
            //UI上对选中的数字按钮的处理
            UIButton *numBtn2 = (UIButton *)[self.view viewWithTag:NumBtnTag+index+1];
            numBtn2.tintColor = NumBtnSelectColor;
            numBtn2.layer.borderColor = NumBtnSelectColor.CGColor;
            
        }
    }else{
        //NSLog(@"右滑");
        if (index > 0) {
            //视频播放窗口的状态
            liveVideo[index].videoSelect = NO;
            //对应的数字的状态
            numbtnSelect[index] = NO;
            //UI上对选中的数字按钮的处理
            UIButton *numBtn1 = (UIButton *)[self.view viewWithTag:NumBtnTag+index];
            numBtn1.tintColor = NumBtnNormalColor;
            numBtn1.layer.borderColor = NumBtnNormalColor.CGColor;
            
            [liveVideo[index] removeFromSuperview];
            float margin_top   = 0;
            float margin_btm   = 0;
            float margin_left  = 0;
            float margin_right = 0;
            
            if (self.view.bounds.size.height < 504) {//4寸以下
                margin_top = 0;
                margin_btm = 0;
            }
            
            liveVideo[index - 1].frame = CGRectMake(0, 0, videoBaseView.bounds.size.width - margin_left - margin_right, videoBaseView.bounds.size.height - margin_top - margin_btm);
            [videoSubBaseView addSubview:liveVideo[index - 1]];
            
            //视频播放窗口的状态
            liveVideo[index - 1].videoSelect = YES;
            //对应的数字的状态
            numbtnSelect[index - 1] = YES;
            
            indexALL = index - 1;
            
            //UI上对选中的数字按钮的处理
            UIButton *numBtn2 = (UIButton *)[self.view viewWithTag:NumBtnTag+index-1];
            numBtn2.tintColor = NumBtnSelectColor;
            numBtn2.layer.borderColor = NumBtnSelectColor.CGColor;
            
            
        }
    }
}
#pragma mark - 返回按钮的点击事件
- (void)backClick:(UIButton *)sender
{
    [self exit];
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - 刷新按钮
- (void)refreshBtn:(UIButton *)sender
{
//    for (int i = 0; i <videoFrameArr.count; i++)
//    {
////        if (i  < LiveCount) {
////        [liveVideo[i] videoResume];
//        //添加设备信息
//        [liveVideo[i] setDeviceInfoWithDeviceID:deviceInfo[@"devID"]
//                                          Passwords:deviceInfo[@"password"]
//                                           UserName:deviceInfo[@"userName"]
//                                            Channel:i
//                                               Port:[deviceInfo[@"port"] intValue]];
//        
//        [liveVideo[i] connectAndPlay];
////        }
//    }
    
    static BOOL isOn = YES;
    if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
        [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
    }else if ([self getExistenceLiveAndSelectNumBtnContain:YES].count > 1)
    {
        [self showAlertWithAlertString:@"只能选择一个通道"];
    }else
    {
        if (isOn) {
            //开启音频
            for (NSNumber *index in [self getExistenceLiveAndSelectNumBtnContain:YES]) {
                //开启音效
                [sender setImage:[UIImage imageNamed:@"novedio.png"] forState:UIControlStateNormal];
                [liveVideo[[index intValue]] audioOpen];
//                [self showAlertWithAlertString:@"音效已开启"];
            }
            isOn = NO;
        }else{
            //关闭音效
            for (NSNumber *index in [self getExistenceLiveAndSelectNumBtnContain:YES]) {
                //开启音效
                [sender setImage:[UIImage imageNamed:@"vedio.png"] forState:UIControlStateNormal];
                [liveVideo[[index intValue]] audioClose];
//                [self showAlertWithAlertString:@"音效已关闭"];
            }
            isOn = YES;
        }
    }
}

- (void)dealloc
{
    NSLog(@"----- Controller Dealloc -----");
}

#pragma mark - --- UI ---
//初始化集合
- (void)_initViewStyle
{
    [self _initNav];
    [self _initVideoView];
    [self _net];
//    [self _initVideoNumHub];
    [self _initControlBtn];
//    [self _intiCtrlHub];
//    [self _initPtzView];
//    [self _initPhotoAndVideo];
}

//导航栏
- (void)_initNav
{
    //导航栏相关
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor lc_colorWithR:48 G:155 B:228 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = self.navigatioName;
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 27, 30, 30);
    //    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //按钮
    /*
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(WIDTH_SCREEN - 30, 27, 30, 30);
    //    vedioButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [refreshButton setImage:[UIImage imageNamed:@"vedio.png"] forState:UIControlStateNormal];//vedio.png  更新-(1)
    [refreshButton addTarget:self action:@selector(refreshBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    */
}
//网络状态栏
- (void)_net
{
    netState = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 250, 0, 250 - 8, NetHeight)];
    netState.textColor = [UIColor whiteColor];
    netState.textAlignment = NSTextAlignmentRight;
    netState.font = [UIFont systemFontOfSize:12];//Default is 17
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getInternetface) userInfo:nil repeats:YES];
    [timer fireDate];
    
    [self.view addSubview:netState];
    
    liuliangImageView = [[UIImageView alloc] init];
    liuliangImageView.frame = CGRectMake(WIDTH - 8 - 100 - NetHeight, 0, 20, NetHeight);
    liuliangImageView.alpha = 0;
    liuliangImageView.image = [UIImage imageNamed:@"liuliang.png"];
    [self.view addSubview:liuliangImageView];
    
}
//使用AFN框架来检测网络状态的改变
-(NSString *)AFNReachability
{
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown     = 未知
     AFNetworkReachabilityStatusNotReachable   = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    static NSString *netStr = @"";
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                netStr = @"未知:";
                netState.frame = CGRectMake(WIDTH - 250, 0, 250 - 8, NetHeight);
                liuliangImageView.alpha = 0;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                netStr = @"没有网络:";
                netState.frame = CGRectMake(WIDTH - 250, 0, 250 - 8, NetHeight);
                liuliangImageView.alpha = 0;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                netStr = @"";
                netState.frame = CGRectMake(ViewRightX(liuliangImageView), 0, 100, NetHeight);
                liuliangImageView.alpha = 1.0;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                netStr = @"WIFI:";
                netState.frame = CGRectMake(WIDTH - 250, 0, 250 - 8, NetHeight);
                liuliangImageView.alpha = 0;
                break;
            default:
                break;
        }
    }];
    //3.开始监听
    [manager startMonitoring];
    
    return netStr;
}
- (void)getInternetface {
//    long long hehe = [self getInterfaceBytes];
//    NSLog(@"hehe:%lld",hehe);
    NSArray *DataArr = [self getDataCounters];
    NSString *netSpeed = nil;
//    float speed = [self getInterfaceBytes] / (8 * 1024);
    float speed = (ABS([DataArr[1] floatValue]) + ABS([DataArr[3] floatValue])) / (8 * 1024);
    //B
    netSpeed = [NSString stringWithFormat:@"%.2f%@",speed,@"B/s"];
    NSLog(@"speed:%f",speed);
    if (speed / (1000 * 1000) > 1) {
        //M
        speed = speed / (1024 * 1024);
        netSpeed = [NSString stringWithFormat:@"%.2f%@",speed,@"MB/s"];
    }else if (speed / 1000 > 1){
        //K
        speed = speed / 1024;
        netSpeed = [NSString stringWithFormat:@"%.2f%@",speed,@"KB/s"];
    }
    netState.text = [NSString stringWithFormat:@"%@%@",[self AFNReachability],netSpeed];
}
//初始化视频小窗口
- (void)_initVideoView
{
    float videoBaseViewHeight = WIDTH;//*.9
    if (HEIGHT_SCREEN < 568) {
        videoBaseViewHeight = WIDTH*.64;
    }
    videoBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, videoBaseViewHeight)];//ViewH(netState)
    videoBaseView.backgroundColor = BackgroundColor;//grayColor
    [self.view addSubview:videoBaseView];
    
    float margin_top   = 0;
    float margin_btm   = 0;
    float margin_left  = 0;
    float margin_right = 0;
    
    if (self.view.bounds.size.height < 568) {//4寸以下
        margin_top = 0;
        margin_btm = 0;
    }
    
    videoSubBaseView = [[UIView alloc]initWithFrame:CGRectMake(margin_left, margin_top, videoBaseView.bounds.size.width-margin_left-margin_right, videoBaseView.bounds.size.height-margin_top-margin_btm)];
    [videoBaseView addSubview:videoSubBaseView];
    
    float videoMargin = 0;
    
    if (DefaultLiveCount == 4){
        float videoWidth  = videoSubBaseView.frame.size.width/2-videoMargin/2;
        float videoHeight = videoSubBaseView.frame.size.height/2-videoMargin/2;
        
        CGRect r1 = (CGRect){0,0,videoWidth,videoHeight};
        CGRect r2 = (CGRect){videoWidth+videoMargin,0,videoWidth,videoHeight};
        CGRect r3 = (CGRect){0,videoHeight+videoMargin,videoWidth,videoHeight};
        CGRect r4 = (CGRect){videoWidth+videoMargin,videoHeight+videoMargin,videoWidth,videoHeight};
        videoFrameArr = @[[NSValue valueWithCGRect:r1],[NSValue valueWithCGRect:r2],[NSValue valueWithCGRect:r3],[NSValue valueWithCGRect:r4]];
    
    }else if (DefaultLiveCount == 8){
        float videoWidth1 = (videoSubBaseView.frame.size.width - videoMargin * 2) / 3;
        float videoHeight1 = (videoSubBaseView.frame.size.height - videoMargin * 2) / 3;
        CGRect r11 = (CGRect){0,0,videoWidth1,videoHeight1};
        CGRect r12 = (CGRect){videoWidth1 + videoMargin,0,videoWidth1,videoHeight1};
        CGRect r13 = (CGRect){(videoWidth1 + videoMargin) * 2,0,videoWidth1,videoHeight1};
        CGRect r21 = {0,videoHeight1 + videoMargin,videoSubBaseView.frame.size.width*(1-GlodScale),videoHeight1};
        CGRect r22 = {videoSubBaseView.frame.size.width*(1-GlodScale),videoHeight1 + videoMargin,videoSubBaseView.frame.size.width*GlodScale,videoHeight1};
        CGRect r31 = (CGRect){0,(videoHeight1 + videoMargin) * 2,videoWidth1,videoHeight1};
        CGRect r32 = (CGRect){videoWidth1 + videoMargin,(videoHeight1 + videoMargin) * 2,videoWidth1,videoHeight1};
        CGRect r33 = (CGRect){(videoWidth1 + videoMargin) * 2,(videoHeight1 + videoMargin) * 2,videoWidth1,videoHeight1};
        videoFrameArr = @[[NSValue valueWithCGRect:r11],[NSValue valueWithCGRect:r12],[NSValue valueWithCGRect:r13],[NSValue valueWithCGRect:r21],[NSValue valueWithCGRect:r22],[NSValue valueWithCGRect:r31],[NSValue valueWithCGRect:r32],[NSValue valueWithCGRect:r33]];
    }
    
}
//初始化数字按钮
- (void)_initVideoNumHub
{
    videoNumHub = [[UIView alloc]initWithFrame:CGRectMake(0, ViewBtmY(videoBaseView), WIDTH, 24)];
    videoNumHub.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [self.view addSubview:videoNumHub];
    
    float btnWith = 30;
    float btnBaseViewWidth = ViewW(videoNumHub)/videoFrameArr.count;
    
    for (int i = 0; i < LiveCount; i++) {
        
        UIView *btnBaseView = [[UIView alloc]initWithFrame:CGRectMake(btnBaseViewWidth*i, 0,btnBaseViewWidth , ViewH(videoNumHub))];
        [videoNumHub addSubview:btnBaseView];
        UIButton *btn          = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame              = CGRectMake(0, 0, btnWith, btnWith);
        btn.titleLabel.font    = [UIFont systemFontOfSize:18];
        [btn setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        btn.tintColor          = NumBtnNormalColor;
//        btn.layer.borderColor  = NumBtnNormalColor.CGColor;
//        btn.layer.borderWidth  = 2;
//        btn.layer.cornerRadius = 5;
        btn.center             = BoundsCenter(btnBaseView);
        btn.tag                = NumBtnTag+i;
//        [btn addTarget:self action:@selector(numBarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnBaseView addSubview:btn];
        
        videoIsSelect[i] = NO;
        
        /*
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnWith, btnWith)];
        numLabel.text = [NSString stringWithFormat:@"%d",i+1];
        numLabel.font = [UIFont systemFontOfSize:24];
        numLabel.textColor = NumBtnNormalColor;
        numLabel.center = BoundsCenter(btnBaseView);;
        [btnBaseView addSubview:numLabel];
        */
        
    }
    
    UIView *btmLineView = [[UIView alloc]initWithFrame:CGRectMake(0, ViewH(videoNumHub)-.5,ViewW(videoNumHub), .5)];
    btmLineView.backgroundColor = [UIColor grayColor];
    [videoNumHub addSubview:btmLineView];
}
- (void)chooseOneTongDao
{
    if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
        [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
    }
}
- (void)_initControlBtn
{
    UIView *controlView = [[UIView alloc] init];
    controlView.backgroundColor = [UIColor whiteColor];
    controlView.frame = CGRectMake(0, ViewBtmY(videoBaseView), WIDTH, HEIGHT_SCREEN - ViewBtmY(videoBaseView) - 64);//videoNumHub  videoNumHub
    [self.view addSubview:controlView];
    NSArray *controlBtnArr = @[@"截图",@"录像",@"全屏",@"分辨率",@"查看",@"回放"];
    int btnWidth = 70;
    int btnheight = 55;
    float partWidth = (WIDTH - 3 * btnWidth) / 6;
    float partHeight = (ViewH(controlView) - btnheight * 2) / 4;
    for (int i = 0; i < 2; i ++) {
        for (int j = 0; j < 3; j ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(partWidth * (2 * j + 1) + btnWidth * j, partHeight * (2 * i + 1) + btnheight * i , btnWidth, btnheight);
            [btn setBackgroundColor:[UIColor colorWithRed:213.0/255.0 green:213/255.0 blue:213/255.0 alpha:1.0]];
            [btn setTitle:controlBtnArr[3 * i + j] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            if (3 * i + j < 4) {
                if (3 * i + j == 2) {
                    btn.tag = CtrlBtnTag + 3 * i + j + 1;
                }else if (3 * i + j == 3){
                    btn.tag = CtrlBtnTag + 3 * i + j - 1;
                }else{
                    btn.tag = CtrlBtnTag + 3 * i + j;
                }
                [btn addTarget:self action:@selector(ctrlBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            }else if (3 * i + j >= 4 && 3 * i + j <= 5){
                btn.tag = BottomBase + 3 * i + j - 4;
                [btn addTarget:self action:@selector(BottomBaseAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            btn.layer.cornerRadius = 15.0;
            [controlView addSubview:btn];
        }
    }
}
//截图、录像、分辨率、全屏
- (void)_intiCtrlHub
{
    ctrlHub = [[UIView alloc]initWithFrame:CGRectMake(0, ViewBtmY(videoNumHub), WIDTH, 64)];
    ctrlHub.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [self.view addSubview:ctrlHub];
    //    NSArray *btnTitleArr = @[@"添加",@"移除",@"暂停",@"继续",@"停止",@"码流"];
//    NSArray *btnTitleArr = @[@"截图",@"录像",@"分辨率",@"全屏"];
    NSArray *ImageNameArr = @[@"NVR截图的副本",@"NVR录像的副本 2",@"NVR智能摄像头-分辨率高",@"NVR全屏"];
    float btnWith          = 32;
    float btnHeight        = 32;
    float btnBaseViewWidth = ViewW(ctrlHub)/ImageNameArr.count;
    for (int i = 0; i < ImageNameArr.count; i++) {
        
        UIView * btnBaseView = [[UIView alloc]initWithFrame:CGRectMake(btnBaseViewWidth*i, 0,btnBaseViewWidth , ViewH(ctrlHub))];
        [ctrlHub addSubview:btnBaseView];
        
        UIButton *btn                = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame                    = CGRectMake(0, 0, btnWith, btnHeight);
        [btn setImage:[UIImage imageNamed:ImageNameArr[i]] forState:UIControlStateNormal];
//        btn.titleLabel.font          = [UIFont systemFontOfSize:14];
//        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
//        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
//        btn.tintColor          = NumBtnNormalColor;
//        btn.layer.borderColor  = NumBtnNormalColor.CGColor;
//        btn.layer.borderWidth  = 1;
//        btn.layer.cornerRadius = 4;
        btn.center             = BoundsCenter(btnBaseView);
        btn.tag                = CtrlBtnTag+i;
        [btn addTarget:self action:@selector(ctrlBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnBaseView addSubview:btn];
        videoIsSelect[i] = NO;
        /*
        if (i == 1) {
            [btn addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
        */
    }
    
    UIView *btmLineView = [[UIView alloc]initWithFrame:CGRectMake(0, ViewH(ctrlHub)-.5,ViewW(videoNumHub), .5)];
    btmLineView.backgroundColor = [UIColor grayColor];
    [ctrlHub addSubview:btmLineView];
    
}
/*
//当被监听的属性发生变化时会调用这个方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //keyPath   被监听的属性
    //object    被监听的对象
    //change    发生改变的信息
    //context   上下文
    if ([keyPath isEqualToString:@"title"]) {
        NSLog(@"%@",change);
        for (UIButton *btn in ctrlHub.subviews) {
            if (btn.tag == CtrlBtnTag + 2) {
                if (isLuXiang) {
                    //正在录像
                    btn.userInteractionEnabled = NO;
                    btn.alpha = 0.4;
                }else{
                    //结束录像
                    btn.userInteractionEnabled = YES;
                    btn.alpha = 1.0;
                }
            }
        }
    }
}
 */
//每个button的点击事件
- (void)ctrlBtnAction:(UIButton *)sender
{
    switch (sender.tag - CtrlBtnTag) {
        case 0://截图
        {
            if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
                [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];//CustomLocalizedString(@"Please select a channel",nil)
            }else
            {
                NSLog(@"截图代码");
                //保存到相册中
                //
                //                for (NSNumber *index in [self getExistenceLiveAndSelectNumBtnContain:YES]) {
                //#warning 相册的名字让用户去起
                //                    [liveVideo[[index intValue]] captureImage:@"海尔无线" Completion:^(int result) {
                //                        /*
                //                        if (result == 0) {
                //#warning 这个地方只提示一次
                //                            [self showAlertWithAlertString:@"截图成功"];
                //
                //                        }
                //                        else
                //                        {
                //                            [self showAlertWithAlertString:@"截图失败"];
                //                        }
                //                         */
                //
                //                    }];
                //                }
                //
                //保存到沙盒路径下
                NSString *path = [LibCachesNVRPhotoPath stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"/",[self dateAndTime],@".png"]];
                
                if ([_fileManager fileExistsAtPath:LibCachesNVRPhotoPath]) {
                    NSLog(@"该路径下已存在同名文件夹，创建失败");
                    //已经有了就写进去
                    //创建成功，写进去
                    BOOL result = [UIImagePNGRepresentation(liveVideo[indexALL].currentImage)writeToFile: path atomically:YES]; // 保存成功会返回YES
                    if (result == YES) {
//                        [self.view makeToast:CustomLocalizedString(@"screenshot_success", nil)];
                        [self showAlertWithAlertString:CustomLocalizedString(@"screenshot_success", nil)];
                    }else{
//                        [self.view makeToast:CustomLocalizedString(@"screenshot_failure", nil)];
                        [self showAlertWithAlertString:CustomLocalizedString(@"screenshot_failure", nil)];
                    }
                }else{
                    
                    BOOL isCreate = [_fileManager createDirectoryAtPath:LibCachesNVRPhotoPath withIntermediateDirectories:YES attributes:nil error:nil];//Direction是目录，也是文件夹的意思,intermediate中间文件夹
                    NSLog(@"文件夹创建%@",isCreate?@"成功":@"失败");
                    if (isCreate) {
                        //创建Image文件
                        BOOL isCreateFile = [_fileManager createFileAtPath:path contents:nil attributes:nil];
                        if (isCreateFile) {
                            //创建成功，写进去
                            BOOL result = [UIImagePNGRepresentation(liveVideo[indexALL].currentImage)writeToFile: path atomically:YES]; // 保存成功会返回YES
                            if (result == YES) {
                                [self showAlertWithAlertString:CustomLocalizedString(@"Save success", nil)];
                            }else{
                                [self showAlertWithAlertString:CustomLocalizedString(@"Save failed", nil)];
                            }
                        }else{
                            NSLog(@"文件路径创建失败");
                        }
                    }else{
                        NSLog(@"创建失败");
                    }
                }
            }
        }
            break;
            
        case 1://录像
        {
//            static int lvXiangIndex;//录像通道
            
            if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
                [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
            }else
            {
                NSString *path = [LibCachesNVRVideoPath stringByAppendingString:[NSString stringWithFormat:@"%@%@%@",@"/",[self dateAndTime],@".mp4"]];
                static BOOL isStarting = YES;//用于区分按钮的状态
                if (isStarting) {
                    //录像
//                    [self showAlertWithAlertString:@"正在录像"];
                    isLuXiang = YES;
                    lvXiangIndex = indexALL;
                    [sender setTitle:@"结束录像" forState:UIControlStateNormal];
                    sender.titleLabel.font = [UIFont systemFontOfSize:15.0];
                    NSLog(@"开始录像");
                    
                    //开始录像
                    //保存到沙盒路径下
                    //                        [liveVideo[indexALL] beginRecord];
                    if ([_fileManager fileExistsAtPath:LibCachesNVRVideoPath]) {
                        NSLog(@"该路径下已存在同名文件夹");
                        
                        [liveVideo[lvXiangIndex] beginRecordWithFilePath:path];
                    }else{
                        BOOL isCreate = [_fileManager createDirectoryAtPath:LibCachesNVRVideoPath withIntermediateDirectories:YES attributes:nil error:nil];//Direction是目录，也是文件夹的意思,intermediate中间文件夹
                        if (isCreate) {
                            //创建成功
                            NSLog(@"文件夹创建成功");
                            
                            BOOL isCreateFile = [_fileManager createFileAtPath:path contents:nil attributes:nil];
                            if (isCreateFile) {
                                //文件创建成功
                                [liveVideo[lvXiangIndex] beginRecordWithFilePath:path];
                            }else{
                                NSLog(@"文件创建失败");
                            }
                        }else{
                            NSLog(@"文件夹创建失败");
                        }
                    }
                    isStarting = NO;
                }
                else
                {
                    isLuXiang = NO;
                    //结束录像
                    [sender setTitle:@"录像" forState:UIControlStateNormal];
                    //结束录像
                    //保存到相册
                    /*
                     [liveVideo[[index intValue]] endRecordAndSave:@"海尔" Completion:^(int result) {
                     NSLog(@"%d",result);
                     if (result == 0) {
                     [self showAlertWithAlertString:@"录像成功"];
                     }
                     else
                     {
                     [self showAlertWithAlertString:@"录像失败"];
                     }
                     
                     }];
                     */
                    //保存到沙盒路径中
                    int a = [liveVideo[lvXiangIndex] endRecord];
                    if (a == 0) {
                        [self showAlertWithAlertString:CustomLocalizedString(@"Recording success", nil)];
                    }else{
                        [self showAlertWithAlertString:CustomLocalizedString(@"Recording failed", nil)];
                    }
                    isStarting = YES;
                }
            }
            
        }
            break;
            
        case 2://分辨率
        {
            if (isLuXiang) {
                [self showAlertWithAlertString:@"正在录像，不能切换分辨率"];
            }else{
                //                sender.enabled = NO;
                if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
                    [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
                }else{
                    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:CustomLocalizedString(@"Choice of clarity", nil) delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"HD", nil),CustomLocalizedString(@"SD", nil), nil];
                    sheet.tag = BitrateActionSheetTag;
                    [sheet showInView:self.view];
                }
            }
        }
            break;
            
        case 3://全屏
        {
            if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
                [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
            }else{
                [self oneAndFourView:sender];
            }
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - 显示一个DatePicker
- (void)datePicker
{
    //
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, ViewBtmY(videoBaseView), WIDTH, HEIGHT - ViewBtmY(videoBaseView))];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    //
    //创建工具条
    UIToolbar *toolbar=[[UIToolbar alloc]init];
    //设置工具条的颜色
    toolbar.barTintColor=[UIColor grayColor];
    
    //设置工具条的frame
    toolbar.frame=CGRectMake(0, 0, WIDTH, 44);
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(10, 5, 60, 44 - 10);
    [btn1 setTitle:CustomLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn1 setTintColor:[UIColor whiteColor]];
    btn1.layer.borderColor = [UIColor whiteColor].CGColor;
    btn1.layer.borderWidth = 1;
    btn1.layer.cornerRadius = 4;
    [btn1 addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(WIDTH - 70, 5, 60, 44 - 10);
    [btn2 setTitle:CustomLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn2 setTintColor:[UIColor whiteColor]];
    btn2.layer.borderColor = [UIColor whiteColor].CGColor;
    btn2.layer.borderWidth = 1;
    btn2.layer.cornerRadius = 4;
    [btn2 addTarget:self action:@selector(clickOK:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btn2];
    
    //给工具条添加按钮
//    UIBarButtonItem *item0=[[UIBarButtonItem alloc]initWithTitle:CustomLocalizedString(@"cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickCancel:)];
//    [item0 setTintColor:[UIColor whiteColor]];
//    item0.style = UIBarButtonSystemItemFixedSpace;
//    
//    UIBarButtonItem *item1=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickOK:)];
//    [item1 setTintColor:[UIColor whiteColor]];
//    item1.style = UIBarButtonSystemItemFlexibleSpace;
//    
//    toolbar.items = @[item0,item1];
//    
    //设置文本输入框键盘的辅助视图
//    self.textfield.inputAccessoryView=toolbar;
    [contentView addSubview:toolbar];
    
    //
    NSDate *currentTime  = [NSDate date];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, WIDTH, HEIGHT - ViewBtmY(videoBaseView) - 44)];
    [datePicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+0800"]];//UTC GMT
    // 设置当前显示
    [datePicker setDate:currentTime animated:YES];
    // 显示模式
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    // 回调的方法由于UIDatePicker 是UIControl的子类 ,可以在UIControl类的通知结构中挂接一个委托
//    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview:datePicker];

}
//-(void)datePickerValueChanged:(id)sender
//{
//    NSDate *selected = [datePicker date];
//    NSLog(@"date: %@", selected);
//}
- (void)clickCancel:(UIBarButtonItem *)item
{
    NSLog(@"item");
    [contentView removeFromSuperview];
    contentView = nil;
    
}
//将任意时间转化为当前时间
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
- (void)clickOK:(UIBarButtonItem *)item
{
    NSDate *selected = [datePicker date];
    NSDate *nowDated = [self getNowDateFromatAnDate:selected];
    NSLog(@"date: %@", selected);//date: 2016-11-19 16:33:17 +0000
    NSArray *arrDate = [[NSString stringWithFormat:@"%@",nowDated] componentsSeparatedByString:@" "];
    [contentView removeFromSuperview];
    ENPlaybackkViewController *playback = [[ENPlaybackkViewController alloc] init];
    if ([self getExistenceLiveAndSelectNumBtnContain:YES].count == 0) {
        [self showAlertWithAlertString:CustomLocalizedString(@"Please select a channel", nil)];
    }else{
        int index = [[[self getExistenceLiveAndSelectNumBtnContain:YES] firstObject] intValue];
        //channel 通道号
        [playback setPlayBackInfoWithDevIDOrIP:deviceInfo[@"devID"] UserName:deviceInfo[@"userName"] Passwords:deviceInfo[@"password"] Channel:index Port:0 PlayTime:arrDate[0]];
        
        //    [self presentViewController:playback animated:YES completion:nil];
        [self exit1];
        [self.navigationController pushViewController:playback animated:YES];
        
    }
}



#pragma mark - 获取当前的日期时间
- (NSString *)dateAndTime
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
//    currentDate = [self getNowDateFromatAnDate:currentDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    
    return dateString;
}
#pragma mark - 提示框的代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == BitrateActionSheetTag) {
        if (buttonIndex > 1) {
            return;
        }
        NSArray *bitrateArr = @[[NSNumber numberWithInteger:HD],[NSNumber numberWithInteger:SD]];
        NSArray *LiveArr = [self getExistenceLiveAndSelectNumBtnContain:YES];
        [self changeLiveBitrateWithType:[bitrateArr[buttonIndex] integerValue] ChangeLiveArr:LiveArr];
    }
}

//更换成查看、回放
- (void)_initPhotoAndVideo
{
    bottomBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, ViewBtmY(ctrlHub), WIDTH_SCREEN, HEIGHT_SCREEN-ViewBtmY(ctrlHub)-64)];
    bottomBaseView.backgroundColor = [UIColor colorWithRed:0.9254901960784314 green:0.9411764705882353 blue:0.9450980392156862 alpha:1];
    [self.view addSubview:bottomBaseView];
    //截图、回放
    NSArray *btnTitleArr = @[@"查看",@"回放"];
    NSArray *btnImageArr = @[@"chakan",@"huifang"];
    float btnBaseViewWidth = ViewW(bottomBaseView) / btnImageArr.count;
    
    for (int i = 0; i < btnImageArr.count; i ++) {
        
        UIView *btnBaseView = [[UIView alloc] initWithFrame:CGRectMake(btnBaseViewWidth * i, 0, btnBaseViewWidth, ViewH(bottomBaseView))];
        [bottomBaseView addSubview:btnBaseView];
        
        float btnWith = btnBaseView.frame.size.width / 2;
        float btnHeight = btnBaseView.frame.size.height - 25 * 2;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, btnWith, btnHeight);
        [btn setImage:[UIImage imageNamed:btnImageArr[i]] forState:UIControlStateNormal];
        
//        [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 20.0)];
        //设置button上字体的偏移量
//        [btn setTitleEdgeInsets:UIEdgeInsetsMake(10.0,-40.0 , 0.0, -8.0)];
        
        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:NumBtnNormalColor forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.tintAdjustmentMode = NSTextAlignmentRight;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.tintColor = NumBtnNormalColor;
        btn.layer.borderColor = NumBtnNormalColor.CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = 4;
        
        btn.center = BoundsCenter(btnBaseView);
        btn.tag = BottomBase + i;
        [btn addTarget:self action:@selector(BottomBaseAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnBaseView addSubview:btn];
        videoIsSelect[i] = NO;
    }
    
}
- (void)BottomBaseAction:(UIButton *)sender
{
    switch (sender.tag - BottomBase) {
        case 0://查看
            NSLog(@"查看");
            [self AlertCTwo:CustomLocalizedString(@"screenshots", nil) and:CustomLocalizedString(@"video", nil)];
            break;
        case 1://回放
            NSLog(@"回放");
            [self datePicker];
            break;
    }
}
- (void)AlertCTwo:(NSString *)message1 and:(NSString *)message2
{
    //提示框
    UIAlertController * alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:message1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        PhotoViewController *photo = [[PhotoViewController alloc] init];
        [self exit1];
        [self.navigationController pushViewController:photo animated:YES];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:message2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //[self datePicker];
        VedioViewController *vedio = [[VedioViewController alloc] init];
        [self exit1];
        [self.navigationController pushViewController:vedio animated:YES];
        
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:CustomLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(CustomLocalizedString(@"cancel", nil));
    }];
    [alertCtr addAction:action1];
    [alertCtr addAction:action2];
    [alertCtr addAction:action3];
    [self presentViewController:alertCtr animated:YES completion:nil];
}


//云台控制底部
- (void)_initPtzView
{
    bottomBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, ViewBtmY(ctrlHub), WIDTH, HEIGHT-ViewBtmY(ctrlHub))];
    bottomBaseView.backgroundColor = [UIColor colorWithRed:0.9254901960784314 green:0.9411764705882353 blue:0.9450980392156862 alpha:1];
    [self.view addSubview:bottomBaseView];
    
    UIView *ptzView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 100)];
    ptzView.alpha   = 1;
    ptzView.center  = BoundsCenter(bottomBaseView);
    [bottomBaseView addSubview:ptzView];
    
    
    UIImageView *ptzPane = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    ptzPane.userInteractionEnabled = YES;
    ptzPane.backgroundColor        = [UIColor whiteColor];
    ptzPane.layer.cornerRadius     = ptzPane.frame.size.width/2;
    ptzPane.layer.borderWidth      = .5f;
    ptzPane.layer.borderColor      = [UIColor grayColor].CGColor;
    ptzPane.alpha                  = 0.8f;
    
    //方向控制按钮
    float l = 15;
    float fix = 8;
    UIButton *upBtn    = [[UIButton alloc] initWithFrame:CGRectMake(0, fix, l, l)];
    UIButton *downBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0, ViewH(ptzPane)-l-fix, l, l)];
    UIButton *leftBtn  = [[UIButton alloc] initWithFrame:CGRectMake(fix, 0, l, l)];
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(ViewW(ptzPane)-l-fix, 0, l, l)];
    UIButton *stopBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, l+15, l+15)];
    
    upBtn.center    = CGPointMake(BoundsCenter(ptzPane).x, upBtn.center.y);
    downBtn.center  = CGPointMake(BoundsCenter(ptzPane).x, downBtn.center.y);
    leftBtn.center  = CGPointMake(leftBtn.center.x, BoundsCenter(ptzPane).y);
    rightBtn.center = CGPointMake(rightBtn.center.x, BoundsCenter(ptzPane).y);
    stopBtn.center  = BoundsCenter(ptzPane);
    
    [upBtn    addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchDown];
    [downBtn  addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchDown];
    [leftBtn  addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchDown];
    [rightBtn addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchDown];
    [stopBtn  addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [upBtn    addTarget:self action:@selector(stopCamera:) forControlEvents:UIControlEventTouchUpInside];
    [downBtn  addTarget:self action:@selector(stopCamera:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn  addTarget:self action:@selector(stopCamera:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addTarget:self action:@selector(stopCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    upBtn.tag    = PTZBtnTag+PTZ_UP;
    downBtn.tag  = PTZBtnTag+PTZ_DOWN;
    leftBtn.tag  = PTZBtnTag+PTZ_LEFT;
    rightBtn.tag = PTZBtnTag+PTZ_RIGHT;
    stopBtn.tag  = PTZBtnTag+PTZ_STOP;
    
    [ptzView addSubview:ptzPane];
    
    [ptzPane addSubview:upBtn];
    [ptzPane addSubview:downBtn];
    [ptzPane addSubview:leftBtn];
    [ptzPane addSubview:rightBtn];
    [ptzPane addSubview:stopBtn];
    
    [upBtn    setImage:[UIImage imageNamed:@"ptz_up"] forState:UIControlStateNormal];
    [downBtn  setImage:[UIImage imageNamed:@"ptz_down"] forState:UIControlStateNormal];
    [leftBtn  setImage:[UIImage imageNamed:@"ptz_left"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"ptz_right"] forState:UIControlStateNormal];
    [stopBtn  setImage:[UIImage imageNamed:@"ptz_auto_1"] forState:UIControlStateNormal];
    
    //
    CGFloat kMarginY = 15;
    CGFloat kMarginX = 90;
    
    NSArray *tagArr = @[
                        [NSNumber numberWithInteger:PTZ_ZOOM_OUT],
                        [NSNumber numberWithInteger:PTZ_ZOOM_IN],
                        [NSNumber numberWithInteger:PTZ_IRIS_CLOSE],
                        [NSNumber numberWithInteger:PTZ_IRIS_OPEN],
                        [NSNumber numberWithInteger:PTZ_FOCUS_NEAR],
                        [NSNumber numberWithInteger:PTZ_FOCUS_FAR]
                        ];
    
    for (int i = 0; i < 6; i++) {
        int row = i/2; //行
        int col = i%2; //列
        CGFloat x = ViewX(ptzPane)+ViewW(ptzPane)+15 + col*(kMarginX+25) ;
        CGFloat y = row*(kMarginY + 20);
        
        CGFloat labelCenterX = ViewX(ptzPane)+ViewW(ptzPane)+10+25;
        CGFloat labelCenterY = y;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelCenterX+20, labelCenterY+5, 75, 20)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [ptzView addSubview:label];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:18.0];
        if (row == 0) {
            label.text = @"变倍";//zoom
        }
        if (row == 1) {
            label.text = @"光圈";//Iris
        }
        if (row == 2) {
            label.text = @"焦距";//Focus
        }
        
        UIButton *ptzBtns = [UIButton buttonWithType:UIButtonTypeSystem];
        ptzBtns.frame = CGRectMake(x, y, 40, 30);
        [ptzBtns addTarget:self action:@selector(PTZBtnAction:) forControlEvents:UIControlEventTouchDown];
        [ptzBtns addTarget:self action:@selector(stopCamera:) forControlEvents:UIControlEventTouchUpInside];
        ptzBtns.tintColor = [UIColor grayColor];
        ptzBtns.layer.borderColor = [UIColor grayColor].CGColor;
        ptzBtns.layer.borderWidth = 1;
        ptzBtns.layer.cornerRadius = 8.0f;
        ptzBtns.titleLabel.font = [UIFont systemFontOfSize:20];
        ptzBtns.tag = [tagArr[i] integerValue]+PTZBtnTag;
        if (col == 0) {
            [ptzBtns setTitle:@"-" forState:UIControlStateNormal];
        }else{
            [ptzBtns setTitle:@"+" forState:UIControlStateNormal];
        }
        [ptzView addSubview:ptzBtns];
    }
    
}
//数字按钮所在的数组
- (NSMutableArray *)selectNumBtnArray
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i = 0; i < LiveCount; i++) {
        
        if (numbtnSelect[i])//数字按钮
        {
            [arr addObject:[NSNumber numberWithInt:i]];
        }
    }
    return arr;
}
//直播视频窗口所在的数组
- (NSMutableArray *)liveBeingArray;
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < LiveCount; i++) {
        if (liveVideo[i]) {//直播视频窗口
            [arr addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return arr;
}

- (BOOL)isSelectOnlyOneAndThisOneIsExistence
{
    int selectCount = 0;
    for (int i= 0; i < LiveCount; i++) {
        if (numbtnSelect[i] && liveVideo[i])//数字按钮&直播视频窗口
        {
            selectCount++;
        }
    }
    
    if (selectCount == 1)
    {
        return YES;
    }
    
    return NO;
}

//提示框封装
- (void)showAlertWithAlertString:(NSString *)alertString
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:alertString delegate:nil cancelButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
    [alert show];
}

//selectNumBtnArray和liveBeingArray 这两个数组分别是数字按钮和直播视频窗口的，该方法就是通过这两个数组中所包含的元素来返回具体的数据源的
- (NSMutableArray *)getExistenceLiveAndSelectNumBtnContain:(BOOL)contain
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    NSArray *numBtnArr   = [self selectNumBtnArray];
    NSArray *haveLiveArr = [self liveBeingArray];
    
    for (NSNumber *num in numBtnArr) {
        if ([haveLiveArr containsObject:num] == contain) {
            [arr addObject:num];
        }
    }
    return arr;
}
//云台控制
- (void)PTZBtnAction:(UIButton *)sender
{
    if (![self isSelectOnlyOneAndThisOneIsExistence])
    {
        [self showAlertWithAlertString:@"请选择单个存在视频进行操作"];
        return;
    }
    
    [self PTZControlWithType:sender.tag-PTZBtnTag];
}

- (void)stopCamera:(UIButton *)sender
{
    [self PTZControlWithType:PTZ_STOP];
}
#pragma mark - 竖屏幕

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 获取网络流量信息
- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name=[[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil];
}

- (long long) getInterfaceBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    NSLog(@"\n[getInterfaceBytes-Total]%d,%d",iBytes,oBytes);
    return iBytes + oBytes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IS_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

//- (void)aaa
//{
//    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size )|| CGSizeEqualToSize([[UIScreen mainScreen] currentMode].size,)


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
