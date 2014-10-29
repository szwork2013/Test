//
//  CourseInfoViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-22.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "CourseInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GlobalOperator.h"
#import "ToolsObject.h"
#import "HomePageOperator.h"
#import "UIImageView+WebCache.h"
#import "UIImage+fixOrientation.h"
#import "CourseUnitOperator.h"
#import "Cell1.h"
#import "Cell2.h"
#import "JSONKit.h"
#import "FileUtil.h"
#import "SidebarLevelTwoViewController.h"
#import "AppDelegate.h"
#import "LoginAndRegistViewController.h"
#import "SidebarViewController.h"
#import "RightSideBarViewController.h"
#import "KKBMoviePlayerController.h"
#import "PlayerFrameView.h"
#import <AVFoundation/AVFoundation.h>
#import "KKBHttpClient.h"
#import "MobClick.h"
#import "FilesDownManage.h"
#import "FileModel.h"
#import "LocalStorage.h"
#import "UIView+ViewFrameGeometry.h"
#import "CourseDetailView.h"
#import "KKBUserInfo.h"
#import "KKBActivityIndicatorView.h"
#import "ShareButtonView.h"
#import "UIView+ViewFrameGeometry.h"
#import "UMSocial.h"
#import "UMSocialControllerService.h"

#define NAVIGATION_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20
#define TAB_BAR_HEIGHT 50
#define degreesToRadians(x) (M_PI * x / 180.0f)

@interface CourseInfoViewController () {
    HomePageOperator *homePageOperator;
    CourseUnitOperator *courseUnitOperator;
    NSString *itemID;
}
@property(nonatomic, assign) KKBMoviePlayerController *moviePlayer;
@end

@implementation CourseInfoViewController
@synthesize btnArrange, btnbreif, btnInfo, btnPaly;
@synthesize lbDayTime, lbNumber, lbSchool, lbStartTime, lbTeacher, lbType,
    lbBrief, lbKeyWords, lbCourseName;
@synthesize currentAllCoursesItem;
@synthesize imgView;
@synthesize wbBrief;
@synthesize selectIndex;
//@synthesize unitTableView;
@synthesize currentSecondLevelUnitList, currentUnitList;
@synthesize badgeView;
@synthesize myScrollView;
@synthesize myCoursesDataArray;
@synthesize btnEntroll;
@synthesize bgView;
@synthesize myBadgeDataArray;
@synthesize courseName, courseImage, courseId;
//@synthesize playerFrameView;
@synthesize playerFrameViewBasic;
@synthesize currentSecondLevelVideoList;
@synthesize selectVideoURL;
@synthesize goOnButton;
@synthesize courseDetailView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isOpen = NO;

        self.currentSecondLevelUnitList = [[NSMutableArray alloc] init];
        self.currentSecondLevelVideoList = [[NSArray alloc] init];

        // add
        //        self.openedInSectionArr = [[[NSMutableArray alloc] init]
        //        autorelease];

        // Custom initialization
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        courseUnitOperator =
            (CourseUnitOperator *)[[GlobalOperator sharedInstance]
                getOperatorWithModuleType:KAIKEBA_MODULE_COURSEUNIT];
    }
    return self;
}

- (IBAction)clickbtnInfo {
    if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] == YES) {
        self.goOnButton.hidden = NO;
        self.bgView.top = 249;
        self.enrollButtonView.hidden = YES;
        self.btnEntroll.hidden = YES;
        [self.goOnButton setTitle:@"继续学习" forState:UIControlStateNormal];
    } else {
        self.enrollButtonView.hidden = NO;
        self.btnEntroll.hidden = NO;
    }

    [MobClick endLogPageView:@"course_detail_introduction"];
    [MobClick endLogPageView:@"course_detail_arragement"];
    [MobClick beginLogPageView:@"course_detail_basic"];

    //[self.courseDetailView.playerFrameView stopMovie];
    [self resetbtn];
    [btnInfo
        setBackgroundImage:[UIImage imageNamed:@"tab_button01_infor_selected"]
                  forState:UIControlStateNormal];
    wbBrief.hidden = YES;
