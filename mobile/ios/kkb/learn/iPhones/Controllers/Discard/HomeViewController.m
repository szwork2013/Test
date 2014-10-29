//
//  HomeViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "HomeViewController.h"
#import "SidebarViewController.h"
#import "SidebarLevelTwoViewController.h"

#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UMFeedback.h"
#import "GlobalOperator.h"
#import "ToolsObject.h"
#import "HomePageOperator.h"
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>
#import "LoginAndRegistViewController.h"
#import "CourseInfoViewController.h"
#import "AppDelegate.h"
#import "FileUtil.h"
#import "KKBHttpCache.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "MobClick.h"
#import "ContentCell.h"
#import "UIView+ViewFrameGeometry.h"
#import "PublicClassViewController.h"
#import "DownloadManagerViewController.h"
#import "KKBActivityIndicatorView.h"
#import "CollectionLayout.h"
#import "CollectionItemView.h"
#import "CourseCategories.h"
#import "CourseHomeViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "IFlyViewController.h"

#define NAVIGATION_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20
#define KKB_ACTIVITY_INDICATOR_TAG 120

@interface HomeViewController () <UINavigationControllerDelegate> {
    HomePageOperator *homePageOperator;
    int tickIndex;
}

@end

@implementation HomeViewController
@synthesize index;
@synthesize headerScrollView;
@synthesize headerPageControl;
@synthesize courseBriefLabel, courseTitleLabel;
@synthesize headerSliderArray;
@synthesize allCoursesDataArray;
@synthesize allCoursesDataArrayVisible;
@synthesize myCoursesDataArray;
@synthesize tbvAllCourses;
@synthesize headerView;
@synthesize logoLable, logoView;
@synthesize tbvMyCourses;
@synthesize noCourseView;
@synthesize showButton;
@synthesize tempCoursesDataArray;
@synthesize pageIndex;
@synthesize allCourseFromCacheArray;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        self.isButtonFold = YES;
        self.isFilter = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    pageIndex = 0;

    //添加默认头像
    UIImage *image = [UIImage imageNamed:@"avater_Default.png"];
    NSData *data = UIImagePNGRepresentation([image fixOrientation]);

    [data writeToFile:[ToolsObject getAvatarPath] atomically:YES];

    // Do any additional setup after loading the view from its nib.
    self.tbvAllCourses.separatorStyle = NO;
    self.tbvMyCourses.separatorStyle = NO;
    self.tbvAllCourses.rowHeight = 300;
    self.tbvMyCourses.rowHeight = 110;
    [tbvAllCourses setTableHeaderView:headerView];

    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, 320, 20);
    footView.backgroundColor = [UIColor clearColor];
    [tbvAllCourses setTableFooterView:footView];

    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, 320, 10);
    header.backgroundColor = [UIColor clearColor];
    [tbvMyCourses setTableHeaderView:header];

    //先创建轮播图，防止timer创建2次
    self.headerScrollView =
        [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)
                             animationDuration:5];

    self.tempCoursesDataArray = [[NSMutableArray alloc] init];

    //从缓存加载轮播图
    //[self uncacheHeaderSliders];
    //从缓存加载全部课程
    //[self uncacheAllCourse];
    //从缓存加载badge图标
    //[self uncacheBadges];
    [self loadData:true];
    [self loadData:false];
    [self loadCategory:true];
    [self loadCategory:false];

    [[KKBHttpClient shareInstance] requestACTUrlPathfromCache:YES
        success:^(id result) { NSLog(@"%@", result); }
        failure:^(id result) {}];

    //上拉刷新
    self.tbvAllCourses.pullArrowImage = [UIImage imageNamed:@"arrow"];
    self.tbvAllCourses.pullBackgroundColor = [UIColor clearColor];
    self.tbvAllCourses.pullTextColor = [UIColor blackColor];
    [self.collectionView registerClass:[ContentCell class]
            forCellWithReuseIdentifier:@"CONTENT"];
    //     UICollectionViewLayout *layout =
    //     self.collectionView.collectionViewLayout;
    //     UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout
    //     *)layout;
    //
    //  flow.minimumLineSpacing = 29;
    //  flow.minimumInteritemSpacing =0;

    //    UISwipeGestureRecognizer *t = [[UISwipeGestureRecognizer
    //    alloc]initWithTarget:self action:@selector(swipeView:)];
    //    [self.allCourseButtonView addGestureRecognizer:t];
    //    t.delegate = self;
    //    [t release];

    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 1)];
    [self.line setBackgroundColor:[UIColor grayColor]];
    [self.line.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    [self.line.layer setShadowOffset:CGSizeMake(320, 2)];

    [self.line setAlpha:0.3];
    [self.allCourseContentView addSubview:self.line];
    self.courseLabel.backgroundColor = [UIColor whiteColor];
    self.courseLabel.textAlignment = NSTextAlignmentCenter;
    self.collectionReplaceView.hidden = YES;
}

