//
//  MyFacilityViewController.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
// [[NSUserDefaults standardUserDefaults] setObject:_yunIDTextField.text forKey:@"NVRDeviceID"];


#import "MyFacilityViewController.h"

//久安SDKSample
#import "ENLiveViewController.h"

#import "LingYunManager.h"

#import "SideBarCell.h"
#import "IndexImgModel.h"
#import "AdView.h"
#import "MyFacilityModel.h"
#import "MyFacilityCell.h"
#import "FacilityContactCell.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

#pragma mark - 商城
#import "ShopMallViewController.h"

#pragma mark - 设置
#import "SetupViewController.h"

#pragma mark - 消息
#import "MessageListViewController.h"

#pragma mark - 基本信息
#import "BaseInfoViewController.h"

#pragma mark - 摄像头列表
#import "ContactController.h"

#pragma mark - 消息类型
#import "MessageTypeViewController.h"

#pragma mark - 重命名
#import "RenameViewController.h"

#import "AddFacilityViewController.h"

//ljp main
#import "ContactController.h"
#import "MessageController.h"
#import "SDWebImageRootViewController.h"
#import "MoreController.h"
#import "P2PVideoController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "P2PMonitorController.h"
#import "Toast+UIView.h"
#import "P2PCallController.h"
#import "AutoNavigation.h"
#import "GlobalThread.h"
#import "AccountResult.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "LoginController.h"
#import "FListManager.h"
#import "ContactController_ap.h"
#import "Utils.h"
#import "JPUSHService.h"
//ljp contact
#import "NetManager.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "BottomBar.h"
#import "SVPullToRefresh.h"
#import "ContactCell.h"
#import "AddContactNextController.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "FListManager.h"
#import "GlobalThread.h"
#import "MainSettingController.h"
#import "P2PPlaybackController.h"
#import "ChatController.h"
#import "LocalDeviceListController.h"
#import "CreateInitPasswordController.h"
#import "PopoverTableViewController.h"
#import "LocalDevice.h"
#import "Toast+UIView.h"
#import "DXPopover.h"
#import "CustomCell.h"
#import "PopoverView.h"
#import "QRCodeController.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "ApModeViewController.h"
#import "UDPManager.h"
#import "Utils.h"
#import "ModifyDevicePasswordController.h"//设备列表界面调整
#import "SDWebImageRootViewController.h"
#import "MessageController.h"

//PLC
#import "DeviceTypeModel.h"
#import "AddFacilityModel.h"
#import "EseeNetLive.h"

@interface MyFacilityViewController ()<UITableViewDelegate,UITableViewDataSource,PushRenameDelegate,ContactRenameDelegate,UIAlertViewDelegate>

//阴影背景
@property (strong, nonatomic) IBOutlet UIImageView *toumingImageView;
//侧边栏
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UIView *sideBarView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *sideTB;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,strong)NSMutableArray *scrollArray;

@property (nonatomic,strong)NSMutableArray *bindArray;
@property (nonatomic,strong)NSMutableArray *yooSeeArray;
@property (nonatomic,strong) NSMutableArray * sameArray;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@end

@implementation MyFacilityViewController

{
    AdView *headAdView;
    UIButton *closeBtn;
    
    BOOL _isCancelUpdateDeviceOk;
    
    MyFacilityModel *selectModel;
    Contact *selectContact;
    Contact *monitorContact;
    
    
    /**< 侧边栏 */
    NSArray *leftPlArray;
    
    NSString *messageCount;
    
    NSString *NVRID;//NVR的ID
    NSArray *array;//首页的cell
}

- (NSMutableArray *)scrollArray
{
    if (!_scrollArray) {
        _scrollArray = [NSMutableArray array];
    }
    return _scrollArray;
}

- (NSMutableArray *)bindArray
{
    if (!_bindArray) {
        _bindArray = [NSMutableArray array];
    }
    return _bindArray;
}

- (NSMutableArray *)yooSeeArray
{
    if (!_yooSeeArray) {
        _yooSeeArray = [NSMutableArray array];
    }
    return _yooSeeArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self stopAnimating];
    
//    [self.facilityTB.mj_header beginRefreshing];
    
//    [self requestDataWithRefresh:YES];
    
    
    [self requestMessageCount];
    
    
    NSString *headUrl = [JPUserDefaults jp_objectForKey:@"HeadUrlKey"];
    NSString *realName = [JPUserDefaults jp_objectForKey:@"RealNameKey"];
    [self.iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:headUrl] forState:UIControlStateNormal placeholderImage:LCImage(@"默认头像")];
    self.nameLabel.text = realName;
    
    if (HLLanguageIsEN) {
        leftPlArray = @[CustomLocalizedString(@"mall", nil),CustomLocalizedString(@"setup0", nil)];
    } else {
        leftPlArray = @[CustomLocalizedString(@"mall", nil),CustomLocalizedString(@"setup0", nil)];
    }
    
    [self requestScrollData];
    
    [self refreshRobotList];
    
    [self.sideTB reloadData];
    
    
}

- (void)requestMessageCount
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"recId":userModel.id,
                              @"status":@"1"};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:FindMessageCount parameters:infoDic successBlock:^(id successObject) {
        messageCount = [successObject[@"object"][@"count"] stringValue];
        [self.sideTB reloadData];
    } FailBlock:^(id failObject) {
        
    }];
}

- (void)refreshNVR {
    [self refreshRobotList];
    
    [self.sideTB reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNVR) name:@"refreshNVR" object:nil];
    
    //获取NVR ID
    [self getID];
    
#pragma mark - 初始化灵云语音
    [LingYunManager shareManager];
#pragma mark - 导航
//    self.navigationItem.title = NSLocalizedString(@"myDevice", nil);
    self.navigationItem.title = CustomLocalizedString(@"myDevice", nil);
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem lc_itemWithIcon:@"菜单" block:^{
        self.toumingImageView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.backImageView.frame = CGRectMake(0, 0, ScreenWidth-100, ScreenHeight);
            [self.navigationController.view insertSubview:self.toumingImageView atIndex:998];
            [self.navigationController.view insertSubview:self.backImageView atIndex:999];
//            [self.view insertSubview:self.backImageView atIndex:999];
//            [self.view bringSubviewToFront:self.backImageView];
//            self.backImageView = (UIImageView *)[[UIApplication sharedApplication].windows lastObject];
            
        }];
    }];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem lc_itemWithIcon:@"添加-(1)" block:^{
        
        AddFacilityViewController *vc = [[AddFacilityViewController alloc] init];
        vc.isHomePage = NO;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        //DeviceTypeViewController *vc = [[DeviceTypeViewController alloc] init];
        //[self.navigationController pushViewController:vc animated:YES];
    }];
#pragma mark - 背景
    self.toumingImageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    self.toumingImageView.hidden = YES;
    [self.navigationController.view addSubview:self.toumingImageView];
#pragma mark - 侧边栏
    
    
    self.backImageView.frame = CGRectMake(-(ScreenWidth-100), 0, ScreenWidth-100, ScreenHeight);
    
    [self.navigationController.view addSubview:self.backImageView];
    
    self.sideBarView.frame = CGRectMake(0, 0, self.backImageView.frame.size.width, self.backImageView.frame.size.height);
    [self.backImageView addSubview:self.sideBarView];
#pragma mark - 滑动手势
    //[self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)]];
#pragma mark - 数据相关
    //[self requestScrollData];
    //[self refreshRobotList];
    
    //ljp main
    BOOL result = NO;
    if ([[AppDelegate sharedDefault] dwApContactID] == 0) {
        LoginResult *loginResult = [UDManager getLoginInfo];
        result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
    }
    else
    {
        //ap模式匿名登陆
        result = [[P2PClient sharedClient] p2pConnectWithId:@"0517401" codeStr1:@"0" codeStr2:@"0"];
    }
    [[P2PClient sharedClient] setDelegate:self];
    
    //ljp contact
    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {//isGettingOnLineState
        contact.isGettingOnLineState = YES;
    }
    
    [self initComponent];

    // Do any additional setup after loading the view from its nib.
}

//ljp
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //ljp main
    //只有从监控界面退出（dismiss）时，才进入viewDidAppear
    self.isShowingMonitorController = NO;
    
    //ljp contact
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetWorkChange:) name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContact) name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocalDevices) name:@"refreshLocalDevices" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];//获取设备报警推送帐号个数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        [self.netStatusBar setHidden:YES];
    }
    
    
    if(!self.isInitPull){
        [[GlobalThread sharedThread:NO] startYoosee];
        self.isInitPull = !self.isInitPull;
    }
    [[GlobalThread sharedThread:NO] setIsPause:NO];
    [self refreshLocalDevices];
    //[self refreshContact];
}

