//
//  StorageSettingController.m
//  Yoosee
//
//  Created by gwelltime on 14-11-8.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "StorageSettingController.h"
#import "Contact.h"
#import "MainController.h"
#import "AutoNavigation.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Constants.h"
#import "P2PEmailSettingCell.h"

#import "Toast+UIView.h"

#define MESG_FORMAT_SDCARD_SUCCESS 80
#define MESG_FORMAT_SDCARD_FAIL 81
#define MESG_SDCARD_NO_EXIST 82

@interface StorageSettingController ()
{
    BOOL _isShow;
}
@end

@implementation StorageSettingController
-(void)dealloc{
    [self.contact release];
    [self.tableView release];
    [self.sdTotalStorage release];
    [self.sdFreeStorage release];
    [self.usbTotalStorage release];
    [self.usbFreeStorage release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.isLoadingStorageInfo = YES;
    self.isLoadingStorageFormat = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[P2PClient sharedClient] getSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_SDCARD_INFO:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == 1) {
                    int storageCount = [[parameter valueForKey:@"storageCount"] intValue];
                    self.storageCount = storageCount;
                    self.sdCardID = [[parameter valueForKey:@"sdCardID"] intValue];
                    self.storageType = [[parameter valueForKey:@"storageType"] intValue];
                    
                    if (self.storageType == SDCARD) {
                        NSString * sdTotalStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"sdTotalStorage"]];
                        self.sdTotalStorage = sdTotalStorage;
                        NSString * sdFreeStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"sdFreeStorage"]];
                        self.sdFreeStorage = sdFreeStorage;
                    }else{
                        NSString * usbTotalStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"usbTotalStorage"]];
                        self.usbTotalStorage = usbTotalStorage;
                        NSString * usbFreeStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"usbFreeStorage"]];
                        self.usbFreeStorage = usbFreeStorage;
                    }
                    
                    if (storageCount > 1) {
                        self.storageCount = storageCount;
                        if (self.storageType == SDCARD) {NSString * usbTotalStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"usbTotalStorage"]];
                            self.usbTotalStorage = usbTotalStorage;
                            NSString * usbFreeStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"usbFreeStorage"]];
                            self.usbFreeStorage = usbFreeStorage;
                        }else{
                            NSString * sdTotalStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"sdTotalStorage"]];
                            self.sdTotalStorage = sdTotalStorage;
                            NSString * sdFreeStorage = [NSString stringWithFormat:@"%@M",[parameter valueForKey:@"sdFreeStorage"]];
                            self.sdFreeStorage = sdFreeStorage;
                        }
                    }
                    
                    self.isLoadingStorageInfo = NO;
                    [self.tableView reloadData];
                }else{
                    //1.存储器不存在，隐藏表格--->return 0;
                    self.storageCount = 0;
                    
                    [self.tableView reloadData];
                    //2.隐藏表格时，显示提示信息
                    if (_isShow) {
                        [self.view makeToast:CustomLocalizedString(@"no_storage", nil)];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            sleep(1);
                            //[self showDialog];
                            _isShow = !_isShow;
                            [self onBackPress];
                        });
                    }
                    
                }
            });
        }
            break;
        case RET_SET_SDCARD_FORMAT:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingStorageFormat = NO;
            if (result == MESG_FORMAT_SDCARD_SUCCESS) {
                //格式化成功
                [[P2PClient sharedClient] getSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:CustomLocalizedString(@"sd_format_success", nil)];
                });
            }else if (result == MESG_FORMAT_SDCARD_FAIL){
                //格式化失败(可能设备的原因)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:CustomLocalizedString(@"not_support_format", nil)];
                });
            }else{
                //SD卡不存在
            }
        }
            break;
        case RET_DEVICE_NOT_SUPPORT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view makeToast:CustomLocalizedString(@"device_not_support", nil)];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    usleep(800000);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self onBackPress];
                    });
                });
            });
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_SDCARD_INFO:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:CustomLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] getSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_SDCARD_INFO:%i",result);
        }
            break;
        case ACK_RET_SET_SDCARD_INFO:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:CustomLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] setSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword sdcardID:self.sdCardID];
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_SDCARD_INFO:%i",result);
        }
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isShow = YES;
    [self initComponent];
}

#define TOP_INFO_BAR_HEIGHT 80
#define TOP_HEAD_MARGIN 10