- (void)loadData:(BOOL)fromCache {
    if (fromCache) {
        [self showLoadingView];
    }
    if (tbvAllCourses.hidden == NO) {
        NSString *jsonUrl2 = @"home-slider.json";
        [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrl2
            method:@"GET"
            param:nil
            fromCache:fromCache
            success:^(id result) {
                self.headerSliderArray = result;
                [self loadAllCoursesHeaderData];
            }
            failure:^(id result) {
                if (fromCache) {
                    [self removeLoadingView];
                    [self showLoadingFailedView];
                }
            }];

        NSString *jsonUrl3 = @"all-courses-meta.json";
        [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrl3
            method:@"GET"
            param:nil
            fromCache:fromCache
            success:^(id result) {
                self.allCoursesDataArray = result;
                self.allCoursesDataArrayVisible = [[NSMutableArray alloc] init];
                for (NSDictionary *courseItem in self.allCoursesDataArray) {
                    if ([[courseItem objectForKey:@"visible"] intValue] == 1) {
                        [self.allCoursesDataArrayVisible addObject:courseItem];
                    }
                }
                [self.tempCoursesDataArray removeAllObjects];
                [self loadMoreDataToTable];
                [tbvAllCourses reloadData];
                [self removeLoadingView];
            }
            failure:^(id result) {
                if (fromCache) {
                    [self removeLoadingView];
                    [self showLoadingFailedView];
                }
            }];

    } else if (tbvMyCourses.hidden == NO) {
        NSString *jsonUrl4 = @"courses?per_page=999999";
        [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrl4
            method:@"GET"
            param:nil
            fromCache:fromCache
            success:^(id result) {
                self.myCoursesDataArray =
                    [NSMutableArray arrayWithArray:result];
                if (self.myCoursesDataArray.count == 0) {
                    noCourseView.hidden = NO;
                    showButton.hidden = NO;
                }
                [self getAllMyCourseData:self.myCoursesDataArray];
                [self.view addSubview:self.tbvMyCourses];
                if (IS_IPHONE_5) {
                    [tbvMyCourses setFrame:CGRectMake(0, 50, 320, 498)];

                } else {
                    [tbvMyCourses setFrame:CGRectMake(0, 50, 320, 410)];
                }
                [self.tbvMyCourses reloadData];

                self.noCourseView.hidden = YES;
                [self removeLoadingView];
            }
            failure:^(id result) {
                if (fromCache) {
                    [self removeLoadingView];
                    [self showLoadingFailedView];
                }
            }];
    }
}

- (void)clickHeader {
    //    NSLog(@"123213");
    for (NSDictionary *allCoursesItem in allCoursesDataArray) {
        // if([allCoursesItem.courseId intValue]== [((HomePageSliderItem
        // *)[self.headerSliderArray objectAtIndex:tickIndex])._id intValue])

        if ([[allCoursesItem objectForKey:@"id"] intValue] ==
            [[[self.headerSliderArray objectAtIndex:tickIndex]
                objectForKey:@"id"] intValue]) {
            [KKBUserInfo shareInstance].courseId =
                [allCoursesItem objectForKey:@"id"];
            NSLog(@"allcourseitem %@", allCoursesItem);
            if ([[allCoursesItem objectForKey:@"courseType"]
                    isEqualToString:@"open"]) {
                // 公开课
                PublicClassViewController *controller =
                    [[PublicClassViewController alloc]
                        initWithNibName:@"PublicClassViewController"
                                 bundle:nil];
                //                controller.myCoursesDataArray =
                //                self.myCoursesDataArray;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^{}];
                //                [self.navigationController
                //                pushViewController:controller animated:YES];
            } else {
                // 导学课
                CourseInfoViewController *controller =
                    [[CourseInfoViewController alloc]
                        initWithNibName:@"CourseInfoViewController"
                                 bundle:nil];
                controller.currentAllCoursesItem = allCoursesItem;
                controller.courseId = [KKBUserInfo shareInstance].courseId;
                //                controller.myCoursesDataArray =
                //                self.myCoursesDataArray;
                //                controller.myBadgeDataArray =
                //                self.myCoursesDataArray;
                [self.navigationController pushViewController:controller
                                                     animated:YES];
            }
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [self.headerScrollView pauseTimer:NO];

    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"all_courses"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.headerScrollView pauseTimer:YES];

    if (self.tbvMyCourses.hidden == YES) {
        [MobClick endLogPageView:@"all_courses"];
    } else {
        [MobClick endLogPageView:@"my_course"];
    }
}

- (void)loadAllCoursesHeaderData {
    if (self.headerSliderArray == nil || [self.headerSliderArray count] == 0) {
        return;
    }
    NSMutableArray *viewsArray = [@[] mutableCopy];

    for (int i = 0; i < [self.headerSliderArray count]; i++) {
        UIImageView *imageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(i * 320, 0, 320, 200)];

        NSDictionary *dic = [self.headerSliderArray objectAtIndex:i];
        NSString *imageUrlString = [dic objectForKey:@"sliderImage"];
        NSURL *imageUrl = [NSURL
            URLWithString:[ToolsObject adaptImageURLforPhone:imageUrlString]];

        [imageView
            sd_setImageWithURL:imageUrl
              placeholderImage:[UIImage imageNamed:@"allcourse_cover_default"]];

        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [viewsArray addObject:imageView];
    }

    //            courseTitleLabel.text = ((HomePageSliderItem
    //            *)[self.headerSliderArray objectAtIndex:0]).courseTitle;
    //            courseBriefLabel.text = ((HomePageSliderItem
    //            *)[self.headerSliderArray objectAtIndex:0]).courseBrief;
    courseTitleLabel.text =
        [[self.headerSliderArray objectAtIndex:0] objectForKey:@"courseTitle"];
    courseBriefLabel.text =
        [[self.headerSliderArray objectAtIndex:0] objectForKey:@"courseBrief"];

    [courseBriefLabel alignTop];

    self.headerScrollView.fetchContentViewAtIndex =
        ^UIView * (NSInteger tempPageIndex) {
        return viewsArray[tempPageIndex];
    };
    __unsafe_unretained HomeViewController *weakSelf = self;
    self.headerScrollView.totalPagesCount =
        ^NSInteger(void) { return [weakSelf.headerSliderArray count]; };
    self.headerScrollView.TapActionBlock = ^(NSInteger pageIndex) {
        //        NSLog(@"点击了第%ld个",(long)pageIndex);
        [weakSelf clickHeader];
    };
    self.headerScrollView.ScrollBlock = ^(NSInteger tempPageIndex) {
        //        NSLog(@"当前第%ld个",(long)pageIndex);
        weakSelf.headerPageControl.currentPage = tempPageIndex;

        weakSelf->tickIndex = (int)tempPageIndex;

        //        courseTitleLabel.text = ((HomePageSliderItem
        //        *)[self.headerSliderArray
        //        objectAtIndex:pageIndex]).courseTitle;
        //        courseBriefLabel.text = ((HomePageSliderItem
        //        *)[self.headerSliderArray
        //        objectAtIndex:pageIndex]).courseBrief;
        if (weakSelf->tickIndex < weakSelf.headerSliderArray.count) {
            weakSelf.courseTitleLabel.text =
                [[weakSelf.headerSliderArray objectAtIndex:weakSelf->tickIndex]
                    objectForKey:@"courseTitle"];
            weakSelf.courseBriefLabel.text =
                [[weakSelf.headerSliderArray objectAtIndex:weakSelf->tickIndex]
                    objectForKey:@"courseBrief"];
        }

        [weakSelf.courseBriefLabel alignTop];
    };
    [self.headerView addSubview:self.headerScrollView];
    [headerView sendSubviewToBack:headerScrollView];

    headerPageControl.numberOfPages = [self.headerSliderArray count];
}
#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT;
    int widht = self.view.bounds.size.width;
    int height = self.view.bounds.size.height - y;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (void)showLoadingView {
    if (_loadingView == nil) {
        _loadingView = [KKBActivityIndicatorView sharedInstance];
        [_loadingView updateFrame:[self loadingViewFrame]];
        [self.view addSubview:_loadingView];
    }

    [_loadingView setHidden:NO];
}

