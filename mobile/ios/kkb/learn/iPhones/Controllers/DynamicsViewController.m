//
//  DynamicsViewController.m
//  learn
//
//  Created by xgj on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "DynamicsViewController.h"
#import "GuideCourseItemView.h"
#import "GuideCourseVideoItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "KKBHttpClient.h"

#import "UIImageView+WebCache.h"
#import "UILabel+KKB_VerticalAlign.h"

#import "GuideCourseCardItemModel.h"
#import "CourseInFavorItemModel.h"
#import "KKBUserInfo.h"
#import "PublicClassViewController.h"
#import "GuideCourseViewController.h"
#import "GuideCourseEnrolledViewController.h"

#import "PublicClassViewController.h"
#import "GuideCourseViewController.h"
//需要解析的model
#import "GuideCourseVideoItemModel.h"
#import "GuideCourseItemModel.h"

#import "AFNetworkReachabilityManager.h"
#import "LocalStorage.h"

#import "MobClick.h"

// 课程卡片宏定义

// cell 图片
#define GuideCourseImageViewTag 1000
// cell 标题
#define GuideCourseTitleLabelTag 1001
// cell 右走
#define GuideCourseArrowButtonTag 1002
// cell 分割线
#define GuideCourseSeperateLineTag 1003
// cell 周数
#define GuideCourseNumberOfWeekButtonTag 1004
// cell 本周学习任务
#define GuideCourseUpdateTextLabelTag 1005
// cell Item背景
#define GuideCourseTasksViewTag 1006
// cell 视频项
#define GuideCourseVideoViewTag 1007
// cell 讨论项
#define GuideCourseDiscussionViewTag 1008
// cell 作业项
#define GuideCourseHomeWorkViewTag 1009
// cell 测验项
#define GuideCourseExamViewTag 1010
// cell 时间已过
#define GuideCoursePassImageViewTag 1020

// cell 标题
#define CourseItemInFavorCourseNameLabelTag 3000
// cell 导学课 or 公开课
#define CourseItemInFavorCourseTypeImageViewTag 3001
// cell 时间
#define CourseItemInFavorUpdateTimeLabelTag 3002
// cell 图片
#define CourseItemInFavorCourseImageViewTag 3003
// cell 介绍
#define CourseItemInFavorUpdateInfoLabelTag 3004

#define DelayAfterLoadData 1.0f

#import "CourseInFavorCell.h"
#import "GuideCourseCardCell.h"

static CGFloat const topFloatViewHeight = 48;
static CGFloat const topFloatViewAddStatusBarHeight = 68;

static CGFloat const coolStartImageOriginY = 166;
static CGFloat const coolStartLabelOriginY = 286;

static CGFloat const cardSpace = 16;

static CGFloat const topFloatCancelButtonX = 284;
static CGFloat const topFloatCancelButtonY = 26;
static CGFloat const topFloatCancelButtonWidth = 36;
static CGFloat const topFloatCancelButtonHeight = 36;

static CGFloat const topFloatLabelWidth = 200;

static CGFloat const topFloatWatchImageOriginX = 217;
static CGFloat const topFloatWatchImageOriginY = 44;
static CGFloat const topFloatWatchImageWidth = 56;
static CGFloat const topFloatWatchImageHeight = 16;

static CGFloat const finishedCardHeaderHeight = 40;

typedef enum { TimeOver, TimeNotOver, TimeUnknown } TimeState;

@interface DynamicsViewController () {
    NSMutableArray *isSelectedArray;

    UILabel *_topFloatViewLabel;
    NSDictionary *_playRecordsDict;
    BOOL isPullRefresh;

    UIView *_coolStartView;
    NSArray *finishCardImageArray;
}

@end

