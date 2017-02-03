//
//  LocalDeviceListController.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "LocalDeviceListController.h"
#import "AppDelegate.h"
#import "LocalDeviceCell.h"
#import "SVPullToRefresh.h"
#import "LocalDevice.h"
#import "AddContactNextController.h"
#import "CreateInitPasswordController.h"
#import "Utils.h"
#import "UDPManager.h"
#import "AddDevicesPopTipsView.h"
#import "YProgressView.h"

@interface LocalDeviceListController ()

@end

@implementation LocalDeviceListController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocalDevices) name:@"refreshNewDevices" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshNewDevices" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define LOCAL_DEVICE_ITEM_HEIGHT 45
-(void)initComponent{
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //导航栏
    self.navigationItem.title = CustomLocalizedString(@"local_device_list", nil);
    //导航栏相关
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor lc_colorWithR:48 G:155 B:228 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 7, 30, 30);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [backButton setImage:[UIImage imageNamed:@"返回按钮"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT - 64, width, height-NAVIGATION_BAR_HEIGHT-80) style:UITableViewStylePlain];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    //NSLog(@"%lf",[[[UIDevice currentDevice] systemVersion] floatValue]);
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
//    [tableView addPullToRefreshWithActionHandler:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNewDevices" object:nil];
//    }];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //底部文字提示 如果没有要添加的设备
    UIButton *noWantedDeviesbtn=[[UIButton alloc] init];
    noWantedDeviesbtn.frame = CGRectMake((width-200)/2.0, CGRectGetMaxY(self.tableView.frame)+60/2.0,200, 40);
    
    [noWantedDeviesbtn addTarget:self
                          action:@selector(noWantedDeviesPress)
                forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString* maStr=[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"no_device_i_want_to_add",nil)];
    NSRange maStrRange=NSMakeRange(0, maStr.length);
    [maStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:maStrRange];
    
    [maStr addAttribute:NSForegroundColorAttributeName
                  value:NavigationBarColor
                  range:maStrRange];
    [maStr addAttribute:NSUnderlineStyleAttributeName
                  value:@1.0
                  range:maStrRange];
    noWantedDeviesbtn.backgroundColor=[UIColor clearColor];
    [noWantedDeviesbtn setAttributedTitle:maStr forState:UIControlStateNormal];
    [self.view addSubview:noWantedDeviesbtn];
    
    [self  setUpRefreshBtn];
    
}

#pragma mark - 返回事件
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark  没有要添加的设备 提示
-(void)noWantedDeviesPress{
    
    self.addDevicesPopView = [[AddDevicesPopTipsView alloc] init];
    self.addDevicesPopView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.addDevicesPopView.delegate = self;
    //文字
    NSArray *arr = @[CustomLocalizedString(@"text_key1", nil),
                     CustomLocalizedString(@"text_key2", nil),
                     CustomLocalizedString(@"text_key3", nil),
                     ];
    NSMutableArray *strArr = [NSMutableArray arrayWithArray:arr];
    
    NSArray *btnArr = @[CustomLocalizedString(@"i_know",nil)];
    NSMutableArray *btnArray = [NSMutableArray arrayWithArray:btnArr];
    
    [self.addDevicesPopView setUpUIWithTitle:CustomLocalizedString(@"device_is_not_listed",nil) numberOfLabel:(int)strArr.count lbTextArr:strArr numberOfBtn:(int)btnArr.count btnTextArr:btnArray eitherHaveImgView:NO];
    
    [self.addDevicesPopView.closeBtn addTarget:self action:@selector(closePopView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addDevicesPopView];
    
    self.addDevicesPopView.blackBgView.hidden=NO;
    self.addDevicesPopView.blackBgView.alpha=0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.addDevicesPopView.blackBgView.alpha=1.0;
    } completion:^(BOOL finished) {
            
    }];
    
}

-(void)closePopView{
    
    self.addDevicesPopView.blackBgView.alpha=1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.addDevicesPopView.blackBgView.alpha=0.0;
    } completion:^(BOOL finished) {
        self.addDevicesPopView.blackBgView.hidden=YES;
    }];
    [self.addDevicesPopView removeFromSuperview];
    
}

#pragma mark - AddDevicesPopTipsViewDelegate
-(void)buttonBePressed:(UIButton*)btn{

    [self closePopView];
}

