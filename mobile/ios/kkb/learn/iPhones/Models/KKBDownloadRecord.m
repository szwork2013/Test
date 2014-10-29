//
//  KKBDownloadRow.m
//  learn
//
//  Created by xgj on 14-7-2.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBDownloadRecord.h"

@implementation KKBDownloadRecord

- (id)initWith:(NSString *)courseId
          fileName:(NSString *)fileName
             title:(NSString *)title
          progress:(float)progress
      progressText:progressText
    downloadStatus:(DownloadStatus)status
               url:(NSString *)url {
    self = [super init];
    if (self) {
        self.fileName = fileName;
        self.courseId = courseId;
        self.title = title;
        self.progress = progress;
        self.progressText = progressText;
        self.status = status;
        self.url = url;
    }

    return self;
}

@end