//ljp contact
- (void)onNetWorkChange:(NSNotification *)notification{
    
    NSDictionary *parameter = [notification userInfo];
    int status = [[parameter valueForKey:@"status"] intValue];
    if(status==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
            
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        
        [self.netStatusBar setHidden:YES];
    }
    [self refreshLocalDevices];
}

//ljp contact
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshLocalDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];//获取设备报警推送帐号个数
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[GlobalThread sharedThread:NO] setIsPause:YES];
    
    if (self.isShowProgressAlert == YES) {
    }
}

//ljp contact
#define CONTACT_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 250:220)
#define NET_WARNING_ICON_WIDTH_HEIGHT 24
#define LOCAL_DEVICES_VIEW_HEIGHT 52
#define LOCAL_DEVICES_ARROW_WIDTH 24
#define LOCAL_DEVICES_ARROW_HEIGHT 16
#define EMPTY_BUTTON_WIDTH 148
#define EMPTY_BUTTON_HEIGHT 42
#define EMPTY_LABEL_WIDTH 260
#define EMPTY_LABEL_HEIGHT 50
-(void)initComponent{
    
    /*
     //view的背景色
     [self.view setBackgroundColor:UIColorFromRGB(0xe2e1e1)];
     
     
     //view的frame
     CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
     CGFloat width = rect.size.width;
     CGFloat height = rect.size.height-TAB_BAR_HEIGHT;
     
     
     //导航栏
     TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
     [topBar setTitle:CustomLocalizedString(@"contact",nil)];
     [topBar setRightButtonHidden:NO];
     [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_add_contact.png"]];
     [topBar.rightButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:topBar];
     self.topBar = topBar;
     [topBar release];
     
     
     //表格
     UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
     [tableView setBackgroundColor:UIColorFromRGB(0xe2e1e1)];
     tableView.allowsSelection = NO;//禁止cell的点击事件
     tableView.showsVerticalScrollIndicator = NO;//隐藏表格的滚动条
     tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//无分割线
     UIView *footView = [[UIView alloc] init];
     [footView setBackgroundColor:[UIColor clearColor]];
     [tableView setTableFooterView:footView];
     [footView release];
     tableView.delegate = self;
     tableView.dataSource = self;
     if(CURRENT_VERSION>=7.0){
     self.automaticallyAdjustsScrollViewInsets = NO;
     
     }
    
     //表格下拉刷新
     [tableView addPullToRefreshWithActionHandler:^{
     
     NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
     for(int i=0;i<[self.contacts count];i++){
     
     Contact *contact = [self.contacts objectAtIndex:i];
     [contactIds addObject:contact.contactId];
     
     //进入首页时，获取设备列表里的设备的可更新状态
     //设备检查更新
     [[P2PClient sharedClient] checkDeviceUpdateWithId:contact.contactId password:contact.contactPassword];
     }
     [[P2PClient sharedClient] getContactsStates:contactIds];
     [[FListManager sharedFList] getDefenceStates];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalDevices" object:nil];
     }];
     
     [self.view addSubview:tableView];
     self.tableView = tableView;
     [tableView release];
     
     
     UIView *netStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, 49)];
     netStatusBar.backgroundColor = [UIColor yellowColor];
     UIImageView *barLeftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (netStatusBar.frame.size.height-NET_WARNING_ICON_WIDTH_HEIGHT)/2, NET_WARNING_ICON_WIDTH_HEIGHT, NET_WARNING_ICON_WIDTH_HEIGHT)];
     barLeftIconView.image = [UIImage imageNamed:@"ic_net_warning.png"];
     [netStatusBar addSubview:barLeftIconView];
     
     UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width+10, 0, netStatusBar.frame.size.width-(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width)-10, netStatusBar.frame.size.height)];
     barLabel.textAlignment = NSTextAlignmentLeft;
     barLabel.textColor = [UIColor redColor];
     barLabel.backgroundColor = XBGAlpha;
     barLabel.font = XFontBold_16;
     barLabel.lineBreakMode = NSLineBreakByWordWrapping;
     barLabel.numberOfLines = 0;
     barLabel.text = CustomLocalizedString(@"net_warning_prompt", nil);
     [netStatusBar addSubview:barLabel];
     
     [barLabel release];
     [barLeftIconView release];
     
     
     
     if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
     [netStatusBar setHidden:NO];
     }else{
     [netStatusBar setHidden:YES];
     }
     
     self.netStatusBar = netStatusBar;
     
     [self.view addSubview:netStatusBar];
     [netStatusBar release];
     
     
     //按钮，发现多少个新设备
     UIButton *localDevicesView = [UIButton buttonWithType:UIButtonTypeCustom];
     [localDevicesView addTarget:self action:@selector(onLocalButtonPress) forControlEvents:UIControlEventTouchUpInside];
     localDevicesView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, LOCAL_DEVICES_VIEW_HEIGHT);
     localDevicesView.backgroundColor = UIColorFromRGBA(0x5ab8ffff);
     [self.view addSubview:localDevicesView];
     self.localDevicesView = localDevicesView;
     //文本，发现几个新设备
     UILabel *localDevicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, localDevicesView.frame.size.width, localDevicesView.frame.size.height)];
     localDevicesLabel.backgroundColor = [UIColor clearColor];
     localDevicesLabel.textAlignment = NSTextAlignmentCenter;
     localDevicesLabel.textColor = XWhite;
     localDevicesLabel.font = XFontBold_16;
     [localDevicesView addSubview:localDevicesLabel];
     self.localDevicesLabel = localDevicesLabel;
     //图片，箭头
     UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(localDevicesLabel.frame.size.width-LOCAL_DEVICES_ARROW_WIDTH, (localDevicesLabel.frame.size.height-LOCAL_DEVICES_ARROW_HEIGHT)/2, LOCAL_DEVICES_ARROW_WIDTH, LOCAL_DEVICES_ARROW_HEIGHT)];
     arrowView.image = [UIImage imageNamed:@"ic_local_devices_arrow.png"];
     [localDevicesLabel addSubview:arrowView];
     [arrowView release];
     [localDevicesLabel release];
     [localDevicesView setHidden:YES];
     [localDevicesView release];
     
     
     
     //添加设备说明文本
     UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
     
     UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [emptyButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
     emptyButton.frame = CGRectMake((emptyView.frame.size.width-EMPTY_BUTTON_WIDTH)/2, (emptyView.frame.size.height-EMPTY_BUTTON_HEIGHT)/2, EMPTY_BUTTON_WIDTH, EMPTY_BUTTON_HEIGHT);
     UIImage *emptyButtonImage = [UIImage imageNamed:@"bg_blue_button.png"];
     UIImage *emptyButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
     emptyButtonImage = [emptyButtonImage stretchableImageWithLeftCapWidth:emptyButtonImage.size.width*0.5 topCapHeight:emptyButtonImage.size.height*0.5];
     emptyButtonImage_p = [emptyButtonImage_p stretchableImageWithLeftCapWidth:emptyButtonImage_p.size.width*0.5 topCapHeight:emptyButtonImage_p.size.height*0.5];
     [emptyButton setBackgroundImage:emptyButtonImage forState:UIControlStateNormal];
     [emptyButton setBackgroundImage:emptyButtonImage_p forState:UIControlStateHighlighted];
     [emptyButton setTitle:CustomLocalizedString(@"add_device", nil) forState:UIControlStateNormal];
     //[emptyView addSubview:emptyButton]; 隐藏“添加设备”按钮
     
     [self.tableView addSubview:emptyView];
     self.emptyView = emptyView;
     [emptyView release];
     [self.emptyView setHidden:YES];
     
     UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.emptyView.frame.size.width-EMPTY_LABEL_WIDTH)/2, emptyButton.frame.origin.y-EMPTY_LABEL_HEIGHT, EMPTY_LABEL_WIDTH, EMPTY_LABEL_HEIGHT)];
     emptyLabel.backgroundColor = [UIColor clearColor];
     emptyLabel.textAlignment = NSTextAlignmentCenter;
     emptyLabel.textColor = [UIColor redColor];
     emptyLabel.numberOfLines = 0;
     emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
     emptyLabel.font = XFontBold_16;
     emptyLabel.text = CustomLocalizedString(@"empty_contact_prompt", nil);
     [self.emptyView addSubview:emptyLabel];
     [emptyLabel release];
     
     
     //设备检查更新
     //更新提示
     [self initUpdateDeviceInterface];
     */
    
    
    
    //ljp
    
    //view的frame
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //表格
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height) style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//无分割线
    tableView.delegate = self;
    tableView.dataSource = self;
    if(CURRENT_VERSION>=7.0){
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
            
            //进入首页时，获取设备列表里的设备的可更新状态
            //设备检查更新
            [[P2PClient sharedClient] checkDeviceUpdateWithId:contact.contactId password:contact.contactPassword];
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        [[FListManager sharedFList] getDefenceStates];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocalDevices" object:nil];
        
        [self requestScrollData];
        [self refreshRobotList];
    }];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    

    
    UIView *netStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 49)];
    netStatusBar.backgroundColor = [UIColor yellowColor];
    UIImageView *barLeftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (netStatusBar.frame.size.height-NET_WARNING_ICON_WIDTH_HEIGHT)/2, NET_WARNING_ICON_WIDTH_HEIGHT, NET_WARNING_ICON_WIDTH_HEIGHT)];
    barLeftIconView.image = [UIImage imageNamed:@"ic_net_warning.png"];
    [netStatusBar addSubview:barLeftIconView];
    
    UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width+10, 0, netStatusBar.frame.size.width-(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width)-10, netStatusBar.frame.size.height)];
    barLabel.textAlignment = NSTextAlignmentLeft;
    barLabel.textColor = [UIColor redColor];
    barLabel.backgroundColor = XBGAlpha;
    barLabel.font = XFontBold_16;
    barLabel.lineBreakMode = NSLineBreakByWordWrapping;
    barLabel.numberOfLines = 0;
    barLabel.text = CustomLocalizedString(@"net_warning_prompt", nil);
    [netStatusBar addSubview:barLabel];
    
    
    
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [netStatusBar setHidden:NO];
    }else{
        [netStatusBar setHidden:YES];
    }
    
    self.netStatusBar = netStatusBar;
    
    [self.view addSubview:netStatusBar];
    
    
    //按钮，发现多少个新设备
    UIButton *localDevicesView = [UIButton buttonWithType:UIButtonTypeCustom];
    [localDevicesView addTarget:self action:@selector(onLocalButtonPress) forControlEvents:UIControlEventTouchUpInside];
    localDevicesView.frame = CGRectMake(0, 0, width, LOCAL_DEVICES_VIEW_HEIGHT);
    localDevicesView.backgroundColor = UIColorFromRGBA(0x5ab8ffff);
    [self.view addSubview:localDevicesView];
    self.localDevicesView = localDevicesView;
    //文本，发现几个新设备
    UILabel *localDevicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, localDevicesView.frame.size.width, localDevicesView.frame.size.height)];
    localDevicesLabel.backgroundColor = [UIColor clearColor];
    localDevicesLabel.textAlignment = NSTextAlignmentCenter;
    localDevicesLabel.textColor = XWhite;
    localDevicesLabel.font = XFontBold_16;
    [localDevicesView addSubview:localDevicesLabel];
    self.localDevicesLabel = localDevicesLabel;
    //图片，箭头
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(localDevicesLabel.frame.size.width-LOCAL_DEVICES_ARROW_WIDTH, (localDevicesLabel.frame.size.height-LOCAL_DEVICES_ARROW_HEIGHT)/2, LOCAL_DEVICES_ARROW_WIDTH, LOCAL_DEVICES_ARROW_HEIGHT)];
    arrowView.image = [UIImage imageNamed:@"ic_local_devices_arrow.png"];
    [localDevicesLabel addSubview:arrowView];
    [localDevicesView setHidden:YES];
    
    
    /*
    //添加设备说明文本
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
    emptyButton.frame = CGRectMake((emptyView.frame.size.width-EMPTY_BUTTON_WIDTH)/2, (emptyView.frame.size.height-EMPTY_BUTTON_HEIGHT)/2, EMPTY_BUTTON_WIDTH, EMPTY_BUTTON_HEIGHT);
    UIImage *emptyButtonImage = [UIImage imageNamed:@"bg_blue_button.png"];
    UIImage *emptyButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
    emptyButtonImage = [emptyButtonImage stretchableImageWithLeftCapWidth:emptyButtonImage.size.width*0.5 topCapHeight:emptyButtonImage.size.height*0.5];
    emptyButtonImage_p = [emptyButtonImage_p stretchableImageWithLeftCapWidth:emptyButtonImage_p.size.width*0.5 topCapHeight:emptyButtonImage_p.size.height*0.5];
    [emptyButton setBackgroundImage:emptyButtonImage forState:UIControlStateNormal];
    [emptyButton setBackgroundImage:emptyButtonImage_p forState:UIControlStateHighlighted];
    [emptyButton setTitle:CustomLocalizedString(@"add_device", nil) forState:UIControlStateNormal];
    //[emptyView addSubview:emptyButton]; 隐藏“添加设备”按钮
    
    [self.tableView addSubview:emptyView];
    self.emptyView = emptyView;
    [self.emptyView setHidden:YES];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.emptyView.frame.size.width-EMPTY_LABEL_WIDTH)/2, emptyButton.frame.origin.y-EMPTY_LABEL_HEIGHT, EMPTY_LABEL_WIDTH, EMPTY_LABEL_HEIGHT)];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor redColor];
    emptyLabel.numberOfLines = 0;
    emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    emptyLabel.font = XFontBold_16;
    emptyLabel.text = CustomLocalizedString(@"empty_contact_prompt", nil);
    [self.emptyView addSubview:emptyLabel];
    */
    
    //设备检查更新
    //更新提示
    [self initUpdateDeviceInterface];
    
   
}

