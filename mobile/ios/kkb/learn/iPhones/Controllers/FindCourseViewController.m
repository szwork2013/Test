//
//  FindCourseViewController.m
//  learn
//
//  Created by zxj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "FindCourseViewController.h"
#import "CoursesViewController.h"
#import "UIView+ViewFrameGeometry.h"
#import "KKBHttpClient.h"
#import "PublicClassViewController.h"
#import "KKBUserInfo.h"
#import "AppDelegate.h"
#import "MobClick.h"
#import "SearchCourseViewController.h"
#import "KKBBaseNavigationController.h"

#import "KKBFindCourseCategoryModel.h"

static CGFloat const CourseCategoriesOriginY = 48.0f;
static CGFloat const above4ImageOriginY = 48;
static CGFloat const above4LabelOriginY = 107;
static CGFloat const iphone4ImageOriginY = 22;
static CGFloat const iphone4LabelOriginY = 80;

@interface FindCourseViewController () {

    UIScrollView *baseScrollView;
    CourseCategories *courseCategoriesView;
    NSArray *categoryArray;
}

@end

@implementation FindCourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = TabBarOnlyMode;
    }
    return self;
}

#pragma mark - CourseCategoryDelegate Methods
- (void)courseViewDidSelect:(NSString *)categoryName
             withCategoryId:(NSUInteger)categoryId {

    CoursesViewController *controller =
        [[CoursesViewController alloc] initWithNibName:@"CoursesViewController"
                                                bundle:nil];
    controller.categoryName = categoryName;
    controller.categoryId = categoryId;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Custom Methods
- (CGRect)baseScrollViewFrame {
    int x = 0;
    int y = gStatusBarHeight;
    int width = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT;

    return CGRectMake(x, y, width, height);
}

- (void)requestBottomViewData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
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

            BOOL hasViews = (courseCategoriesView != nil);
            if (!hasViews) {
                int height = G_SCREEN_HEIGHT - gTabBarHeight -
                             gNavigationAndStatusHeight;
                int addcount = 0;
                if (categoryArray.count % 3 == 0) {
                    addcount = 0;
                } else {
                    addcount = 1;
                }
                CGFloat imageOriginY = above4ImageOriginY;
                CGFloat labelOriginY = above4LabelOriginY;
                if (G_SCREEN_HEIGHT == 480) {
                    imageOriginY = iphone4ImageOriginY;
                    labelOriginY = iphone4LabelOriginY;
                }
                courseCategoriesView = [[CourseCategories alloc]
                            initWithFrame:CGRectMake(0, CourseCategoriesOriginY,
                                                     G_SCREEN_WIDTH,
                                                     (categoryArray.count / 3 +
                                                      addcount) *
                                                         (height / 3))
                                 withData:categoryArray
                         withImageOriginY:imageOriginY
                    withLabelImageOriginY:labelOriginY];
                courseCategoriesView.delegate = self;
                [baseScrollView addSubview:courseCategoriesView];
            } else {
                // update courseCategoriesView
                [courseCategoriesView updateViewWithData:categoryArray];
            }
            [self resizeBaseView:categoryArray];
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

- (void)reloadTableViewData {

    [self.loadingView showInView:self.view];
    [self.loadingFailedView hide];

    [self requestBottomViewData:YES];
}

- (void)resizeBaseView:(NSArray *)array {
    int i = array.count;
    int j = 0;
    if (i % 3 == 0) {
        j = i / 3;
    } else {
        j = i / 3 + 1;
    }
    [baseScrollView
        setContentSize:CGSizeMake(G_SCREEN_WIDTH,
                                  (j * (G_SCREEN_HEIGHT - gStatusBarHeight -
                                        gTabBarHeight) /
                                   3))];
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = gStatusBarHeight;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - y - gTabBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (UIView *)fakeSearchView {

    UIView *searchView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 20, G_SCREEN_WIDTH, 48)];
    [searchView setBackgroundColor:UIColorFromRGB(0x288BE6)];

    UIButton *searchButton = [[UIButton alloc]
        initWithFrame:CGRectMake(8, 8, G_SCREEN_WIDTH - 16, 32)];
    [searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [searchButton setTitleColor:UIColorFromRGB(0xa3c4e1)
                       forState:UIControlStateNormal];
    [searchButton setBackgroundColor:UIColorRGBA(0, 0, 0, 0.2)];
    [searchButton.titleLabel setFont:[UIFont systemFontOfSize:16]];

    [searchButton
        setImage:[UIImage imageNamed:@"kkb_iphone_find_courses_search_blue"]
        forState:UIControlStateNormal];
    [searchButton
        setImage:[UIImage imageNamed:@"kkb_iphone_find_courses_search_blue"]
        forState:UIControlStateHighlighted];
    [searchButton addTarget:self
                     action:@selector(searchButtonDidPress:)
           forControlEvents:UIControlEventTouchUpInside];
    [searchButton.layer setCornerRadius:3.0f];
    [searchButton.layer setMasksToBounds:YES];

    [searchView addSubview:searchButton];

    return searchView;
}

- (void)addFakeSearchView {
    [self.view addSubview:[self fakeSearchView]];
}

- (void)searchButtonDidPress:(UIButton *)button {
    SearchCourseViewController *searchVC = [[SearchCourseViewController alloc]
        initWithNibName:@"SearchCourseViewController"
                 bundle:nil];

    KKBBaseNavigationController *navController =
        [[KKBBaseNavigationController alloc]
            initWithRootViewController:searchVC];

    [self presentViewController:navController animated:NO completion:nil];
}

#pragma mark - viewDidLoad Method
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;
    baseScrollView =
        [[UIScrollView alloc] initWithFrame:[self baseScrollViewFrame]];
    [baseScrollView setBounces:NO];
    [baseScrollView setContentSize:CGSizeMake(G_SCREEN_WIDTH, G_SCREEN_HEIGHT)];

    [self.view addSubview:baseScrollView];

    [self requestBottomViewData:YES];
    [self requestBottomViewData:NO];

    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view addSubview:[appDelegate statusBar]];

    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadTableViewData)];

    [self addFakeSearchView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [MobClick beginLogPageView:@"FindCourse"];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"FindCourse"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
