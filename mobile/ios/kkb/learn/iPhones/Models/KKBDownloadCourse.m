//
//  KKBDownloadModule.m
//  learn
//
//  Created by xgj on 14-7-2.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBDownloadCourse.h"

@implementation KKBDownloadCourse

- (id)initWith:(NSString *)courseId title:(NSString *)title {
    self = [super init];
    if (self) {
        self.courseId = courseId;
        self.title = title;
        self.downloadRecords = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)addRecord:(KKBDownloadRecord *)aRecord {
    [self.downloadRecords addObject:aRecord];
}

@end
