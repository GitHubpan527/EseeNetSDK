//
//  OnePhotoViewController.m
//  EseeNetSDK
//
//  Created by lichao pan on 2016/11/20.
//  Copyright © 2016年 Wynton. All rights reserved.
//

#import "OnePhotoViewController.h"
#define WIDTH              self.view.bounds.size.width
#define HEIGHT             self.view.bounds.size.height


@interface OnePhotoViewController ()

@property (nonatomic,strong) UIView *contentView;
//@property (nonatomic,strong) UIScrollView *contentView;
@property (nonatomic,strong) UIPanGestureRecognizer * pangr;

@end

@implementation OnePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //拖动手势
    _pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paned:)];
    [self photo];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self prefersStatusBarHidden];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)photo
{
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    _contentView.bounces = NO;
//    _contentView.showsVerticalScrollIndicator = NO;
//    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.backgroundColor = [UIColor blackColor];
    _contentView.userInteractionEnabled = YES;
    //单击
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taped:)];
    [_contentView addGestureRecognizer:tgr];
    //双击
    UITapGestureRecognizer * tgrTwo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taped:)];
    tgrTwo.numberOfTapsRequired = 2;
    //    tgrTwo.delegate = self;
    [_contentView addGestureRecognizer:tgrTwo];
    [tgr requireGestureRecognizerToFail:tgrTwo];
    
    //图片ImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 64, WIDTH - 4, HEIGHT - 64 * 2)];;
    imageView.userInteractionEnabled = YES;
    //捏合手势
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinched:)];
    [imageView addGestureRecognizer:pgr];
    //创建长按手势
    UILongPressGestureRecognizer * lgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
    //设置长按时间
    lgr.minimumPressDuration = 1;
    //设置多少个手指头
    lgr.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:lgr];
    
    [self.view addSubview:_contentView];
    imageView.image = [UIImage imageWithContentsOfFile:_photoPath];
    [_contentView addSubview:imageView];
    
    //时间Lable
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 2 - 200, 64, 200, 30)];
    dateLabel.textAlignment = NSTextAlignmentRight;
    
    NSArray *dateArray = [_dateStr componentsSeparatedByString:@"."];
    NSArray *dateArr = [dateArray[0] componentsSeparatedByString:@"_"];
    NSString *dateString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@",dateArr[0],@"-",dateArr[1],@"-",dateArr[2],@" ",dateArr[3],@":",dateArr[4],@":",dateArr[5]];
    dateLabel.text = dateString;//2016_11_19_12_23_34.png
    dateLabel.textColor = [UIColor whiteColor];
    [_contentView addSubview:dateLabel];
    
    
}
//提示框封装
- (void)showAlertWithAlertString:(NSString *)alertString
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:alertString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];

    
    [alert show];
}
#pragma mark - 点击手势
-(void)taped:(UITapGestureRecognizer *)tgr
{
    UIImageView *imageView = (UIImageView *)tgr.view.subviews[0];
    
    static BOOL isClick = YES;
    if (tgr.numberOfTapsRequired == 1) {
        //单击
        _contentView = nil;
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        //双击
        NSLog(@"%f",imageView.frame.origin.x);
        if (isClick == YES && imageView.frame.origin.x == 2.000000) {
            //
            CGPoint point = [tgr locationInView:self.view];
            _contentView.subviews[0].frame = CGRectMake(- (point.x), - (point.y), _contentView.frame.size.width + ABS(2 * point.x), _contentView.frame.size.height + ABS(2 * point.y));
            
            //添加拖动手势
            [imageView addGestureRecognizer:_pangr];
            
            isClick = NO;
        }else{
            //变成原来的frame
            _contentView.subviews[0].frame = CGRectMake(2, 64, WIDTH - 4, HEIGHT - 64 * 2);
            [imageView removeGestureRecognizer:_pangr];
            isClick = YES;
        }
    }
}
#pragma mark - 长按手势
- (void)longPressed:(UILongPressGestureRecognizer *)lgr
{
    //    UIImageView *imageV = (UIImageView *)lgr.view;
    //    [imageV removeFromSuperview];
    if (lgr.state == UIGestureRecognizerStateBegan) {
//        [self AlertCTwo:@"分享" and:@"保存到相册" and:@"删除图片"];
        [self AlertCTwo:@"保存到相册" and:@"删除图片"];
    }
}
- (void)AlertCTwo:(NSString *)message2 and:(NSString *)message3
{
    
    //提示框
    UIAlertController * alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    /*
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:message1 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //分享
        NSLog(@"分享");
    }];
     */
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:message2 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //保存到相册
        NSLog(@"保存到相册");
        //将图片保存到相册中
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:_photoPath], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:message3 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //删除图片
        NSLog(@"删除图片");
//        UIImageView *imageView = _contentView.subviews[0];
//        [imageView removeFromSuperview];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:_photoPath error:nil];
        if (![fileManager fileExistsAtPath:_photoPath]) {
            [self showAlertWithAlertString:@"删除成功"];
        }
    }];
    UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"取消");
    }];
    
    [action3 setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    
//    [alertCtr addAction:action1];
    [alertCtr addAction:action2];
    [alertCtr addAction:action3];
    [alertCtr addAction:action4];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error != nil) {
        UIAlertView *fail = [[UIAlertView alloc]initWithTitle:nil message:@"保存失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [fail show];
        NSLog(@"%@",error);
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"保存成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        [self.view addSubview:alert];
    }
}
#pragma mark - 拖动手势
-(void)paned:(UIPanGestureRecognizer *)pgr
{
    //记录原位置
    static CGPoint center;
    if (pgr.state == UIGestureRecognizerStateBegan) {
        center = pgr.view.center;
    }
    //找到原位置与上一次滑动的偏移
    CGPoint point = [pgr translationInView:self.view];
    //计算出现在的位置
    pgr.view.center = CGPointMake(center.x + point.x, center.y + point.y);

}
#pragma mark - 捏合手势
-(void)pinched:(UIPinchGestureRecognizer *)pgr
{
    UIImageView *imageView = (UIImageView *)pgr.view;
    //拖动手势
    //    UIPanGestureRecognizer * pangr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paned:)];
    static CGFloat scale = 1;
    pgr.view.transform = CGAffineTransformMakeScale(scale * pgr.scale, scale * pgr.scale);
    if (pgr.state == UIGestureRecognizerStateEnded) {
        scale *= pgr.scale;
    }
    NSLog(@"%f -- %f -- %f -- %f -- %f",imageView.frame.origin.x,imageView.frame.origin.y,imageView.bounds.size.width,imageView.bounds.size.height,WIDTH);
    
    if (imageView.frame.origin.x < 2) {
        [imageView addGestureRecognizer:_pangr];
    }else{
        [imageView removeGestureRecognizer:_pangr];
    }
    
    
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
