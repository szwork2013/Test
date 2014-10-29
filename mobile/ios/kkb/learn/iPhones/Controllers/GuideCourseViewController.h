//
//  GuideCourseViewController.h
//  learn
//
//  Created by zxj on 14-7-30.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBVideoPlayerViewController.h"
#import "RATreeView.h"
#import "KCourseItem.h"
#import "PlayerFrameView.h"
#import "KKBBaseViewController.h"
#import "UMSocialControllerService.h"
#import "kKBShare.h"
#import "SLExpandableTableView.h"

@interface GuideCourseViewController
    : KKBVideoPlayerViewController <UITableViewDataSource, UITableViewDelegate,
                                    UMSocialUIDelegate, KKBShareDelegate,
                                    SLExpandableTableViewDatasource,
                                    SLExpandableTableViewDelegate> {

    NSArray *allCoursesDataArray;
    NSMutableArray *guideCourseDataArray;
    NSMutableArray *relativeCourseDataArray;
    NSMutableArray *buttonArray;
    NSMutableArray *baseViewArray;
    NSMutableArray *commentArray;
    NSMutableArray *courseSummaryArray;
    NSArray *techArray;
    NSArray *courseTreeArray;

    //班次信息表
    NSArray *classInfoArray;
    NSMutableArray *enrolledArray;
    NSMutableArray *unenrolledArray;
    BOOL isLearnButtonFold;
    BOOL isCheckButtonFold;
    BOOL isCollectioned;
}

@property(nonatomic, assign) BOOL shouldExpandTreeViewTargetSection;
@property(nonatomic, assign) BOOL playVideoImmediately;
@property(nonatomic, assign) NSUInteger weekNumber;

@property(strong, nonatomic) IBOutlet UILabel *courseName;
@property(retain, nonatomic) NSDictionary *guideCourseDictionary;
@property(retain, nonatomic) NSDictionary *courseSummaryDictionary;
@property(retain, nonatomic) NSMutableArray *recommendDataArray;
@property(retain, nonatomic) KCourseItem *courseItem;
@property(copy, nonatomic) NSString *courseId;
@property(strong, nonatomic) IBOutlet UIView *checkOtherViewLine;
@property(retain, nonatomic) UILabel *courseTitleLabel;

@property(retain, nonatomic) IBOutlet UIView *buttonView;
//点击Tab 对应的四个页面
@property(retain, nonatomic) IBOutlet UIScrollView *firstButtonBaseView;
@property(retain, nonatomic) SLExpandableTableView *secondButtonBaseView;
@property(retain, nonatomic) UITableView *ThirdButtonBaseView;
@property(strong, nonatomic) IBOutlet UITableView *CheckOtherClassTableView;
@property(retain, nonatomic) UITableView *fourthButtonBaseView;
@property(strong, nonatomic) UIView *titleView;
@property(strong, nonatomic) IBOutlet UIView *enrollButtonView;
@property(strong, nonatomic) UILabel *hasBeenEnrollClassLabel;
@property(strong, nonatomic) IBOutlet UIView *checkOtherClassInfoView;
@property(strong, nonatomic) IBOutlet UITableView *infoTableView;
@property(strong, nonatomic) IBOutlet UIButton *learnCourseButton;
@property(strong, nonatomic) IBOutlet UITableView *learnButtonTableView;

//基本信息栏对应的数据
@property(strong, nonatomic) IBOutlet UIView *courseInfoView;
@property(strong, nonatomic) IBOutlet UILabel *courseDetailLabel;
@property(strong, nonatomic) IBOutlet UILabel *schoolLabel;
@property(strong, nonatomic) IBOutlet UILabel *courseDurationLabel;
@property(strong, nonatomic) IBOutlet UILabel *courseWeekTime;
@property(strong, nonatomic) IBOutlet UILabel *courseDifficultLevel;
@property(strong, nonatomic) IBOutlet UILabel *courseKeyWordLevelLabel;
@property(strong, nonatomic) IBOutlet UILabel *courseIntroLabel;

@property(strong, nonatomic) IBOutlet UILabel *certificationIntroLabel;
@property(strong, nonatomic) IBOutlet UIImageView *certificationImageView;
@property(strong, nonatomic) IBOutlet UIView *learnButtonView;
@property(strong, nonatomic) IBOutlet UIView *checkOtherClassView;
@property(strong, nonatomic) IBOutlet UIButton *checkOtherButton;
@property(strong, nonatomic) IBOutlet UIButton *goOnStudyButton;
@property(strong, nonatomic) IBOutlet UILabel *totalWeek;
@property(strong, nonatomic) IBOutlet UILabel *everyWeek;
@property(strong, nonatomic) IBOutlet UIView *levelCardView;

@end
