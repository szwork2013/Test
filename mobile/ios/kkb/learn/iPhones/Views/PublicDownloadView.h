//
//  PublicDownloadView.h
//  learn
//
//  Created by 翟鹏程 on 14-7-30.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PublicDownloadViewDelegate <NSObject>

- (void)downloadCoverViewClick;

@end

@interface PublicDownloadView
    : UIView <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSDictionary *currentCourse;
@property(nonatomic, strong) NSArray *currentCourseVideoList;

@property(nonatomic, assign) id<PublicDownloadViewDelegate> delegate;

- (void)initWithUI;
@end
