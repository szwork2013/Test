//
//  KKBDownloadRow.h
//  learn
//
//  Created by xgj on 14-7-2.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UNKNOWN,
    READY,
    DOWNLOADING,
    PAUSED,
    FINISHED,
    FAILED
} DownloadStatus;

@interface KKBDownloadRecord : NSObject

@property(strong, nonatomic) NSString *fileName;
@property(strong, nonatomic) NSString *url;
@property(strong, nonatomic) NSString *courseId;
@property(strong, nonatomic) NSString *title;
@property(assign) float progress;
@property(strong, nonatomic) NSString *progressText;
@property(assign, nonatomic) DownloadStatus status;
@property(assign, nonatomic) BOOL isSelected;

- (id)initWith:(NSString *)courseId
          fileName:(NSString *)fileName
             title:(NSString *)title
          progress:(float)progress
      progressText:progressText
    downloadStatus:(DownloadStatus)status
               url:(NSString *)url;

@end
