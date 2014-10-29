//
//  KKBDownloadStorage.h
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBDownloadHeader.h"

@interface KKBDownloadStorage : NSObject

+ (instancetype)sharedInstacne;

+ (void)createTaskWithClass:(KKBDownloadClassModel *)classModel
                      video:(KKBDownloadVideoModel *)videoModel;

/*
+ (void)updateTaskWithVideoItem:(KKBDownloadVideoModel *)videoModel;
*/

+ (void)updateTaskWithVideoID:(int)videoID status:(VideoDownloadStatus)status;

+ (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                 downloadPath:(NSString *)downloadPath;

+ (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                     progress:(float)progress
                   totalBytes:(long long)totalBtyes
                  readedBytes:(long long)readedBytes;

+ (void)deleteTaskWithVideoID:(int)videoID;

+ (BOOL)shouldResumeTask;

@end
