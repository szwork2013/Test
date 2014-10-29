//
//  CourseInFavorItem.m
//  learn
//
//  Created by xgj on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseInFavorItemModel.h"
#import "NSDate+DateTools.h"

@implementation CourseInFavorItemModel

- (id)init {
    self = [super init];
    if (self) {
    }

    return self;
}

- (NSString *)updateInfo {
    if (!_updateInfo) {
        NSString *name = @"未知";
        if (_courseTitle) {
            name = _courseTitle;
        }
        if (self.isOpenCourse) {
            _updateInfo =
                [NSString stringWithFormat:@"公开课《%@"
                                           @"》的老师又往里面加了些"
                                           @"干货呦，快来看看吧",
                                           _courseTitle];
        } else {
            _updateInfo =
                [NSString stringWithFormat:@"导学课《%@"
                                           @"》开了新的班次，让我们"
                                           @"一起开课吧！",
                                           _courseTitle];
        }
    }
    return _updateInfo;
}

- (NSString *)updateTime {
    if (!_updateTime) {
        //        long timeLong = [self.time longValue];
        //        NSDate *date = [NSDate
        //        dateWithTimeIntervalSince1970:timeLong];
        // TODO: <#byzm#>
        _updateTime = @"08:00";
    }
    return _updateTime;
}

@end
