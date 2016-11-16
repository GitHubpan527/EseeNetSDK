//
//  ENViewController.m
//  HaierSweepRobotApp
//
//  Created by lichao pan on 2016/11/16.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "ENViewController.h"
#import "EseeNetlive.h"
#define LiveCount 4 //视频最大数量
#define WIDTH              self.view.bounds.size.width
#define HEIGHT             self.view.bounds.size.height

@interface ENViewController ()<EseeNetLiveDelegate>
{
    EseeNetLive *liveVideo[LiveCount];
    NSDictionary *deviceInfo;/**< 设备信息*/
    
}
@property (weak, nonatomic) IBOutlet UIView *ENView;

@end
@implementation ENViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self createVideoAndPlayWithIndex:0];
    //_ENView.frame = CGRectMake(50, 100, WIDTH - 100, HEIGHT - 200);
    
    EseeNetLive *live = [[EseeNetLive alloc] initEseeNetLiveVideoWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width)];
    [live setDeviceInfoWithDeviceID:@"762214618" Passwords:@"" UserName:@"admin" Channel:0 Port:0];
    [live connectAndPlay];
    [self.view addSubview:live];
    
    
    
}
- (void)setDeviceInfoWithDeviceIDOrIP:(NSString *)IDOrIP
                             UserName:(NSString *)userName
                            Passwords:(NSString *)passwords
                                 Port:(int)port
{
    deviceInfo = @{
                   @"devID":IDOrIP,//设备ID或IP
                   @"password":passwords,
                   @"userName":userName,
                   @"port":[NSNumber numberWithInt:port]
                   };
}
- (void)createVideoAndPlayWithIndex:(int)index
{
    liveVideo[index] = [[EseeNetLive alloc] initEseeNetLiveVideoWithFrame:self.view.frame];
    //添加设备信息
    [liveVideo[index] setDeviceInfoWithDeviceID:deviceInfo[@"devID"]
                                      Passwords:deviceInfo[@"password"]
                                       UserName:deviceInfo[@"userName"]
                                        Channel:index
                                           Port:[deviceInfo[@"port"] intValue]];
    //设置代理
    liveVideo[index].delegate = self;
    //添加到视频BaseView窗口上
    [self.view addSubview:liveVideo[index]];
    //视频窗口连接并且播放
    [liveVideo[index] connectAndPlay];
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
