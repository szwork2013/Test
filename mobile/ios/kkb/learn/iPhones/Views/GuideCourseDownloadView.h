//
//  GuideCourseDownloadView.h
//  learn
//
//  Created by zxj on 14-8-6.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RATreeView.h"
@protocol GuideCourseDownloadViewDelegate <NSObject>

- (void)downloadCoverViewClick;

@end

@interface GuideCourseDownloadView
    : UIView <RATreeViewDataSource, RATreeViewDelegate>

@property(nonatomic, strong) NSDictionary *currentCourse;
@property(nonatomic, strong) NSArray *currentCourseVideoList;
@property(nonatomic, strong) NSString *courseId;

@property(nonatomic, assign) id<GuideCourseDownloadViewDelegate> delegate;
- (void)initWithUI;
@end
