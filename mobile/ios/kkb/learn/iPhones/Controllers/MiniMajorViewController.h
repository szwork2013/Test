//
//  MiniMajorViewController.h
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBVideoPlayerViewController.h"
#import "KKBLoadingFailedView.h"
#import "UMSocialControllerService.h"

#define CourseStatusNew @"new"

@interface MiniMajorViewController
    : KKBVideoPlayerViewController <UITableViewDataSource, UITableViewDelegate,
                                    UMSocialUIDelegate> {
    UILabel *introductionLabel;
    UIImageView *certificat;
    UITableView *coursesTableView;
    UIButton *enrollCourseButton;
    
    NSArray *subCoursesData; //里面存储的是来自网络的原始数据
}

@property(nonatomic, strong) NSString *majorId;
@property(nonatomic, strong) NSString *majorTitle;

@property(nonatomic, strong) NSDictionary *currentMajor;

@end