- (void) initComponent
{
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //导航
    self.navigationItem.title = CustomLocalizedString(@"storage_info",nil);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    
    UIView *topInfoBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, TOP_INFO_BAR_HEIGHT)];
    //[topInfoBarView setBackgroundColor:XWhite];
    UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(TOP_HEAD_MARGIN, TOP_HEAD_MARGIN, (TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3, TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)];
    //动态头像
    NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
    
    UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
    if(headImg==nil){
        //静态头像
        headImg = [UIImage imageNamed:@"ic_header.png"];
    }
    headImgView.image = headImg;
    
    [topInfoBarView addSubview:headImgView];
    [headImgView release];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_HEAD_MARGIN+(TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3+TOP_HEAD_MARGIN,0,width-(TOP_HEAD_MARGIN+(TOP_INFO_BAR_HEIGHT-TOP_HEAD_MARGIN*2)*4/3+TOP_HEAD_MARGIN),TOP_INFO_BAR_HEIGHT)];
    
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = XBlack;
    nameLabel.backgroundColor = XBGAlpha;
    [nameLabel setFont:XFontBold_18];
    
    //联系（设备）的名字
    nameLabel.text = self.contact.contactName;
    [topInfoBarView addSubview:nameLabel];
    [nameLabel release];
    
    [contentView addSubview:topInfoBarView];
    [topInfoBarView release];
    
    //水平线
    UIImageView *sep_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, TOP_INFO_BAR_HEIGHT, width, 1)];
    UIImage *sep = [UIImage imageNamed:@"separator_horizontal.png"];
    sep_view.image = sep;
    [contentView addSubview:sep_view];
    [sep_view release];
    
    //表格
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,TOP_INFO_BAR_HEIGHT+1, width, height-(TOP_INFO_BAR_HEIGHT+1)) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.storageCount = 2;
    tableView.delegate = self;
    tableView.dataSource = self;
    [contentView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    [self.view addSubview:contentView];
    [contentView release];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.storageCount == 1 && self.storageType == SDCARD) {
        return 2;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.storageCount * 2;
    }else{
        return 1;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"StorageCell";
    P2PEmailSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg = nil;
    UIImage *backImg_p = nil;
    
    [cell setRightIcon:@"ic_arrow.png"];
    
    switch (section) {
        case 0:
        {
            if ((self.storageCount*2) == 2) {
                NSString * totalStorageName = nil;
                NSString * freeStorageName = nil;
                NSString * totalStorage = nil;
                NSString * freeStorage = nil;
                if (self.storageType == SDCARD) {
                    totalStorageName = CustomLocalizedString(@"sd_card_capacity", nil);
                    freeStorageName = CustomLocalizedString(@"sd_card_rem_capacity", nil);
                    totalStorage = self.sdTotalStorage;
                    freeStorage = self.sdFreeStorage;
                }else{
                    totalStorageName = CustomLocalizedString(@"u_disk_capacity", nil);
                    freeStorageName = CustomLocalizedString(@"u_disk_rem_capacity", nil);
                    totalStorage = self.usbTotalStorage;
                    freeStorage = self.usbFreeStorage;
                }
                
                if(row==0){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                    
                    [cell setLeftLabelText:totalStorageName];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:totalStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }else if(row==1){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                    
                    [cell setLeftLabelText:freeStorageName];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:freeStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }
            }else{
                if(row==0){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                    
                    [cell setLeftLabelText:CustomLocalizedString(@"sd_card_capacity", nil)];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:self.sdTotalStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }else if(row==1){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                    
                    [cell setLeftLabelText:CustomLocalizedString(@"sd_card_rem_capacity", nil)];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:self.sdFreeStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }else if(row==2){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                    
                    [cell setLeftLabelText:CustomLocalizedString(@"u_disk_capacity", nil)];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:self.usbTotalStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }else{
                    backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                    
                    [cell setLeftLabelText:CustomLocalizedString(@"u_disk_rem_capacity", nil)];
                    if(self.isLoadingStorageInfo){
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:YES];
                        [cell setProgressViewHidden:NO];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }else{
                        [cell setRightLabelText:self.usbFreeStorage];
                        
                        [cell setLeftLabelHidden:NO];
                        [cell setRightLabelHidden:NO];
                        [cell setProgressViewHidden:YES];
                        
                        [cell setLeftIconHidden:YES];
                        [cell setRightIconHidden:YES];
                    }
                }
            }
        }
            break;
            
        case 1:
        {
            if (self.storageType == SDCARD) {
                backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                
                [cell setLeftLabelText:CustomLocalizedString(@"sd_card_format", nil)];
                if(self.isLoadingStorageFormat){
                    [cell setLeftLabelHidden:NO];
                    [cell setRightLabelHidden:YES];
                    [cell setProgressViewHidden:NO];
                    
                    [cell setLeftIconHidden:YES];
                    [cell setRightIconHidden:YES];
                }else{
                    [cell setLeftLabelHidden:NO];
                    [cell setRightLabelHidden:YES];
                    [cell setProgressViewHidden:YES];
                    
                    [cell setLeftIconHidden:YES];
                    [cell setRightIconHidden:NO];
                }
            }
        }
            break;
    }
    
    
    
    if((self.storageCount*2) == 2){
        if(row==1){
            backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
        }
    }
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"format_sd_card", nil) message:CustomLocalizedString(@"confirm_format", nil) delegate:self cancelButtonTitle:CustomLocalizedString(@"cancel", nil) otherButtonTitles:CustomLocalizedString(@"ok", nil), nil];
        [alertView show];
        [alertView release];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        self.isLoadingStorageFormat = YES;
        [self.tableView reloadData];
        
        [[P2PClient sharedClient] setSDCardInfoWithId:self.contact.contactId password:self.contact.contactPassword sdcardID:self.sdCardID];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

#define CONNECT_VIEW_LEFT_RIGHT_MARGIN 20

#pragma mark - 没有发现存储器（提示）
-(void)showDialog{
    CGFloat viewHeight = 175;
    
    UIImage *backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
    UIImageView *backImageView = [[UIImageView alloc] init];
    //拉伸的图片作用的对象（如：backImageView），其frame=父视图frame，但左右仍会离父视图左右边20像素????
    backImageView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT+TOP_INFO_BAR_HEIGHT+BAR_BUTTON_HEIGHT-10, self.view.frame.size.width, viewHeight);
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5,backImageView.frame.size.width, backImageView.frame.size.height-10)];
    label.backgroundColor = XBGAlpha;
    label.textColor = XBlack;
    label.font = XFontBold_18;
    label.text = CustomLocalizedString(@"no_storage", nil);
    label.textAlignment = NSTextAlignmentCenter;
    
    [backImageView addSubview:label];
    [label release];
    
    backImageView.transform = CGAffineTransformMakeScale(1, 0.1);
    [UIView transitionWithView:backImageView duration:0.1 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGAffineTransform transform1 = CGAffineTransformScale(backImageView.transform, 1, 10);
                        backImageView.transform = transform1;
                    }
                    completion:^(BOOL finished){
                        
                    }
     ];
    
    [self.view addSubview:backImageView];
    [backImageView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