-(void)setUpRefreshBtn{
    
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    
    //加一个手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(refreshingLocalDevices)];
    
    YProgressView *progressView = [[YProgressView alloc] initWithFrame:CGRectMake((width-143/2.0)/2.0, 200, 143/2.0, 141/2.0)];
    progressView.backgroundView.image = [UIImage imageNamed:@"local_list_refresh.png"];
    self.yProgressViewRefresh = progressView;
    self.yProgressViewRefresh.userInteractionEnabled = YES;
    
    [self.yProgressViewRefresh addGestureRecognizer:tap];
    [self.tableView addSubview:self.yProgressViewRefresh];
    
    if(self.isNewDevicesArray.count==0){
        //没有新设备时  空白处刷新按钮 提示
        [self.yProgressViewRefresh setHidden:NO];
        
    }else{
        
        [self.yProgressViewRefresh setHidden:YES];
        
    }
}

-(void)refreshingLocalDevices{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSArray* lanDevicesArray = [[UDPManager sharedDefault]getLanDevices];
        self.isNewDevicesArray = [Utils getNewDevicesFromLan:lanDevicesArray];
        if(self.isNewDevicesArray.count==0){
            
        //没有新设备时  空白处刷新按钮 提示
            [self.yProgressViewRefresh setHidden:NO];
            [self.yProgressViewRefresh startAnimation];
            
        }else{
            
            [self.yProgressViewRefresh setHidden:YES];
            [self.yProgressViewRefresh stop];
            
        }
        
        [self.tableView reloadData];
    });
}

-(void)refreshLocalDevices{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.pullToRefreshView stopAnimating];
        
        NSArray *lanDevicesArray = [[UDPManager sharedDefault]getLanDevices];
        self.isNewDevicesArray = [Utils getNewDevicesFromLan:lanDevicesArray];
        if(self.isNewDevicesArray.count==0){
            //没有新设备时  空白处刷新按钮 提示
            [self.yProgressViewRefresh setHidden:NO];
            
        }else{
            
            [self.yProgressViewRefresh setHidden:YES];
            
        }
        [self.tableView reloadData];
    });
}

//section的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        
        return 23.0/2.0;
        
    }
    return 0.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.isNewDevicesArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LOCAL_DEVICE_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"LocalDeviceCell";
    LocalDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[LocalDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    UIImage *backImg = [UIImage imageNamed:@"bg_normal_cell.png"];
    UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
    UIImageView *backImageView = [[UIImageView alloc] init];
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    
    LocalDevice *localDevice = [self.isNewDevicesArray objectAtIndex:indexPath.row];
    cell.rightImage = @"LocalDevice_cell_add.png";
    cell.idContentText = [NSString stringWithFormat:@"%@",localDevice.contactId];//显示设备ID
    cell.ipContentText = [NSString stringWithFormat:@"%@",localDevice.address];//显示设备IP
    switch (localDevice.contactType) {
        case CONTACT_TYPE_IPC:
        {
            cell.leftImage = @"ic_contact_type_ipc.png";
        }
            break;
        case CONTACT_TYPE_NPC:
        {
            cell.leftImage = @"ic_contact_type_npc.png";
        }
            break;
        case CONTACT_TYPE_DOORBELL:
        {
            cell.leftImage = @"ic_contact_type_doorbell.png";
        }
            break;
        case CONTACT_TYPE_NVR:
        {
            cell.leftImage = @"ic_contact_type_nvr.png";
        }
            break;
        default:
        {
            cell.leftImage = @"ic_contact_type_unknown.png";
        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LocalDevice *localDevice = [self.isNewDevicesArray objectAtIndex:indexPath.row];
    NSInteger contactFlag = localDevice.flag;
    if(contactFlag==1){
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.isPopRoot = NO;//isPopRoot
        addContactNextController.isInFromLocalDeviceList = YES;
        [addContactNextController setContactId:localDevice.contactId];
        [self.navigationController pushViewController:addContactNextController animated:YES];
        
    }else if(contactFlag==0){
        CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
        createInitPasswordController.isPopRoot = NO;//isPopRoot
        [createInitPasswordController setContactId:localDevice.contactId];
        [createInitPasswordController setAddress:localDevice.address];
        [self.navigationController pushViewController:createInitPasswordController animated:YES];
    }
}

#pragma mark - 屏幕旋转
-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
