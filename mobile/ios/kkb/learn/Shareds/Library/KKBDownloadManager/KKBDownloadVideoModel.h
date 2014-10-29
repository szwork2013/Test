//
//  KKBDownloadVideoModek.h
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBDownloadHeader.h"

@interface KKBDownloadVideoModel : NSObject

@property (nonatomic, assign) VideoDownloadStatus status;

@property (strong ,nonatomic) NSNumber *videoID;
@property (nonatomic, copy) NSNumber *position;

@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, copy) NSString *tmpPath;
@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, copy) NSString *videoTitle;

@property (strong ,nonatomic) NSNumber *totalBytesReaded;//已读字节
@property (strong ,nonatomic) NSNumber *totalBytesFile;//总字节数

@property (nonatomic, assign) float progress;

#pragma mark - 页面属性
@property (nonatomic, assign) BOOL isSelected;

@end