- (void)removeLoadingView {
    [_loadingView setHidden:YES];
}

#pragma mark - Loading Failed Method
- (void)showLoadingFailedView {
    KKBLoadingFailedView *_loadingFailedView =
        [KKBLoadingFailedView sharedInstance];
    [_loadingFailedView updateFrame:[self loadingViewFrame]];
    [_loadingFailedView setTapTarget:self action:@selector(refresh)];
    [self.view addSubview:_loadingFailedView];

    [_loadingFailedView setHidden:NO];
}

- (void)removeLoadingFailedView {
    KKBLoadingFailedView *_loadingFailedView =
        [KKBLoadingFailedView sharedInstance];
    [_loadingFailedView setHidden:YES];
}

- (void)refresh {
    [self removeLoadingFailedView];
    [self loadData:true];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEnd {
    headerPageControl.currentPage = headerScrollView.currentPageIndex;
    tickIndex = (int)headerPageControl.currentPage;

    courseTitleLabel.text =
        ((HomePageSliderItem *)
         [self.headerSliderArray objectAtIndex:headerPageControl.currentPage])
            .courseTitle;
    courseBriefLabel.text =
        ((HomePageSliderItem *)
         [self.headerSliderArray objectAtIndex:headerPageControl.currentPage])
            .courseBrief;
    [courseBriefLabel alignTop];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = [tbvAllCourses contentOffset];

    float p = point.y;

    self.allCourseContentView.top = 244 - p;
    self.coverTableView.top = 244 - p;
    self.allCourseButton.top = 254 - p;
    self.courseLabel.top = 258 - p;

    if (self.allCourseContentView.top <= 44) {
        self.allCourseContentView.top = 44;
        self.coverTableView.top = 44;
        self.allCourseButton.top = 54;
        self.courseLabel.top = 58;
    }

    NSLog(@"tbvtop:%f", point.y);
}

/*po
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView.contentOffset.x < 0 ) {
////        [self previousImageViewWithImage];
////        [scrollView setContentOffset:CGPointMake(320, 0)];
//    }
//    if (scrollView.contentOffset.x > 320*(self.headerSliderArray.count-1)) {
////        [self nextImageViewWithImage];
//        [scrollView setContentOffset:CGPointMake(-320, 0)];
//    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{


    headerPageControl.currentPage = scrollView.contentOffset.x/320;
    tickIndex = (int)headerPageControl.currentPage;

    courseTitleLabel.text = ((HomePageSliderItem *)[self.headerSliderArray
objectAtIndex:headerPageControl.currentPage]).courseTitle;
    courseBriefLabel.text = ((HomePageSliderItem *)[self.headerSliderArray
objectAtIndex:headerPageControl.currentPage]).courseBrief;
    [courseBriefLabel alignTop];
}
*/
- (IBAction)showCourseName:(UIButton *)sender {

    if (self.isButtonFold) {
        self.itemArray =
            [NSMutableArray arrayWithCapacity:self.courseFilter.count];
        // self.collectionView.transform =
        // CGAffineTransformTranslate(self.collectionView.transform, 0, -50);
        self.collectionReplaceView.frame = CGRectMake(0, 0, 320, 50);
        self.collectionReplaceView.hidden = NO;
        self.collectionReplaceView.alpha = 1;
        // self.tbvAllCourses.alpha = 1;
        self.coverTableView.hidden = NO;
        self.coverTableView.alpha = 0.5;

        for (int i = 0; i < self.courseFilter.count; i++) {
            CollectionItemView *item = (CollectionItemView *)
                [self.collectionReplaceView viewWithTag:1000 + i];
            item.transform = CGAffineTransformTranslate(item.transform, 0, -60);
            item.transform = CGAffineTransformScale(item.transform, 0.0, 0.0);
            item.hidden = NO;
            [self.itemArray addObject:item];
        }

        [UIView animateWithDuration:0.6
                         animations:^{
                             // self.collectionView.transform =
                             // CGAffineTransformIdentity;
                             for (int i = 0; i < self.courseFilter.count; i++) {
                                 CollectionItemView *item =
                                     (CollectionItemView *)
                                     [self.collectionReplaceView
                                         viewWithTag:1000 + i];
                                 item.transform = CGAffineTransformIdentity;
                             }

                             self.collectionReplaceView.frame =
                                 CGRectMake(0, 50, 320, 160);

                             // self.coverview.alpha = 1;
                             // self.collectionView.alpha = 1;
                             // self.line.alpha = 0.7;
                             // self.tbvAllCourses.alpha =0.3;
                         }];

        self.tbvAllCourses.userInteractionEnabled = NO;
        [self.allCourseButton
            setBackgroundImage:[UIImage imageNamed:@"allcourses_up.png"]
                      forState:UIControlStateNormal];
        self.isButtonFold = NO;
        self.allCourseContentView.userInteractionEnabled = YES;
    } else {
        self.collectionReplaceView.frame = CGRectMake(0, 50, 320, 160);

        //        [UIView animateWithDuration:0.8 animations:^{
        //
        //            self.collectionView.alpha = 0;
        //        }completion:^(BOOL finished){
        //            self.collectionView.hidden = YES;
        //            self.collectionView.frame = CGRectMake(0, 50, 320, 160);
        //        }];
        [UIView animateWithDuration:0.8
            delay:0
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
                self.collectionReplaceView.alpha = 0;
                self.tbvAllCourses.alpha = 1;
                // self.line.alpha = 0;
                self.coverTableView.alpha = 0;
                // self.coverview.alpha = 0;
            }
            completion:^(BOOL finished) {
                self.coverTableView.hidden = YES;
                self.collectionReplaceView.hidden = YES;
                self.collectionReplaceView.alpha = 1;
                self.collectionReplaceView.frame = CGRectMake(0, 50, 320, 160);
            }];
        //

        // self.collectionView.hidden = YES;
        self.tbvAllCourses.userInteractionEnabled = YES;
        [self.allCourseButton
            setBackgroundImage:[UIImage imageNamed:@"allcourses_down.png"]
                      forState:UIControlStateNormal];
        self.isButtonFold = YES;
        self.allCourseContentView.userInteractionEnabled = NO;
    }
}