//ljp contact
#define PROGRESS_VIEW_WIDTH 160
#define PROGRESS_VIEW_HEIGHT 140
#define INDECATOR_LABEL_HEIGHT 100
-(void)initUpdateDeviceInterface{
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    UIView *progressMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:progressMaskView];
    self.progressMaskView = progressMaskView;
    
    
    //设备更新进度
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake((width-PROGRESS_VIEW_WIDTH)/2, (height-PROGRESS_VIEW_HEIGHT)/2, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT)];
    progressView.layer.borderColor = [XBlack CGColor];
    progressView.layer.cornerRadius = 2.0;
    progressView.layer.borderWidth = 1.0;
    progressView.backgroundColor = XBlack_128;
    progressView.layer.masksToBounds = YES;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PROGRESS_VIEW_WIDTH, 30.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = XWhite;
    titleLabel.font = XFontBold_16;
    titleLabel.text = CustomLocalizedString(@"update", nil);
    [progressView addSubview:titleLabel];
    
    //百分比进度
    UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PROGRESS_VIEW_WIDTH, INDECATOR_LABEL_HEIGHT)];
    indicatorLabel.backgroundColor = [UIColor clearColor];
    indicatorLabel.textAlignment = NSTextAlignmentCenter;
    indicatorLabel.textColor = XWhite;
    indicatorLabel.font = XFontBold_18;
    indicatorLabel.text = @"%0";
    [progressView addSubview:indicatorLabel];
    self.progressLabel = indicatorLabel;
    
    //取消更新按钮
    UIButton *indicatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    indicatorButton.frame = CGRectMake(0, indicatorLabel.frame.origin.y+indicatorLabel.frame.size.height, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT-(indicatorLabel.frame.origin.y+indicatorLabel.frame.size.height));
    indicatorButton.layer.borderWidth = 1.0;
    indicatorButton.layer.borderColor = [XBlack CGColor];
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, indicatorButton.frame.size.width, indicatorButton.frame.size.height)];
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.textColor = XWhite;
    buttonLabel.font = XFontBold_16;
    buttonLabel.text = CustomLocalizedString(@"cancel_update", nil);
    [indicatorButton addSubview:buttonLabel];
    [indicatorButton addTarget:self action:@selector(onCancelUpdateButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [indicatorButton addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [indicatorButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    [progressView addSubview:indicatorButton];
    
    
    [self.progressMaskView addSubview:progressView];
    
    
    self.progressView = progressView;
    [self.progressMaskView setHidden:YES];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = [UIColor clearColor];
}

-(void)onCancelUpdateButtonPress:(UIButton*)button{
    [self normalButton:button];
    [[P2PClient sharedClient] cancelDeviceUpdateWithId:self.selectedContact.contactId password:self.selectedContact.contactPassword];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(didHiddenProgressMaskView) userInfo:nil repeats:NO];
}

-(void)didHiddenProgressMaskView{
    if (!_isCancelUpdateDeviceOk) {
        [self.progressMaskView setHidden:YES];
        [self.view makeToast:CustomLocalizedString(@"device_update_timeout", nil)];
    }
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)refreshContact{
    NSLog(@"33333333333");
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    
    NSMutableArray * sameArray = [NSMutableArray arrayWithCapacity:0];//相同数据的数据
    for (int i = 0; i <self.yooSeeArray.count; i ++) {
        MyFacilityModel * myFacilityModel = self.yooSeeArray[i];
        Contact * contactTempModel;
        BOOL isSame = NO;
        for (int j = 0; j<self.contacts.count; j++) {
            Contact * contactModel = self.contacts[j];
            if ([myFacilityModel.res2 integerValue]==[contactModel.contactId integerValue]) {//同时有数据
                contactTempModel = contactModel;
                isSame = YES;
                break;
            }else{
                isSame = NO;
            }
        }
        if (isSame) {
            [sameArray addObject:contactTempModel];//后台和本地都有的数据
        }else{
            
        }
    }
    self.contacts = [NSMutableArray arrayWithCapacity:0];
    self.contacts = [NSMutableArray arrayWithArray:sameArray];
    
    if(self.tableView){
        [self.tableView reloadData];
    }
}


-(void)refreshLocalDevices{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height-64;
    
    NSArray *lanDeviceArray = [[UDPManager sharedDefault] getLanDevices];
    NSMutableArray *array = [Utils getNewDevicesFromLan:lanDeviceArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([array count]>0){
            UILabel *localDevicesLabel = [[self.localDevicesView subviews] objectAtIndex:0];
            localDevicesLabel.text = [NSString stringWithFormat:@"%@ %i %@",CustomLocalizedString(@"discovered", nil),[array count],CustomLocalizedString(@"new_device", nil)];
            if([self.netStatusBar isHidden]){
                self.localDevicesView.frame = CGRectMake(0, 0, width, LOCAL_DEVICES_VIEW_HEIGHT);
                self.tableView.frame = CGRectMake(0.0, LOCAL_DEVICES_VIEW_HEIGHT, width, height-LOCAL_DEVICES_VIEW_HEIGHT);//设备列表界面调整
                self.tableViewOffset = self.localDevicesView.frame.size.height;
                

            }else{
                self.localDevicesView.frame = CGRectMake(0, self.netStatusBar.frame.size.height, width, LOCAL_DEVICES_VIEW_HEIGHT);
                
                self.tableView.frame = CGRectMake(0.0, self.netStatusBar.frame.size.height+self.localDevicesView.frame.size.height, width, height-self.netStatusBar.frame.size.height-self.localDevicesView.frame.size.height);//设备列表界面调整
                self.tableViewOffset = self.netStatusBar.frame.size.height+self.localDevicesView.frame.size.height;
                
            }
            
            [self.localDevicesView setHidden:NO];
            
        }else{
            if([self.netStatusBar isHidden]){
                self.tableView.frame = CGRectMake(0.0, 0.0, width, height);//设备列表界面调整
                self.tableViewOffset = 0;

            }else{
                self.tableView.frame = CGRectMake(0.0, self.netStatusBar.frame.size.height, width, height-self.netStatusBar.frame.size.height);//设备列表界面调整
                self.tableViewOffset = self.netStatusBar.frame.size.height;
                
            }
            
            [self.localDevicesView setHidden:YES];
        }
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

#pragma mark - 设备绑定报警推送帐号(user id)
-(void)willBindUserIDByContactWithContactId:(NSString *)contactId contactPassword:(NSString *)contactPassword{
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
    BOOL isDeviceBindedUserID = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (isDeviceBindedUserID) {
        return ;
    }
    [[P2PClient sharedClient] getBindAccountWithId:contactId password:contactPassword];//获取设备报警推送帐号个数
}

#pragma mark -
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_DO_DEVICE_UPDATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.isShowProgressAlert) {
                    self.isShowProgressAlert = NO;
                }
                
                if(result==1){
                    self.progressLabel.text = [NSString stringWithFormat:@"%li%%",(long)value];//device update
                    [self.progressMaskView setHidden:NO];
                    DLog(@"%i",value);
                }else if(result==65){
                    [self.progressMaskView setHidden:YES];
                    [self.view makeToast:CustomLocalizedString(@"start_update", nil)];
                    //设备检查更新
                    //设备升级成功，将设备的isNewVersionDevice设置为NO，刷新表格，去除红色角标
                    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                        if ([self.selectedContact.contactId isEqualToString:contact.contactId]) {
                            contact.isNewVersionDevice = NO;
                        }
                    }
                    [self.tableView reloadData];

                    
                }else{
                    _isCancelUpdateDeviceOk = YES;
                    [self.progressMaskView setHidden:YES];
                    [self.view makeToast:CustomLocalizedString(@"update_failed", nil)];
                }
            });
            
        }
            break;
        case RET_CHECK_DEVICE_UPDATE://设备检查更新
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(result==1 || result==72){
                //读取到了服务器升级文件（1）
                //读取到了sd卡升级文件（72）
                NSString *curVersion = [parameter valueForKey:@"curVersion"];
                NSString *upgVersion = [parameter valueForKey:@"upgVersion"];
                for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                    if ([contactId isEqualToString:contact.contactId]) {
                        contact.isNewVersionDevice = YES;
                        contact.result_sd_server = result;
                        contact.deviceCurVersion = curVersion;
                        contact.deviceUpgVersion = upgVersion;
                    }
                }
            }else{
                //设备没有可升级包
                for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {
                    if ([contactId isEqualToString:contact.contactId]) {
                        contact.isNewVersionDevice = NO;
                    }
                }
            }
        }
            break;
        case RET_GET_BIND_ACCOUNT://获取设备报警推送帐号个数
        {
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] integerValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            
            NSMutableArray *bindIds = [NSMutableArray arrayWithArray:datas];
            
            
            if (bindIds.count < maxCount) {
                LoginResult *loginResult = [UDManager getLoginInfo];
                if (bindIds.count>0){
                    if (![bindIds containsObject:[NSNumber numberWithInt:loginResult.contactId.intValue]]) {
                        [bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                    }
                }else{
                    [bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                }
                
                NSString *contactId = [parameter valueForKey:@"contactId"];
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:contactId];
                [[P2PClient sharedClient] setBindAccountWithId:contactId password:contact.contactPassword datas:bindIds];
            }else{
                NSString *contactId = [parameter valueForKey:@"contactId"];
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:[NSString stringWithFormat:@"%@%@%@ %i %@",CustomLocalizedString(@"device", nil),contactId,CustomLocalizedString(@"add_bind_account_prompt1", nil),maxCount,CustomLocalizedString(@"add_bind_account_prompt2", nil)]];
                });
            }
        }
            break;
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            
            if(result==0){//绑定成功，isDeviceBindedUserID为YES,不再绑定
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];

            }else{

            }
        }
            break;
    }
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    
    if (key != ACK_RET_GET_NPC_SETTINGS) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isShowProgressAlert == YES) {
            self.isShowProgressAlert = NO;
        }
        if (result == 0)
        {
            MainSettingController *mainSettingController = [[MainSettingController alloc] init];
            mainSettingController.contact = self.selectedContact;
            [self.navigationController pushViewController:mainSettingController animated:YES];
        }
        else if(result==1)
        {
            [self.view makeToast:CustomLocalizedString(@"device_password_error", nil)];
        }
        else if(result==2)
        {
            [self.view makeToast:CustomLocalizedString(@"net_exception", nil)];
        }
        else if(result==4)
        {
            [self.view makeToast:CustomLocalizedString(@"no_permission", nil)];
        }
    });
}


