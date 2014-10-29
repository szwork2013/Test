//
//  PublicClassViewController.h
//  learn
//
//  Created by 翟鹏程 on 14-6-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "BottomView.h"
#import "PublicDownloadView.h"
#import "KKBVideoPlayerViewController.h"
#import "UMSocialControllerService.h"
#import "KKBShare.h"
#import "KKBCommentListView.h"

@interface PublicClassViewController
    : KKBVideoPlayerViewController <
          UIWebViewDelegate, PublicDownloadViewDelegate, UMSocialUIDelegate,
          KKBShareDelegate, UITableViewDataSource, UITableViewDelegate,
          KKBCommentListViewDelegate>

@property(strong, nonatomic) IBOutlet UIView *introView;
@property(retain, nonatomic) IBOutlet UIImageView *infoView;
@property(retain, nonatomic) IBOutlet UIView *coverView;

@property(retain, nonatomic) IBOutlet UIWebView *infoWebView;

@property(nonatomic, strong) NSMutableArray *myCoursesDataArray;
@property(nonatomic, strong) NSArray *currentUnitList;
@property(nonatomic, strong) NSMutableArray *currentSecondLevelUnitList;
@property(nonatomic, strong) NSArray *currentSecondLevelVideoList;
@property(nonatomic, strong) NSIndexPath *selectIndex;
@property(nonatomic, copy) NSString *selectVideoURL;
@property(nonatomic, copy) NSString *courseName;
@property(nonatomic, copy) NSString *courseImage;
@property(assign) BOOL isOpen;

@property(nonatomic, strong) NSMutableDictionary *progressLabelDict;
@property(nonatomic, strong) NSMutableDictionary *downloadBtnDict;

// new
@property(nonatomic, strong) NSDictionary *currentCourse;
@property(nonatomic, strong) NSArray *currentCourseVideoList;

@property(nonatomic, strong) NSString *playRecordVideoId;
@property(nonatomic, assign)
    NSTimeInterval lastWatchRecord; //上次播放时间从动态页面进用

@property(weak, nonatomic) IBOutlet PublicDownloadView *publicDownloadView;
@property(weak, nonatomic) BottomView *bottomView;

@end
