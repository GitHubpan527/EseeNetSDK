//
//  MyFacilityViewController.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/11.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "BaseViewController.h"

//ljp main
#import "P2PClient.h"
#import "AutoTabBarController.h"
#import "Contact.h"//重新调整监控画面

@protocol MainDelegate <NSObject>

@optional
- (void)P2PClientReady:(NSDictionary*)info;
-(void)mainControllerMonitorReject:(NSDictionary*)info;
@end

//ljp contact
#import "ContactCell.h"
#import "PopoverView.h"
#define ALERT_TAG_DELETE 0

#define kOperatorViewTag 15236
#define kBarViewTag 32536
#define kButtonsViewTag 32533

#define kOperatorBtnTag_Chat 23581
#define kOperatorBtnTag_Message 23582
#define kOperatorBtnTag_Modify 23583
#define kOperatorBtnTag_Monitor 23584
#define kOperatorBtnTag_Playback 23585
#define kOperatorBtnTag_Control 23586
#define kOperatorBtnTag_WeakPwd 23587
#define kOperatorBtnTag_UpdateDevice 23588
#define kOperatorBtnTag_initDevicePwd 23589

@class  Contact;
@class TopBar;
@class DXPopover;

@interface MyFacilityViewController : BaseViewController<P2PClientDelegate,UITableViewDataSource,UITableViewDelegate,OnClickDelegate,PopoverViewDelegate>

//ljp main
@property (nonatomic) BOOL isShowP2PView;
@property (nonatomic) BOOL isShowingMonitorController;
@property (nonatomic,strong) NSString * contactName;
@property (nonatomic,strong) Contact * contact;//重新调整监控画面
@property (nonatomic, assign) id<MainDelegate> mainControllerDelegate;

-(void)setUpCallWithId:(NSString*)contactId password:(NSString*)password callType:(P2PCallType)type;
-(void)dismissP2PView;
-(void)dismissP2PView:(void (^)())callBack;

//ljp contact
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *contacts;
@property (nonatomic) BOOL isInitPull;
@property (strong, nonatomic) NSIndexPath *curDelIndexPath;
@property (strong, nonatomic) Contact *selectedContact;

@property (strong, nonatomic) UIView *netStatusBar;

@property (strong, nonatomic) UIButton *localDevicesView;
@property (strong, nonatomic) UILabel *localDevicesLabel;
@property (nonatomic) CGFloat tableViewOffset;
@property (nonatomic,strong) UIView *emptyView;

@property (strong, nonatomic) TopBar *topBar;
@property (strong, nonatomic) DXPopover *popover;

@property (assign) BOOL isShowProgressAlert;
@property (strong, nonatomic) UIView *progressMaskView;//设备检查更新
@property (strong, nonatomic) UILabel *progressLabel;//设备检查更新
@property (strong, nonatomic) UIView *progressView;//设备检查更新
@property (strong,nonatomic)NSTimer * timer;

@end