#define OPERATOR_ITEM_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80:55)
#define OPERATOR_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:48)
#define OPERATOR_ARROW_WIDTH_AND_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20:10)
#define OPERATOR_BAR_OFFSET (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:30)

-(UIButton*)getOperatorView:(CGFloat)offset itemCount:(NSInteger)count{
    offset += self.tableViewOffset;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIButton *operatorView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height-TAB_BAR_HEIGHT)];
    operatorView.tag = kOperatorViewTag;
    
    
    
    UIView *barView = [[UIView alloc] init];
    barView.tag = kBarViewTag;
    
    UIImageView *arrowView = [[UIImageView alloc] init];
    UIView *buttonsView = [[UIView alloc] init];
    buttonsView.tag = kButtonsViewTag;
    if((offset>self.tableView.frame.size.height)||((self.tableView.frame.size.height-offset)<CONTACT_ITEM_HEIGHT)){
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset-OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, OPERATOR_ITEM_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        
        buttonsView.frame = CGRectMake(0, 0, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_bottom.png"]];
        
    }else{
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset+OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, 0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        buttonsView.frame = CGRectMake(0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_top.png"]];
    }
    
    buttonsView.layer.borderColor = [[UIColor grayColor] CGColor];
    buttonsView.layer.borderWidth = 1;
    buttonsView.layer.cornerRadius = 5;
    [buttonsView.layer setMasksToBounds:YES];

    [barView addSubview:arrowView];
    [barView addSubview:buttonsView];
    [operatorView addSubview:barView];
    return operatorView;
}

-(void)onOperatorViewSingleTap{
    UIView *operatorView = [self.view viewWithTag:kOperatorViewTag];
    UIView *barView = [operatorView viewWithTag:kBarViewTag];
    [UIView transitionWithView:barView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        barView.alpha = 0.3;
                        
                    }
                    completion:^(BOOL finished){
                        [operatorView removeFromSuperview];
                    }
     ];
}

