//
//  VedioViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/17.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "VedioViewController.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import "VedioTableViewCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#warning 需要添加库：CoreMedia.framework

//录像保存在沙盒路径Library下的Caches文件下NVRVideo中
#define LibCachesNVRVideoPath [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],@"/Caches/NVRVideo"]

#define WIDTH              self.view.bounds.size.width
#define HEIGHT             self.view.bounds.size.height

@interface VedioViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSFileManager *fileManager;
@property (nonatomic,strong) AVPlayerItem *myPlayerItem1;
@property (nonatomic,strong) AVPlayer *player1;
@property (nonatomic,strong) AVPlayerLayer *playerLayer1;
@property (nonatomic,strong) AVPlayerViewController *videoVC;

@end

@implementation VedioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _fileManager = [NSFileManager defaultManager];
    [self layoutTableView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _dataSource = [[NSMutableArray alloc] initWithArray:[_fileManager contentsOfDirectoryAtPath:LibCachesNVRVideoPath error:nil]];
    [_tableView reloadData];
    if (_dataSource.count == 0) {
        [self showAlertWithAlertString:@"暂无数据"];
    }
}
#pragma mark - 获取本地视频的缩略图
- (UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (void)layoutTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}
- (void)showAlertWithAlertString:(NSString *)alertString
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:alertString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VedioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VedioTableViewCell"];
    if (cell == nil) {
        cell = [[VedioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VedioTableViewCell"];
    }
    NSString *path = [LibCachesNVRVideoPath stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"/",_dataSource[indexPath.row]]];
    NSLog(@"%@",_dataSource);
    cell.myImageView.image = [self getImage:path];
    cell.pauseBtn.tag = indexPath.row;
    [cell.pauseBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)clicked:(UIButton *)sender
{
    NSString *path = [LibCachesNVRVideoPath stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"/",_dataSource[sender.tag]]];//_dataSource[indexPath.row]
    /*
    NSURL *sourceMovieUrl = [NSURL fileURLWithPath:path];
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    _myPlayerItem1 = playerItem;
    _player1 = [AVPlayer playerWithPlayerItem:playerItem];
    _playerLayer1 = [AVPlayerLayer playerLayerWithPlayer:_player1];
    _playerLayer1.frame = CGRectMake(0, 0, 1024, 600);
    _playerLayer1.videoGravity =AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_playerLayer1];
    [_player1 play];
    */
    
    _videoVC = [[AVPlayerViewController alloc]init];
    _videoVC.player = [[AVPlayer alloc]initWithURL:[NSURL fileURLWithPath:path]];
    [_videoVC.player play];
    [self presentViewController:_videoVC animated:YES completion:nil];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = [LibCachesNVRVideoPath stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"/",_dataSource[indexPath.row]]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    [_dataSource removeObjectAtIndex:indexPath.item];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    if (![fileManager fileExistsAtPath:path]) {
        [self showAlertWithAlertString:@"删除成功"];
    }
    
}
//设置单元格的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
#pragma mark - 数据源
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
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
