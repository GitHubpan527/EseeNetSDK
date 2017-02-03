//
//  QRCodeNextController.h
//  Yoosee
//
//  Created by guojunyi on 14-9-18.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
#import "QRCodeController.h"//set wifi to add device by qr
#import "TopBar.h"//set wifi to add device by qr
#import "BaseViewController.h"
#import "AddDevicesPopTipsView.h"

#define ALERT_TAG_SET_FAILED 20161024
#define ALERT_TAG_SET_SUCCESS 20161024+1
@class WaitingPageView;
enum
{
    conectType_Intelligent,
    conectType_qrcode
};

@interface QRCodeNextController : BaseViewController<AddDevicesPopTipsViewDelegate>
@property (nonatomic,strong) NSString *uuidString;
@property (nonatomic,strong) NSString *wifiPwd;
@property (nonatomic,strong) UIImageView *qrcodeImageView;
@property (nonatomic,strong) WaitingPageView *smartKeyPromptView;

@property (nonatomic) BOOL isNotFirst;
@property (nonatomic) BOOL isWaiting;//YES表示发包设置wifi后，在等待局域网添加设备
@property (nonatomic) BOOL isFinish;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (nonatomic,assign) BOOL isRun;
@property (nonatomic) BOOL isShowSuccessAlert;
@property (nonatomic,assign) BOOL isPrepared;
@property (nonatomic) int conectType;        //1-二维码扫描 0-智能联机
@property (strong, nonatomic) QRCodeController *qrCodeController;//set wifi to add device by qr
@property (nonatomic,strong) UIButton *promptButton;//set wifi to add device by qr
@property (strong, nonatomic) TopBar *topBar;//set wifi to add device by qr
@property (strong, nonatomic) AddDevicesPopTipsView *addDevicesPopTipsView;
@property(nonatomic,unsafe_unretained)UIViewController* thePopViewController;
@end
