//
//  MiniMajorCourse.m
//  learn
//
//  Created by xgj on 14-7-14.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MiniMajorCourse.h"

@implementation MiniMajorCourse

- (id)init {
    self = [super init];
    if (self) {
        _imageUrl = [[NSString alloc] init];
        _title = [[NSString alloc] init];
        _detail = [[NSString alloc] init];
    }

    return self;
}

- (id)initWith:(NSString *)imageUrl
     withTitle:(NSString *)title
     andDetail:(NSString *)detail
        onLine:(BOOL)online {
    self = [super init];
    if (self) {
        _imageUrl = imageUrl;
        _title = title;
        _detail = detail;
        _isOnline = online;
    }

    return self;
}

@end