#pragma mark - 需要删除
    //    unitTableView.hidden = YES;
    myScrollView.hidden = NO;
    self.courseDetailView.hidden = YES;
}
- (IBAction)clickbtnbreif {
    [MobClick endLogPageView:@"course_detail_basic"];
    [MobClick endLogPageView:@"course_detail_arragement"];
    [MobClick beginLogPageView:@"course_detail_introduction"];

    //[self.courseDetailView.playerFrameView stopMovie];
    //[self.playerFrameViewBasic stopMovie];
    [self.playerFrameViewBasic.player pauseContent];
    NSLog(@"btnEntroll title is %@", btnEntroll.titleLabel.text);
    if (NO && [btnEntroll.titleLabel.text isEqualToString:@"注册此课程"]) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"提示"
                                       message:@"请先注册此课程"
                                      delegate:self
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self resetbtn];
        [self loadDataIntroduction:YES];
        [btnbreif
            setBackgroundImage:[UIImage
                                   imageNamed:@"tab_button02_infor_selected"]
                      forState:UIControlStateNormal];

        myScrollView.hidden = YES;
        wbBrief.hidden = NO;
//    courseArrangeView.hidden = YES;
#pragma mark - 需要删除的地方
        //        unitTableView.hidden = YES;
        self.courseDetailView.hidden = YES;
    }
}
- (IBAction)clickbtnArrange {
    [MobClick endLogPageView:@"course_detail_basic"];
    [MobClick endLogPageView:@"course_detail_introduction"];
    [MobClick beginLogPageView:@"course_detail_arragement"];

    //[self.playerFrameViewBasic stopMovie];
    [self.playerFrameViewBasic.player pauseContent];
    if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] == NO) {
        // if ([btnEntroll.titleLabel.text isEqualToString:@"注册此课程"]) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"提示"
                                       message:@"请先注册此课程"
                                      delegate:self
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self resetbtn];
        //        [self loadDataArrange:YES];
        [btnArrange
            setBackgroundImage:[UIImage
                                   imageNamed:@"tab_button03_infor_selected"]
                      forState:UIControlStateNormal];

        myScrollView.hidden = YES;
        wbBrief.hidden = YES;
//    courseArrangeView.hidden = NO;
#pragma mark - 需要删除的地方
        if (selectVideoURL != nil) {
            self.courseDetailView.playerFrameView.promoVideoStr =
                selectVideoURL;
        } else {
            self.courseDetailView.playerFrameView.promoVideoStr =
                [currentAllCoursesItem objectForKey:@"promoVideo"];
        }
        self.courseDetailView.playerFrameView.strCourseID = self.courseId;
        self.courseDetailView.playerFrameView.imageURL = self.courseImage;
        self.courseDetailView.hidden = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self enrollCourseOnclick];
    }
}

#pragma mark DownloadDelegate Method
- (void)updateNumbersOfDownloading:(NSDictionary *)numbersByCourse {
}

#pragma mark - added by guojun

- (void)addShareButton {
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
        initWithImage:[UIImage imageNamed:@"share icon"]
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(shareButtonDidPress:)];

    self.navigationItem.rightBarButtonItem = shareButton;
}

- (NSString *)getUserId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId = [prefs objectForKey:@"USER_ID"];

    return userId;
}

- (void)initbackImageWithBasic {
    self.playerFrameViewBasic.imageURL =
        [ToolsObject adaptImageURLforPhone:[currentAllCoursesItem
                                               objectForKey:@"coverImage"]];
    NSLog(@"imageURL is %@", self.playerFrameViewBasic.imageURL);
    [self.playerFrameViewBasic initImage];
}