//设备列表界面调整
-(void)ContactCellOnClickBottomBtn:(int)btnTag contact:(Contact *)contact{
    self.selectedContact = contact;
    switch(btnTag){
        case kOperatorBtnTag_Modify:
        {
//            AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//            addContactNextController.isModifyContact = YES;
//            addContactNextController.contactId = contact.contactId;
//            addContactNextController.modifyContact = contact;
//            [self.navigationController pushViewController:addContactNextController animated:YES];
            
            LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
            addContactNextController.isModifyContact = YES;
            addContactNextController.contactId = contact.contactId;
            addContactNextController.modifyContact = contact;
            [self.navigationController pushViewController:addContactNextController animated:YES];
            
        }
            break;
        case kOperatorBtnTag_Message:
        {
            ChatController *chatController = [[ChatController alloc] init];
            
            chatController.contact = contact;
            
            [self.navigationController pushViewController:chatController animated:YES];
            
            
        }
            break;
        case kOperatorBtnTag_Monitor:
        {
            MainController *mainController = [AppDelegate sharedDefault].mainController;
            [mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
        }
            break;
        case kOperatorBtnTag_Chat:
        {
            MainController *mainController = [AppDelegate sharedDefault].mainController;
            [mainController setUpCallWithId:contact.contactId password:@"0" callType:P2PCALL_TYPE_VIDEO];
        }
            break;
        case kOperatorBtnTag_Playback:
        {
            if (contact.defenceState==DEFENCE_STATE_NO_PERMISSION) {
                [self.view makeToast:CustomLocalizedString(@"no_permission", nil)];
            }else{
                P2PPlaybackController *playbackController = [[P2PPlaybackController alloc] init];
                playbackController.contact = contact;
                [self.navigationController pushViewController:playbackController animated:YES];
                
            }
        }
            
            break;
        case kOperatorBtnTag_Control:
        {
            self.isShowProgressAlert = YES;
            [[P2PClient sharedClient]getNpcSettingsWithId:contact.contactId password:contact.contactPassword];
            
        }
            break;
        case kOperatorBtnTag_WeakPwd:
        {
            ModifyDevicePasswordController *modifyDevicePasswordController = [[ModifyDevicePasswordController alloc] init];
            modifyDevicePasswordController.contact = contact;
            modifyDevicePasswordController.isIntoHereOfClickWeakPwd = YES;
            [self.navigationController pushViewController:modifyDevicePasswordController animated:YES];
        }
            break;
        case kOperatorBtnTag_UpdateDevice:
        {
            //设备检查更新
            if(contact.result_sd_server==1){
                //读取到了服务器升级文件
                NSString *title = [NSString stringWithFormat:@"%@:%@,%@:%@",CustomLocalizedString(@"cur_version_is", nil),contact.deviceCurVersion,CustomLocalizedString(@"can_update_to", nil),contact.deviceUpgVersion];
                UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
                deleteAlert.tag = ALERT_TAG_UPDATE;
                [deleteAlert show];
            }
            if(contact.result_sd_server==72){
                //读取到了sd卡升级文件
                NSString *title = [NSString stringWithFormat:@"%@:%@,%@",CustomLocalizedString(@"cur_version_is", nil),contact.deviceCurVersion,CustomLocalizedString(@"can_update_sd", nil)];
                UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
                deleteAlert.tag = ALERT_TAG_UPDATE;
                [deleteAlert show];
            }
        }
            break;
        case kOperatorBtnTag_initDevicePwd:
        {
            CreateInitPasswordController * createInitPwdCtl = [[CreateInitPasswordController alloc] init];
            createInitPwdCtl.contactId = contact.contactId;
            [self.navigationController pushViewController:createInitPwdCtl animated:YES];
        }
            break;
    }
}

-(void) onAddPress{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PopoverTableViewController *popoverTableViewController = [[PopoverTableViewController alloc] init];
        popoverTableViewController.navigationController = self.navigationController;
        
        //内存泄漏
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverTableViewController];
        popoverController.popoverContentSize = CGSizeMake(200, 136);
        [popoverController presentPopoverFromRect:CGRectMake(self.topBar.rightButton.frame.size.width/2.0, self.topBar.rightButton.frame.size.height, 5, 5) inView:self.topBar.rightButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverTableViewController.popover = popoverController;
        
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"popover_background_image.png"];
        PopoverView *popoverView = [[PopoverView alloc] init];
        popoverView.frame = CGRectMake(0, 0, 160, 160*(image.size.height/image.size.width));
        popoverView.delegate = self;
        popoverView.backgroundImage = image;
        
        DXPopover *popover = [DXPopover popover];
        self.popover = popover;
        popover.arrowSize = CGSizeMake(0.0, 0.0);
        [popover showAtView:self.topBar.rightButton withContentView:popoverView];
        
    }
}

-(void)didSelectedPopoverViewRow:(NSInteger)row{
    [self.popover dismiss];//去掉泡沫
    if (row == 1) {
        QRCodeController *qecodeController = [[QRCodeController alloc] init];
        [self.navigationController pushViewController:qecodeController animated:YES];
        AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        tempDelegate.qrVC = qecodeController;
    }else if (row == 2){
//        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//        addContactNextController.inType = 1;
//        addContactNextController.isInFromManuallAdd = YES;
//        [self.navigationController pushViewController:addContactNextController animated:YES];
        
        LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
    }else if (row == 3)
    {
        ApModeViewController *apModeController = [[ApModeViewController alloc] init];
        [self.navigationController pushViewController:apModeController animated:YES];
    }
}

-(void)onLocalButtonPress{
    NSArray* lanDevicesArray = [[UDPManager sharedDefault]getLanDevices];
    NSArray* newDevicesArray = [Utils getNewDevicesFromLan:lanDevicesArray];
    
    LocalDeviceListController *localDeviceListController = [[LocalDeviceListController alloc] init];
    localDeviceListController.isNewDevicesArray = newDevicesArray;
    [self.navigationController pushViewController:localDeviceListController animated:YES];
}

-(void)stopAnimating{
    DLog(@"stopAnimating");
    
    [self refreshContact];
    
    //self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            //[self.tableView.pullToRefreshView stopAnimating];
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];

        });
    });
}

#pragma mark -监控
-(void)onClick:(NSInteger)position contact:(Contact *)contact{
    [AppDelegate sharedDefault].isDoorBellAlarm = NO;
    
    //ljp
    AppDelegate * tempDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MyFacilityViewController *mainVC = tempDelegate.mainVC;
    mainVC.contactName = contact.contactName;
    mainVC.contact = contact;
    [mainVC setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
    
    monitorContact = contact;
    
    //    MainController *mainController = [AppDelegate sharedDefault].mainController;
    //    mainController.contactName = contact.contactName;
    //    mainController.contact = contact;//重新调整监控画面
    //    [mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
}

//ljp main
#pragma mark - 进入呼叫设备界面1
-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];
    
    //rtsp监控界面弹出修改
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        if(!self.presentedViewController){
            
            P2PCallController *p2pCallController = [[P2PCallController alloc] init];
            p2pCallController.contactName = self.contactName;
            
            AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
            [self presentViewController:controller animated:YES completion:^{
                
            }];
        }
        
    }else{
        /*
         *1. 用线程延时100毫秒来呈现监控界面
         *2. 目的是，等待上个动画结束了，再模态监控界面
         *3. 效果是，就不会出现APP接收到门铃推送，进入监控且返回时，设备列表cell的不正常显示(9.1)
         */
        [NSThread detachNewThreadSelector:@selector(presentMonitorInterface) toTarget:self withObject:nil];
    }
}

-(void)presentMonitorInterface{
    usleep(600000);
    dispatch_async(dispatch_get_main_queue(), ^{
        /*
         * 1. 点击监控，直接进入监控界面
         * 2. 在监控界面上，调用接口，向设备端发送监控连接
         * 3. 发送监控连接的同时，界面提示正在连接
         */
        if (!self.isShowingMonitorController) {
            self.isShowingMonitorController = YES;
            P2PMonitorController *monitorController = [[P2PMonitorController alloc] init];
            monitorController.monitorContact = monitorContact;
            BaseNaviViewController *navi = [[BaseNaviViewController alloc] initWithRootViewController:monitorController];
            [self presentViewController:navi animated:YES completion:nil];
        }
    });
}

