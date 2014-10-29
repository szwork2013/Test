//
//  KKBDownloadMonitor.m
//  learn
//
//  Created by zengmiao on 9/19/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBDownloadMonitor.h"
#import "KKBUserInfo.h"

@interface KKBDownloadMonitor ()
@property(strong, nonatomic, readwrite)
    AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation KKBDownloadMonitor

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDelegate:(id<KKBDownloadMonitorDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self customInit];
    }
    return self;
}

- (void)customInit {

    // setup reachability
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    self.reachabilityManager =
        [AFNetworkReachabilityManager managerForAddress:&address];
    [self.reachabilityManager startMonitoring];
    [self startMonitoringNetwork];

    // registerNotification
    [self addNotificationObserver];
}

#pragma mark - 网络变化处理
- (void)startMonitoringNetwork {
    __weak typeof(self) weakSelf = self;

    [self.reachabilityManager
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            //判断app是不是在前台 防止app在退出到后台10s内网络变化勿操作
            if (![[weakSelf class] runningInBackground]) {

                switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN: {
                    // Via 3G
                    //检测登录状态
                    if ([KKBUserInfo shareInstance].isLogin && [weakSelf.delegate shouldResumeTask]) {
                        [weakSelf.delegate pauseAllTaskInDB:weakSelf];
                        [UIAlertView alertViewWithTitle:@"提示"
                                                message:@"您当前处于非WiFi环境，下载"
                         @"可能产生额外的流量费用"
                                      cancelButtonTitle:@"取消下载"
                                      otherButtonTitles:@[ @"继续下载" ]
                                              onDismiss:^(int buttonIndex) {
                                                  if (buttonIndex == 0) {
                                                      [weakSelf.delegate resumeAllTaskInDB:weakSelf
                                                                           allowAlertVia3G:NO];
                                                  }
                                              }
                                               onCancel:^{}];
                    }
                   
                } break;

                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    if ([KKBUserInfo shareInstance].isLogin &&[weakSelf.delegate shouldResumeTask]) {
                        [weakSelf.delegate resumeAllTaskInDB:weakSelf
                                             allowAlertVia3G:YES];
                    }

                } break;

                case AFNetworkReachabilityStatusNotReachable: {
                    [weakSelf.delegate pauseAllTaskInDB:weakSelf];

                } break;

                case AFNetworkReachabilityStatusUnknown: {

                } break;

                default:
                    break;
                }
            }
        }];
}

#pragma mark - notification
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationEnterForground)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
}

- (void)applicationEnterForground {
    //开启所有数据库中暂停、下载失败的下载任务
    if ([KKBUserInfo shareInstance].isLogin &&[self.delegate shouldResumeTask]) {
        [self.delegate resumeAllTaskInDB:self allowAlertVia3G:YES];
    }
}

- (void)applicationEnterBackground {
    //暂停所有任务
    [self.delegate pauseAllTaskInDB:self];
}

+ (BOOL)runningInBackground {
    UIApplicationState state =
        [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);

    return result;
}
@end