- (void)resetbtn {
    [btnInfo
        setBackgroundImage:[UIImage imageNamed:@"tab_button01_infor_normal"]
                  forState:UIControlStateNormal];
    [btnbreif
        setBackgroundImage:[UIImage imageNamed:@"tab_button02_infor_normal"]
                  forState:UIControlStateNormal];
    [btnArrange
        setBackgroundImage:[UIImage imageNamed:@"tab_button03_infor_normal"]
                  forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] == YES) {
        self.goOnButton.hidden = NO;
        self.bgView.top = 249;
        self.enrollButtonView.hidden = YES;
        self.btnEntroll.hidden = YES;
        [self.goOnButton setTitle:@"继续学习" forState:UIControlStateNormal];
    }

    [MobClick beginLogPageView:@"course_detail"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //    [ToolsObject showLoading:@"正在努力加载中..." andView:self.view];
    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        self.courseDetailView.frame = CGRectMake(
            0, 100, 320, [[UIScreen mainScreen] bounds].size.height - 100);
    } else {
        self.courseDetailView.frame = CGRectMake(
            0, 100, 320, [[UIScreen mainScreen] bounds].size.height - 100);
    }

    [FilesDownManage sharedInstance].downloadDelegate = self;

    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];

    delegant.isClickEntrollment = NO;

    self.courseId = (NSString *)[currentAllCoursesItem objectForKey:@"id"];

    if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] == YES) {
        self.goOnButton.hidden = NO;
        self.bgView.top = 249;
        self.enrollButtonView.hidden = YES;
        self.btnEntroll.hidden = YES;
        [self.goOnButton setTitle:@"继续学习" forState:UIControlStateNormal];
    }
    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        self.enrollButtonView.frame = CGRectMake(0, 492, 320, 64);
        self.btnEntroll.frame = CGRectMake(10, 501, 300, 46);
    }
    [self loadData:YES];
    [self loadData:NO];

    if ([@"guide" isEqualToString:[currentAllCoursesItem
                                      objectForKey:@"courseType"]]) {
        lbType.text = @"导学课";
    } else {
        lbType.text = @"公开课";
    }
    self.lbDayTime.text = [currentAllCoursesItem objectForKey:@"estimate"];
    self.lbStartTime.text = [currentAllCoursesItem objectForKey:@"startDate"];
    self.lbNumber.text = [currentAllCoursesItem objectForKey:@"courseNum"];
    self.lbSchool.text = [currentAllCoursesItem objectForKey:@"schoolName"];
    self.lbTeacher.text =
        [currentAllCoursesItem objectForKey:@"instructorName"];
    self.lbKeyWords.text =
        [NSString stringWithFormat:@"课程关键字：%@",
                                   [currentAllCoursesItem
                                       objectForKey:@"courseKeywords"]];
    self.lbBrief.text = [currentAllCoursesItem objectForKey:@"courseIntro"];
    self.lbCourseName.text = [currentAllCoursesItem objectForKey:@"courseName"];

    //    UIImageView * tempView = [[[UIImageView
    //    alloc]initWithFrame:CGRectMake(0, 0, 310, 170)]autorelease];
    //    [tempView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject
    //    adaptImageURL:currentAllCoursesItem.coverImage]]
    //    placeholderImage:[UIImage imageNamed:@"allcourse_cover_default.png"]];
    //    CGRect rect =  imgView.frame;
    //    CGImageRef cgimg = CGImageCreateWithImageInRect([tempView.image
    //    CGImage], rect);
    //    imgView.image = [UIImage imageWithCGImage:cgimg];
    [self.imgView
        sd_setImageWithURL:
            [NSURL
                URLWithString:[ToolsObject adaptImageURLforPhone:
                                               [currentAllCoursesItem
                                                   objectForKey:@"coverImage"]]]
          placeholderImage:[UIImage imageNamed:@"allcourse_cover_default.png"]];

    //    NSLog(@"%d",currentAllCoursesItem.courseBadges.count);
    int rows;
    if ([(NSArray *)
            [currentAllCoursesItem objectForKey:@"courseBadges"] count] %
            2 ==
        0) {
        rows = (int)([(NSArray *)[currentAllCoursesItem
                         objectForKey:@"courseBadges"] count] /
                     2);
    } else {
        rows = (int)([(NSArray *)[currentAllCoursesItem
                         objectForKey:@"courseBadges"] count] /
                     2) +
               1;
    }
    //    if(isInMyCourse == NO){
    badgeView.frame = CGRectMake(10, 567, 300, 42 * rows + 18);
    //    }else
    //    {
    //         badgeView.frame = CGRectMake(10, 550, 300, 42*rows +18);
    //        bgView.frame = CGRectMake(10, 186, bgView.frame.size.width,
    //        bgView.frame.size.height);
    //    }

    //    if(isInMyCourse == NO){
    //         myScrollView.contentSize =
    //         CGSizeMake(myScrollView.frame.size.width, 1010.0f + 40*rows);

    //    }else
    //    {
    myScrollView.contentSize =
        CGSizeMake(myScrollView.frame.size.width, 1000.0f + 40 * rows);
    //    }
    //    NSLog(@"%lf",myScrollView.contentSize.height-40*rows);
    myScrollView.scrollEnabled = YES;
    myScrollView.delegate = self;

    //    unitTableView.frame = CGRectMake(0, 175, 320, [UIScreen
    //    mainScreen].bounds.size.height - 200);
    self.playerFrameViewBasic.promoVideoStr =
        [currentAllCoursesItem objectForKey:@"promoVideo"];
    self.playerFrameViewBasic.strCourseID = self.courseId;
    self.playerFrameViewBasic.imageURL = self.courseImage;
    self.playerFrameViewBasic.courseName =
        [currentAllCoursesItem objectForKey:@"courseName"];
    self.playerFrameViewBasic.userID = [GlobalOperator sharedInstance].userId;
    [self initbackImageWithBasic];
    self.playerFrameViewBasic.isTheLastMovie = YES;
    self.playerFrameViewBasic.playerFrameDelegate = self;

    self.courseDetailView.hidden = YES;
    self.courseDetailView.currentAllCoursesItem = self.currentAllCoursesItem;
    self.courseDetailView.playerFrameView.promoVideoStr =
        [currentAllCoursesItem objectForKey:@"promoVideo"];
    self.courseDetailView.playerFrameView.strCourseID =
        [KKBUserInfo shareInstance].courseId;
    self.courseDetailView.playerFrameView.imageURL = self.courseImage;
    self.courseDetailView.currentLocation = 120;
    NSMutableArray *array = [NSMutableArray arrayWithObject:self];
    self.courseDetailView.viewControllerArray = array;
    self.courseDetailView.viewController = self;
    [self.courseDetailView initWithUI];

    [self.navigationController.navigationBar setHidden:NO];
    [self setTitle:[currentAllCoursesItem objectForKey:@"courseName"]];
}
- (void)loadDataIntroduction:(BOOL)fromCache {
    if (fromCache) {
        [self showLoadingView];
    }

    NSString *jsonUrlForIntr = [NSString
        stringWithFormat:@"courses/%@/pages/course-introduction-4tablet",
                         self.courseId];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForIntr
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            NSDictionary *dictResult = (NSDictionary *)result;
            [wbBrief loadHTMLString:[dictResult objectForKey:@"body"]
                            baseURL:nil];

            [self removeLoadingView];
        }
        failure:^(id result) {//
                }];
}