-(void)P2PClientCalling:(NSDictionary*)info{
    DLog(@"P2PClientCalling");
    BOOL isBCalled = [[P2PClient sharedClient] isBCalled];
    NSString *callId = [[P2PClient sharedClient] callId];
    if(isBCalled){
        if([[AppDelegate sharedDefault] isGoBack]){
            UILocalNotification *alarmNotify = [[UILocalNotification alloc] init];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = @"default";
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:Calling!",callId];
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = CustomLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
            return;
        }
        
        if(!self.isShowP2PView){
            self.isShowP2PView = YES;
            UIViewController *presentView1 = self.presentedViewController;
            UIViewController *presentView2 = self.presentedViewController.presentedViewController;
            if(presentView2){
                [self dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                }];
            }else if(presentView1){
                [presentView1 dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                }];
            }else{
                P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                
                [self presentViewController:controller animated:YES completion:^{
                    
                }];
            }
        }
    }
}

-(void)dismissP2PView{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [presentView1 dismissViewControllerAnimated:YES completion:nil];
    }
    self.isShowP2PView = NO;
}

-(void)dismissP2PView:(void (^)())callBack{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else if(presentView1){
        [presentView1 dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else{
        callBack();
    }
    self.isShowP2PView = NO;
}

#pragma mark - 挂断监控设备回调
-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        if (self.mainControllerDelegate && [self.mainControllerDelegate respondsToSelector:@selector(mainControllerMonitorReject:)]) {
            [self.mainControllerDelegate mainControllerMonitorReject:info];
        }
        
    }else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_NONE];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(500000);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                int errorFlag = [[info objectForKey:@"errorFlag"] intValue];
                if ([AppDelegate sharedDefault].isMonitoring) {
                    [AppDelegate sharedDefault].isMonitoring = NO;//挂断，不处于监控状态
                }
                //视频通话或呼叫状态下
                [self dismissP2PView];
                
                switch(errorFlag)
                {
                    case CALL_ERROR_NONE:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_unknown_error", nil)];
                        break;
                    }
                    case CALL_ERROR_DESID_NOT_ENABLE:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_disabled", nil)];
                        break;
                    }
                    case CALL_ERROR_DESID_OVERDATE:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_overdate", nil)];
                        break;
                    }
                    case CALL_ERROR_DESID_NOT_ACTIVE:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_inactived", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_DESID_OFFLINE:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_offline", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_DESID_BUSY:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_busy", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_DESID_POWERDOWN:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_powerdown", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_NO_HELPER:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_connect_failed", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_HANGUP:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_hangup", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_TIMEOUT:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_timeout", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_INTER_ERROR:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_internal_error", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_RING_TIMEOUT:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_no_accept", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_PW_WRONG:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_password_error", nil)];
                        
                        break;
                    }
                    case CALL_ERROR_CONN_FAIL:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_connect_failed", nil)];
                        break;
                    }
                    case CALL_ERROR_NOT_SUPPORT:
                    {
                        [self.view makeToast:CustomLocalizedString(@"id_not_support", nil)];
                        break;
                    }
                    default:
                        [self.view makeToast:CustomLocalizedString(@"id_unknown_error", nil)];
                        
                        break;
                }
            });
        });
    }
}

-(void)P2PClientAccept:(NSDictionary*)info{
    DLog(@"P2PClientAccept");
}

#pragma mark - 连接设备就绪
-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_READY_P2P];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        //rtsp监控界面弹出修改
        /*
         * 监控连接已经准备就绪，发送监控开始渲染通知
         * 在监控界面上，接收通知，并开始渲染监控画面
         */
        [[NSNotificationCenter defaultCenter] postNotificationName:MONITOR_START_RENDER_MESSAGE
                                                            object:self
                                                          userInfo:NULL];
    }else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        P2PVideoController *videoController = [[P2PVideoController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
        }else{
            [self presentViewController:videoController animated:YES completion:nil];
        }
        
    }
}

#pragma mark -
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


//ljp facility
- (void)panAction:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender translationInView:self.view];
    if (point.x >= 30) {
        self.toumingImageView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.backImageView.frame = CGRectMake(0, 0, ScreenWidth-100, ScreenHeight);
        }];
    }
}

