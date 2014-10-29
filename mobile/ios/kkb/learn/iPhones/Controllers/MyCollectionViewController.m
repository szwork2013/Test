//
//  MyCollectionViewController.m
//  learn
//
//  Created by zxj on 14-7-28.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "KKBHttpClient.h"
#import "MyCollectionCell.h"
#import "KKBUserInfo.h"
#import "GlobalOperator.h"
#import "GuideCourseViewController.h"
#import "PublicClassViewController.h"
#import "KKBLoadingFailedView.h"
#import "KKBActivityIndicatorView.h"
#import "AppDelegate.h"
#import "MobClick.h"

#import "KKBCourseItemCellModel.h"
#import "CourseItemCell.h"

static const CGFloat tableViewCellHeight = 95;
static const CGFloat topViewHeight = 37;

@interface MyCollectionViewController () {
    UIView *_coolStartView;

    BOOL isPublicHidden;
    BOOL isGuideHidden;
}

@end

@implementation MyCollectionViewController

#pragma mark - viewDidLoad
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"我的收藏";

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initCoolStartView];
    publicArray = [[NSMutableArray alloc] init];
    guideArray = [[NSMutableArray alloc] init];
    isPublicClass = YES;
    isGuideClass = NO;

    [self.tableView registerNib:[CourseItemCell cellNib]
         forCellReuseIdentifier:COURSEITEMCELL_RESUEDID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self requestData:YES];
    [self requestData:NO];

    [self.navigationController.navigationBar setHidden:NO];

    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadSelfViewData)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"MyFavoriteCourse"];
    [self requestData:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"MyFavoriteCourse"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView setFrameHeight:G_SCREEN_HEIGHT -
                                   gNavigationAndStatusHeight - topViewHeight];
    [self.tableView setFrameOriginY:topViewHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isPublicClass) {
        return publicArray.count;
    } else {
        return guideArray.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CourseItemCell *cell =
        [tableView dequeueReusableCellWithIdentifier:COURSEITEMCELL_RESUEDID
                                        forIndexPath:indexPath];

    NSDictionary *dic = nil;
    if (isPublicClass) {
        dic = [publicArray objectAtIndex:indexPath.section];
    } else {
        dic = [guideArray objectAtIndex:indexPath.section];
    }

    KKBCourseItemCellModel *model = [[KKBCourseItemCellModel alloc] init];
    model.headImageURL = (NSString *)[dic objectForKey:@"cover_image"];

    model.cellTitle = [dic objectForKey:@"name"];

    NSNumber *starRate = [dic objectForKey:@"rating"];
    int rating = [starRate intValue];
    CGFloat covertRating = rating / 2.0;
    if (covertRating > 5) {
        covertRating = 5;
    }

    model.rating = covertRating;
    model.itemType = [[dic objectForKey:@"type"] isEqualToString:@"OpenCourse"]
                         ? CourseItemOpenType
                         : CourseItemGuideType;
    model.isOnLine = YES;

    NSInteger baseEnrollmentsCount =
        [[dic objectForKey:@"base_enrollments_count"] integerValue];
    NSInteger enrollmentCount =
        [[dic objectForKey:@"enrollments_count"] integerValue];
    NSInteger totalEnrollmentCount = baseEnrollmentsCount + enrollmentCount;
    NSNumber *viewNumber = [NSNumber numberWithInteger:totalEnrollmentCount];
    NSNumber *studyNum =
        (isPublicClass ? [dic objectForKey:@"view_count"] : viewNumber);
    model.enrollments = studyNum;
    cell.model = model;

    return cell;
}

- (float)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = nil;
    if (isPublicClass) {
        dic = [publicArray objectAtIndex:indexPath.section];
        PublicClassViewController *public =
            [[PublicClassViewController alloc] init];
      public
        .currentCourse = dic;
        [self.navigationController pushViewController:public animated:YES];

    } else {
        dic = [guideArray objectAtIndex:indexPath.section];
        GuideCourseViewController *guide =
            [[GuideCourseViewController alloc] init];

        guide.courseId = [dic objectForKey:@"id"];
        [self.navigationController pushViewController:guide animated:YES];
    }
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Custom Methods
- (IBAction)segmentAction:(UISegmentedControl *)sender {

    if (sender.selectedSegmentIndex == 0) {
        isPublicClass = YES;
        isGuideClass = NO;
        if (isPublicHidden == YES) {
            _coolStartView.hidden = YES;
        } else {
            _coolStartView.hidden = NO;
        }

    } else {
        isGuideClass = YES;
        isPublicClass = NO;
        if (isGuideHidden == YES) {
            _coolStartView.hidden = YES;
        } else {
            _coolStartView.hidden = NO;
        }
    }
    [self.tableView reloadData];
}

