//
//  GCDManager.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/9/7.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "GCDManager.h"

static GCDManager *manager = nil;

@implementation GCDManager

{
    // 这个socket用来做发送使用 当然也可以接收
    GCDAsyncSocket *sendTcpSocket;
    /** 定时器保持连接 */
    NSTimer *timer;
}

+ (GCDManager *)shareManager
{
    @synchronized(self) {
        if (!manager) {
            manager = [[GCDManager alloc] init];
            [manager createClientTcpSocket];
        }
        return manager;
    }
}

- (void)createClientTcpSocket {
    dispatch_queue_t dQueue = dispatch_queue_create("client tdp socket", NULL);
    // 1. 创建一个 udp socket用来和服务端进行通讯
    sendTcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dQueue socketQueue:nil];
    // 2. 连接服务器端. 只有连接成功后才能相互通讯 如果60s连接不上就出错
    NSString *host = @"101.200.214.66";
    uint16_t port = 1999;
    [sendTcpSocket connectToHost:host onPort:port withTimeout:-1 error:nil];
    // 连接必须服务器在线
    
}

#pragma mark - 代理方法表示连接成功/失败 回调函数
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"tcp连接成功");
}
// 如果对象关闭了 这里也会调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"连接失败 %@", err);
    // 断线重连
    NSString *host = @"101.200.214.66";
    uint16_t port = 1999;
    [sendTcpSocket connectToHost:host onPort:port withTimeout:-1 error:nil];
}
#pragma mark - 消息发送成功 代理函数
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//    NSLog(@"消息发送成功");
    // 等待数据来啊
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (self.block && data) {
        self.block(data);
    }
    
//    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"接收到服务器返回的数据 tcp %@", resultDic);
    
    //接收数据后还要执行接收方法
    [sendTcpSocket readDataWithTimeout:-1 tag:tag];

    
}
- (void)sendMessageToServer {
    
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    
    NSString *JSString = [NSString stringWithFormat:@"U0%@\r\n",userModel.id];
    NSData *data = [JSString dataUsingEncoding:NSUTF8StringEncoding];
    // 发送消息 这里不需要知道对象的ip地址和端口
    [sendTcpSocket writeData:data withTimeout:-1 tag:100];
    
    
    /** 保持连接 */
    timer = [NSTimer lc_scheduledTimerWithTimeInterval:30 block:^{
        
        NSString *JSString = @"U21\r\n";
        NSData *data = [JSString dataUsingEncoding:NSUTF8StringEncoding];
        [sendTcpSocket writeData:data withTimeout:-1 tag:100];
        
    } repeats:YES];
  
}
- (void)sendMessageToServerAgain:(NSString *)deviceId {
    
    NSString *JSString = [NSString stringWithFormat:@"U1%@\r\n",deviceId];
    
    NSData *data = [JSString dataUsingEncoding:NSUTF8StringEncoding];
    [sendTcpSocket writeData:data withTimeout:-1 tag:100];
}
- (void)sendDataPackageToServerWithCommand:(NSString *)command {
    NSString *JSString = [NSString stringWithFormat:@"%@\r\n",command];
    
    NSData *data = [JSString dataUsingEncoding:NSUTF8StringEncoding];
    [sendTcpSocket writeData:data withTimeout:-1 tag:100];
    
}
- (void)sendRoomCleanTheAreaToServerWithCommand:(NSString *)command {
    NSString *JSString = [NSString stringWithFormat:@"%@\r\n",command];
    
    NSData *data = [JSString dataUsingEncoding:NSUTF8StringEncoding];
    [sendTcpSocket writeData:data withTimeout:-1 tag:100];
}

- (void)objectRelease
{
    [timer invalidate];
    timer = nil;
    
    // 关闭套接字
    [sendTcpSocket disconnect];
    sendTcpSocket = nil;
}

@end