#pragma mark - 基本信息
- (IBAction)baseInfoAction:(id)sender {
    [self exitSide];
    BaseInfoViewController *vc = [[BaseInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 消息
- (IBAction)messageAction:(id)sender {
    [self exitSide];
    MessageTypeViewController *vc = [[MessageTypeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 退出侧边栏
- (IBAction)exitSideAction:(id)sender {
    [self exitSide];
}

- (void)exitSide
{
    self.toumingImageView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.backImageView.frame = CGRectMake(-(ScreenWidth-100), 0, ScreenWidth-100, ScreenHeight);
//        self.backImageView = (UIImageView *)[[UIApplication sharedApplication].windows firstObject];
    }];
}

#pragma mark - 点击阴影
- (IBAction)tapBackAction:(id)sender {
    [self exitSide];
}

#pragma mark - tableView/delegate/datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 3;//
    }
    else {
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (!self.bindArray.count && !self.yooSeeArray.count) {
            if (section == 0) {
                return 1;
            }
            else if (section == 1) {
                //return self.bindArray.count;
                return 1;
            }
            else {
                if (self.yooSeeArray.count && self.contacts.count) {
                    return self.yooSeeArray.count;
                } else {
                    return 0;
                }
            }
        } else {
            if (section == 0) {
                return 1;
            }
            else if (section == 1) {
                return self.bindArray.count;
            }
            else {
                if (self.yooSeeArray.count && self.contacts.count) {
                    return self.yooSeeArray.count<=self.contacts.count?self.yooSeeArray.count:self.contacts.count;
                } else {
                    return 0;
                }
            }
        }
    }
    else {
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            //广告分区
            static NSString *cellIde = @"cell11";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (self.scrollArray.count) {
                //广告位
                NSMutableArray *adArray = [NSMutableArray array];
                NSMutableArray * toArr = [NSMutableArray arrayWithCapacity:0];
                for (IndexImgModel *model in self.scrollArray) {
                    NSString *picStr = model.picturePath;
                    [adArray addObject:picStr];
                    [toArr addObject:model.commonId];
                }
                
                //如果你的这个广告视图是添加到导航控制器子控制器的View上,请添加此句,否则可忽略此句
                self.automaticallyAdjustsScrollViewInsets = NO;
                //加载网络图片
                if (!headAdView && !closeBtn) {
                    headAdView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth/4.0) imageLinkURL:adArray placeHoderImageName:@"banner" pageControlShowStyle:UIPageControlShowStyleCenter];
                    //图片被点击后回调的方法
                    __block MyFacilityViewController *weakself  = self;
                    //点击图片跳转
                    headAdView.callBack = ^(NSInteger index,NSString * imageURL)
                    {
                    ShopMallViewController * contrller = [[ShopMallViewController alloc]init];
                    contrller.isfromAd = YES;
                    contrller.AdUrlString = imageURL;
                    [weakself.navigationController pushViewController:contrller animated:YES];
                    
                    };
                    [headAdView setimageToURL:toArr];
                    
                    [cell addSubview:headAdView];
                    
                    //关闭广告按钮
                    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    closeBtn.frame = CGRectMake(ScreenWidth-30, 0, 30, 30);
                    [closeBtn setBackgroundImage:LCImage(@"关闭广告") forState:UIControlStateNormal];
                    [closeBtn lc_block:^(id sender) {
                        closeBtn.selected = YES;
                        for (UIView *view in cell.subviews) {
                            [view removeFromSuperview];
                        }
                        [self.tableView reloadData];
                        
                    }];
                    [cell addSubview:closeBtn];
                }
            }
            
            return cell;
        }
        else if (indexPath.section == 1) {
            //扫地机
            static NSString *cellIde = @"cell44";
            MyFacilityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
            if (!cell) {
                cell = [[MyFacilityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                
                if (array.count == 0) {
                    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 70)];
                    addLabel.backgroundColor = [UIColor lc_colorWithR:239 G:239 B:244 alpha:1.0];
                    addLabel.text = @"点击右上角添加设备";
                    addLabel.textAlignment = NSTextAlignmentCenter;
                    addLabel.textColor = [UIColor grayColor];
                    addLabel.tag = 1000;
                    [cell addSubview:addLabel];
                    [cell bringSubviewToFront:addLabel];
                }
            }
            
            if (self.bindArray.count || self.yooSeeArray.count) {
                UILabel *tempLabel = (UILabel *)[cell viewWithTag:1000];
                tempLabel.hidden = YES;
            }
            if (self.bindArray.count) {
                cell.model = self.bindArray[indexPath.row];
            }
            
            return cell;
        }
        else {
            //摄像头
            static NSString *cellIde = @"cell22";
            
       FacilityContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
            if (!cell) {
                cell = [[FacilityContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
            }
            
            if (self.yooSeeArray.count && self.contacts.count) {
                
                
                cell.model = self.yooSeeArray[indexPath.row];
                
                Contact *contactModel = self.contacts[indexPath.row];
                cell.contactModel = self.contacts[indexPath.row];
                //第一次或者删除后添加设备到设备列表时，若设备的状态是在线，则绑定报警推送帐号；
                //绑定成功，isDeviceBindedUserID为YES,不再绑定
                if (contactModel.onLineState == STATE_ONLINE && contactModel.contactType == CONTACT_TYPE_DOORBELL) {
                    [self willBindUserIDByContactWithContactId:contactModel.contactId contactPassword:contactModel.contactPassword];
                }
            }
            
            return cell;
        }
    }
    else {
        //侧边视图
        static NSString *cellIde = @"cell33";
        SideBarCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SideBarCell" owner:self options:nil].firstObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UIImageView *iconImageV = (UIImageView *)[cell viewWithTag:10];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:20];
        
        NSArray *imageArr = @[@"商城",@"设置"];
        iconImageV.image = LCImage(imageArr[indexPath.row]);
        
        titleLabel.text = leftPlArray[indexPath.row];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (self.scrollArray.count) {
            if (!closeBtn.selected) {
                if (indexPath.section == 0) {
                    return ScreenWidth/4.0;
                } else {
                    return 70;
                }
            } else {
                if (indexPath.section == 0) {
                    return CGFLOAT_MIN;
                } else {
                    return 70;
                }
            }
        } else {
            if (indexPath.section == 0) {
                return CGFLOAT_MIN;
            } else {
                return 70;
            }
        }
    }
    else {
        return 60;
    }
}
- (void)getID
{
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceTypeFrontFindAll parameters:nil successBlock:^(id successObject) {
        if ([successObject[@"result"] boolValue]) {
            
            array = [DeviceTypeModel mj_objectArrayWithKeyValuesArray:successObject[@"object"]];
            DeviceTypeModel *modelID = array[0];
            NSArray *arr = modelID.deviceModelList;
            for (AddFacilityModel *facilityID in arr) {
                if ([facilityID.deviceModelName isEqualToString: @"套装 NVR"]) {
                    NVRID = facilityID.id;
                }
            }
        }
    } FailBlock:^(id failObject) {
        
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 1) {
            //扫地机
            if (self.bindArray.count) {
                MyFacilityModel *model = self.bindArray[indexPath.row];
                [self checkRoomExist:model.deviceId];
            }
            
        }
        else if (indexPath.section == 2)
        {
            //摄像头
            MyFacilityModel *model = self.yooSeeArray[indexPath.row];
            NSLog(@"%@,%@,%@,%@,%@,%@,%@,%@",model.id,model.deviceId,model.type,model.typeId,model.name,model.modelId,model.res1,model.res2);
            
            if ([model.modelId isEqualToString:NVRID]) {//358113623439362
                //NVR
                NSLog(@"久安NVR");
                ENLiveViewController *ENLive = [[ENLiveViewController alloc] init];
                if (model.res1 == nil) {
                    model.res1 = @"";
                }
                
                int port = 0;//也没有这个端口
                NSString *channel = [[NSUserDefaults standardUserDefaults] objectForKey:@"NVRAllChannel"];
                if (channel == nil) {
                    channel = @"4";
                }
                [ENLive setDeviceInfoWithDeviceIDOrIP:model.res2 UserName:model.res4 Passwords:model.res1 Port:port Channel:[model.res3 intValue]];
                ENLive.navigatioName = model.name;
//                [self presentViewController:ENLive animated:YES completion:nil];
                
                [self.navigationController pushViewController:ENLive animated:YES];
            }else{
                [self onClick:indexPath.row contact:self.contacts[indexPath.row]];
            }
        }
    }
    else {
        //隐藏 
        [self exitSide];
        //跳转
        NSArray *classArray = @[@"ShopMallViewController",@"SetupViewController"];
        BaseViewController *vc = [[NSClassFromString(classArray[indexPath.row]) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - NVR请求数据
- (void)nvrNet
{
//    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceAdd parameters:requestDic successBlock:^(id successObject) {
//        NSLog(@"success");
//        if ([successObject[@"result"] integerValue]) {//添加成功
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    } FailBlock:^(id failObject) {
//        HL_ALERT(CustomLocalizedString(@"prompy", nil), failObject[@"message"]);
//    }];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            return NO;
        }
        else if (indexPath.section == 1) {
            if (self.bindArray.count) {
                return YES;
            } else {
                return NO;
            }
        }
        else {
            return YES;
        }
    }
    else {
        return NO;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (indexPath.section == 1) {
                MyFacilityModel *model = self.bindArray[indexPath.row];
                RenameViewController *vc = [[RenameViewController alloc] init];
                vc.facilityId = model.id;
                vc.facilityName = model.name;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.section == 2) {
//                Contact *facilityContact = self.contacts[indexPath.row];
//                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
//                addContactNextController.selectModel = self.yooSeeArray[indexPath.row];
//                addContactNextController.isModifyContact = YES;
//                addContactNextController.contactId = facilityContact.contactId;
//                addContactNextController.modifyContact = facilityContact;
//                [self.navigationController pushViewController:addContactNextController animated:YES];
                
                Contact *facilityContact = self.contacts[indexPath.row];
                LC_AddContactNextViewController *addContactNextController = [[LC_AddContactNextViewController alloc] init];
                addContactNextController.selectModel = self.yooSeeArray[indexPath.row];
                addContactNextController.isModifyContact = YES;
                addContactNextController.contactId = facilityContact.contactId;
                addContactNextController.modifyContact = facilityContact;
                [self.navigationController pushViewController:addContactNextController animated:YES];
            }
        }];
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if (indexPath.section == 1) {
                selectModel = self.bindArray[indexPath.row];
                UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
                deleteAlert.tag = 10000;
                [deleteAlert show];
            }
            else if (indexPath.section == 2){
                selectContact = self.contacts[indexPath.row];
                selectModel = self.yooSeeArray[indexPath.row];
                UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
                deleteAlert.tag = ALERT_TAG_DELETE;
                [deleteAlert show];
            }
        }];
        return @[deleteAction,renameAction];
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        editingStyle = UITableViewCellEditingStyleDelete;
    }
}

#pragma mark - 查询是否存在户型图
- (void)checkRoomExist:(NSString *)deviceId {
    [self mb_normal];
    
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
   
    /**< 储存设备信息 */
    [UD setObject:deviceId forKey:@"deviceIdText"];
    [UD synchronize];
    
    
    NSDictionary *requestDic = @{@"userId":userModel.id,
                                 @"deviceId":deviceId};
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypeGET urlStr:CheckRoomExist parameters:requestDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"object"] intValue] == 1) {
            
            [JPAlertView jp_alertViewInitWithTitle:@"提示" message:@"初次绑定设备会进行房屋空间绘制" cancelButton:nil otherButton:@"绘制" actionBlock:^(NSInteger buttonIndex) {
                /*
                if (buttonIndex == 0) {
                    OperateViewController *vc = [[OperateViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    IRDrawViewController *dvc = [[IRDrawViewController alloc]init];
                    dvc.isDrawed = NO;
                    dvc.areaSelectFlag = YES;
                    [self.navigationController pushViewController:dvc animated:YES];
                }
                 */

            }];
            
        } else if ([successObject[@"object"] intValue] == 2) {

        }
        
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == 0) {
            return CGFLOAT_MIN;
        } else {
            return 5;
        }
    }
    else {
        return 150;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return CGFLOAT_MIN;
    }
    else {
        return CGFLOAT_MIN;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return nil;
    }
    else {
        UILabel *label = (UILabel *)[self.messageButton viewWithTag:1000];
        if (label != nil) {
            [label removeFromSuperview];
        }
        
        UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, 10, 10)];
        redLabel.backgroundColor = [UIColor redColor];
        redLabel.layer.masksToBounds = YES;
        redLabel.layer.cornerRadius = 5.0;
        redLabel.tag = 1000;
        [self.messageButton addSubview:redLabel];
        if (LCStrEqual(messageCount, @"0")) {
            redLabel.hidden = YES;
        } else {
            redLabel.hidden = NO;
        }
        
        return self.headerView;
    }
}

- (void)requestScrollData
{
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:IndexImgFindAll parameters:nil successBlock:^(id successObject) {
        NSArray *array = [IndexImgModel mj_objectArrayWithKeyValuesArray:successObject[@"object"]];
        [self.scrollArray removeAllObjects];
        [self.scrollArray addObjectsFromArray:array];
        //[self.tableView reloadData];
        
    } FailBlock:^(id failObject) {
        //失败
    }];
}

