
//  CourseHomeViewController.m
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "CourseHomeViewController.h"
#import "MajorViews.h"
#import "MiniMajorViewController.h"
#import "CoursesViewController.h"
#import "KKBHttpClient.h"

#import "MicroMajorViewController.h"
#import "MeViewController.h"
#import "FindCourseViewController.h"

#import "LoginAndRegisterView.h"
#import "RegisterViewController.h"
#import "DynamicsViewController.h"

#import "KKBUserInfo.h"

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"

#import "MobClick.h"
#import "GlobalDefine.h"

#import "KKBFindCourseCategoryModel.h"

#define ScrollAnimationDuration 0.5f
#define AnimationDurationAfterLoadData 1.0f

#define NavigationBarHeight 44
#define StatusBarHeight 20

static CGFloat const topTitleViewHeightPlusStatusBar = 68;
static CGFloat const loginAndRegisterViewHeight = 48;
static CGFloat const topTitleViewHeight = 48;

static CGFloat const findTopViewHeight = 48;
static CGFloat const findTitleLabelOriginY = 10;
static CGFloat const findDetailTitleLabelOriginY = 31;

static CGFloat const majorTopViewOriginY = 444;
static CGFloat const majorTopViewHeight = 53;
static CGFloat const majorTitleLabelOriginY = 15;
static CGFloat const majorDetailTitleLabelOriginY = 36;

static CGFloat const topTitleLabelWidth = 100;
static CGFloat const topTitleLabelHeight = 16;

static CGFloat const topDetailTitleHeight = 12;

static CGFloat const majorViewOriginY = 499;

static CGFloat const allScrollViewContentSize = 931;

static CGFloat const skipButtonOriginX = 25;
static CGFloat const skipButtonOffSetY = 60;
static CGFloat const skipButtonWidth = 270;
static CGFloat const skipButtonHeight = 50;

static CGFloat const lauchButtonOriginX = 80;
static CGFloat const lauchButtonOffSetY = 60;
static CGFloat const lauchButtonWidth = 160;
static CGFloat const lauchButtonHeight = 40;

static int const columnsInARow = 3;

static const int ddLogLevel = LOG_LEVEL_INFO;

@interface CourseHomeViewController () {
    UIView *bgView;
    UIView *mainView;
    UIView *subView;
    NSMutableArray *majorViewArray;
    MajorViews *tempMV;

    LoginAndRegisterView *loginAndRegisterView;
}

@end

@implementation CourseHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = NavigationBarPlusTabBarMode;
    }
    return self;
}

#pragma mark - MiniMajorDelegate Methods

- (void)miniMajorViewDidSelect:(UIView *)miniView {
    MiniMajorViewController *controller = [[MiniMajorViewController alloc]
        initWithNibName:@"MiniMajorViewController"
                 bundle:nil];
    NSString *speId = [NSString stringWithFormat:@"%d", miniView.tag / 10];
    NSString *microId = [NSString stringWithFormat:@"%d", miniView.tag % 10];

    DDLogDebug(@"speId is %@       microId is %@", speId, microId);

    [self.navigationController pushViewController:controller animated:YES];

    for (NSDictionary *majorDict in microSpecialitiesArray) {
        if ([[[majorDict objectForKey:@"id"] stringValue]
                isEqualToString:speId]) {
            NSArray *microSpecialtiesArray =
                [majorDict objectForKey:@"micro_specialties"];
            for (NSDictionary *microMajorDict in microSpecialtiesArray) {
                if ([[[microMajorDict objectForKey:@"id"] stringValue]
                        isEqualToString:microId]) {
                    controller.currentMajor = microMajorDict;
                }
            }
        }
    }

    controller.majorId = microId;
    DDLogInfo(@"major id is %d", miniView.tag);
}