- (IBAction)showRightSideBar:(id)sender {
    if ([[SidebarViewController share]
            respondsToSelector:@selector(
                                   showSideBarControllerWithDirection:)]) {
        if ([[SidebarViewController share] getSideBarShowing] == YES) {
            [[SidebarViewController share]
                showSideBarControllerWithDirection:SideBarShowDirectionNone];
        } else {
            [[SidebarViewController share]
                showSideBarControllerWithDirection:SideBarShowDirectionRight];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showAllCourse {
    self.noCourseView.hidden = YES;
    self.showButton.hidden = YES;
    self.tbvAllCourses.hidden = NO;
    self.headerView.hidden = NO;
    self.logoView.hidden = NO;
    self.logoLable.hidden = YES;
    self.tbvMyCourses.hidden = YES;
    self.noCourseView.hidden = YES;
}

- (void)showMyCourseView {
    self.tbvAllCourses.hidden = YES;
    self.tbvMyCourses.hidden = NO;

    self.headerView.hidden = YES;
    self.logoView.hidden = YES;
    self.logoLable.hidden = NO;

    // load data from server
    [self loadData:true];
    [self loadData:false];
}

- (void)showTestViewCtr {
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication
    //    sharedApplication] delegate];
    //    BOOL hasLogined = [appDelegate hasLogined];

    //    if (hasLogined) {
    //        [self presentViewController:[self fourTabsBarController]
    //        animated:YES completion:nil];
    //    } else {
    //        CourseHomeViewController *courseHomeViewCtr =
    //        [[CourseHomeViewController alloc]init];
    //        [self presentViewController:courseHomeViewCtr animated:YES
    //        completion:nil];
    //    }

    CourseHomeViewController *courseHomeViewCtr =
        [[CourseHomeViewController alloc]
            initWithNibName:@"CourseHomeViewController"
                     bundle:nil];
    [self presentViewController:courseHomeViewCtr animated:YES completion:nil];
}

- (void)showDownloadManagerView {
    DownloadManagerViewController *downloadMngViewController =
        [[DownloadManagerViewController alloc]
            initWithNibName:@"DownloadManagerViewController"
                     bundle:nil];
    [self.navigationController pushViewController:downloadMngViewController
                                         animated:YES];
}

- (void)showQRCodeViewController {
    ViewController *scanVC =
        [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)showIFlyViewController {
    IFlyViewController *iFlyVC = [[IFlyViewController alloc] init];
    [self presentViewController:iFlyVC animated:YES completion:nil];
}

- (void)popDownloadManagerView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showButtonOnclick:(id)sender {
    self.noCourseView.hidden = YES;
    self.showButton.hidden = YES;
    self.tbvAllCourses.hidden = NO;
    self.headerView.hidden = NO;
    self.logoView.hidden = NO;
    self.logoLable.hidden = YES;
}

#pragma mark - UITableViewDelegate
//-(CGFloat)tableView:(UITableView *)tableView
// heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if([tableView isEqual:tbvAllCourses]){
//        return 345;
//    }else if([tableView isEqual:tbvMyCourses])
//    {
//        return 110;
//    }
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:tbvAllCourses] && self.tempCoursesDataArray != nil &&
        [self.tempCoursesDataArray count] > 0) {
        // return self.tempCoursesDataArray.count;
        return self.tempCoursesDataArray.count;

    } else if ([tableView isEqual:tbvMyCourses]) {
        return self.allMyCoursesDataArray.count;
    }
    return 0;
}
/*
-(UIImage *)handleImage:(NSString *)imgUrl withFrame:(CGSize)size
{
    UIImageView * tempView = [[[UIImageView alloc]init] autorelease];
    [tempView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject
adaptImageURLforPhone:imgUrl]] placeholderImage:[UIImage
imageNamed:@"allcourse_cover_default.png"]];
    UIImage *image = tempView.image;
    CGRect rect = tempView.frame;
    rect.size.width = size.width;
    rect.size.height = (image.size.height * size.width)/image.size.width;

    tempView.frame = rect;
    [tempView setImage:image];
    CGRect rect1 = CGRectMake(0, 0, size.width, size.height);
    UIImage*lastImage = [tempView.image getSubImage:rect1];
    return lastImage;


}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:tbvAllCourses]) {
        static NSString *cellIdentifier = @"allCourseCellForiPhone";
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"allLesson"
                                                         owner:self
                                                       options:nil];
            cell = [arr objectAtIndex:0];
        }
        //        cell.selectedBackgroundView = [[[UIView alloc]
        //        initWithFrame:cell.frame] autorelease];
        //        cell.selectedBackgroundView.backgroundColor = [UIColor
        //        blueColor];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *courseDic = [NSDictionary dictionary];
        //        if (self.isFilter && self.tempCoursesDataArray !=nil &&) {
        //            courseDic = [self.tempCoursesDataArray
        //            objectAtIndex:indexPath.row];
        //        }
        if (self.tempCoursesDataArray != nil &&
            [self.tempCoursesDataArray count] > 0 &&
            indexPath.row < [self.tempCoursesDataArray count])
            courseDic = [self.tempCoursesDataArray objectAtIndex:indexPath.row];

        UILabel *lbType = (UILabel *)[cell viewWithTag:104];
        if ([@"guide" isEqualToString:[courseDic objectForKey:@"courseType"]]) {
            lbType.text = @"[导学课]";

        } else {
            lbType.text = @"[公开课]";
        }
        [cell.contentView addSubview:lbType];
        UIImageView *_coverImage = (UIImageView *)[cell viewWithTag:102];

        //[_coverImage sd_setImageWithURL:[NSURL URLWithString:[ToolsObject
        // adaptImageURLforPhone:item.coverImage]] placeholderImage:[UIImage
        // imageNamed:@"allcourse_cover_default.png"]];
        [_coverImage
            sd_setImageWithURL:
                [NSURL URLWithString:[ToolsObject
                                         adaptImageURLforPhone:
                                             [courseDic
                                                 objectForKey:@"coverImage"]]]
              placeholderImage:[UIImage
                                   imageNamed:@"allcourse_cover_default.png"]];

        //        _coverImage.image = [self handleImage:item.coverImage
        //        withFrame:_coverImage.frame.size];

        UIImageView *instructorAvatar = (UIImageView *)[cell viewWithTag:110];

        [instructorAvatar
            sd_setImageWithURL:
                [NSURL
                    URLWithString:
                        [ToolsObject
                            adaptImageURL:
                                [courseDic objectForKey:@"instructorAvatar"]]]
              placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];

        UILabel *lbCourseName = (UILabel *)[cell viewWithTag:105];

        lbCourseName.text = [courseDic objectForKey:@"courseName"];

        UILabel *lbCourseBrief = (UILabel *)[cell viewWithTag:106];
        // lbCourseBrief.text = item.courseBrief;
        lbCourseBrief.text = [courseDic objectForKey:@"courseBrief"];

        UILabel *lbCourseIntro = (UILabel *)[cell viewWithTag:107];
        // lbCourseIntro.text = item.courseIntro;
        lbCourseIntro.text = [courseDic objectForKey:@"courseIntro"];

        UILabel *lbTeacherName = (UILabel *)[cell viewWithTag:108];
        // lbTeacherName.text = item.instructorName;
        lbTeacherName.text = [courseDic objectForKey:@"instructorName"];

        UILabel *lbInstructorTitle = (UILabel *)[cell viewWithTag:109];
        // lbInstructorTitle.text = item.instructorTitle;
        lbInstructorTitle.text = [courseDic objectForKey:@"instructorTitle"];

        UILabel *schoolNameTitle = [[UILabel alloc] init];
        [schoolNameTitle
            setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
        [schoolNameTitle setBackgroundColor:[UIColor colorWithRed:0 / 255.0
                                                            green:0 / 255.0
                                                             blue:0 / 255.0
                                                            alpha:0.5]];
        [schoolNameTitle setTextAlignment:NSTextAlignmentCenter];
        schoolNameTitle.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:schoolNameTitle];
        //自适应高度
        // NSString *str = item.schoolName;
        NSString *str = [courseDic objectForKey:@"schoolName"];
        // CGSize size = [str sizeWithFont:[UIFont
        // fontWithName:@"Helvetica-Bold" size:16]
        // constrainedToSize:CGSizeMake(175.0f, 2000.0f)];
        CGRect rect1 = [str
            boundingRectWithSize:CGSizeMake(175.0f, 2000.0f)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:16]
                      } context:nil];
        CGSize size = rect1.size;
        CGRect rect = schoolNameTitle.frame;
        // rect.size.width=size.width + 15;7;
        rect.origin.x = 310 - size.width - 15;
        rect.origin.y = 139;
        [schoolNameTitle setFrame:rect];
        [schoolNameTitle setText:str];

        return cell;

    } else if ([tableView isEqual:tbvMyCourses]) {
        NSString *cellIdentifier = @"myCourseCellForiPhone";
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"myCourseCellForIPhone"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *item =
            [self.allMyCoursesDataArray objectAtIndex:indexPath.row];

        UILabel *courseName = (UILabel *)[cell viewWithTag:205];
        // courseName.text = item.courseName;
        courseName.text = [item objectForKey:@"courseName"];

        UILabel *lbType = (UILabel *)[cell viewWithTag:203];
        // if([@"guide" isEqualToString:item.courseType])
        if ([@"guide" isEqualToString:[item objectForKey:@"courseType"]]) {
            lbType.text = @"[导学课]";

        } else {
            lbType.text = @"[公开课]";
        }

        UILabel *lbTimeTitle = (UILabel *)[cell viewWithTag:204];
        // if ([ToolsObject isBlankString:item.startDate])
        if ([ToolsObject isBlankString:[item objectForKey:@"startDate"]]) {
            lbTimeTitle.text = @"待定";
        } else if ([ToolsObject isLaterCurrentSystemDate:
                                    [item objectForKey:@"startDate"]]) {
            lbTimeTitle.text = [item objectForKey:@"startDate"];
        } else {
            lbTimeTitle.text = @"已结束";
        }

        UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:201];
        [coverImageView
            sd_setImageWithURL:
                [NSURL URLWithString:[ToolsObject
                                         adaptImageURLforPhone:
                                             [item objectForKey:@"coverImage"]]]
              placeholderImage:[UIImage imageNamed:@"mycourse_cover_default"]];
        UIImageView *instructorAvatarImage =
            (UIImageView *)[cell viewWithTag:202];
        [instructorAvatarImage
            sd_setImageWithURL:
                [NSURL URLWithString:
                           [NSString
                               stringWithFormat:
                                   @"%@",
                                   [ToolsObject
                                       adaptImageURL:
                                           [item objectForKey:
                                                     @"instructorAvatar"]]]]];
        UILabel *courseBrief = (UILabel *)[cell viewWithTag:206];
        courseBrief.text = [item objectForKey:@"courseBrief"];
        UILabel *instructorName = (UILabel *)[cell viewWithTag:207];
        instructorName.text = [item objectForKey:@"instructorName"];

        UILabel *instructorTitle = (UILabel *)[cell viewWithTag:208];
        instructorTitle.text = [item objectForKey:@"instructorTitle"];

        UILabel *schoolNameTitle = [[UILabel alloc] init];
        [schoolNameTitle
            setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]];
        [schoolNameTitle setBackgroundColor:[UIColor colorWithRed:0 / 255.0
                                                            green:0 / 255.0
                                                             blue:0 / 255.0
                                                            alpha:0.5]];
        [schoolNameTitle setTextAlignment:NSTextAlignmentCenter];
        schoolNameTitle.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:schoolNameTitle];
        //自适应高度
        NSString *str = [item objectForKey:@"schoolName"];
        // CGSize size = [str sizeWithFont:[UIFont
        // fontWithName:@"Helvetica-Bold" size:12]
        // constrainedToSize:CGSizeMake(175.0f, 2000.0f)];
        CGRect rect1 = [str
            boundingRectWithSize:CGSizeMake(175.0f, 2000.0f)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:12]
                      } context:nil];
        CGSize size = rect1.size;
        CGRect rect = schoolNameTitle.frame;
        rect.size.width = size.width + 8;
        rect.size.height = size.height + 11;
        rect.origin.x = 165 - size.width + 2;
        rect.origin.y = 85 - rect.size.height;

        [schoolNameTitle setFrame:rect];
        [schoolNameTitle setText:str];

        return cell;
    }

    return nil;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([tableView isEqual:tbvAllCourses] && self.tempCoursesDataArray != nil &&
        [self.tempCoursesDataArray count] > 0) {
        NSDictionary *allCoursesItem = [NSDictionary dictionary];

        allCoursesItem =
            [self.tempCoursesDataArray objectAtIndex:indexPath.row];

        [KKBUserInfo shareInstance].courseId =
            [allCoursesItem objectForKey:@"id"];
        if ([[allCoursesItem objectForKey:@"courseType"]
                isEqualToString:@"open"]) {
            // 公开课
            PublicClassViewController *controller =
                [[PublicClassViewController alloc]
                    initWithNibName:@"PublicClassViewController"
                             bundle:nil];
            //            controller.myCoursesDataArray =
            //            self.myCoursesDataArray;
            [self presentViewController:controller animated:YES completion:^{}];
            //            [self.navigationController
            //            pushViewController:controller animated:YES];
        } else {
            // 导学课
            CourseInfoViewController *controller =
                [[CourseInfoViewController alloc]
                    initWithNibName:@"CourseInfoViewController"
                             bundle:nil];
            controller.currentAllCoursesItem = allCoursesItem;
            controller.courseId = [KKBUserInfo shareInstance].courseId;
            //            controller.myCoursesDataArray =
            //            self.myCoursesDataArray;
            //            controller.myBadgeDataArray = self.myCoursesDataArray;
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        }
    } else if ([tableView isEqual:tbvMyCourses]) {
        AppDelegate *delegate =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.TwoLevel = YES;
        [ToolsObject setIsFirstIn:YES];

        if (self.allMyCoursesDataArray == nil ||
            indexPath.row >= self.allMyCoursesDataArray.count) {
            return;
        }

        NSDictionary *myCourseItem =
            [self.allMyCoursesDataArray objectAtIndex:indexPath.row];
        [KKBUserInfo shareInstance].courseId =
            [myCourseItem objectForKey:@"id"];

        if ([[myCourseItem objectForKey:@"courseType"]
                isEqualToString:@"open"]) {
            // 公开课
            PublicClassViewController *controller =
                [[PublicClassViewController alloc]
                    initWithNibName:@"PublicClassViewController"
                             bundle:nil];
            //            controller.courseDetailView.currentAllCoursesItem =
            //            myCourseItem;
            //            controller.myCoursesDataArray =
            //            self.myCoursesDataArray;
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        } else {
            // 导学课
            CourseInfoViewController *controller =
                [[CourseInfoViewController alloc]
                    initWithNibName:@"CourseInfoViewController"
                             bundle:nil];
            controller.currentAllCoursesItem = myCourseItem;
            controller.courseId = [KKBUserInfo shareInstance].courseId;
            //            controller.myBadgeDataArray = self.myCoursesDataArray;
            [self.navigationController pushViewController:controller
                                                 animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:tbvAllCourses]) {
        return 44;
    } else
        return 0;
}
#pragma mark - Refresh and load more methods

- (void)refreshTable {
    /*

     Code to actually refresh goes here.

     */
    self.tbvAllCourses.pullLastRefreshDate = [NSDate date];
    self.tbvAllCourses.pullTableIsRefreshing = NO;
}