- (void)requestData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    NSString *urlPath = [NSString stringWithFormat:@"v1/collections/user"];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSArray *tempArray = result;
            allCourseArray = [[NSMutableArray alloc] init];
            NSMutableArray *idArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in tempArray) {
                NSNumber *courseId = [dic objectForKey:@"id"];
                [idArray addObject:courseId];
            }

            [KKBCourseManager
                getCoursesWithIDs:idArray
                      forceReload:NO
                completionHandler:^(id model, NSError *error) {
                    if (!error) {
                        if ([model isKindOfClass:[NSArray class]]) {

                            allCourseArray = model;

                            [publicArray removeAllObjects];
                            [guideArray removeAllObjects];
                            for (NSDictionary *dic in allCourseArray) {
                                if ([[dic objectForKey:@"type"]
                                        isEqualToString:@"OpenCourse"]) {
                                    [publicArray addObject:dic];
                                } else {
                                    [guideArray addObject:dic];
                                }
                            }
                            if (publicArray.count == 0) {
                                isPublicHidden = NO;
                                _coolStartView.hidden = NO;
                            } else {
                                isPublicHidden = YES;
                                _coolStartView.hidden = YES;
                            }
                            if (guideArray.count == 0) {
                                isGuideHidden = NO;
                            } else {
                                isGuideHidden = YES;
                            }

                            [self.tableView reloadData];
                            if (fromCache) {
                                [self.loadingView hideView];
                            }
                        }
                    }
                }];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
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

- (KCourseItem *)model:(NSDictionary *)aCourseDict {
    NSString *name = [aCourseDict objectForKey:@"name"];
    NSString *imageUrl = [aCourseDict objectForKey:@"cover_image"];
    NSUInteger weeks = [[aCourseDict objectForKey:@"weeks"] intValue];
    NSUInteger viewCount = [[aCourseDict objectForKey:@"view_count"] intValue];
    NSString *type = [aCourseDict objectForKey:@"type"];
    NSUInteger rating = [[aCourseDict objectForKey:@"rating"] intValue];
    NSString *ratingText = [self getRatingStar:rating];
    CGFloat covertRating = rating / 2.0;
    if (covertRating > 5) {
        covertRating = 5;
    }

    NSUInteger updatedTo =
        [[aCourseDict objectForKey:@"updated_amount"] intValue];
    NSString *other =
        [NSString stringWithFormat:@"更新至第%d节视频", updatedTo];
    NSString *courseId = [aCourseDict objectForKey:@"id"];

    NSString *courseIntro = [aCourseDict objectForKey:@"intro"];
    NSString *courseLevel = [aCourseDict objectForKey:@"level"];
    NSString *keyWord = [aCourseDict objectForKey:@"slogan"];
    NSString *coverImage = [aCourseDict objectForKey:@"cover_image"];
    NSString *videoUrl = [aCourseDict objectForKey:@"promotional_video_url"];

    int courseType = ([type isEqualToString:@"OpenCourse"] ? 0 : 1);
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
    return aCourseItem;
}

- (void)reloadSelfViewData {

    [self.loadingFailedView hide];
    [self.loadingView showInView:self.view];

    [self requestData:YES];
}

- (void)initCoolStartView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 54, 320,
                                 G_SCREEN_HEIGHT - gNavigationBarHeight)];

    [self.view addSubview:_coolStartView];
    _coolStartView.backgroundColor = [UIColor colorWithRed:240 / 256.0
                                                     green:240 / 256.0
                                                      blue:240 / 256.0
                                                     alpha:1];

    UIImageView *coolStartImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(80, 122, 160, 120)];
    [coolStartImageView setImage:[UIImage imageNamed:@"icon_box"]];
    [_coolStartView addSubview:coolStartImageView];

    UILabel *coolStartLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 280, 16)];
    coolStartLabel.textAlignment = NSTextAlignmentCenter;
    coolStartLabel.font = [UIFont systemFontOfSize:16];
    coolStartLabel.textColor = [UIColor colorWithRed:125 / 256.0
                                               green:125 / 256.0
                                                blue:128 / 256.0
                                               alpha:1];
    coolStartLabel.text = @"你的课程表是空的耶~";
    [_coolStartView addSubview:coolStartLabel];

    _coolStartView.hidden = YES;
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = 0;
    int widht = self.view.bounds.size.width;
    int height =
        self.view.bounds.size.height - NavigationBarHeight - TabBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

@end