- (void)miniMajorViewDidMove:(UIView *)miniView {
    // 动态改变scrollView的contentSize属性

    int scrollViewContentSizeHeight = majorViewOriginY;
    for (MajorViews *majorView in majorViewArray) {
        if (majorView.opened) {
            scrollViewContentSizeHeight += gMajorCardOpenHeight;
            scrollViewContentSizeHeight +=
                (majorView.subItemsCount * gMicroMajorInfoHeight);
            scrollViewContentSizeHeight += gMajorCardsSpaceHeight;
        } else {
            scrollViewContentSizeHeight += gMajorCardClosePlusSpaceHeight;
        }
    }
    if (scrollViewContentSizeHeight < allScrollViewContentSize) {
        scrollViewContentSizeHeight = allScrollViewContentSize;
    }
    DDLogInfo(@"%d", scrollViewContentSizeHeight);
    [self.allScrollView
        setContentSize:CGSizeMake(G_SCREEN_WIDTH, scrollViewContentSizeHeight)];
}

#pragma mark - CourseCategories Delegate Method

- (void)courseViewDidSelect:(NSString *)categoryName
             withCategoryId:(NSUInteger)categoryId {

    CoursesViewController *controller =
        [[CoursesViewController alloc] initWithNibName:@"CoursesViewController"
                                                bundle:nil];
    controller.categoryName = categoryName;
    controller.categoryId = categoryId;

    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - EAIntroView Delegate Methods
- (void)intro:(EAIntroView *)introView
    pageAppeared:(EAIntroPage *)page
       withIndex:(NSInteger)pageIndex {
    if (pageIndex == 3) {
        introView.skipButton = [self launchButton];
    } else {
        introView.skipButton = [self skipButton];
    }
}

- (void)initDataAndTopView {
    BOOL hasViews = (majorViewArray != nil && majorViewArray.count > 0);
    [self.allScrollView
        setContentSize:CGSizeMake(G_SCREEN_WIDTH,
                                  majorViewOriginY +
                                      microSpecialitiesArray.count *
                                          gMajorCardClosePlusSpaceHeight)];

    for (int i = 0; i < microSpecialitiesArray.count; i++) {
        NSDictionary *aCourse = microSpecialitiesArray[i];
        NSString *course = [aCourse objectForKey:@"name"];
        NSArray *microMajors = [aCourse objectForKey:@"micro_specialties"];
        NSInteger SpecialityId = [[aCourse objectForKey:@"id"] integerValue];
        DDLogDebug(@"specialityId is %d", SpecialityId);
        if (!hasViews) {
            /***************************** [ Views ]
             * *******************************/
            MajorViews *majorView = [[MajorViews alloc]
                   initWithFrame:CGRectMake(
                                     gScreenToCardLine,
                                     majorViewOriginY +
                                         i * gMajorCardClosePlusSpaceHeight,
                                     gMajorCardWidth, gMajorCardCloseHeight)
                      parentView:self.allScrollView
                andSubItemsCount:microMajors.count];
            majorView.row = i;
            majorView.delegate = self;
            [[NSNotificationCenter defaultCenter]
                addObserver:majorView
                   selector:@selector(changeMajor:)
                       name:@"changeMajor"
                     object:nil];
            UILabel *courseNameLabel = (UILabel *)
                [majorView.majorView viewWithTag:MajorViewCourseNameLabelTag];
            courseNameLabel.text = course;
            [courseNameLabel setNeedsDisplay]; // redraw view
            majorView.majorViewTitle.text = course;
            majorView.majorIntroTitle.text = course;
            NSString *introContent = [[aCourse objectForKey:@"intro"]
                stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceCharacterSet]];
            majorView.majorIntroContent.text = introContent;

            [majorView.majorImageView
                sd_setImageWithURL:
                    [NSURL URLWithString:[aCourse objectForKey:@"img_url"]]];
            [majorViewArray addObject:majorView];
            /***************************** [ Data ]
             * *******************************/
            for (int j = 0; j < microMajors.count; j++) {
                NSDictionary *aMicroMajor = microMajors[j];
                NSString *microMajorName = [aMicroMajor objectForKey:@"name"];
                NSUInteger microMajorId =
                    [[aMicroMajor objectForKey:@"id"] intValue];

                UIView *aSubView = (UIView *)majorView.subMajorViews[j];
                aSubView.tag = SpecialityId * 10 + microMajorId;
                UILabel *aTitleLabel = (UILabel *)
                    [aSubView viewWithTag:(MicroMajorCourseTitleLabelTag + j)];

                aTitleLabel.text = microMajorName;
                [aTitleLabel setNeedsDisplay]; // redraw view

                UILabel *subTitleLabel = [[aSubView subviews] objectAtIndex:2];
                subTitleLabel.text = [aMicroMajor objectForKey:@"name"];
                UILabel *subCourseLabel = [[aSubView subviews] objectAtIndex:3];
                NSArray *subCourseArray = [aMicroMajor objectForKey:@"courses"];
                NSMutableArray *subCourseNameArray =
                    [[NSMutableArray alloc] init];
                for (NSDictionary *courseDict in subCourseArray) {
                    [subCourseNameArray
                        addObject:[NSString
                                      stringWithFormat:
                                          @"《%@》",
                                          [courseDict objectForKey:@"name"]]];
                }
                subCourseLabel.text =
                    [subCourseNameArray componentsJoinedByString:@"、"];
            }
        } else { // 已经创建了视图的话，则找到相应的视图，然后赋值并刷新
                 /*****************************[ Views ]
                  * ******************************/
            MajorViews *majorView = majorViewArray[i];

            UILabel *courseNameLabel = (UILabel *)
                [majorView.majorView viewWithTag:MajorViewCourseNameLabelTag];
            courseNameLabel.text = course;
            [courseNameLabel setNeedsDisplay]; // redraw view

            /*****************************[ Data ]
             * ******************************/
            for (int j = 0; j < microMajors.count; j++) {
                NSDictionary *aMicroMajor = microMajors[j];
                NSString *microMajorName = [aMicroMajor objectForKey:@"name"];
                NSUInteger microMajorId =
                    [[aMicroMajor objectForKey:@"id"] intValue];

                UIView *aSubView = (UIView *)majorView.subMajorViews[j];
                aSubView.tag = SpecialityId * 10 + microMajorId;

                DDLogDebug(@"morcroMajorId is %d", microMajorId);
                DDLogInfo(@"subView tag is %d", aSubView.tag);
                UILabel *aTitleLabel = (UILabel *)
                    [aSubView viewWithTag:(MicroMajorCourseTitleLabelTag + j)];

                aTitleLabel.text = microMajorName;
                [aTitleLabel setNeedsDisplay]; // redraw view
            }
        }
    }
}

