//
//  PhotoViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/17.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoCollectionViewCell.h"
#import "OnePhotoViewController.h"
#import "ENLiveViewController.h"

#define LibCachesNVRPhotoPath [NSString stringWithFormat:@"%@%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject],@"/Caches/NVRPhoto"]

#define WIDTH              self.view.bounds.size.width
#define HEIGHT             self.view.bounds.size.height


@interface PhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
//UIGestureRecognizerDelegate

@property (nonatomic,strong)NSMutableArray * dataSource;
@property (nonatomic,strong)UICollectionView * collectionView;
@property (nonatomic,strong)NSFileManager *fileManager;
/* contentView */
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,assign) NSInteger stateBool;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self naV];
    _fileManager = [NSFileManager defaultManager];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _stateBool = 0;
    [self createCollectionView];
}
- (void)naV
{
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 27, 30, 30);
    //    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}
- (void)navTitle
{
    NSArray *arrOne = [_dataSource[0] componentsSeparatedByString:@"_"];
    NSArray *arrLast = [[_dataSource lastObject] componentsSeparatedByString:@"_"];
    NSString *str = nil;
    if ([arrOne[0] isEqualToString:arrLast[0]]) {
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",arrOne[0],@".",arrOne[1],@".",arrOne[2],@"-",arrLast[1],@".",arrLast[2]];
    }else{
        str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@",arrOne[0],@".",arrOne[1],@".",arrOne[2],@"-",arrLast[0],@".",arrLast[1],@".",arrLast[2]];
    }
    if ([arrOne[0] isEqualToString:arrLast[0]] && [arrOne[1] isEqualToString:arrLast[1]] && [arrOne[2] isEqualToString:arrLast[2]]) {
        str = [NSString stringWithFormat:@"%@%@%@%@%@",arrOne[0],@".",arrOne[1],@".",arrOne[2]];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@%@%@",CustomLocalizedString(@"screenshots", nil),@":",str];
}
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _dataSource = [[NSMutableArray alloc] initWithArray:[_fileManager contentsOfDirectoryAtPath:LibCachesNVRPhotoPath error:nil]];
    [self.collectionView reloadData];
    if (_dataSource.count == 0) {
        [self showAlertWithAlertString:CustomLocalizedString(@"No Data", nil)];
    }else
    {
        [self prefersStatusBarHidden];
        //    NSLog(@"%@",_dataSource[0]);
        //    NSLog(@"%@",[_dataSource lastObject]);
        [self navTitle];
    }
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_dataSource removeAllObjects];
    _dataSource = nil;
}
- (void)createCollectionView
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    //每个Item的大小
    flowLayout.itemSize = CGSizeMake(100, 120);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    //注册给collectionView注册cell
    [self.collectionView registerClass:NSClassFromString(@"PhotoCollectionViewCell") forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
}
#pragma mark - CollectionDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    cell.myImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@%@",LibCachesNVRPhotoPath,@"/",self.dataSource[indexPath.item]]];
//    cell.myImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@%@",LibCachesNVRPhotoPath,@"/",self.dataSource[indexPath.item]]];
    return cell;
}
//单击cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"我是第%lu张图片",indexPath.item);
    _stateBool = 1;
    OnePhotoViewController *photo = [[OnePhotoViewController alloc] init];
    photo.photoPath = [NSString stringWithFormat:@"%@%@%@",LibCachesNVRPhotoPath,@"/",self.dataSource[indexPath.item]];
    photo.dateStr = self.dataSource[indexPath.item];
    [self.navigationController pushViewController:photo animated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
//提示框封装
- (void)showAlertWithAlertString:(NSString *)alertString
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:CustomLocalizedString(@"prompt", nil) message:alertString delegate:nil cancelButtonTitle:nil otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
    [alert show];
}

#pragma mark - 懒加载
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
