//
//  LingYunManager.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/2.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "LingYunManager.h"

#import "hci_sys.h"
#import "hci_asr_recorder.h"
#import "AccountInfo.h"
#import "CommonTool.h"

static LingYunManager *manager = nil;

@implementation LingYunManager

@synthesize asrDlg;
@synthesize asrCapKey;

+ (LingYunManager *)shareManager
{
    @synchronized(self) {
        if (!manager) {
            manager = [[LingYunManager alloc] init];
            [manager initLingYun];
        }
        return manager;
    }
}

- (void)initLingYun
{
    string strAccountInfo;
    bool bRet = GetAccountInfo(@"AccountInfo", @"txt", strAccountInfo);
    if(!bRet)
    {
        printf("\nAccount information not found in AccountInfo.txt\n");
    }
    string capKey;
    bRet = GetCapKey(@"AccountInfo", @"txt", capKey);
    if (!bRet) {
        printf("\ncapKey not found in AccountInfo.txt\n");
        return;
    }
    
    HCI_ERR_CODE errCode = HCI_ERR_NONE;
    //默认日志级别为0，调试阶段建议打开日志，级别设置为5，开发者也可以设置其他如日志文件大小，日志文件个数等配置，其中日志路径必须是存在的可读写的路径
    string strLogConfig = string("logLevel=5,logFilePath=") + GetIosDocumentPath();;
    //授权文件路径，必须是存在的可读写的路径
    string strAuthPath = string(",authPath=") + GetIosDocumentPath();
    string strConfig = strAccountInfo + strLogConfig + strAuthPath;
    errCode = hci_init(strConfig.c_str());
    if (errCode != HCI_ERR_NONE) {
        printf("hci_init return %d\n",errCode);
        return;
    }
    printf("hci_init success\n");
    
    //检测授权,必要时到云端下载授权。此处需要注意的是，这个函数只是通过检测授权是否过期来判断是否需要进行
    //获取授权操作，如果在开发调试过程中，授权账号中新增了灵云sdk的能力，请到hci_init传入的authPath路径中
    //删除HCI_AUTH文件。否则无法获取新的授权文件，从而无法使用新增的灵云能力。
    if (!self.CheckAndUpdateAuth)
    {
        hci_release();
        printf("check and update auth failed\n");
        return;
    }
    printf("check and update auth success\n");
    
    //判断capkey是否可用
    if (!IsCapkeyEnable(capKey))
    {
        //如果正确的填写了capkey，但是capkey不可用，可以尝试性的做一次hci_check_auth()操作
        printf("capKey cannot be used!\n");
        hci_release();
        return;
    }
    printf("capKey can be used\n");
    asrCapKey = [NSString stringWithUTF8String:capKey.c_str()];
    NSLog(@"asrCapKey:%@",asrCapKey);
    
    //asr-ui 模块
    //得到一个单例控件对象
    asrDlg = [JTAsrRecorderDialog sharedInstance];
    //初始化asr能力，如果使用本地能力，会有如下配置
    //若使用云端能力，则此配置可以为null或“”
    NSString *strSourcePath =[[NSBundle mainBundle] pathForResource:@"data" ofType:Nil];
    NSString *initParam = [NSString stringWithFormat:@"initCapKeys=%@,datapath=%@",asrCapKey,strSourcePath];
    
    //初始化录音机
    [asrDlg initWithConfig:initParam andDelegate:self];
}