- (BOOL)loadMoreDataToTable {
    /*

     Code to actually load more data goes here.

    */
    const int SISE_PER_PAGE = 4;
    pageIndex++;
    if (!self.isFilter) {
        if (SISE_PER_PAGE * pageIndex - SISE_PER_PAGE <
            self.allCoursesDataArrayVisible.count) {

            for (NSInteger i = SISE_PER_PAGE * pageIndex - SISE_PER_PAGE;
                 i < SISE_PER_PAGE * pageIndex; i++) {
                NSLog(@"%ld", (long)i);
                if (i < allCoursesDataArrayVisible.count) {
                    NSDictionary *item =
                        [self.allCoursesDataArrayVisible objectAtIndex:i];

                    [self.tempCoursesDataArray addObject:item];

                } else {
                    break;
                }
            }
            [self.tbvAllCourses reloadData];
        } else {
            [ToolsObject showHUD:@"没有课程啦" andView:self.view];
        }
    } else {
        if (SISE_PER_PAGE * pageIndex - SISE_PER_PAGE <
            self.filterResult.count) {
            for (NSInteger i = SISE_PER_PAGE * pageIndex - SISE_PER_PAGE;
                 i < SISE_PER_PAGE * pageIndex; i++) {
                NSLog(@"%ld", (long)i);
                if (i < self.filterResult.count) {
                    NSDictionary *item = [self.filterResult objectAtIndex:i];
                    [self.tempCoursesDataArray addObject:item];

                } else {
                    break;
                }
            }
            [self.tbvAllCourses reloadData];
        } else {
            [ToolsObject showHUD:@"没有课程啦" andView:self.view];
        }
    }

    self.tbvAllCourses.pullTableIsLoadingMore = NO;
    return YES;
}
#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView {
    [self performSelector:@selector(refreshTable)
               withObject:nil
               afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView {
    [self performSelector:@selector(loadMoreDataToTable)
               withObject:nil
               afterDelay:2.0f];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    //    interfaceOrientation == UIInterfaceOrientationLandscapeRight);

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark uncache data
- (void)uncacheHeaderSliders {

    NSString *cacheFileName = CACHE_HOMEPAGE_HEADERSLIDER;
    // unarchiver
    NSString *homeSliderPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR,
                                    ARCHIVER_HOMEPAGE_HEADERSLIDER, nil];
    self.headerSliderArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:homeSliderPath];
    [self loadAllCoursesHeaderData];
}