@implementation DynamicsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        self.viewMode = FullViewMode;
    }
    return self;
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dynamicCoursesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject *object = dynamicCoursesArray[indexPath.section];

    NSString *reusedIDStr = nil;
    UITableViewCell *cell = nil;

    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];

    if (isCourseInFavorItem) {
        reusedIDStr = COURSEINFAVO_CELL_REUSEDID;
        cell = [tableView dequeueReusableCellWithIdentifier:reusedIDStr
                                               forIndexPath:indexPath];
        CourseInFavorCell *courseCell = (CourseInFavorCell *)cell;
        courseCell.model = (CourseInFavorItemModel *)object;

        // 设置选中时的颜色
        UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backgroundView;
        cell.selectedBackgroundView.backgroundColor =
            [UIColor tableViewCellSelectedColor];

    } else {
        reusedIDStr = GUIDE_COURSE_CELL_REUSEDID;
        cell = [tableView dequeueReusableCellWithIdentifier:reusedIDStr
                                               forIndexPath:indexPath];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        GuideCourseCardCell *courseCell = (GuideCourseCardCell *)cell;
        courseCell.model = (GuideCourseCardItemModel *)object;
        courseCell.model.indexPath = indexPath;
        courseCell.delegate = self;
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    NSObject *object = [dynamicCoursesArray objectAtIndex:section];
    UIView *headerView = [[UIView alloc] init];
    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];

    headerView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, gMajorCardWidth,
                                                 finishedCardHeaderHeight)];

    if (!isCourseInFavorItem) {
        GuideCourseCardItemModel *model = (GuideCourseCardItemModel *)object;
        if (model.isFinishedAllTask) {
            headerView.frame =
                CGRectMake(0, 0, gMajorCardWidth,
                           gMajorCardsSpaceHeight + finishedCardHeaderHeight);
            UIImageView *imageView = [[UIImageView alloc]
                initWithFrame:CGRectMake(0, gMajorCardsSpaceHeight,
                                         gMajorCardWidth,
                                         finishedCardHeaderHeight)];
            imageView.backgroundColor = [UIColor yellowColor];
            int randomCount = arc4random() % (finishCardImageArray.count);
            [imageView
                setImage:[UIImage imageNamed:[finishCardImageArray
                                                 objectAtIndex:randomCount]]];
            [headerView addSubview:imageView];
        }
    }
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    NSObject *object = [dynamicCoursesArray objectAtIndex:section];
    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];
    if (isCourseInFavorItem) {
        return gMajorCardsSpaceHeight;
    } else {
        GuideCourseCardItemModel *model = (GuideCourseCardItemModel *)object;
        if (model.isFinishedAllTask) {
            return gMajorCardsSpaceHeight + finishedCardHeaderHeight;
        } else {
            return gMajorCardsSpaceHeight;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *object = dynamicCoursesArray[indexPath.section];
    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];

    if (isCourseInFavorItem) {

        CourseInFavorItemModel *item = (CourseInFavorItemModel *)object;
        item.isSelected = YES;
        if (item.isOpenCourse) {
            PublicClassViewController *controller =
                [[PublicClassViewController alloc]
                    initWithNibName:@"PublicClassViewController"
                             bundle:nil];

            /**统一查询course接口zeng**/
            [KKBCourseManager getCourseWithID:item.courseId
                                  forceReload:NO
                            completionHandler:^(id model, NSError *error) {
                                if (!error) {
                                    controller.currentCourse = model;
                                    [self.navigationController
                                        pushViewController:controller
                                                  animated:YES];
                                }
                            }];

        } else {
            GuideCourseViewController *controller =
                [[GuideCourseViewController alloc] init];
            controller.courseId = [item.courseId stringValue];
            controller.playVideoImmediately = YES;
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        }
    } else {

        GuideCourseCardItemModel *item = (GuideCourseCardItemModel *)object;
        item.isSelected = YES;
        GuideCourseEnrolledViewController *controller =
            [[GuideCourseEnrolledViewController alloc] init];
        controller.courseId = [item.courseId stringValue];
        controller.courseNumberOfWeeks = item.courseNumberOfWeek;
        controller.classId = [item.lmsCourseId stringValue];
        controller.shouldExpandTreeViewTargetSection = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSObject *object = dynamicCoursesArray[indexPath.section];
    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];

    if (isCourseInFavorItem) {
        //收藏
        return COURSE_INFAVOR_CELL_HEIGHT;
    } else {
        //推荐的导学课
        return [GuideCourseCardCell
            heightForCellWithModel:(GuideCourseCardItemModel *)object];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {

    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:
            (EGORefreshTableHeaderView *)view {

    isPullRefresh = YES;
    [self reloadTopViewData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:
            (EGORefreshTableHeaderView *)view {

    return reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:
                (EGORefreshTableHeaderView *)view {

    return [NSDate date]; // should return date data source was last changed
}

#pragma mark - GuideCourseCardCell Delegate Methods
- (void)guideCourseCardDetailButtonDidSelect:(GuideCourseCardItemModel *)data {

    [self tableView:_dynamicsTableView didSelectRowAtIndexPath:data.indexPath];
}

- (void)guideCourseCardVideoItemDidSelect:(GuideCourseCardItemModel *)data {

    NSObject *object = dynamicCoursesArray[data.indexPath.section];
    BOOL isCourseInFavorItem =
        [object isMemberOfClass:[CourseInFavorItemModel class]];

    if (isCourseInFavorItem) {

        CourseInFavorItemModel *item = (CourseInFavorItemModel *)object;
        item.isSelected = YES;
        if (!item.isOpenCourse) {
            GuideCourseCardItemModel *item = (GuideCourseCardItemModel *)object;

            GuideCourseViewController *controller =
                [[GuideCourseViewController alloc] init];
            controller.courseId = [item.courseId stringValue];
            controller.weekNumber = item.courseNumberOfWeek;
            controller.shouldExpandTreeViewTargetSection = YES;
            controller.playVideoImmediately = YES;
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        }
    } else {

        GuideCourseCardItemModel *item = (GuideCourseCardItemModel *)object;
        item.isSelected = YES;
        GuideCourseEnrolledViewController *controller =
            [[GuideCourseEnrolledViewController alloc] init];
        controller.courseId = [item.courseId stringValue];
        controller.courseNumberOfWeeks = item.courseNumberOfWeek;
        controller.classId = [item.lmsCourseId stringValue];
        controller.shouldExpandTreeViewTargetSection = YES;
        controller.playVideoImmediately = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)guideCourseCardPlainItemDidSelect:(GuideCourseItemModel *)data {

    NSDate *deadline = [self stringToDate:data.due_at];
    TimeState timeState = [self isTimeOver:deadline];

    NSMutableString *msgBody = [[NSMutableString alloc]
        initWithString:@"程序猿施工中，请先到开课吧官网进行"];
    if (data.guideType == GuideCourseType_Discuss) {
        [msgBody appendString:@"讨论。"];

        if (timeState == TimeOver) {
            [msgBody appendFormat:@"提"
                     @"交讨论时间已过，提交将无法获得分数。"];
        }
    } else if (data.guideType == GuideCourseType_homework) {
        [msgBody appendString:@"作业。"];

        if (timeState == TimeOver) {
            [msgBody appendFormat:@"提"
                     @"交作业时间已过，提交将无法获得分数。"];
        }
    } else if (data.guideType == GuideCourseType_Test) {
        [msgBody appendString:@"测验。"];

        if (timeState == TimeOver) {
            [msgBody appendFormat:@"提"
                     @"交测验时间已过，提交将无法获得分数。"];
        } else if (timeState == TimeNotOver) {
            if (data.remainingSubmitCount <= 0) {
                [msgBody
                    appendFormat:@"您"
                    @"的剩余有效提交次数为0，提交将无法获得"
                    @"分数"];
            }
        }
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msgBody
                                                       delegate:self
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil];

    [alertView show];
}

- (NSDate *)stringToDate:(NSString *)string {

    if (string == nil || [string isKindOfClass:NSNull.class]) {
        return nil;
    }

    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    //    date = [formatter dateFromString:string];

    @try {
        date = [formatter dateFromString:string];
    }
    @catch (NSException *exception) {
        NSLog(@"Parse NSString to NSDate Exception: %@", exception);

        return nil;
    }
    @finally {
        return date;
    }

    return date;
}

- (TimeState)isTimeOver:(NSDate *)date {

    if (date == nil) {
        return TimeUnknown;
    }

    NSDate *today = [NSDate date];
    if ([date compare:today] == NSOrderedAscending ||
        [date compare:today] == NSOrderedSame) {
        return TimeOver;
    } else {
        return TimeNotOver;
    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {

        // [cancel] button, do nothing
    } else {
        [self gotoWebSite];
    }
}

#pragma mark - Custom Methods

- (void)gotoWebSite {
    [[UIApplication sharedApplication]
        openURL:[NSURL URLWithString:@"http://www.kaikeba.com"]];
}

- (void)addTopFloatView {

    int height = topFloatViewAddStatusBarHeight;
    int width = G_SCREEN_WIDTH;
    int x = 0;
    int y = -height;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(topFloatViewDidPress:)];

    topFloatView =
        [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [topFloatView addGestureRecognizer:tapGesture];
    [topFloatView setBackgroundColor:UIColorFromRGB(0x288BE6)];
    _topFloatViewLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine, gStatusBarHeight,
                                 topFloatLabelWidth, topFloatViewHeight)];
    _topFloatViewLabel.text = @"";
    _topFloatViewLabel.numberOfLines = 2;
    _topFloatViewLabel.adjustsFontSizeToFitWidth = YES;
    _topFloatViewLabel.font = [UIFont fontWithName:nil size:12];
    _topFloatViewLabel.textColor = [UIColor whiteColor];
    [topFloatView addSubview:_topFloatViewLabel];

    UIImageView *viewImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(
                          topFloatWatchImageOriginX, topFloatWatchImageOriginY,
                          topFloatWatchImageWidth, topFloatWatchImageHeight)];
    viewImageView.image = [UIImage imageNamed:@"nav_button_watch"];
    [topFloatView addSubview:viewImageView];

    UIButton *cancelButton = [[UIButton alloc]
        initWithFrame:CGRectMake(topFloatCancelButtonX, topFloatCancelButtonY,
                                 topFloatCancelButtonWidth,
                                 topFloatCancelButtonHeight)];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"nav_button_delete"]
                            forState:UIControlStateNormal];
    [cancelButton addTarget:self
                     action:@selector(cancelButtonDidPress:)
           forControlEvents:UIControlEventTouchUpInside];
    [topFloatView addSubview:cancelButton];

    [self.view addSubview:topFloatView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"Dynamic"];

    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"Dynamic"];
}

- (void)refreshPlayRecordsData {
    NSString *urlPath = [NSString stringWithFormat:@"v1/play_records/"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result : %@", result);
            _playRecordsDict = (NSDictionary *)result;

            NSString *courseType = nil;
            if ([[_playRecordsDict objectForKey:@"type"]
                    isEqualToString:@"OpenCourse"]) {
                courseType = @"公开课";
            } else {
                courseType = @"导学课";
            }
            NSString *courseName = [NSString
                stringWithFormat:@"《%@》", [_playRecordsDict
                                                  objectForKey:@"course_name"]];

            if ([[_playRecordsDict objectForKey:@"type"]
                    isEqualToString:@"OpenCourse"]) {
                _topFloatViewLabel.text = [NSString
                    stringWithFormat:@"上次观看公开课%@", courseName];
            } else {
                _topFloatViewLabel.text = [NSString
                    stringWithFormat:@"上次学习导学课%@", courseName];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)topFloatViewProcess:(NSDictionary *)playRecordCourse {
    NSMutableArray *courseInfoArray = [[NSMutableArray alloc] init];

    NSArray *lmsCourseArray =
        [playRecordCourse objectForKey:@"lms_course_list"];
    for (NSDictionary *classInfoDict in lmsCourseArray) {
        if ([[[classInfoDict objectForKey:@"lms_course_id"] stringValue]
                isEqualToString:
                    [[_playRecordsDict
                        objectForKey:@"lms_course_id"] stringValue]]) {
            courseInfoArray = [classInfoDict objectForKey:@"course_arrange"];
        }
    }

    NSMutableArray *videosItemIDArray = [[NSMutableArray alloc] init];
    NSMutableArray *videoUrlArray = [[NSMutableArray alloc] init];
    for (NSDictionary *itemsDict in courseInfoArray) {
        NSArray *itemArray = [itemsDict objectForKey:@"items"];
        for (NSDictionary *itemDict in itemArray) {
            if ([[itemDict objectForKey:@"type"]
                    isEqualToString:@"ExternalTool"]) {
                [videosItemIDArray addObject:[itemDict objectForKey:@"id"]];
                [videoUrlArray addObject:[itemDict objectForKey:@"url"]];
            }
        }
    }

    for (int i = 0; i < videosItemIDArray.count; i++) {
        if ([[[videosItemIDArray objectAtIndex:i] stringValue]
                isEqualToString:
                    [[_playRecordsDict
                        objectForKey:@"last_video_id"] stringValue]]) {
            [[LocalStorage shareInstance]
                savePlaybackPosition:[[_playRecordsDict
                                         objectForKey:@"duration"] floatValue]
                            courseId:[_playRecordsDict
                                         objectForKey:@"course_id"]
                             classId:[_playRecordsDict
                                         objectForKey:@"lms_course_id"]
                            videoUrl:[videoUrlArray objectAtIndex:i]];
        }
    }

    NSString *courseType = nil;
    if ([[_playRecordsDict objectForKey:@"type"]
            isEqualToString:@"OpenCourse"]) {
        courseType = @"公开课";
        PublicClassViewController *publicViewController =
            [[PublicClassViewController alloc]
                initWithNibName:@"PublicClassViewController"
                         bundle:nil];

        /**统一查询course接口zeng**/
        NSNumber *courseID = [_playRecordsDict objectForKey:@"course_id"];
        [KKBCourseManager
              getCourseWithID:courseID
                  forceReload:NO
            completionHandler:^(id model, NSError *error) {
                if (!error) {
                    publicViewController.playRecordVideoId =
                        [_playRecordsDict objectForKey:@"last_video_id"];
                    publicViewController.classId =
                        [_playRecordsDict objectForKey:@"lms_course_id"];
                    publicViewController.courseId =
                        [_playRecordsDict objectForKey:@"course_id"];

                    NSTimeInterval duration = [[_playRecordsDict
                        objectForKey:@"duration"] integerValue];

                    publicViewController.lastWatchRecord = duration;
                    publicViewController.currentCourse = model;
                    [self.navigationController
                        pushViewController:publicViewController
                                  animated:YES];
                }
            }];

    } else {
        courseType = @"导学课";
        GuideCourseEnrolledViewController *controller =
            [[GuideCourseEnrolledViewController alloc] init];
        controller.classId =
            [[_playRecordsDict objectForKey:@"lms_course_id"] stringValue];
        controller.courseId = [_playRecordsDict objectForKey:@"course_id"];
        controller.playRecordVideoId =
            [_playRecordsDict objectForKey:@"last_video_id"];
        [self.navigationController pushViewController:controller animated:YES];
    }

    [self setTopFloatViewHidden:YES];
}

- (void)topFloatViewDidPress:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"topFloatViewDidPress");

    /**统一查询course接口zeng**/
    NSNumber *courseID = [_playRecordsDict objectForKey:@"course_id"];
    [KKBCourseManager getCourseWithID:courseID
                          forceReload:NO
                    completionHandler:^(id model, NSError *error) {
                        if (!error) {
                            NSDictionary *playRecordCourse = model;
                            [self topFloatViewProcess:playRecordCourse];
                        }
                    }];
}

- (void)cancelButtonDidPress:(UIButton *)button {
    NSLog(@"cancelButtonDidPress");
    [self setTopFloatViewHidden:YES];
}

- (void)setTopFloatViewHidden:(BOOL)hidden {

    [UIView animateWithDuration:1.0f
        animations:^{

            /***************************** [ topFloatView ]
             * *******************************/

            CGRect frame = topFloatView.frame;
            frame.origin.y = (hidden ? -topFloatViewAddStatusBarHeight : 0);
            topFloatView.frame = frame;

            /***************************** [ dynamicsTableView ]
             * *******************************/

            CGRect frame2 = _dynamicsTableView.frame;
            frame2.origin.y =
                (hidden ? gStatusBarHeight : topFloatViewAddStatusBarHeight);
            //            frame2.origin.y = (hidden ? -20 : (20));//
            //            不加下拉刷新的，ok
            frame2.size.height =
                (hidden ? G_SCREEN_HEIGHT - gStatusBarHeight - gTabBarHeight
                        : G_SCREEN_HEIGHT - topFloatViewAddStatusBarHeight -
                              gTabBarHeight);

            _dynamicsTableView.frame = frame2;
        }
        completion:^(BOOL finished) {}];
}

- (void)addBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
        initWithImage:[UIImage imageNamed:@"course_back"]
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(backButtonDidPress:)];

    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backButtonDidPress:(id)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestPlayRecordsData:(BOOL)fromCache {
    NSString *urlPath = [NSString stringWithFormat:@"v1/play_records/"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result : %@", result);
            if (result == nil) {
                [self setTopFloatViewHidden:YES];
            } else {
                [self setTopFloatViewHidden:NO];
            }
            _playRecordsDict = (NSDictionary *)result;

            NSString *courseType = nil;
            if ([[_playRecordsDict objectForKey:@"type"]
                    isEqualToString:@"OpenCourse"]) {
                courseType = @"公开课";
            } else {
                courseType = @"导学课";
            }
            NSString *courseName = [NSString
                stringWithFormat:@"《%@》", [_playRecordsDict
                                                  objectForKey:@"course_name"]];

            if ([[_playRecordsDict objectForKey:@"type"]
                    isEqualToString:@"OpenCourse"]) {
                _topFloatViewLabel.text = [NSString
                    stringWithFormat:@"上次观看公开课%@", courseName];
            } else {
                _topFloatViewLabel.text = [NSString
                    stringWithFormat:@"上次学习导学课%@", courseName];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            [self setTopFloatViewHidden:YES];
        }];
}

- (void)requestTableViewData:(BOOL)fromCache {
    NSString *urlPath = [NSString stringWithFormat:@"v1/userapply/dynamic"];
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {

            NSArray *coursesFromRemote = (NSArray *)result;
            [dynamicCoursesArray removeAllObjects];
            if (coursesFromRemote.count == 0) {
                _coolStartView.hidden = NO;
            } else {
                _coolStartView.hidden = YES;
            }
            for (NSDictionary *aCourse in coursesFromRemote) {

                BOOL isUpdateOfGuideCourse = [[aCourse objectForKey:@"cardtype"]
                    isEqualToString:@"card"];

                if (isUpdateOfGuideCourse) {
                    // all finish task count
                    NSInteger allTaskCount = 0; // video count
                    NSInteger hasFinishedTaskCount = 0;
                    //解析 cardtype = card类别 带点击条目的类别(推荐的导学课)
                    NSNumber *courseId = [aCourse objectForKey:@"course_id"];
                    NSString *courseTitle = [aCourse objectForKey:@"name"];
                    NSUInteger courseNumberOfWeek =
                        [[aCourse objectForKey:@"week"] integerValue];
                    NSString *cover_image = aCourse[@"cover_image"];

                    //解析info
                    NSDictionary *courseInfo = [aCourse objectForKey:@"info"];
                    NSArray *videoInfo = [courseInfo objectForKey:@"video"];
                    NSArray *discussInfo = [courseInfo objectForKey:@"discuss"];
                    NSArray *homeworkInfo =
                        [courseInfo objectForKey:@"homework"];
                    NSArray *testInfo = [courseInfo objectForKey:@"test"];

                    // allTaskCount
                    allTaskCount = videoInfo.count + discussInfo.count +
                                   homeworkInfo.count + testInfo.count;

                    // homework
                    NSMutableArray *homeworkModelArr = [[NSMutableArray alloc]
                        initWithCapacity:[homeworkInfo count]];
                    for (NSDictionary *modelDic in homeworkInfo) {
                        GuideCourseItemModel *itemModel =
                            [[GuideCourseItemModel alloc] init];
                        itemModel.guideType = GuideCourseType_homework;
                        itemModel.point = modelDic[@"point"];
                        itemModel.statue = modelDic[@"statue"];
                        itemModel.due_at = modelDic[@"due_at"];
                        [homeworkModelArr addObject:itemModel];
                        if ([[modelDic objectForKey:@"statue"]
                                isEqualToString:@"y"]) {
                            hasFinishedTaskCount++;
                        }
                    }

                    // test
                    NSMutableArray *testModelArr = [[NSMutableArray alloc]
                        initWithCapacity:[testInfo count]];
                    for (NSDictionary *modelDic in testInfo) {
                        GuideCourseItemModel *itemModel =
                            [[GuideCourseItemModel alloc] init];
                        itemModel.guideType = GuideCourseType_Test;
                        itemModel.point = modelDic[@"point"];
                        itemModel.statue = modelDic[@"statue"];
                        itemModel.due_at = modelDic[@"due_at"];
                        itemModel.remainingSubmitCount =
                            [modelDic[@"allowed_attempts"] integerValue];
                        [testModelArr addObject:itemModel];
                        if ([[modelDic objectForKey:@"statue"]
                                isEqualToString:@"y"]) {
                            hasFinishedTaskCount++;
                        }
                    }

                    // discuss
                    NSMutableArray *discussModelArr = [[NSMutableArray alloc]
                        initWithCapacity:[discussInfo count]];
                    for (NSDictionary *modelDic in discussInfo) {
                        GuideCourseItemModel *itemModel =
                            [[GuideCourseItemModel alloc] init];
                        itemModel.guideType = GuideCourseType_Discuss;
                        itemModel.point = modelDic[@"point"];
                        itemModel.statue = modelDic[@"statue"];
                        itemModel.due_at = modelDic[@"due_at"];
                        [discussModelArr addObject:itemModel];
                        if ([[modelDic objectForKey:@"statue"]
                                isEqualToString:@"y"]) {
                            hasFinishedTaskCount++;
                        }
                    }

                    // video
                    NSMutableArray *videoModelArr = [[NSMutableArray alloc]
                        initWithCapacity:[videoInfo count]];
                    for (NSDictionary *modelDic in videoInfo) {
                        GuideCourseVideoItemModel *itemModel =
                            [[GuideCourseVideoItemModel alloc] init];
                        itemModel.guideType = GuideCourseType_Video;
                        itemModel.video_count = modelDic[@"video_count"];
                        itemModel.view_count = modelDic[@"view_count"];
                        [videoModelArr addObject:itemModel];
                        if ([[modelDic
                                objectForKey:@"video_count"] integerValue] ==
                            [[modelDic
                                objectForKey:@"view_count"] integerValue]) {
                            hasFinishedTaskCount++;
                        }
                    }

                    // all item arr
                    NSMutableArray *allItems = [[NSMutableArray alloc] init];
                    [allItems addObjectsFromArray:videoModelArr];
                    [allItems addObjectsFromArray:discussModelArr];
                    [allItems addObjectsFromArray:homeworkModelArr];
                    [allItems addObjectsFromArray:testModelArr];

                    // map to model
                    GuideCourseCardItemModel *cardItem =
                        [[GuideCourseCardItemModel alloc] init];
                    cardItem.courseId = courseId;
                    cardItem.lmsCourseId =
                        [aCourse objectForKey:@"lms_course_id"];
                    cardItem.courseTitle = courseTitle;
                    cardItem.courseNumberOfWeek = courseNumberOfWeek;
                    cardItem.courseImageUrl = cover_image;
                    cardItem.items = allItems;

                    // finish all task
                    /*
                     video video_count = view_count
                     discuss    statue y
                     homework   statue y
                     test       statue y
                     */
                    if (allTaskCount == hasFinishedTaskCount) {
                        NSLog(@"has finished");
                        cardItem.isFinishedAllTask = YES;
                    } else {
                        NSLog(@"not finished");
                        cardItem.isFinishedAllTask = NO;
                    }

                    [dynamicCoursesArray addObject:cardItem];
                } else {
                    //解析cardtype = update 类别 收藏类别
                    NSNumber *courseId = [aCourse objectForKey:@"course_id"];
                    NSString *courseTitle = [aCourse objectForKey:@"name"];
                    NSString *courseImageUrl =
                        [aCourse objectForKey:@"cover_image"];
                    BOOL isOpenCourse = [[aCourse objectForKey:@"type"]
                        isEqualToString:@"OpenCourse"];
                    NSNumber *time = [aCourse objectForKey:@"update_at"];

                    CourseInFavorItemModel *courseItem =
                        [[CourseInFavorItemModel alloc] init];
                    courseItem.courseId = courseId;
                    courseItem.courseTitle = courseTitle;
                    courseItem.courseImageUrl = courseImageUrl;
                    courseItem.isOpenCourse = isOpenCourse;
                    courseItem.time = time;
                    courseItem.updateTime = [aCourse objectForKey:@"date"];

                    [dynamicCoursesArray addObject:courseItem];
                }
            }

            [self.dynamicsTableView reloadData];

            if (!isPullRefresh) {

                [self.loadingView hideView];
            }
            if (isPullRefresh) {
                [self refreshTableDidFinish];
                isPullRefresh = NO;
            }
            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result is %@", result);
            if (fromCache) {
                [self.view bringSubviewToFront:self.loadingFailedView];
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
            isPullRefresh = NO;

            [self.loadingView hideView];
        }];
}

- (CGRect)loadingViewFrame {
    int x = 0;
    // navbar 44
    int y = -gNavigationBarHeight;
    NSLog(@"y is %d", y);
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - gTabBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (void)reloadTopViewData {
    if (!isPullRefresh) {
        [self.loadingFailedView hide];
        [self.loadingView showInView:self.view];
    }

    [self requestTableViewData:NO];
}

- (CGRect)refreshHeaderViewFrame {
    int x = 0;
    int y = -self.dynamicsTableView.bounds.size.height;
    int width = G_SCREEN_WIDTH;
    int height = self.dynamicsTableView.bounds.size.height;

    return CGRectMake(x, y, width, height);
}
- (void)initRefreshHeaderView {
    if (refreshHeaderView == nil) {

        refreshHeaderView = [[EGORefreshTableHeaderView alloc]
            initWithFrame:[self refreshHeaderViewFrame]];
        refreshHeaderView.delegate = self;

        refreshHeaderView.pullToRefreshText = @"下拉刷新动态";
        refreshHeaderView.releaseToRefreshText = @"释放加载动态";

        [self.dynamicsTableView addSubview:refreshHeaderView];
    }

    //  update the last update date
    [refreshHeaderView refreshLastUpdatedDate];
}

- (void)refreshTableDidFinish {

    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:
                           self.dynamicsTableView];
}

- (void)modifyLoadingViewFrame {
    CGRect frame = self.loadingView.frame;
    frame.origin.y = frame.origin.y + gNavigationBarHeight;
    self.loadingView.frame = frame;
}

- (void)initCoolStartView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                 G_SCREEN_HEIGHT - gNavigationBarHeight)];

    [self.dynamicsTableView addSubview:_coolStartView];
    _coolStartView.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;

    UIImageView *coolStartImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(gCoolStartImageOriginX, coolStartImageOriginY,
                                 gCoolStartImageOriginWidth,
                                 gCoolStartImageOriginHeight)];
    [coolStartImageView setImage:[UIImage imageNamed:@"icon_video_default"]];
    [_coolStartView addSubview:coolStartImageView];

    UILabel *coolStartLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, coolStartLabelOriginY, G_SCREEN_WIDTH,
                                 gCoolStartLabelHeight)];
    coolStartLabel.textAlignment = NSTextAlignmentCenter;
    coolStartLabel.font = [UIFont systemFontOfSize:16];
    coolStartLabel.textColor = UIColorRGB(125, 125, 128);
    coolStartLabel.text = @"还没有课程动态";
    [_coolStartView addSubview:coolStartLabel];
    UILabel *coolStartSecondLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, coolStartLabelOriginY + cardSpace +
                                        gCoolStartLabelHeight,
                                 G_SCREEN_WIDTH, gCoolStartLabelHeight)];
    coolStartSecondLabel.textAlignment = NSTextAlignmentCenter;
    coolStartSecondLabel.font = [UIFont systemFontOfSize:16];
    coolStartSecondLabel.textColor = UIColorRGB(125, 125, 128);
    coolStartSecondLabel.text = @"小鞭一挥，快去学习~";
    [_coolStartView addSubview:coolStartSecondLabel];

    _coolStartView.hidden = YES;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // register cell
    [self initCoolStartView];

    [self.dynamicsTableView registerNib:[GuideCourseCardCell cellNib]
                 forCellReuseIdentifier:GUIDE_COURSE_CELL_REUSEDID];
    [self.dynamicsTableView registerNib:[CourseInFavorCell cellNib]
                 forCellReuseIdentifier:COURSEINFAVO_CELL_REUSEDID];

    [self modifyLoadingViewFrame];

    [self addTopFloatView];
    [self setTitle:@"动态"];

    dynamicCoursesArray = [[NSMutableArray alloc] init];

    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    [_dynamicsTableView setBackgroundColor:[UIColor clearColor]];

    [self requestPlayRecordsData:YES];
    [self requestPlayRecordsData:NO];

    [self setTopFloatViewHidden:NO];
    /************************* status bar **************************/
    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view addSubview:[appDelegate statusBar]];

    [self initRefreshHeaderView];

    [self requestTableViewData:YES];
    [self requestTableViewData:NO];

    //
    finishCardImageArray = [[NSArray alloc]
        initWithObjects:@"kkb-iphone-guidecourse-finished-header",
                        @"kkb-iphone-guidecourse-finished-header-test",
                        @"kkb-iphone-guidecourse-finished-header-test1", nil];
    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadDynamicsData)];
}

- (void)reloadDynamicsData {
    [self.loadingView showInView:self.view];
    [self.loadingFailedView hide];
    [self requestTableViewData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {

    topFloatView = nil;
    dynamicCoursesArray = nil;
}
@end