- (bool) CheckAndUpdateAuth
{
    /* 检查授权是否正确，必要时会下载云端授权，授权过期后7天内继续有效
     
     更新授权文件有如下两种做法：
     
     1. 在 hci_init() 时将 autoCloudAuth 配置项设为 yes，系统会启动一个后台线程，
     定期检查授权的过期时间， 如果授权过期时间已到，会自动更新授权文件。此为缺省配置。
     
     2. 如果 autoCloudAuth 设为 no，则需要开发者自行在适当的时机通过 hci_check_auth() 来更新授权。
     
     自动更新授权的方式在PC等联网条件不受限的情况下会工作得很好，但对于移动终端应用等对网络条件
     和流量比较敏感的情况来说， 最好由开发者自行决定更新授权的时机，这样可控性更强，例如可以在WiFi
     打开的时候才进行授权更新等等。
     
     开发者可以使用 hci_get_auth_expire_time() 获取当前授权过期时间，当此函数返回错误或者授权过期
     时间已经快到了或者已经过期的时候， 再调用 hci_check_auth()函数到云端下载授权文件。例如，下面
     的示例会在授权过期后检测并下载新的授权。
     */
    
    int64 nExpireTime;
    int64 nCurTime = (int64)time( NULL );
    HCI_ERR_CODE errCode = hci_get_auth_expire_time( &nExpireTime );
    if( errCode == HCI_ERR_NONE )
    {
        if( nExpireTime < nCurTime )// “—æ≠π˝∆⁄
        {
            errCode = hci_check_auth();
            if( errCode == HCI_ERR_NONE )
            {
                printf( "check auth success\n" );
                return true;
            }
            else
            {
                printf( "check auth failed %d\n", errCode );
                return false;
            }
        }
        else
        {
            printf( "check auth success\n" );
            return true;
        }
    }
    else if( errCode ==	HCI_ERR_SYS_AUTHFILE_INVALID )
    {
        errCode = hci_check_auth();
        if( errCode == HCI_ERR_NONE )
        {
            printf( "check auth success\n" );
            return true;
        }
        else
        {
            printf( "check auth failed %d\n", errCode );
            return false;
        }
    }
    else
    {
        printf( "check auth failed %d\n", errCode );
        return false;
    }
    return true;
}

//////////////////////////////////////////////////////////////////////////
bool IsCapkeyEnable(const string &capKey)
{
    //获取一下授权中全部可用能力列表
    CAPABILITY_LIST capbility_list;
    HCI_ERR_CODE errCode = hci_get_capability_list( NULL, &capbility_list);
    if (errCode != HCI_ERR_NONE)
    {
        printf("hci_get_capability_list failed return %d\n",errCode);
        return false;
    }
    
    //判断传入的capbility_array 中的能力是否在可用能力列表中
    bool is_capkey_enable = false;
    for (size_t capbility_index = 0; capbility_index < capbility_list.uiItemCount; capbility_index++)
    {
        if (capKey == string(capbility_list.pItemList[capbility_index].pszCapKey))
        {
            is_capkey_enable = true;
            break;
        }
    }
    //释放可用能力列表
    hci_free_capability_list(&capbility_list);
    return is_capkey_enable;
}

#pragma mark - delegate

- (void) onError: (HCI_ERR_CODE) errCode errInfo:(NSString *)errInfo
{
    NSLog(@"onError:%d  errDetail:%@",errCode,errInfo);
}

- (void) onResult: (ASR_RECOG_RESULT *) asrRecogResult
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"识别结果："];
    
    for (int i = 0; i < (int)asrRecogResult->uiResultItemCount; ++i)
    {
        //一般只有一个结果
        ASR_RECOG_RESULT_ITEM& item = asrRecogResult->psResultItemList[i];
        [result appendString:@"\n\t"];
        [result appendString:[NSString stringWithUTF8String:item.pszResult]];
    }
    NSLog(@"%@",result);
    if (self.block) {
        self.block(result);
    }
    /*
    if (result.length != 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:result delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
     */
}

#pragma mark - 开始录音
- (void)startSpeak
{
    //启动录音机
    NSString *strGrammar = nil;
    NSString * recogConfig = [NSString stringWithFormat:@"capkey=%@,audioformat=pcm16k16bit",asrCapKey];
    
    if ([asrCapKey rangeOfString:@"grammar"].location != NSNotFound) {
        //若使用语法识别，需配置 isFile 和 grammarType 两个配置项。
        recogConfig = [recogConfig stringByAppendingString:@",isFile=yes,grammarType=wordlist"];
        strGrammar = [[NSBundle mainBundle] pathForResource:@"wordlist_utf8" ofType:@"txt"];
    }
    
    [asrDlg showWithConfig:recogConfig andGrammar:strGrammar];
}

- (void)dealloc
{
    hci_release();
    self.asrCapKey = nil;
    self.asrDlg = nil;
}

@end