/*
- (void)loadDataArrange:(BOOL)fromCache
{
    if (fromCache) {
        [self showLoadingView];
    }

    NSString *jsonUrlForVideo = [NSString
stringWithFormat:@"api.php?num=666&courseid=%@",self.courseId];
    [[KKBHttpClient shareInstance] requestSuperClassUrlPath:jsonUrlForVideo
method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        self.currentSecondLevelVideoList = (NSArray *)result;
    } failure:^(id result) {

    }];

    NSString *jsonUrlModules = [NSString
stringWithFormat:@"courses/%@/modules?per_page=%d", self.courseId, 999999];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlModules
method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        self.currentUnitList = (NSArray *)result;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
0), ^{
            @synchronized(self.currentSecondLevelUnitList) {
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                [self.currentSecondLevelUnitList removeAllObjects];
                for (int i = 0; i < [self.currentUnitList count]; i++) {
                    NSDictionary *item = [self.currentUnitList objectAtIndex:i];
                    NSString *itemId = [item objectForKey:@"id"];


                    NSString *jsonUrlModulesItems = [NSString
stringWithFormat:@"courses/%@/modules/%@/items?per_page=%d",self.courseId,
itemId, 999999];
                    [[KKBHttpClient shareInstance]
requestLMSUrlPath:jsonUrlModulesItems method:@"GET" param:nil
fromCache:fromCache success:^(id result) {
                        NSLog(@"result is %@",result);
                        [self.currentSecondLevelUnitList addObject:(NSArray
*)result];
                        NSLog(@"currentSecondL is
%@",self.currentSecondLevelUnitList);

                        dispatch_semaphore_signal(sema);

                    } failure:^(id result) {

                        dispatch_semaphore_signal(sema);
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                }
                dispatch_release(sema);
            }


            dispatch_async(dispatch_get_main_queue(), ^{
                if (fromCache) {
                    [self removeLoadingView];
                }

                [unitTableView reloadData];
            });
        });
    } failure:^(id result) {

    }];

}
*/