+ (void)clearCacheMyCourse {
    NSString *cacheFileName = CACHE_HOMEPAGE_MYCOURSE;
    // unarchiver
    NSString *myCoursePath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_MYCOURSE, nil];
    [FileUtil removeFileAtPath:myCoursePath];
}

- (void)getAllMyCourseData:(NSMutableArray *)myCourseDataArray {
    self.allMyCoursesDataArray =
        [NSMutableArray arrayWithCapacity:myCourseDataArray.count];
    for (int i = 0; i < myCourseDataArray.count; i++) {
        NSDictionary *myCourseDic = [myCourseDataArray objectAtIndex:i];
        NSString *courseId = [myCourseDic objectForKey:@"id"];
        for (int j = 0; j < self.allCoursesDataArray.count; j++) {
            NSDictionary *allCourseDic =
                [self.allCoursesDataArray objectAtIndex:j];
            NSString *allCourseId = [allCourseDic objectForKey:@"id"];
            if ([courseId intValue] == [allCourseId intValue]) {
                [self.allMyCoursesDataArray addObject:allCourseDic];
            }
        }
    }
}
#pragma mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:
                 (UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.courseFilter count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ContentCell *cell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CONTENT"
                                                       forIndexPath:indexPath];

    NSString *courseName = [self.courseFilter objectAtIndex:indexPath.row];
    cell.text = courseName;
    cell.tag = indexPath.row + 1;
    //    UIView *selectBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0,
    //    100, 50)];
    //    [selectBack setBackgroundColor:[UIColor grayColor]];
    UIImageView *selectBack = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"category_pressed.png"]];
    cell.selectedBackgroundView = selectBack;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.courseFilter != nil && self.courseFilter.count > 0) {
        CGSize size =
            [ContentCell sizeForContentString:[self.courseFilter
                                                  objectAtIndex:indexPath.row]];
        CGSize size1 = CGSizeMake(size.width + 32, 22);
        return size1;
    }
    return CGSizeMake(10, 44);
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", (long)indexPath.row);
    // self.allCourseButton.titleLabel.text = [self.courseFilter
    // objectAtIndex:indexPath.row];
    ContentCell *cell =
        (ContentCell *)[self.collectionView viewWithTag:indexPath.row + 1];
    cell.label.textColor = [UIColor whiteColor];
    self.courseLabel.text = [self.courseFilter objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        self.isFilter = NO;
        [self.tempCoursesDataArray removeAllObjects];

        //[self.tbvAllCourses reloadData];

    } else {
        NSPredicate *predicate;
        NSString *name = [self.courseFilter objectAtIndex:indexPath.row];
        predicate = [NSPredicate
            predicateWithFormat:@"%K CONTAINS %@", @"courseCategory", name];
        //    NSMutableArray *array = [NSMutableArray array];
        //    if (self.allCoursesDataArray !=nil) {
        //        for (NSDictionary *dic in self.allCoursesDataArray) {
        //            NSString *courseName = [dic objectForKey:@"courseName"];
        //            [array addObject:courseName];
        //        }
        //
        //    }

        NSArray *result = [self.allCoursesDataArrayVisible
            filteredArrayUsingPredicate:predicate];
        self.filterResult = result;
        NSLog(@"%@", result);
        self.isFilter = YES;
        //[self.tbvAllCourses reloadData];
    }

    [UIView animateWithDuration:0.8
        delay:0
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            self.collectionView.alpha = 0;
            self.tbvAllCourses.alpha = 1;
            // self.line.alpha = 0;
        }
        completion:^(BOOL finished) {

            self.collectionView.hidden = YES;
            self.collectionView.alpha = 1;
        }];

    pageIndex = 0;
    [self.tempCoursesDataArray removeAllObjects];
    if (self.filterResult.count == 0) {
        [self.tbvAllCourses reloadData];
        [ToolsObject showHUD:@"没有课程啦" andView:self.view];
    }
    [self loadMoreDataToTable];
    self.tbvAllCourses.userInteractionEnabled = YES;
    [self.allCourseButton
        setBackgroundImage:[UIImage imageNamed:@"allcourses_down.png"]
                  forState:UIControlStateNormal];
    self.isButtonFold = YES;
    self.allCourseContentView.userInteractionEnabled = NO;
}
- (void)collectionView:(UICollectionView *)collectionView
    didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ContentCell *cell =
        (ContentCell *)[self.collectionView viewWithTag:indexPath.row + 1];
    cell.label.textColor =
        [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
}
- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView
// layout:(UICollectionViewLayout*)collectionViewLayout
// minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 0;
//}

