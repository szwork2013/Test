//
//  KKBDownloadSaveCount.m
//  VideoDownload
//
//  Created by zengmiao on 9/4/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadSaveCount.h"
const float maxSecond = 1;

@interface KKBDownloadSaveCount ()

@property (nonatomic, assign) NSTimeInterval lastTimeInterval;

@end

@implementation KKBDownloadSaveCount


- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastTimeInterval = 0.0;
    }
    return self;
}

- (BOOL)allowSaveToDB {
    BOOL allow = NO;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    if (_lastTimeInterval == 0.0) {
        _lastTimeInterval = timeInterval;
    }
    if ((timeInterval - _lastTimeInterval) > maxSecond) {
        allow = YES;
        _lastTimeInterval = timeInterval;
//        DDLogInfo(@"timeInterval:%f",(timeInterval - _lastTimeInterval));
    }
    
    return allow;
}

@end