- (void)loadBadgesWithArray:(NSArray *)allBadgesArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([(NSArray *)
            [currentAllCoursesItem objectForKey:@"courseBadges"] count] > 0) {
        for (int i = 0; i < [(NSArray *)[currentAllCoursesItem
                                objectForKey:@"courseBadges"] count];
             i++) {
            [array addObject:[allBadgesArray
                                 objectAtIndex:[[[currentAllCoursesItem
                                                   objectForKey:@"courseBadges"]
                                                   objectAtIndex:i] intValue] -
                                               1]];
        }
    }
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            NSDictionary *badge = [array objectAtIndex:i];
            if ((i + 1) % 2 == 0) {
                UIImageView *imageView = [[UIImageView alloc]
                    initWithFrame:CGRectMake(15 + 150, 18 + 42 * (int)(i / 2),
                                             24, 24)];
                [imageView
                    sd_setImageWithURL:
                        [NSURL URLWithString:
                                   [ToolsObject
                                       adaptImageURLforPhone:
                                           [badge objectForKey:@"image4big"]]]
                      placeholderImage:nil];
                [badgeView addSubview:imageView];
                UILabel *lable = [[UILabel alloc]
                    initWithFrame:CGRectMake(45 + 150, 18 + 42 * (int)(i / 2),
                                             100, 24)];
                lable.text = [badge objectForKey:@"badgeTitle"];
                lable.font = [UIFont fontWithName:@"Helvetica" size:14];
                lable.textColor = [UIColor colorWithRed:102.0 / 255.0
                                                  green:102.0 / 255.0
                                                   blue:102.0 / 255.0
                                                  alpha:1.0];
                [badgeView addSubview:lable];
            } else {
                UIImageView *imageView = [[UIImageView alloc]
                    initWithFrame:CGRectMake(15, 18 + 42 * (int)(i / 2), 24,
                                             24)];
                [imageView
                    sd_setImageWithURL:
                        [NSURL URLWithString:
                                   [ToolsObject
                                       adaptImageURLforPhone:
                                           [badge objectForKey:@"image4big"]]]
                      placeholderImage:nil];
                [badgeView addSubview:imageView];

                UILabel *lable = [[UILabel alloc]
                    initWithFrame:CGRectMake(45, 18 + 42 * (int)(i / 2), 100,
                                             24)];
                lable.text = [badge objectForKey:@"badgeTitle"];
                lable.font = [UIFont fontWithName:@"Helvetica" size:14];
                lable.textColor = [UIColor colorWithRed:102.0 / 255.0
                                                  green:102.0 / 255.0
                                                   blue:102.0 / 255.0
                                                  alpha:1.0];
                [badgeView addSubview:lable];
            }
        }
    }
}

