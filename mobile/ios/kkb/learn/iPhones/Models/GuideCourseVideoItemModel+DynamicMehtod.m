//
//  GuideCourseVideoItemModel+DynamicMehtod.m
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "GuideCourseVideoItemModel+DynamicMehtod.h"

@implementation GuideCourseVideoItemModel (DynamicMehtod)

- (NSString *)title {

    return @"视频学习";
}

- (float)videoProgress {
    int videoTotalCount = [self.video_count intValue];
    int videoWatchedCount = [self.view_count intValue];

    float courseLearnProgress = (float)videoWatchedCount / videoTotalCount;
    if (isnan(courseLearnProgress)) {
        courseLearnProgress = 0.0;
    }

    return courseLearnProgress;
}

@end
