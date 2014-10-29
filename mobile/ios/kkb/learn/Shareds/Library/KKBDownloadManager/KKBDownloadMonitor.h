//
//  KKBDownloadMonitor.h
//  learn
//
//  Created by zengmiao on 9/19/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

@class KKBDownloadMonitor;

@protocol KKBDownloadMonitorDelegate <NSObject>

- (void)pauseAllTaskInDB:(KKBDownloadMonitor *)monitor;
- (void)resumeAllTaskInDB:(KKBDownloadMonitor *)monitor
          allowAlertVia3G:(BOOL)alertVia3G;
- (BOOL)shouldResumeTask;

@end

@interface KKBDownloadMonitor : NSObject

@property(nonatomic, assign) id<KKBDownloadMonitorDelegate> delegate;
@property(strong, nonatomic, readonly)
    AFNetworkReachabilityManager *reachabilityManager;

- (instancetype)initWithDelegate:(id<KKBDownloadMonitorDelegate>)delegate;

@end