- (void)loadData:(BOOL)fromCache {
    if (fromCache) {
        [self showLoadingView];
    }

    NSString *jsonUrl4 = @"courses?per_page=999999";
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrl4
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            [[LocalStorage shareInstance] removeAllLearnStatus];
            for (NSDictionary *dict in(NSArray *)result) {
                NSString *tempCourseId = [dict objectForKey:@"id"];
                [[LocalStorage shareInstance] saveLearnStatus:YES
                                                       course:tempCourseId];
            }

            [self removeLoadingView];
        }
        failure:^(id result) {}];

    //    [self loadDataIntroduction:fromCache];
    //    [self loadDataArrange:fromCache];
    //    [self.courseDetailView loadData:fromCache];

    NSString *jsonUrlForBadges = @"badges-info.json";
    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrlForBadges
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) { [self loadBadgesWithArray:(NSArray *)result]; }
        failure:^(id result) {}];
}

- (void)showLoginView {
    LoginAndRegistViewController *controller = nil;
    if (IS_IPHONE_5) {
        controller = [[LoginAndRegistViewController alloc]
            initWithNibName:@"LoginAndRegistViewController_iph5"
                     bundle:nil];
    } else {
        controller = [[LoginAndRegistViewController alloc]
            initWithNibName:@"LoginAndRegistViewController"
                     bundle:nil];
    }

    controller.btnBack.hidden = NO;
    controller.btnBack2.hidden = NO;
    controller.logoView.hidden = YES;
    controller.logoView2.hidden = YES;
    controller.courseInfoViewController = self;

    SidebarViewController *con = (SidebarViewController *)
        [self.parentViewController parentViewController];
    controller.sideBarViewController = con.rightSideBarViewController;
    //    NSLog(@"%@",(RightSideBarViewController*)[self.parentViewController
    //    parentViewController].rightSideBarViewController);
    [self presentViewController:controller animated:NO completion:nil];
    controller.loginView.hidden = NO;
    controller.registView.hidden = YES;
}

- (void)shareButtonDidPress:(UIButton *)sender {

    //[UMSocialConfig addSocialSnsPlatform:[NSArray
    //arrayWithObjects:UMShareToInstagram,nil]];
    [UMSocialConfig
        setSnsPlatformNames:
            [NSArray arrayWithObjects:UMShareToSina, UMShareToTencent,
                                      UMShareToRenren, UMShareToDouban,
                                      UMShareToQzone, UMShareToWechatSession,
                                      UMShareToWechatTimeline,
                                      UMShareToWechatFavorite, nil]];
    [[UMSocialControllerService defaultControllerService]
            setShareText:@"#新课抢先知#"
                         @"这课讲的太屌了，朕灰常满意！小伙伴们不要太想我，我"
                         @"在@开课吧 虐学渣，快来和我一起吧！下载地址："
              shareImage:[UIImage imageNamed:@"icon.png"]
        socialUIDelegate:nil];
    UMSocialIconActionSheet *sheet =
        [[UMSocialControllerService defaultControllerService]
            getSocialIconActionSheetInController:self];

    [sheet showInView:self.view.window];

    //    [UMSocialSnsService presentSnsIconSheetView:self
    //                                         appKey:nil
    //                                      shareText:@"你要分享的文字"
    //                                     shareImage:[UIImage
    //                                     imageNamed:@"icon.png"]
    //                                shareToSnsNames:[NSArray
    //                                arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,nil]
    //                                       delegate:nil];

    //    ShareButtonView *shareView = [[ShareButtonView
    //    alloc]initWithFrame:CGRectMake(0, self.view.bottom-274, 320, 274)];
    //    shareView.transform = CGAffineTransformTranslate(shareView.transform,
    //    0, 274);
    //    [self.view addSubview:shareView];
    //    [UIView animateWithDuration:0.6 animations:^{
    //        shareView.transform = CGAffineTransformIdentity;
    //    }];
}

