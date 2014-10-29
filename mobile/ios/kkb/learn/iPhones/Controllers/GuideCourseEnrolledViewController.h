//
//  GuideCourseAfterLoginViewController.h
//  learn
//  导学课enroll前未登录状况下点击enroll跳转到登陆页，登陆成功后直接跳转到导学课enroll后页面
//  Created by zxj on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBVideoPlayerViewController.h"
#import "RATreeView.h"
#import "KCourseItem.h"
#import "GuideCourseDownloadView.h"
#import "UMSocialControllerService.h"
#import "KKBShare.h"
#import "KKBCommentListView.h"

@interface GuideCourseEnrolledViewController
    : KKBVideoPlayerViewController <RATreeViewDataSource, RATreeViewDelegate,
                                    GuideCourseDownloadViewDelegate,
                                    UMSocialUIDelegate, KKBShareDelegate,
                                    UITableViewDataSource, UITableViewDelegate,
                                    KKBCommentListViewDelegate> {
    NSDictionary *allCourseInfoDic;
    NSArray *currentCommentArray;
    NSArray *courseTreeArray;
    UIImageView *commentCountImageView;
    UILabel *countLabel;
    NSMutableArray *buttonArray;
    NSMutableArray *_currentCourseVideoList;
    BOOL isCollectioned;
    NSMutableArray *courseItemIDs;
    NSMutableArray *courseVideoURLs;
}

@property(nonatomic, assign) BOOL shouldExpandTreeViewTargetSection;
@property(nonatomic, assign) BOOL playVideoImmediately;

@property(retain, nonatomic) NSDictionary *currentCourse;
@property(strong, nonatomic) UIView *bottomView;
@property(strong, nonatomic) RATreeView *treeView;
@property(strong, nonatomic) KCourseItem *courseItem;
@property(copy, nonatomic) NSString *courseId;
@property(nonatomic, copy) NSString *classId;
@property(nonatomic, copy) NSString *playRecordVideoId;
// 点击的周数
@property(nonatomic, assign) NSUInteger courseNumberOfWeeks;
// 以开放的周数
@property(nonatomic, copy) NSString *hasOpendWeeks;
@end