- (void)requestTopViewData:(BOOL)fromCache {

    [self.loadingFailedView hide];
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    [self.view bringSubviewToFront:loginAndRegisterView];
    NSString *jsonForTopView = [NSString stringWithFormat:@"v1/specialty"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForTopView
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"%@", result);
            DDLogInfo(@"%@", result);
            microSpecialitiesArray = result;
            [self initDataAndTopView];

            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.view bringSubviewToFront:self.loadingFailedView];
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

- (void)requestBottomViewData:(BOOL)fromCache {

    [self.loadingFailedView hide];
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    [self.view bringSubviewToFront:loginAndRegisterView];

    NSString *jsonForBottomView = [NSString stringWithFormat:@"v1/category"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForBottomView
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSError *error = nil;
            categoryArray =
            [MTLJSONAdapter modelsOfClass:KKBFindCourseCategoryModel.class
                            fromJSONArray:result
                                    error:&error];

            BOOL hasViews = (self.courseCategoriesView != nil);
            if (!hasViews) {
                int height =
                    (G_SCREEN_HEIGHT - topTitleViewHeightPlusStatusBar -
                     loginAndRegisterViewHeight) /
                    columnsInARow;
                int addcount = 0;
                if (categoryArray.count % columnsInARow == 0) {
                    addcount = 0;
                } else {
                    addcount = 1;
                }

                int columns = categoryArray.count / columnsInARow + addcount;
                self.courseCategoriesView = [[CourseCategories alloc]
                            initWithFrame:CGRectMake(0, topTitleViewHeight,
                                                     G_SCREEN_WIDTH,
                                                     columns * 132)
                                 withData:categoryArray
                         withImageOriginY:36
                    withLabelImageOriginY:96];

                _courseCategoriesView.delegate = self;
                [self.allScrollView addSubview:_courseCategoriesView];
            } else {
                // update courseCategoriesView
                [self.courseCategoriesView updateViewWithData:categoryArray];
            }
            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.view bringSubviewToFront:self.loadingFailedView];
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

- (void)reloadCourseHomeVCData {

    [self.loadingFailedView hide];
    [self.loadingView showInView:self.view];

    [self requestTopViewData:YES];
    [self requestBottomViewData:YES];
}

- (void)viewDidLayoutSubviews {

    [self.allScrollView
        setHeight:(G_SCREEN_HEIGHT - gBottomViewHeight - gStatusBarHeight)];
    self.loadingFailedView.frame =
        CGRectMake(0, gStatusBarHeight, G_SCREEN_WIDTH,
                   G_SCREEN_HEIGHT - gStatusBarHeight - gBottomViewHeight);
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = gStatusBarHeight;
    int width = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - y;

    return CGRectMake(x, y, width, height);
}

- (void)showIntroView {

    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"page1"];
    page1.showTitleView = NO;

    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"page2"];
    page2.showTitleView = NO;

    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"page3"];
    page3.showTitleView = NO;

    EAIntroPage *page4 = [EAIntroPage page];
    page4.bgImage = [UIImage imageNamed:@"page4"];
    page4.showTitleView = NO;

    EAIntroView *intro =
        [[EAIntroView alloc] initWithFrame:self.view.bounds
                                  andPages:@[ page1, page2, page3, page4 ]];
    intro.titleView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigLogo"]];
    intro.titleViewY = 120;
    intro.tapToNext = YES;
    [intro setDelegate:self];

    SMPageControl *pageControl = [[SMPageControl alloc] init];
    pageControl.pageIndicatorImage = [UIImage imageNamed:@"pageDot"];
    pageControl.currentPageIndicatorImage =
        [UIImage imageNamed:@"pageDotSelected"];
    [pageControl sizeToFit];
    intro.pageControl = (UIPageControl *)pageControl;
    intro.pageControlY = 130.0f;

    UIButton *btn = [self skipButton];
    intro.skipButton = btn;

    [intro showInView:self.view animateDuration:0.3];
}