- (IBAction)enrollCourseOnclick {
    //    [self.playerFrameView stopMovie];
    //[self.courseDetailView.playerFrameView stopMovie];

    if ([GlobalOperator sharedInstance].isLogin) {
        if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] ==
            NO) {
            //            [ToolsObject showLoading:@"加载中……"
            //            andView:self.view];
            [self showLoadingView];

            [[KKBHttpClient shareInstance] enrollCourseId:self.courseId
                userId:[GlobalOperator sharedInstance].userId
                success:^(id result) {
                    // 保存用户是否已学习过此课程的状态
                    [self loadData:NO];
                    [self loadDataIntroduction:YES];
                    //                 [self loadDataArrange:YES];
                    [self.courseDetailView loadData:YES];

                    [[LocalStorage shareInstance]
                        saveLearnStatus:YES
                                 course:[currentAllCoursesItem
                                            objectForKey:@"id"]];
                    //                 [ToolsObject closeLoading:self.view];
                    [self removeLoadingView];

                    [ToolsObject
                        showHUD:@"添加成功，请到我的课程查看"
                        andView:self.view];
                    [self switchToCourseArrangeTab];
                }
                failure:^(id result) {
                    [self removeLoadingView];
                    [self showLoadingFailedView];
                    //                [ToolsObject closeLoading:self.view];
                    [ToolsObject showHUD:@"课程添加失败" andView:self.view];
                }];
        } else {
            [self switchToCourseArrangeTab];
        }
        self.btnEntroll.hidden = YES;
        self.enrollButtonView.hidden = YES;
    } else {
        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegant.isClickEntrollment = YES;
        [self showLoginView];
    }
}

#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT + TAB_BAR_HEIGHT;
    int widht = self.view.frame.size.width;
    int height = [[UIScreen mainScreen] bounds].size.height - y;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}