- (void)swipeView:(UISwipeGestureRecognizer *)swipGesture {
    NSLog(@"swipe");
}
- (void)initCollectionView {
    int lastWidth = 0;
    int row = 0;
    // self.itemArray = [NSMutableArray
    // arrayWithCapacity:self.courseFilter.count];
    for (int i = 0; i < self.courseFilter.count; i++) {
        CollectionItemView *item = [[CollectionItemView alloc] init];
        [item setTag:1000 + i];
        item.text = [self.courseFilter objectAtIndex:i];
        if (item.width + lastWidth > self.collectionReplaceView.width) {
            lastWidth = 0;
            row++;
        }
        item.left = lastWidth;
        lastWidth += item.width;
        item.top = 14 + row * 33;
        if (row > 0) {
            item.top = 14 + (row * 33) + 16 * row;
        }

        [self.collectionReplaceView addSubview:item];

        if (i + 1 >= self.courseFilter.count) {
            [item.lineImageView removeFromSuperview];
        } else {
            CollectionItemView *nextItem = [[CollectionItemView alloc] init];

            nextItem.text = [self.courseFilter objectAtIndex:(i + 1)];
            if (lastWidth + nextItem.width > self.collectionReplaceView.width) {
                [item.lineImageView removeFromSuperview];
            }
        }
        [item.labelButton addTarget:self
                             action:@selector(chooseCourse:)
                   forControlEvents:UIControlEventTouchUpInside];
        //[self.itemArray addObject:item];
    }
}
- (void)chooseCourse:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"全部"]) {
        self.isFilter = NO;
        [self.tempCoursesDataArray removeAllObjects];
        self.courseLabel.text = @"全部课程";
    } else {
        for (int i = 0; i < self.courseFilter.count; i++) {
            NSString *course = [self.courseFilter objectAtIndex:i];
            if ([button.titleLabel.text isEqualToString:course]) {
                NSPredicate *predicate;

                predicate =
                    [NSPredicate predicateWithFormat:@"%K CONTAINS %@",
                                                     @"courseCategory", course];
                //    NSMutableArray *array = [NSMutableArray array];
                //    if (self.allCoursesDataArray !=nil) {
                //        for (NSDictionary *dic in self.allCoursesDataArray) {
                //            NSString *courseName = [dic
                //            objectForKey:@"courseName"];
                //            [array addObject:courseName];
                //        }
                //
                //    }

                NSArray *result = [self.allCoursesDataArrayVisible
                    filteredArrayUsingPredicate:predicate];
                self.filterResult = result;
                NSLog(@"%@", result);
                self.isFilter = YES;
            }
        }
        self.courseLabel.text = button.titleLabel.text;
    }
    [UIView animateWithDuration:0.8
        delay:0
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
            self.collectionReplaceView.alpha = 0;
            self.coverTableView.alpha = 0;
            self.tbvAllCourses.alpha = 1;
            // self.line.alpha = 0;
        }
        completion:^(BOOL finished) {
            self.coverTableView.hidden = YES;
            self.collectionReplaceView.hidden = YES;
            self.collectionReplaceView.alpha = 1;
        }];

    pageIndex = 0;
    [self.tempCoursesDataArray removeAllObjects];
    if (self.filterResult.count == 0 &&
        ![button.titleLabel.text isEqualToString:@"全部"]) {
        [self.tbvAllCourses reloadData];
        [ToolsObject showHUD:@"没有课程啦" andView:self.view];
    }
    [self loadMoreDataToTable];
    self.tbvAllCourses.userInteractionEnabled = YES;
    [self.allCourseButton
        setBackgroundImage:[UIImage imageNamed:@"allcourses_down.png"]
                  forState:UIControlStateNormal];
    self.isButtonFold = YES;
    [button setSelected:YES];
    CollectionItemView *item = (CollectionItemView *)[button superview];
    item.pressImageView.hidden = NO;
    NSMutableArray *deleteArray =
        [NSMutableArray arrayWithArray:self.itemArray];
    [deleteArray removeObject:item];
    for (CollectionItemView *courseItem in deleteArray) {
        courseItem.pressImageView.hidden = YES;
        [courseItem.labelButton setSelected:NO];
    }
    self.allCourseContentView.userInteractionEnabled = NO;
}
- (void)loadCategory:(BOOL)fromCache {
    NSString *jsonUrl5 = @"categories.json";
    NSString *allCourse = @"全部";

    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrl5
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            NSMutableArray *courseFilter1 = [[NSMutableArray alloc] init];
            courseFilter1 = result;

            self.courseFilter = [NSMutableArray arrayWithArray:courseFilter1];
            [self.courseFilter insertObject:allCourse atIndex:0];
            [self initCollectionView];
        }
        failure:^(id result) {}];
}

- (void)dealloc {
    _loadingView = nil;
}

@end
