//
//  RJSocket.m
//  testForCocopod
//
//  Created by RJ_engel on 16/10/28.
//  Copyright © 2016年 ruizi_G. All rights reserved.
//

#import "RJSocket.h"
#import <GCDAsyncSocket.h>
#import "NSString+jsonString.h"
#import "NSDictionary+jsonData.h"
#import "RootOperation.h"
#import "FMDBManager.h"

#define IPADRESS @"120.27.53.216"
#define OTHERPORT 8800
#define RJCAR @"rjcar"  //


@interface RJSocket () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *localSocket;
@property (nonatomic, strong) GCDAsyncSocket *remoteSocket;
/** op*/
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

static RJSocket *socketManager = nil;

@implementation RJSocket

+ (instancetype)defaultScoket
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (socketManager == nil) {
            socketManager = [[self alloc] init];
        }
    });
    return socketManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (socketManager == nil) {
        socketManager = [super allocWithZone:zone];
    }
    return socketManager;
}

- (void)initSocket
{
    if (self.localSocket == nil) {
        self.localSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    if (self.localSocket.isConnected == 0) {
        NSError *error;
        BOOL connectResult;
        connectResult = [self.localSocket connectToHost:IPADRESS onPort:OTHERPORT withTimeout:5.0 error:&error];
        if(!connectResult)
        {
            NSLog(@"<Socket Error>:%@",error);
        }
        else
        {
            NSLog(@"打开资源端口\n");
        }
    }
}


//确认连接
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    if(sock == self.localSocket)
    {
        NSLog(@"已经连接到资源服务器 %@",host);
        NSArray *a = [NSArray arrayWithObject:@"BBS"];
        NSDictionary *b = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:18],@"APPID",@"FLYAPP",@"APPNAME",@"086",@"COUNTRYCODE",RJCAR,@"DOMAIN",a,@"SERVICES",@"APP",@"TERMINALTYPE",@"",@"RUNTYPE",nil];
        
        [self.remoteSocket writeData:[b posJsonData] withTimeout:-1 tag:395];
        [self.remoteSocket readDataWithTimeout:-1 tag:395];
        
    }
    else
    {
        //将登录信息存入本地数据库
        DeviceModel *dm = [[DeviceModel alloc] init];
        dm.ip = host, dm.port = port;
        [[FMDBManager shareManager] insertModel:dm];
        NSLog(@"已经连接到BBS服务器 ");
        // 获取滚动界面
        [self startThread];
    }
    
}

- (void)startThread{
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:nil];
    NSLog(@"start thread");
}

- (void)test{
    while (1) {
        NSLog(@"....");
    }
}

//未连接服务器
int BBSnum = 0;
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock == self.localSocket)
    {
        NSLog(@"未连接资源服务器 %d",self.localSocket.isConnected);
        //数据库 连BBS
        
        DeviceModel *dm = [[FMDBManager shareManager] selectModel];
        
        //从本地数据库获取精华信息
        if (!self.remoteSocket)
        {
            self.remoteSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        }
        [self.remoteSocket connectToHost:dm.ip onPort:dm.port withTimeout:5.0 error:nil];
        self.localSocket = nil;
    }
    else
    {
        BBSnum++;
        if (BBSnum < 3) {
            NSLog(@"未连接BBS服务器  %d",self.localSocket.isConnected);
            //再请求BBS 3次  最后用数据库 BBS
            NSArray *a = [NSArray arrayWithObject:@"BBS"];
            NSDictionary *b = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:18],@"APPID",@"FLYAPP",@"APPNAME",@"086",@"COUNTRYCODE",RJCAR,@"DOMAIN",a,@"SERVICES",@"APP",@"TERMINALTYPE",@"",@"RUNTYPE",nil];
            [self.remoteSocket writeData:[b posJsonData] withTimeout:-1 tag:395];
            [self.remoteSocket readDataWithTimeout:-1 tag:395];
        }
        else if(BBSnum == 3)
        {
            
            if (!self.localSocket)
            {
                self.localSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                //_mysocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            }
//            [self.localSocket connectToHost:ip onPort:port withTimeout:5.0 error:nil];
        }
        else if (BBSnum > 3)
        {
            NSLog(@"彻底连不上BBS服务器");
            BBSnum = 0;
            return;
        }
    }
    
}
//did receive
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // DLog(@"did receive %ld   %ld  %d ",tag,(unsigned long)data.length,numCs);
    NSLog(@"did receive %ld   %ld  ",tag,(unsigned long)data.length);
    
    if(395 == tag)
    {
        NSMutableString *a = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"<395>:%@",a);
        a = [[a substringFromIndex:13] mutableCopy];
        a = [[a substringToIndex:(a.length-2)] mutableCopy];;
        NSDictionary *jsonDic = [a dictionaryFromJsonString];
        
        NSString *result = [jsonDic objectForKey:@"RESULT"];
        if ([result isEqualToString:@"OK"])
        {
            NSArray *services = [jsonDic objectForKey:@"SERVICES"];
            NSString *Ip = [[services objectAtIndex:0] objectForKey:@"IP"];
            NSString *port = [NSString stringWithFormat:@"%@",[[services objectAtIndex:0] objectForKey:@"PORT"]];
            
            if (!self.remoteSocket)
            {
                self.remoteSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            }
            
            [self.remoteSocket connectToHost:Ip onPort:[port integerValue] withTimeout:5.0 error:nil];
        }
    }
//    if (_isBBS)
//    {
//        if (recvbufData == nil)
//        {
//            DLog(@"初始化存储字符串");
//            recvbufData = [[NSMutableData alloc] initWithCapacity:1];
//        }
//        [recvbufData appendData:data];
    
        [self.localSocket readDataWithTimeout:-1 tag:tag];
        //        NSMutableString *halfStr = [[NSMutableString alloc] initWithData:recvbufData encoding:NSASCIIStringEncoding];
        //        halfStr =  [[halfStr substringFromIndex:9] mutableCopy];
        //        NSInteger length = 0;
        //        for(int i = 1; i<10; i++)
        //        {
        //            if ([[halfStr substringWithRange:NSMakeRange(i, 2)] isEqualToString:@"\r\n"])
        //            {
        //                length = [[halfStr substringWithRange:NSMakeRange(0, i)] integerValue];
        //
        //                if(recvbufData.length == length + i + 12)
        //                {
        //                }
        //                else
        //                {
        //                    
        //                }
        //            }
        //        }
//    }
    
}



#pragma mark - Setter & Getter

- (NSOperationQueue *)queue
{
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

@end
