- (void)showLoadingView {
    if (_loadingView == nil) {
        _loadingView = [[KKBActivityIndicatorView alloc]
            initWithFrame:[self loadingViewFrame]];
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

- (void)switchToCourseArrangeTab {
    [btnArrange sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)showCourseModul {
    AppDelegate *delegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.TwoLevel = YES;
}

- (IBAction)back {
    //[self.courseDetailView.playerFrameView stopMovie];

    //[self.playerFrameViewBasic stopMovie];
    [self.playerFrameViewBasic.player pauseContent];
    self.playerFrameViewBasic.player = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"course_detail"];
    [MobClick endLogPageView:@"course_detail_basic"];
    [MobClick endLogPageView:@"course_detail_introduction"];
    [MobClick endLogPageView:@"course_detail_arragement"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    willChangeOrientationTo:(UIInterfaceOrientation)orientation {

    NSLog(@"videoPlayer is %@", videoPlayer);
    NSLog(@"orientation is %d", orientation);

    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // self playerframeview
        self.myScrollView.frame = CGRectMake(0, 0, 548, 320);
        [self.myScrollView setScrollEnabled:NO];
        self.shadowView.hidden = YES;
        [self.btnEntroll setHidden:YES];
        [self.enrollButtonView setHidden:YES];
        self.goOnButton.hidden = YES;
        self.playerFrameViewBasic.player.view.view.frame =
            self.playerFrameViewBasic.player.view.frame;
        self.playerFrameViewBasic.player.view.view.clipsToBounds = NO;
        [self.playerFrameViewBasic.player.view.view becomeFirstResponder];
    } else {
        self.myScrollView.frame = CGRectMake(0, 94, 320, 366);
        if ([GlobalOperator sharedInstance].isLogin) {
            if ([[LocalStorage shareInstance] getLearnStatusBy:self.courseId] ==
                NO) {
                // 没学习过
                self.enrollButtonView.hidden = NO;
                self.btnEntroll.hidden = NO;
                self.goOnButton.hidden = YES;
            } else { // 已注册课程
                self.enrollButtonView.hidden = YES;
                self.btnEntroll.hidden = YES;
                self.goOnButton.hidden = NO;
            }
        } else {
            self.enrollButtonView.hidden = NO;
            self.btnEntroll.hidden = NO;
            self.goOnButton.hidden = YES;
        }
        [self.myScrollView setScrollEnabled:YES];
        self.shadowView.hidden = NO;
    }
    // self vkvideoplayer
    CGFloat degrees = [self degreesForOrientation:orientation];
    UIInterfaceOrientation lastOrientation =
        self.playerFrameViewBasic.player.visibleInterfaceOrientation;
    self.playerFrameViewBasic.player.visibleInterfaceOrientation = orientation;
    [UIView animateWithDuration:0.3f
        animations:^{
            CGRect bounds = [[UIScreen mainScreen] bounds];
            CGRect parentBounds;
            CGRect viewBoutnds;
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                viewBoutnds = CGRectMake(
                    0, 0, CGRectGetWidth(
                              self.playerFrameViewBasic.player.landscapeFrame) -
                              20,
                    CGRectGetHeight(
                        self.playerFrameViewBasic.player.landscapeFrame));
                parentBounds = CGRectMake(0, 0, CGRectGetHeight(bounds) - 20,
                                          CGRectGetWidth(bounds));
                if (self.myScrollView != nil) {
                    CGRect wvFrame = self.myScrollView.frame;
                    if (wvFrame.origin.y >= 0) {
                        wvFrame.size.height = CGRectGetHeight(bounds);
                        wvFrame.origin.y = 0;
                        self.myScrollView.frame = wvFrame;
                    }
                }
            } else {
                viewBoutnds = CGRectMake(0, 0, 320, 180);
                parentBounds = CGRectMake(0, 0, 320, 180);
                if (self.myScrollView != nil) {
                    CGRect wvFrame = self.myScrollView.frame;
                    wvFrame.size.height = CGRectGetHeight(bounds);
                    if ([self.myScrollView
                            isKindOfClass:[UIScrollView class]]) {
                        wvFrame.origin.y = 94;
                    } else {
                        wvFrame.origin.y = 44;
                    }
                    self.myScrollView.frame = wvFrame;
                }
            }
            self.playerFrameViewBasic.transform =
                CGAffineTransformMakeRotation(degreesToRadians(degrees));
            self.playerFrameViewBasic.bounds = parentBounds;

            [self.playerFrameViewBasic setFrameOriginX:0.0f];
            [self.playerFrameViewBasic setFrameOriginY:0.0f];

            self.playerFrameViewBasic.player.view.bounds = viewBoutnds;
            [self.playerFrameViewBasic.player.view setFrameOriginX:0.0f];
            [self.playerFrameViewBasic.player.view setFrameOriginY:0.0f];
            [self.playerFrameViewBasic.player.view
                layoutForOrientation:orientation];
        }
        completion:^(BOOL finished) {
            if ([self.playerFrameViewBasic.player.delegate
                    respondsToSelector:@selector(videoPlayer:
                                           didChangeOrientationFrom:)]) {
                [self.playerFrameViewBasic.player.delegate
                                 videoPlayer:self.playerFrameViewBasic.player
                    didChangeOrientationFrom:lastOrientation];
            }
        }];
}

- (CourseInfoViewController *)courseInfoViewController {
    id next = [self nextResponder];
    do {
        if ([next isKindOfClass:[CourseInfoViewController class]]) {
            return next;
        } else {
            next = [next nextResponder];
        }
    } while (next != nil);
    return nil;
}

- (CGFloat)degreesForOrientation:(UIInterfaceOrientation)deviceOrientation {
    switch (deviceOrientation) {
    case UIInterfaceOrientationPortrait:
        return 0;
        break;
    case UIInterfaceOrientationLandscapeRight:
        return 90;
        break;
    case UIInterfaceOrientationLandscapeLeft:
        return -90;
        break;
    case UIInterfaceOrientationPortraitUpsideDown:
        return 180;
        break;
    }
}

#pragma mark BaseOperatorDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

#endif

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
    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (void)dealloc {
    _loadingView = nil;
}

@end
