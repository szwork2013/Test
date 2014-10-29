//
//  CoursesViewController.m
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CoursesViewController.h"
#import "KCourseItem.h"
#import "PushUpScrollView.h"
#import "KKBHttpClient.h"
#import "PublicClassViewController.h"
#import "GuideCourseViewController.h"
#import "SDWebImageManager.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "GuideCourseEnrolledViewController.h"

#import "CourseItemCell.h"
#import "KKBCourseItemCellModel.h"
#import "MobClick.h"

#define RefreshTableViewDelay 0.5f
#define LoadCourseNumberEachTime 10

#define NavigationBarHeight 44
#define StatusBarHeight 20

#define OpenCourse @"OpenCourse" //公开课
#define InstructiveCourse @"InstructiveCourse"

@interface CoursesViewController ()

@end

@implementation CoursesViewController {
    NSArray *allCoursesOnThisCatgory;
}

@synthesize categoryId;
@synthesize categoryName;

#pragma mark - initWithNibName

- (void)dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CourseItemCell *cell =
        [tableView dequeueReusableCellWithIdentifier:COURSEITEMCELL_RESUEDID
                                        forIndexPath:indexPath];

    KCourseItem *aCourseItem = courses[indexPath.row];

    KKBCourseItemCellModel *model = [[KKBCourseItemCellModel alloc] init];
    model.headImageURL = aCourseItem.imageUrl;
    model.cellTitle = aCourseItem.name;
    model.rating = aCourseItem.rating;
    model.itemType =
        !aCourseItem.type ? CourseItemOpenType : CourseItemGuideType;
    model.isOnLine = YES;
    model.enrollments = @(aCourseItem.learnerNumber);

    cell.model = model;

    return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    KCourseItem *aCourseItem = courses[indexPath.row];

    if (aCourseItem.type) {
        // instructive course
        GuideCourseViewController *controller =
            [[GuideCourseViewController alloc] init];
        controller.courseId = aCourseItem.courseId;
        [self.navigationController pushViewController:controller animated:YES];

    } else {
        // open course
        PublicClassViewController *controller =
            [[PublicClassViewController alloc]
                initWithNibName:@"PublicClassViewController"
                         bundle:nil];

        /**统一查询course接口zeng**/
        NSNumber *courseID =
            [[allCoursesOnThisCatgory objectAtIndex:indexPath.row]
                objectForKey:@"id"];
        [KKBCourseManager getCourseWithID:courseID
                              forceReload:NO
                        completionHandler:^(id model, NSError *error) {
                            if (!error) {
                                controller.currentCourse = model;
                                [self.navigationController
                                    pushViewController:controller
                                              animated:YES];
                            } else {
                            }
                        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return COURSEITEMCELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Custom Methods
- (IBAction)backButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addMoreCourses:(BOOL)isLoadingMore {
    // 为防止从Cache和网络上2次加载数据导致courses中的数据量超过10条记录，做如下保护
    if (!isLoadingMore) {
        coursesTotalCount = 0;
        [courses removeAllObjects];
    }

    if (coursesTotalCount < allCourses.count) {

        int initValue = coursesTotalCount;
        for (int i = initValue; i < (initValue + LoadCourseNumberEachTime);
             i++) { // add x courses every time
            if (i < allCourses.count) {
                [courses addObject:allCourses[i]];
                coursesTotalCount++;
            }
        }

        [self.courseTableView reloadData];
    }
}

- (void)setTableView {
    self.courseTableView.separatorStyle =
        UITableViewCellSeparatorStyleSingleLine;
    self.courseTableView.pullArrowImage = [UIImage imageNamed:@"arrow"];
    self.courseTableView.pullBackgroundColor = [UIColor clearColor];
    self.courseTableView.pullTextColor = [UIColor blackColor];

    [self.courseTableView registerNib:[CourseItemCell cellNib]
               forCellReuseIdentifier:COURSEITEMCELL_RESUEDID];
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = StatusBarHeight;
    int width = 320;
    int height = self.view.bounds.size.height - y;

    return CGRectMake(x, y, width, height);
}

- (UIView *)noCourseView {
    UIView *noCourseView =
        [[UIView alloc] initWithFrame:[self loadingViewFrame]];
    [noCourseView setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

    int width = 120;
    int height = 21;
    int x = (320 - width) / 2;
    int y = (noCourseView.frame.size.height - height) / 2;
    UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    label.text = @"暂无课程";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:nil size:18];
    [label setTextAlignment:NSTextAlignmentCenter];

    [noCourseView addSubview:label];

    return noCourseView;
}

#pragma mark - PushUpScrollViewDelegate Method

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView {

    [self performSelector:@selector(loadMoreDataToTable)
               withObject:nil
               afterDelay:RefreshTableViewDelay];
}

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView {
}

- (void)loadMoreDataToTable {
    // load more data

    [self addMoreCourses:YES];

    [self.courseTableView reloadData];

    NSString *courseNumberInfo =
        [NSString stringWithFormat:@"共%d门课程", coursesTotalCount];
    BOOL shown = (coursesTotalCount >= courses.count);
    if (shown) {
        self.courseTableView.loadMoreView.notLoadAnyMore = YES;
        [self.courseTableView.loadMoreView setStatusLabelText:courseNumberInfo];
        [self.courseTableView.loadMoreView setArrowImageHidden:shown];

        self.courseTableView.loadMoreView.activityView.hidden = YES;
    }

    self.courseTableView.pullTableIsLoadingMore = NO;
}

- (void)requestTableViewData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    NSString *jsonForSpecialties = [NSString
        stringWithFormat:@"v1/courses/categoryid/%d", self.categoryId];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForSpecialties
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"course: %@", result);

            NSArray *courseInfos = (NSArray *)result;
            allCoursesOnThisCatgory = (NSArray *)result;
            //
            if (courseInfos == nil || courseInfos.count == 0) {

                [self.loadingView hideView];
                [self.view addSubview:[self noCourseView]];
                return;
            }

            NSMutableArray *tempCourses = [[NSMutableArray alloc] init];
            for (NSDictionary *aCourseDict in courseInfos) {

                NSString *name = [aCourseDict objectForKey:@"name"];
                NSString *imageUrl = [aCourseDict objectForKey:@"cover_image"];
                NSUInteger weeks =
                    [[aCourseDict objectForKey:@"weeks"] intValue];

                NSString *type = [aCourseDict objectForKey:@"type"];
                NSUInteger viewCount;
                if ([type isEqualToString:@"OpenCourse"]) {
                    viewCount =
                        [[aCourseDict objectForKey:@"view_count"] integerValue];
                } else {
                    NSInteger baseEnrollmentsCount = [[aCourseDict
                        objectForKey:@"base_enrollments_count"] integerValue];
                    NSInteger enrollmentCount = [[aCourseDict
                        objectForKey:@"enrollments_count"] integerValue];
                    viewCount = baseEnrollmentsCount + enrollmentCount;
                }
                NSUInteger rating =
                    [[aCourseDict objectForKey:@"rating"] intValue];
                NSString *ratingText = [self getRatingStar:rating];
                CGFloat covertRating = rating / 2.0;
                if (covertRating > 5) {
                    covertRating = 5;
                }

                NSUInteger updatedTo =
                    [[aCourseDict objectForKey:@"updated_amount"] intValue];
                NSString *other = [NSString
                    stringWithFormat:@"更新至第%d节视频", updatedTo];
                NSString *courseId = [aCourseDict objectForKey:@"id"];

                NSString *courseIntro = [aCourseDict objectForKey:@"intro"];
                NSString *courseLevel = [aCourseDict objectForKey:@"level"];
                NSString *keyWord = [aCourseDict objectForKey:@"slogan"];
                NSString *coverImage =
                    [aCourseDict objectForKey:@"cover_image"];
                NSString *videoUrl =
                    [aCourseDict objectForKey:@"promotional_video_url"];

                int courseType = ([type isEqualToString:OpenCourse] ? 0 : 1);
                KCourseItem *aCourseItem = [[KCourseItem alloc] init:imageUrl
                                                                name:name
                                                            duration:weeks
                                                   learnTimeEachWeek:3
                                                                vote:ratingText
                                                       learnerNumber:viewCount
                                                                type:courseType
                                                            courseId:courseId
                                                               other:other
                                                         courseIntro:courseIntro
                                                         courseLevel:courseLevel
                                                             keyWord:keyWord
                                                          coverImage:coverImage
                                                            videoUrl:videoUrl];
                aCourseItem.rating = covertRating;
                [tempCourses addObject:aCourseItem];
            }

            allCourses = [NSArray arrayWithArray:tempCourses];
            [self addMoreCourses:NO];

            if (fromCache) {

                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {

            if (fromCache) {
                [self.loadingView hideView];
                [loadingFailedView setHidden:NO];
            }
        }];
}

- (void)reloadTableViewData {

    [self.loadingView showInView:self.view];
    [loadingFailedView setHidden:YES];

    [self requestTableViewData:YES];
}

- (NSString *)getRatingStar:(int)ratingCount {
    if (ratingCount == 0) {
        return nil;
    } else {
        NSMutableString *rateString = [[NSMutableString alloc] init];

        float count = ceilf(ratingCount / 2.0f);
        for (int i = 0; i < count; i++) {
            [rateString appendString:@"★"];
        }

        return rateString;
    }
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //颜色
    _courseTableView.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;
    self.view.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;

    _courseTableView.showsHorizontalScrollIndicator = NO;
    _courseTableView.showsVerticalScrollIndicator = NO;

    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    courses = [[NSMutableArray alloc] init];

    if (self.categoryName) {
        [self setTitle:self.categoryName];
    } else {
        [self setTitle:@"暂无课程"];
    }

    /************************* request data **************************/

    [self requestTableViewData:YES];
    [self requestTableViewData:NO];

    [self setTableView];

    /************************* loading view **************************/

    loadingFailedView =
        [[KKBLoadingFailedView alloc] initWithFrame:[self loadingViewFrame]];
    [loadingFailedView setHidden:YES];
    [loadingFailedView setTapTarget:self action:@selector(reloadTableViewData)];
    [self.view addSubview:loadingFailedView];

    /************************* all courses **************************/
    [self.navigationController.navigationBar setHidden:NO];

    // modify loading view frame
    CGRect loadingViewFrame = self.loadingView.frame;
    loadingViewFrame.origin.y = 0;
    self.loadingView.frame = loadingViewFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //必须在这改掉tableView的分割线
    _courseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [MobClick beginLogPageView:@"CategoryCourse"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"CategoryCourse"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_courseTableView setFrameHeight:G_SCREEN_HEIGHT - 70];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
