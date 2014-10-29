//
//  KKBDownloadVideoModek.m
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadVideoModel.h"

@implementation KKBDownloadVideoModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"KKBDownloadVideoModel&&&VideoID:%@&&&VideoTitle:%@&&&VideoURL:%@&&&downloadPath:%@&&&", self.videoID,self.videoTitle,self.videoURL,self.downloadPath];
}

@end