/**< 用户已绑定的设备列表 */
#pragma mark - 用户已绑定的设备列表
- (void)refreshRobotList
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    NSDictionary *infoDic = @{@"userId":userModel.id};
    
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:UserDeviceFindPage parameters:infoDic successBlock:^(id successObject) {
        [self.tableView.mj_header endRefreshing];
        //[self stopAnimating];
        self.bindArray = [NSMutableArray array];
        self.yooSeeArray = [NSMutableArray array];
        if ([successObject[@"result"] boolValue]) {
            NSArray *array = [MyFacilityModel mj_objectArrayWithKeyValuesArray:successObject[@"object"][@"page"][@"recordList"]];
            /*
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDeviceID"]) {
                MyFacilityModel *nvrModel = [[MyFacilityModel alloc] init];
                nvrModel.deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDeviceID"];
                nvrModel.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"NVRDeviceName"];
                nvrModel.modelImg = @"nvr.jpg";
            }
             */
            for (MyFacilityModel *model in array) {
                if (LCStrEqual(model.type, @"扫地机") || LCStrEqual(model.type, @"扫地机器人")) {
                    [self.bindArray addObject:model];
                } else {
                    [self.yooSeeArray addObject:model];
                }
            }
            
            #warning 做一些工作，比如后台数据和本地缓存匹配的问题
            [self dataMatchUpdate];
            [self.tableView reloadData];
        } else {
            //[self stopAnimating];
            [JPAlertView jp_alertViewInitWithTitle:@"提示" message:successObject[@"message"] cancelButton:nil otherButton:@"确定" actionBlock:^(NSInteger buttonIndex) {
                AppDelegate *temp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [temp againLogin];
            }];
            
            //退出摄像头
            LoginResult *loginResult = [UDManager getLoginInfo];
            [[NetManager sharedManager] logoutWithUserName:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON) {
                
                NSString *errorString = (NSString *)JSON;
                int error_code = errorString.intValue;
                switch (error_code) {
                    case NET_RET_LOGOUT_SUCCESS:
                    {
                        //退出成功
                        [UDManager setIsLogin:NO];
                        [JPUSHService setTags:nil alias:@"" fetchCompletionHandle:nil];
                        [JPUSHService setTags:nil alias:@"" callbackSelector:nil object:nil];
                        [[GlobalThread sharedThread:NO] kill];
                        [[FListManager sharedFList] setIsReloadData:YES];
                        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                        
                        //APP将返回登录界面时，注册新的token，登录时传给服务器
                        [[AppDelegate sharedDefault] reRegisterForRemoteNotifications];
                        
                        dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
                        dispatch_async(queue, ^{
                            [[P2PClient sharedClient] p2pDisconnect];
                            DLog(@"p2pDisconnect.");
                        });
                    }
                        break;
                        
                    default:
                    {
                        //退出失败
                        [self mb_show:@"退出失败"];
                    }
                        break;
                }
            }];
        }
        
    } FailBlock:^(id failObject) {
        
    }];
}
#pragma mark - 后台数据和本地缓存匹配的问题
-(void)dataMatchUpdate{
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
   
    NSMutableArray * addArray = [NSMutableArray arrayWithCapacity:0];//即将要添加到本地的数据数组
    NSMutableArray * deleteArray = [NSMutableArray arrayWithCapacity:0];//后台没有而本地有的数据要删除
    //12356
    //找出本地没有的数据
    for (int i = 0; i <self.yooSeeArray.count; i ++) {
        MyFacilityModel * myFacilityModel = self.yooSeeArray[i];
        Contact * contactTempModel;
        BOOL isSame = NO;
        for (int j = 0; j<self.contacts.count; j++) {
            Contact * contactModel = self.contacts[j];
            if ([myFacilityModel.res2 integerValue]==[contactModel.contactId integerValue]) {//同时有数据
                contactTempModel = contactModel;
                isSame = YES;
                break;
            }else{
                isSame = NO;
            }
        }
        if (isSame) {
            //[sameArray addObject:myFacilityModel];//后台和本地都有的数据
        }else{
            [addArray addObject:myFacilityModel];
        }
    }
    //self.sameArray = [NSMutableArray arrayWithArray:sameArray];
    //找出后台没有而本地有的数据给删除
    for (int i = 0; i<self.contacts.count; i ++) {
         Contact * contactModel = self.contacts[i];
         BOOL isHave = NO;
        for (int j = 0; j <self.yooSeeArray.count; j++) {
             MyFacilityModel * myFacilityModel = self.yooSeeArray[j];
            if ([myFacilityModel.res2 integerValue]==[contactModel.contactId integerValue]) {//同时有数据
                isHave = YES;
                break;
            }else{
                isHave = NO;
            }
        }
        if (isHave==NO) {
            [deleteArray addObject:contactModel];
        }
    }
    
    for (int i = 0; i < addArray.count; i ++) {
        MyFacilityModel * myFacilityModel = addArray[i];
        //自动的手动添加
            Contact *contact = [[Contact alloc] init];
            contact.contactId = [NSString stringWithFormat:@"%@",myFacilityModel.res2];//不同self.contactId;
            contact.contactName = [NSString stringWithFormat:@"%@",myFacilityModel.name];
            contact.contactPassword = [NSString stringWithFormat:@"%@",myFacilityModel.res1];
        
            if([contact.contactId characterAtIndex:0]!='0'){
                
                contact.contactPassword = [Utils GetTreatedPassword:[NSString stringWithFormat:@"%@",myFacilityModel.res1]];
                contact.contactType = CONTACT_TYPE_UNKNOWN;
            }else{
                contact.contactType = CONTACT_TYPE_PHONE;
            }
        
            [[FListManager sharedFList] myinsert:contact];
        
            [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
    }
    for (int i = 0; i <deleteArray.count; i ++) {
        Contact * contactModel = deleteArray[i];
        LoginResult *loginResult = [UDManager getLoginInfo];
        NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactModel.contactId];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //删除数据源中的数据
        [[FListManager sharedFList] deleteYoosee:contactModel];
    }
    //刷新数据
    NSLog(@"22222222222222222222");
    [self refreshContact];

}
#pragma mark - PushRenameDelegate
- (void)pushRenameVC:(NSString *)facilityId facilityName:(NSString *)facilityName
{
    RenameViewController *vc = [[RenameViewController alloc] init];
    vc.facilityId = facilityId;
    vc.facilityName = facilityName;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteAction:(NSString *)facilityId
{
    [self mb_normal];
    NSDictionary *infoDic = @{@"id":facilityId};
    [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceDelete parameters:infoDic successBlock:^(id successObject) {
        [self mb_stop];
        if ([successObject[@"result"] boolValue]) {
            [self refreshRobotList];
        } else {
            [self mb_show:successObject[@"message"]];
        }
    } FailBlock:^(id failObject) {
        [self mb_stop];
    }];
}

#pragma mark - ContactRenameDelegate
- (void)ContactRenameVC:(Contact *)facilityContact
{
    AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
    addContactNextController.isModifyContact = YES;
    addContactNextController.contactId = facilityContact.contactId;
    addContactNextController.modifyContact = facilityContact;
    [self.navigationController pushViewController:addContactNextController animated:YES];
}

- (void)ContactDeleteAction:(Contact *)facilityContact
{
    selectContact = facilityContact;
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_TAG_DELETE;
    [deleteAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_DELETE:
        {
            if(buttonIndex==1){
                
                [self mb_normal];
                NSDictionary *infoDic = @{@"id":selectModel.id};
                [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceDelete parameters:infoDic successBlock:^(id successObject) {
                    [self mb_stop];

                    if ([successObject[@"result"] boolValue]) {
                        
                        [self refreshRobotList];
                        //[self.bindArray removeObject:selectModel];
                        //[self.tableView reloadData];
                        
                    } else {
                        [self mb_stop];
                        [self mb_show:successObject[@"message"]];
                    }
                } FailBlock:^(id failObject) {
                    [self mb_stop];
                }];
            }
        }
            break;
        case ALERT_TAG_UPDATE:
        {
            if(buttonIndex==1){
                
                self.isShowProgressAlert = YES;
                [[P2PClient sharedClient] doDeviceUpdateWithId:self.selectedContact.contactId password:self.selectedContact.contactPassword];
            }else{
                [[P2PClient sharedClient] cancelDeviceUpdateWithId:self.selectedContact.contactId password:self.selectedContact.contactPassword];
            }
        }
            break;
            
        case 10000:
        {
            if (buttonIndex == 1) {
                [self mb_normal];
                NSDictionary *infoDic = @{@"id":selectModel.id};
                [[RequestManager shareRequestManager] requestDataType:RequestTypePOST urlStr:DeviceDelete parameters:infoDic successBlock:^(id successObject) {
                    [self mb_stop];
                    if ([successObject[@"result"] boolValue]) {
                        
                        [self refreshRobotList];
                        //[self.bindArray removeObject:selectModel];
                        //[self.tableView reloadData];
                    } else {
                        [self mb_show:successObject[@"message"]];
                    }
                } FailBlock:^(id failObject) {
                    [self mb_stop];
                }];
            }
        }
            break;
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