- (UIButton *)skipButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"立即体验" forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(skipButtonOriginX,
                             G_SCREEN_HEIGHT - skipButtonOffSetY,
                             skipButtonWidth, skipButtonHeight)];
    return btn;
}

- (UIButton *)launchButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_start"]
                   forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(lauchButtonOriginX,
                             G_SCREEN_HEIGHT - lauchButtonOffSetY,
                             lauchButtonWidth, lauchButtonHeight)];

    return btn;
}

- (void)addIntroView {

    BOOL hasLaunchedOnce = [[LocalStorage shareInstance] hasLaunchedOnce];
    if (!hasLaunchedOnce) {

        [self showIntroView];

        [[LocalStorage shareInstance] saveLaunchStatus];
    }
}

- (void)loginAndRegisterViewButtonClick:(UIButton *)button {

    DDLogInfo(@"CLICK!!!!!");
    if (button.tag == 10000) {
        NSLog(@"loginButtonClick!!!");
        LoginViewController *loginVC =
            [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                                  bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else if (button.tag == 10001) {
        RegisterViewController *registerVC = nil;

        registerVC = [[RegisterViewController alloc]
            initWithNibName:@"RegisterViewController"
                     bundle:nil];

        [self.navigationController pushViewController:registerVC animated:YES];
    }
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    majorViewArray = [[NSMutableArray alloc] init];

    self.allScrollView.bounces = NO;
    self.allScrollView.contentSize = CGSizeMake(
        G_SCREEN_WIDTH,
        (G_SCREEN_HEIGHT - gStatusBarHeight - gBottomViewHeight) * 2);
    /************************* findTopTitleView*****************************/
    UIView *findTopTitleView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, findTopViewHeight)];
    findTopTitleView.backgroundColor = UIColorFromRGB(0xf0f0f0);
    UILabel *title = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine, findTitleLabelOriginY,
                                 topTitleLabelWidth, topTitleLabelHeight)];
    title.textColor = UIColorFromRGB(0x969699);
    [title setFont:[UIFont systemFontOfSize:16]];
    title.text = @"发现课程";
    title.tag = 1000;
    [findTopTitleView addSubview:title];
    UILabel *detailTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine, findDetailTitleLabelOriginY,
                                 gMajorCardWidth, topDetailTitleHeight)];
    detailTitle.textColor = UIColorFromRGB(0x969699);

    [detailTitle setFont:[UIFont systemFontOfSize:12]];
    detailTitle.text =
        @"自" @"从我学了这些课，贱贱地发现人类已"
        @"经无法阻止我了…";
    detailTitle.tag = 1001;
    [findTopTitleView addSubview:detailTitle];
    [self.allScrollView addSubview:findTopTitleView];

    /*****************majorTopTitleView********************/
    UIView *majorTopTitleView = [[UIView alloc]
        initWithFrame:CGRectMake(0, majorTopViewOriginY, G_SCREEN_WIDTH,
                                 majorTopViewHeight)];
    majorTopTitleView.backgroundColor = UIColorFromRGB(0xf0f0f0);
    UILabel *majorTopTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine, majorTitleLabelOriginY,
                                 topTitleLabelWidth, topTitleLabelHeight)];
    majorTopTitle.textColor = UIColorFromRGB(0x969699);
    [majorTopTitle setFont:[UIFont systemFontOfSize:16]];
    majorTopTitle.text = @"专业/微专业";
    [majorTopTitleView addSubview:majorTopTitle];
    UILabel *majorTopDetailTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine,
                                 majorDetailTitleLabelOriginY, gMajorCardWidth,
                                 topDetailTitleHeight)];
    majorTopDetailTitle.textColor = UIColorFromRGB(0x969699);

    [majorTopDetailTitle setFont:[UIFont systemFontOfSize:12]];
    majorTopDetailTitle.text = @"一" @"证" @"儿"
        @"在手，欧份儿不愁。学渣，让我来拯救你吧！";
    [majorTopTitleView addSubview:majorTopDetailTitle];
    [self.allScrollView addSubview:majorTopTitleView];

    self.allScrollView.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;
    self.allScrollView.showsVerticalScrollIndicator = NO;

    /************************* request data **************************/

    loginAndRegisterView = [[LoginAndRegisterView alloc]
        initWithFrame:CGRectMake(0,
                                 G_SCREEN_HEIGHT - loginAndRegisterViewHeight,
                                 G_SCREEN_WIDTH, loginAndRegisterViewHeight)];
    loginAndRegisterView.target = self;
    loginAndRegisterView.action = @selector(loginAndRegisterViewButtonClick:);

    [self.view addSubview:loginAndRegisterView];

    /************************* status bar **************************/
    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.statusBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:[appDelegate statusBar]];

    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadCourseHomeVCData)];

    [self requestTopViewData:YES];
    [self requestTopViewData:NO];

    [self requestBottomViewData:YES];
    [self requestBottomViewData:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [MobClick beginLogPageView:@"AnonymousHome"];

    [self.navigationController.navigationBar setHidden:YES];

    [self addIntroView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"AnonymousHome"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

#endif

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    //    interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (void)dealloc {
    toTabsPageButton = nil;
    _refreshHeaderView = nil;

    microSpecialitiesArray = nil;
    categoryArray = nil;
}

@end
