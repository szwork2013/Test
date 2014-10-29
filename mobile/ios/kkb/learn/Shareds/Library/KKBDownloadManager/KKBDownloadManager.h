//
//  KKBDownloadManager.h
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface KKBDownloadManager : AFHTTPRequestOperationManager

+ (BOOL)countInQueue;

/**
 *  初始化
 */
+ (void)setUpDownloadManager;

+ (NSString *)videoDownbloadPath;

#pragma mark - static download control
/**
 *  创建下载任务
 *
 *  @param items 需要创建的下载KKBDownloadTaskModel的集合
 */
+ (void)startDownloadWithItems:(NSArray *)items;

/**
 *  暂停下载任务
 *
 *  @param items 为KKBDownloadVideoModel集合
 */
+ (void)pauseDownloadWithItems:(NSArray *)items;

/**
 *  继续下载任务
 *
 *  @param items 为KKBDownloadVideoModel集合
 */
+ (void)resumeDownloadWithItems:(NSArray *)items;

/**
 *  继续下载任务
 *
 *  @param items      为KKBDownloadVideoModel集合
 *  @param alertVia3G 是检测网络提示
 */
+ (void)resumeDownloadWithItems:(NSArray *)items
                allowAlertVia3G:(BOOL)alertVia3G;

/**
 *  删除下载任务
 *
 *  @param items 为KKBDownloadVideoModel集合
 */
+ (void)deleteDownloadWithItems:(NSArray *)items;

+ (void)pauseAllDownloadingTaskInQueue;

@end
