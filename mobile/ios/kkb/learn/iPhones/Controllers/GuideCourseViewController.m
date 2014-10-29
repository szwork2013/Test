//
//  GuideCourseViewController.m
//  learn
//
//  Created by zxj on 14-7-30.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideCourseViewController.h"
#import "UIView+ViewFrameGeometry.h"
#import "KKBHttpClient.h"
#import "KCourseItem.h"
#import "KKBCourseSummaryItem.h"
#import "KKBCourseWeekItem.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "KKBUserInfo.h"
#import "AppUtilities.h"
#import "LocalStorage.h"
#import "GlobalOperator.h"
#import "PublicClassViewController.h"
#import "UMSocial.h"
#import "UMSocialConfig.h"
#import "LocalStorage.h"
#import "LoginViewController.h"
#import "KKBUserInfo.h"
#import "GuideCourseEnrolledViewController.h"
#import "DifficultCard.h"
#import "CoursesIntroCell.h"
#import "TeacherIntroCell.h"
#import "CertificationIntroCell.h"
#import "CourseDetailTreeOneCell.h"
#import "CourseDetailTreeTwoCell.h"
#import "CourseItemCell.h"
#import "RTLabel.h"
#import "CheckClassCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "AppUtilities.h"
#import "MobClick.h"
#import "SDWebImageDownloader.h"
#import "KKBBaseNavigationController.h"

#define degreesToRadians(x) (M_PI * x / 180.0f)
#define navigationHeight 0
#define SEGEMENT_BAR_HEIGHT 44

#define navigationRightButton_rectSide 28

#define navagationPlusStatusBar_Height 64
#define bottomButton_Height 48

static const CGFloat Offset = 48.0f;

@interface GuideCourseViewController () {
    LoginViewController *loginViewCtr;
    NSDictionary *_nearestEnrolledClass;
    NSDictionary *_courseInfoDict;
    UIView *_coolStartView;
    UIView *_coverView;
    BOOL coolStarViewShow;

    UIImage *_shareImage;

    UIButton *collectionButton;
    UIButton *shareButton;
    __weak KKBBaseNavigationController *navigation;
    id _itemToBeExpanded;

    CGSize basicInfoScrollViewContentSize;
}
@property(nonatomic, strong) NSArray *sectionsArray;
@property(nonatomic, strong) NSMutableIndexSet *expandableSections;

@end

@implementation GuideCourseViewController

#pragma mark - LifeCycle Methods

- (void)dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isLearnButtonFold = YES;
        isCheckButtonFold = YES;
        self.hidesBottomBarWhenPushed = YES;

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 如在子页面做了收藏操作再回到当前页面，则需要重新从网络上请求收藏状态
    [self requestCollectionStatus:YES];
    [self requestCollectionStatus:NO];
    self.navigationController.navigationBar.hidden = NO;

    [MobClick beginLogPageView:@"GuideCourse"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navCoverViewTap)
                                                 name:navigationBarCoverTap
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"GuideCourse"];

    navigation.allowShowCoverView = NO;
    //查看其他班次按钮复原
    self.checkOtherButton.frame = CGRectMake(160, 0, 160, 48);
    self.goOnStudyButton.left = 0;
    self.checkOtherViewLine.left = 160;
    self.checkOtherClassView.top =
        G_SCREEN_HEIGHT - bottomButton_Height - navagationPlusStatusBar_Height;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:navigationBarCoverTap
                                                  object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.buttonView.top = 0;
    self.firstButtonBaseView.top = self.buttonView.bottom;
    self.secondButtonBaseView.top = self.buttonView.bottom;
    self.ThirdButtonBaseView.top = self.buttonView.bottom;
    self.fourthButtonBaseView.top = self.buttonView.bottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _courseInfoDict = [[NSDictionary alloc] init];
    _nearestEnrolledClass = [[NSDictionary alloc] init];
    self.allowRemovePlayer = YES; // push时销毁播放器

    [KKBCourseManager getCourseWithID:@([self.courseId intValue])
                          forceReload:NO
                    completionHandler:^(id model, NSError *error) {
                        self.guideCourseDictionary = model;

                        [self customInit];
                        [self.infoTableView reloadData];

                        [self playVideoIfNeededLater];
                    }];
}

#pragma mark - Custom Methods

- (void)playVideoIfNeededLater {
    // 延迟执行以避免闪退
    [self performSelector:@selector(playVideoIfNeeded)
               withObject:nil
               afterDelay:0.2f];
}
- (void)playVideoIfNeeded {

    if (self.playVideoImmediately) {
        [self.player playButtonPressed];
    }
}

- (void)customInit {
    [[SDWebImageDownloader sharedDownloader]
        downloadImageWithURL:[NSURL
                                 URLWithString:[self.guideCourseDictionary
                                                   objectForKey:@"cover_image"]]
        options:1
        progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
        completed:^(UIImage *image, NSData *data, NSError *error,
                    BOOL finished) {
            if (finished) {
                _shareImage = image;
            }
        }];

    if ([[self.guideCourseDictionary objectForKeyedSubscript:@"course_outline"]
            isKindOfClass:[NSNull class]]) {

    } else {
        courseTreeArray =
            [self.guideCourseDictionary objectForKey:@"course_outline"];
    }

    relativeCourseDataArray = [[NSMutableArray alloc] init];

    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];
    self.title = [self.guideCourseDictionary objectForKey:@"name"];

    // 导航条右侧两个按钮

    collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [collectionButton
        setBackgroundImage:[UIImage imageNamed:@"kkb-iphone-instructivecourse-"
                                    @"collection-normal"]
                  forState:UIControlStateNormal];

    [collectionButton setFrame:CGRectMake(0, 0, navigationRightButton_rectSide,
                                          navigationRightButton_rectSide)];

    [collectionButton addTarget:self
                         action:@selector(collectionAction:)
               forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item1 =
        [[UIBarButtonItem alloc] initWithCustomView:collectionButton];

    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton
        setBackgroundImage:[UIImage
                               imageNamed:@"kkb-iphone-common-share-normal"]
                  forState:UIControlStateNormal];

    [shareButton
        setBackgroundImage:[UIImage
                               imageNamed:@"kkb-iphone-common-share-selected"]
                  forState:UIControlStateSelected];

    [shareButton setFrame:CGRectMake(0, 0, navigationRightButton_rectSide,
                                     navigationRightButton_rectSide)];

    [shareButton setSelected:NO];
    [shareButton addTarget:self
                    action:@selector(shareAction:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 =
        [[UIBarButtonItem alloc] initWithCustomView:shareButton];

    NSArray *array = [NSArray arrayWithObjects:item2, item1, nil];

    self.navigationItem.rightBarButtonItems = array;

    [self initCoolStartImageView];

    [self initButtonView];
    [self initFirstButtonBaseView];
    [self initSecondButtonBaseView];
    [self initThirdButtonBaseView];
    [self initFourthButtonBaseView];
    [self initCoverView];

    [self requestCollectionStatus:YES];
    [self requestCollectionStatus:NO];

    [self.loadingView setViewStyle:GrayStyle];

    [self.view addSubview:self.learnButtonView];

    [self requestClassInfo:YES];
    [self requestClassInfo:NO];

    [self requestCommentData:YES];
    [self requestCommentData:NO];

    [self.loadingFailedView
        setTapTarget:self
              action:@selector(reloadTableViewDataWhenFailed)];

    [self basicInfoScrollViewContentSize];
}

- (void)basicInfoScrollViewContentSize {
    basicInfoScrollViewContentSize = self.firstButtonBaseView.contentSize;
}

- (void)restoreBasicInfoScrollViewContentSize {

    basicInfoScrollViewContentSize.height += Offset;
    self.firstButtonBaseView.contentSize = basicInfoScrollViewContentSize;
}

- (void)initCoverView {
    _coverView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, 320,
                                 G_SCREEN_HEIGHT - SEGEMENT_BAR_HEIGHT)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5;
    _coverView.userInteractionEnabled = YES;
    [_coverView setHidden:YES];
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapCover:)];
    [_coverView addGestureRecognizer:tap];
    [self.view addSubview:_coverView];

    navigation = (KKBBaseNavigationController *)self.navigationController;
}

- (void)initButtonView {

    [self.buttonView setBackgroundColor:[UIColor colorWithRed:0
                                                        green:142 / 256.0
                                                         blue:236 / 256.0
                                                        alpha:1]];
    buttonArray = [NSMutableArray arrayWithCapacity:4];
    NSArray *buttonNameArray =
        [NSArray arrayWithObjects:@"基本信息", @"课程大纲",
                                  @"查看评价", @"相关推荐", nil];
    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(8 + i * 76, 3, 75, 29)];
        [button setBackgroundImage:[UIImage imageNamed:@"nav_button_MidL_def"]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"nav_button_MidL_sel"]
                          forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithRed:0
                                              green:142 / 256.0
                                               blue:236 / 256.0
                                              alpha:1]
                     forState:UIControlStateSelected];

        if (i == 0) {
            [button
                setBackgroundImage:[UIImage imageNamed:@"nav_button_left1_def"]
                          forState:UIControlStateNormal];
            [button
                setBackgroundImage:[UIImage imageNamed:@"nav_button_left1_sel"]
                          forState:UIControlStateSelected];
            [button setSelected:YES];
        }
        if (i == 3) {
            [button
                setBackgroundImage:[UIImage imageNamed:@"nav_button_right1_def"]
                          forState:UIControlStateNormal];
            [button
                setBackgroundImage:[UIImage imageNamed:@"nav_button_right1_sel"]
                          forState:UIControlStateSelected];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        NSString *title = [buttonNameArray objectAtIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateSelected];
        [button addTarget:self
                      action:@selector(PageChange:)
            forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + i;
        [buttonArray addObject:button];
        [self.buttonView addSubview:button];
    }
}
- (void)initFirstButtonBaseView {
    // player View
    [self.firstButtonBaseView addSubview:self.player.view];
    self.contentScrollView = self.firstButtonBaseView;

    self.firstButtonBaseView.frame =
        CGRectMake(0, -7, 320, [UIScreen mainScreen].bounds.size.height - 49);
    self.firstButtonBaseView.backgroundColor = [UIColor clearColor];

    self.firstButtonBaseView.contentSize = CGSizeMake(320, 1000);
    self.infoTableView.backgroundColor = [UIColor clearColor];
    self.learnButtonView.top =
        G_SCREEN_HEIGHT - bottomButton_Height - navagationPlusStatusBar_Height;

    [self.learnCourseButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateNormal];
    [self.learnCourseButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateHighlighted];

    [self.goOnStudyButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateNormal];
    [self.goOnStudyButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateHighlighted];

    [self.checkOtherButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateNormal];
    [self.checkOtherButton
        setTitleColor:
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1]
             forState:UIControlStateHighlighted];

    [self.learnCourseButton
        setImage:[UIImage imageNamed:@"suspension_icon_study"]
        forState:UIControlStateNormal];
    [self.learnCourseButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];

    [self.goOnStudyButton
        setImage:[UIImage imageNamed:@"suspension_icon_ConToLea"]
        forState:UIControlStateNormal];
    [self.goOnStudyButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];

    [self.checkOtherButton
        setImage:[UIImage imageNamed:@"Suspension_icon_check"]
        forState:UIControlStateNormal];
    [self.checkOtherButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];

    baseViewArray = [NSMutableArray arrayWithObject:self.firstButtonBaseView];

    [self refreshView];
}
- (void)initSecondButtonBaseView {
    self.secondButtonBaseView = [[SLExpandableTableView alloc]
        initWithFrame:CGRectMake(0, 0, 320, G_SCREEN_HEIGHT - 156)];

    _secondButtonBaseView.delegate = self;
    _secondButtonBaseView.dataSource = self;
    _secondButtonBaseView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _secondButtonBaseView.showsVerticalScrollIndicator = NO;
    //    _secondButtonBaseView.showsHorizontalScrollIndicator = NO;
    //    _secondButtonBaseView.showsVerticalScrollIndicator = NO;
    //    _secondButtonBaseView.rowsExpandingAnimation =
    //    RATreeViewRowAnimationNone;
    //    _secondButtonBaseView.rowsCollapsingAnimation =
    //    RATreeViewRowAnimationNone;
    [self.view addSubview:self.secondButtonBaseView];
    [baseViewArray addObject:self.secondButtonBaseView];
    [self.secondButtonBaseView setHidden:YES];
    _expandableSections = [NSMutableIndexSet indexSet];
}
- (void)initThirdButtonBaseView {
    self.view.backgroundColor = [UIColor colorWithRed:244 / 256.0
                                                green:244 / 256.0
                                                 blue:244 / 256.0
                                                alpha:1];
    self.ThirdButtonBaseView = [[UITableView alloc]
        initWithFrame:CGRectMake(8, 0, 304, G_SCREEN_HEIGHT - 156)
                style:UITableViewStyleGrouped];
    _ThirdButtonBaseView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _ThirdButtonBaseView.dataSource = self;
    _ThirdButtonBaseView.delegate = self;
    _ThirdButtonBaseView.showsHorizontalScrollIndicator = NO;
    _ThirdButtonBaseView.showsVerticalScrollIndicator = NO;
    _ThirdButtonBaseView.sectionHeaderHeight = 1;
    _ThirdButtonBaseView.sectionFooterHeight = 1;
    self.ThirdButtonBaseView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.ThirdButtonBaseView];
    [baseViewArray addObject:self.ThirdButtonBaseView];
    [self.ThirdButtonBaseView setHidden:YES];
}
- (void)initFourthButtonBaseView {
    self.fourthButtonBaseView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, 0, 320, G_SCREEN_HEIGHT - 156)
                style:UITableViewStylePlain];
    _fourthButtonBaseView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _fourthButtonBaseView.dataSource = self;
    _fourthButtonBaseView.delegate = self;
    _fourthButtonBaseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.fourthButtonBaseView];
    [baseViewArray addObject:self.fourthButtonBaseView];
    [self.fourthButtonBaseView setHidden:YES];
    [self initRecommendArray];
    [self loadRecommendTableView];
}

- (void)loadRecommendTableView {
    for (NSDictionary *aCourseDict in self.recommendDataArray) {

        NSString *name = [aCourseDict objectForKey:@"name"];
        NSString *imageUrl = [aCourseDict objectForKey:@"cover_image"];
        NSUInteger weeks = [[aCourseDict objectForKey:@"weeks"] intValue];

        NSInteger baseEnrollmentsCount =
            [[aCourseDict objectForKey:@"base_enrollments_count"] integerValue];
        NSInteger enrollmentCount =
            [[aCourseDict objectForKey:@"enrollments_count"] integerValue];
        NSUInteger viewCount = baseEnrollmentsCount + enrollmentCount;

        NSString *type = [aCourseDict objectForKey:@"type"];
        NSUInteger rating = [[aCourseDict objectForKey:@"rating"] intValue];
        NSString *ratingText = [self getRatingStar:rating];
        NSUInteger updatedTo =
            [[aCourseDict objectForKey:@"updatedAmount"] intValue];
        NSString *other =
            [NSString stringWithFormat:@"更新至第%d节视频", updatedTo];
        NSString *courseId = [aCourseDict objectForKey:@"id"];

        NSString *courseIntro = [aCourseDict objectForKey:@"intro"];
        NSString *courseLevel = [aCourseDict objectForKey:@"level"];
        NSString *keyWord = [aCourseDict objectForKey:@"slogan"];
        NSString *coverImage = [aCourseDict objectForKey:@"cover_image"];
        NSString *videoUrl =
            [aCourseDict objectForKey:@"promotional_video_url"];
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

        [relativeCourseDataArray addObject:aCourseItem];
    }

    [_fourthButtonBaseView reloadData];
}

- (void)initRecommendArray {
    self.recommendDataArray = [[NSMutableArray alloc] init];
    NSArray *recommendIdArray =
        [self.guideCourseDictionary objectForKey:@"recommen"];
    if (recommendIdArray.count == 0) {
        coolStarViewShow = YES;
    } else {
        coolStarViewShow = NO;
    }
    if (recommendIdArray != nil) {

        [KKBCourseManager getCoursesWithIDs:recommendIdArray
                                forceReload:NO
                          completionHandler:^(id model, NSError *error) {
                              if (!error) {
                                  self.recommendDataArray = model;
                              }
                          }];
    }
}

- (void)initCoolStartImageView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 44, 320, G_SCREEN_HEIGHT - 64)];
    _coolStartView.backgroundColor = [UIColor colorWithRed:240 / 256.0
                                                     green:240 / 256.0
                                                      blue:240 / 256.0
                                                     alpha:1];

    UIImageView *coolStartImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(80, 122, 160, 120)];

    [coolStartImageView setImage:[UIImage imageNamed:@"icon_kkb"]];

    UILabel *infoLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 280, 16)];
    infoLabel.font = [UIFont systemFontOfSize:16];
    infoLabel.text = @"一大波儿课程正在袭来~";
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor colorWithRed:125 / 256.0
                                          green:125 / 256.0
                                           blue:128 / 256.0
                                          alpha:1];
    [_coolStartView addSubview:infoLabel];

    [_coolStartView addSubview:coolStartImageView];

    [self.view addSubview:_coolStartView];

    coolStarViewShow = NO;
    _coolStartView.hidden = YES;
}

- (void)PageChange:(UIButton *)button {
    if (button.tag == 1003 && coolStarViewShow == YES) {
        _coolStartView.hidden = NO;
        [self.view bringSubviewToFront:_coolStartView];
    } else {
        _coolStartView.hidden = YES;
    }
    for (int i = 0; i < 4; i++) {

        if (button.tag == 1000 + i) {
            //播放器得暂停 且禁止横屏
            if (button.tag == 1000) {
                if (self.videoStatus != VideoStatusUNKnown) {
                    self.allowForceRotation = YES;
                }

            } else {
                self.allowForceRotation = NO;
            }

            [button setSelected:YES];
            NSMutableArray *otherButton =
                [NSMutableArray arrayWithArray:buttonArray];
            [otherButton removeObject:button];
            for (UIButton *button1 in otherButton) {
                [button1 setSelected:NO];
            }
            id baseView = [baseViewArray objectAtIndex:i];
            [baseView setHidden:NO];
            NSMutableArray *otherBaseViewArray =
                [NSMutableArray arrayWithArray:baseViewArray];
            [otherBaseViewArray removeObject:baseView];
            for (id otherBaseView in otherBaseViewArray) {
                [otherBaseView setHidden:YES];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkOtherClass:(UIButton *)sender {
    if (isCheckButtonFold) {
        isCheckButtonFold = NO;
        self.allowForceRotation = NO;
        [UIView animateWithDuration:0.2
            animations:^{
                self.checkOtherButton.frame =
                    CGRectMake(0, 0, 320, bottomButton_Height);
                self.goOnStudyButton.left = -80;
                self.checkOtherViewLine.left = -80;
            }
            completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.checkOtherClassView.top =
                                         G_SCREEN_HEIGHT - 380 -
                                         navagationPlusStatusBar_Height;
                                 }];
            }];
        [_coverView setHidden:NO];
        navigation.allowShowCoverView = YES;
    } else {
        self.allowForceRotation = YES;
        [self checkOtherButtonAnimationDown];
    }
}

- (void)checkOtherButtonAnimationDown {
    isCheckButtonFold = YES;
    [UIView animateWithDuration:0.2
        animations:^{

            self.checkOtherClassView.top = G_SCREEN_HEIGHT -
                                           bottomButton_Height -
                                           navagationPlusStatusBar_Height;
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.checkOtherButton.frame = CGRectMake(
                                     160, 0, 160, bottomButton_Height);
                                 self.goOnStudyButton.left = 0;
                                 self.checkOtherViewLine.left = 160;
                             }];
        }];
    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;
}

- (IBAction)enrollCourse:(UIButton *)sender {

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    if ([KKBUserInfo shareInstance].userId == nil) {
        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegant.isClickEntrollment = YES;
        loginViewCtr = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewCtr
                                             animated:YES];
    } else {
        NSDictionary *dic = [classInfoArray objectAtIndex:sender.tag - 100];
        NSString *classId = (NSString *)[dic objectForKey:@"lms_course_id"];
        NSString *urlPath = [NSString
            stringWithFormat:@"v1/userapply/register/course/%@", classId];

        if (![AppUtilities isExistenceNetwork]) {
            [self.netDisconnectView showInView:self.view];
            return;
        }

        [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
            method:@"GET"
            param:nil
            fromCache:NO
            success:^(id result, AFHTTPRequestOperation *operation) {
                NSLog(@"enroll success");
                [[LocalStorage shareInstance] saveLearnStatus:YES
                                                       course:self.courseId];

                [[LocalStorage shareInstance] saveLearnStatus:YES
                                                    ByClassId:classId];
                GuideCourseEnrolledViewController *guideCourseAfter =
                    [[GuideCourseEnrolledViewController alloc] init];
                guideCourseAfter.courseId = self.courseId;
                guideCourseAfter.classId = classId;

                [self.navigationController pushViewController:guideCourseAfter
                                                     animated:YES];
                [[KKBHttpClient shareInstance] refreshDynamic];
                self.learnButtonView.top = G_SCREEN_HEIGHT -
                                           bottomButton_Height -
                                           navagationPlusStatusBar_Height;
            }
            failure:^(id result, AFHTTPRequestOperation *operation) {}];
    }
}

- (void)enrollOtherCourse:(UIButton *)sender {
    NSDictionary *dic = [classInfoArray objectAtIndex:sender.tag - 200];
    NSString *classId = (NSString *)[dic objectForKey:@"lms_course_id"];

    NSString *urlPath =
        [NSString stringWithFormat:@"v1/userapply/register/course/%@", classId];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"enroll success");
            [[LocalStorage shareInstance] saveLearnStatus:YES
                                                   course:self.courseId];

            [[LocalStorage shareInstance] saveLearnStatus:YES
                                                ByClassId:classId];
            GuideCourseEnrolledViewController *guideCourseAfter =
                [[GuideCourseEnrolledViewController alloc] init];
            guideCourseAfter.courseId = self.courseId;
            guideCourseAfter.classId = classId;
            // guideCourseAfter.currentCourse = self.currentCourse;
            [self.navigationController pushViewController:guideCourseAfter
                                                 animated:YES];
            [[KKBHttpClient shareInstance] refreshDynamic];
            // 底部按钮恢复原始状态
            self.checkOtherButton.frame = CGRectMake(160, 0, 160, 48);
            self.goOnStudyButton.left = 0;
            self.checkOtherViewLine.left = 160;
            [self.checkOtherClassView
                setFrame:CGRectMake(0, G_SCREEN_HEIGHT - 48 - 64, 320, 380)];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}
- (IBAction)goOnStudy:(UIButton *)sender {
    GuideCourseEnrolledViewController *guideCourseAfter =
        [[GuideCourseEnrolledViewController alloc] init];
    NSInteger nearestClass = [[_courseInfoDict
        objectForKey:@"position_of_nearest_enrolled"] integerValue];
    _nearestEnrolledClass = [classInfoArray objectAtIndex:nearestClass];

    guideCourseAfter.courseId = self.courseId;

    guideCourseAfter.classId =
        [[_nearestEnrolledClass objectForKey:@"lms_course_id"] stringValue];

    [self.navigationController pushViewController:guideCourseAfter
                                         animated:YES];
}

- (void)refreshView {
    NSNumber *duration = [self.guideCourseDictionary objectForKey:@"weeks"];
    self.totalWeek.text = [NSString stringWithFormat:@"%@周", duration];
    NSNumber *maxDuration =
        [self.guideCourseDictionary objectForKey:@"max_duration"];
    NSNumber *minDuration =
        [self.guideCourseDictionary objectForKey:@"min_duration"];

    NSString *perWeekTime =
        [NSString stringWithFormat:@"%@-%@", minDuration, maxDuration];
    self.courseName.text = [self.guideCourseDictionary objectForKey:@"name"];

    NSString *school = [self.guideCourseDictionary objectForKey:@"school"];
    if ([[self.guideCourseDictionary objectForKey:@"school"]
            isKindOfClass:[NSNull class]]) {
        school = @"";
    } else {
        self.schoolLabel.text = school;
    }

    techArray = [self.guideCourseDictionary objectForKey:@"tech"];

    NSString *certImage =
        [self.guideCourseDictionary objectForKey:@"certificate_img"];
    [self.certificationImageView
        sd_setImageWithURL:[NSURL URLWithString:certImage]];

    self.everyWeek.text =
        [NSString stringWithFormat:@"每周%@小时", perWeekTime];
    self.courseTitleLabel.text =
        [self.guideCourseDictionary objectForKey:@"name"];
    self.courseIntroLabel.text =
        [self.guideCourseDictionary objectForKey:@"intro"];
    self.courseKeyWordLevelLabel.text =
        [self.guideCourseDictionary objectForKey:@"slogan"];
    NSString *level = [self.guideCourseDictionary objectForKey:@"level"];
    DifficultCard *diffCardView =
        [[DifficultCard alloc] initWithFrame:CGRectMake(0, 14, 58, 14)];
    diffCardView.right = 320 - 8;
    [diffCardView initCardView:level];
    [self.levelCardView addSubview:diffCardView];

    NSString *videoURLStr =
        [self.guideCourseDictionary objectForKey:@"promotional_video_url"];

    if (videoURLStr) {
        self.videoURLs = [@[ videoURLStr ] mutableCopy];
    }

    self.coverImgURL =
        [AppUtilities adaptImageURLforPhone:[self.guideCourseDictionary
                                               objectForKey:@"cover_image"]];
}

- (void)requestCommentData:(BOOL)fromCache {

    if (fromCache) {
        [self.loadingView showInView:self.view];
    }

    NSString *urlPath =
        [NSString stringWithFormat:@"v1/evaluation/courseid/%@", self.courseId];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            commentArray = result;
            [self.ThirdButtonBaseView reloadData];

            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {

            if (fromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
                NSLog(@"request comment data from cache failed");
            }
        }];
}

- (void)requestClassInfo:(BOOL)fromCache {

    if (![KKBUserInfo shareInstance].isLogin) {
        return;
    }

    if (enrolledArray == nil) {
        enrolledArray = [[NSMutableArray alloc] init];
    } else {
    }
    if (unenrolledArray == nil) {
        unenrolledArray = [[NSMutableArray alloc] init];
    } else {
    }

    if (fromCache) {
        [self.loadingView showInView:self.view];
    }

    NSString *urlPath =
        [NSString stringWithFormat:@"v1/courses/%@/user", self.courseId];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSDictionary *dict = result;
            _courseInfoDict = result;
            classInfoArray = [dict objectForKey:@"lms_course_list"];

            [enrolledArray removeAllObjects];
            [unenrolledArray removeAllObjects];
            for (NSDictionary *dic in classInfoArray) {
                if ([[dic objectForKey:@"status"]
                        isEqualToString:@"unenrolled"]) {
                    [unenrolledArray addObject:dic];
                } else {
                    [enrolledArray addObject:dic];
                }
            }
            [self.CheckOtherClassTableView reloadData];
            [self.learnButtonTableView reloadData];

            int enrolledNum =
                [[dict objectForKey:@"number_of_enrolled_lms_course"] intValue];
            if (enrolledNum > 0) {

                [self.checkOtherClassView
                    setFrame:CGRectMake(0,
                                        G_SCREEN_HEIGHT - bottomButton_Height -
                                            navagationPlusStatusBar_Height,
                                        320, 380)];
                [self.view addSubview:self.checkOtherClassView];

            } else {
                [self.view addSubview:self.learnButtonView];
            }

            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
                NSLog(@"request class info from cache failed");
            }
        }];
}

- (void)reloadTableViewDataWhenFailed {

    [self.loadingFailedView hide];
    [self.loadingView showInView:self.view];

    [self requestCommentData:YES];
    [self requestClassInfo:YES];
    [self requestCollectionStatus:YES];
}

- (id)iskindOfNullClass:(id) class {
    if ([class isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return class;
    }
} - (NSString *)transforTime : (NSString *)timeSeconds {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"MM月dd日 HH:mm:ss"];
    [formatter setDateFormat:@"MM月dd日"];
    NSTimeInterval timesec = [timeSeconds doubleValue] / 1000;
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timesec];
    NSString *create_time = [formatter stringFromDate:createDate];
    NSLog(@"create_time is %@", create_time);
    // 时区
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger integer = [timeZone secondsFromGMTForDate:createDate];
    NSDate *localDate = [createDate dateByAddingTimeInterval:integer];
    NSString *localTime = [formatter stringFromDate:localDate];
    NSLog(@"localTime is %@", localTime);
    return create_time;
}

- (IBAction)studeButtonAction:(UIButton *)sender {

    //判断是否登录
    if (![KKBUserInfo shareInstance].isLogin) {
        [AppUtilities pushToLoginViewController:self];
    } else {
        if (isLearnButtonFold == YES) {

            //不允许视频播放器横竖屏
            self.allowForceRotation = NO;
            [self.player pauseButtonPressed];

            [UIView animateWithDuration:0.5
                animations:^{
                    self.learnButtonView.bottom =
                        G_SCREEN_HEIGHT - navagationPlusStatusBar_Height;
                }
                completion:^(BOOL finished) { isLearnButtonFold = NO; }];

            [_coverView setHidden:NO];

            navigation =
                (KKBBaseNavigationController *)self.navigationController;
            navigation.allowShowCoverView = YES;

            //[navigation.coverView setHidden:NO];

        } else {
            //允许视频播放器横竖屏
            self.allowForceRotation = YES;
            if (self.player.state == VKVideoPlayerStateContentPaused) {
                [self.player playButtonPressed];
            }
            

            [UIView animateWithDuration:0.5
                animations:^{
                    self.learnButtonView.top = G_SCREEN_HEIGHT -
                                               bottomButton_Height -
                                               navagationPlusStatusBar_Height;
                }
                completion:^(BOOL finished) { isLearnButtonFold = YES; }];
            [_coverView setHidden:YES];
            navigation.allowShowCoverView = NO;
        }
    }
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

- (void)handleError {

    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:@"提示"
                  message:@"视频文件被损坏了，无法播放"
                 delegate:nil
        cancelButtonTitle:@"我知道了"
        otherButtonTitles:nil];

    [alertView show];
}

#pragma mark - KKBShare Delegate Methods
- (void)shareViewControllerDidDismiss {
    self.allowForceRotation = YES;
    [self.player playButtonPressed];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:self.infoTableView]) {
        if ([[self.guideCourseDictionary objectForKey:@"certificate_img"]
                isKindOfClass:[NSNull class]] ||
            [self.guideCourseDictionary objectForKey:@"certificate_img"] ==
                nil ||
            [[self.guideCourseDictionary objectForKey:@"certificate_img"]
                isEqualToString:@""]) {
            _firstButtonBaseView.contentSize = CGSizeMake(320, 650);
            return 2;
        }
        return 3;
    } else if ([tableView isEqual:_ThirdButtonBaseView]) {
        return commentArray.count;
    } else if ([tableView isEqual:self.CheckOtherClassTableView] ||
               [tableView isEqual:self.learnButtonTableView]) {

        return 2;
    } else if ([tableView isEqual:_secondButtonBaseView]) {
        return courseTreeArray.count;
    } else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_ThirdButtonBaseView]) {
        return 1;
    } else if ([tableView isEqual:_secondButtonBaseView]) {
        NSDictionary *dic = [courseTreeArray objectAtIndex:section];
        NSArray *dataArray = [dic objectForKey:@"items"];
        return dataArray.count + 1;
    } else if ([tableView isEqual:_fourthButtonBaseView]) {
        return relativeCourseDataArray.count;
    } else if ([tableView isEqual:self.infoTableView]) {
        if (section == 1) {
            if (techArray.count > 1) {
                _firstButtonBaseView.contentSize =
                    CGSizeMake(320, _firstButtonBaseView.contentSize.height +
                                        (techArray.count - 1) * 74);
            }
            return techArray.count;

        } else {
            return 1;
        }
    } else if ([tableView isEqual:self.CheckOtherClassTableView] ||
               [tableView isEqual:self.learnButtonTableView]) {
        if (section == 0) {
            return enrolledArray.count + 1;
        } else {
            return unenrolledArray.count + 2;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_fourthButtonBaseView]) {

        static NSString *cellIdentifier = @"CourseItemCell";
        CourseItemCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"CourseItemCell"
                                                         owner:self
                                                       options:nil];
            cell = [arr objectAtIndex:0];
        }

        KCourseItem *aCourseItem = relativeCourseDataArray[indexPath.row];

        KKBCourseItemCellModel *model = [[KKBCourseItemCellModel alloc] init];
        model.headImageURL = aCourseItem.imageUrl;
        model.cellTitle = aCourseItem.name;

        NSDictionary *dic =
            [self.recommendDataArray objectAtIndex:indexPath.row];
        float rating = [[dic objectForKey:@"rating"] floatValue];
        rating = (rating / 2.0);

        model.rating = rating;
        model.itemType =
            aCourseItem.type == 1 ? CourseItemGuideType : CourseItemOpenType;
        model.isOnLine = YES;
        model.enrollments = @(aCourseItem.learnerNumber);

        cell.model = model;

        return cell;

    } else if ([tableView isEqual:_secondButtonBaseView]) {
        static NSString *cellIdentifier = @"CourseDetailTreeTwoCell";
        CourseDetailTreeTwoCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTreeTwoCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dict = [courseTreeArray objectAtIndex:indexPath.section];
        NSArray *array = [dict objectForKey:@"items"];
        NSDictionary *dic = [array objectAtIndex:indexPath.row - 1];
        NSString *courseName = [dic objectForKey:@"title"];
        cell.courseName.text = courseName;
        return cell;

    } else if ([tableView isEqual:_ThirdButtonBaseView]) {
        static NSString *cellIdentifier = @"CommentCell";
        CommentCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"CommentCell"
                                                         owner:self
                                                       options:nil];
            cell = [arr objectAtIndex:0];
        }

        NSDictionary *dic = [commentArray objectAtIndex:indexPath.section];

        [cell.commentContentNewLabel setText:[dic objectForKey:@"content"]];
        cell.commentContentNewLabel.textColor = [UIColor blackColor];
        cell.commentContentNewLabel.height =
            cell.commentContentNewLabel.optimumSize.height;
        cell.height += cell.commentContentNewLabel.optimumSize.height - 14;

        float starNum = [[dic objectForKey:@"rating"] floatValue];
        cell.commentScoreLabel.text =
            [NSString stringWithFormat:@"(%0.f分)", starNum];
        cell.starRatingView.fullImage = @"star_yellow_full";
        cell.starRatingView.halfImage = @"star_yellow_half";
        starNum = starNum / 2;
        cell.starRatingView.rating = starNum;

        if ([[dic objectForKey:@"user_image_url"]
                isKindOfClass:[NSNull class]]) {
            // 默认图
            [cell.commentUserImageView
                setImage:[UIImage imageNamed:@"assess_user"]];
        } else {
            NSString *imageUrl = [dic objectForKey:@"user_image_url"];
            // 默认图
            [cell.commentUserImageView
                sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:[UIImage imageNamed:@"assess_user"]];
        }

        if ([[dic objectForKey:@"created_at"] isKindOfClass:[NSNull class]]) {

        } else {
            cell.commentTimeLabel.text = [self
                transforTime:[[dic objectForKey:@"created_at"] stringValue]];
        }

        cell.commentUserNameLabel.text = [dic objectForKey:@"user_name"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if ([tableView isEqual:self.CheckOtherClassTableView] ||
               [tableView isEqual:self.learnButtonTableView]) {
        static NSString *cellIdentifier = @"CheckClassCell";
        CheckClassCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"CheckClassCell"
                                                         owner:self
                                                       options:nil];
            cell = [arr objectAtIndex:0];
        }
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                UITableViewCell *cell1 = [[UITableViewCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"cell1"];
                cell1.textLabel.text = @"已参加班次:";

                cell1.textLabel.font = [UIFont systemFontOfSize:14];
                cell1.left = 8;
                
                BOOL isEmpty = (enrolledArray == nil || enrolledArray.count == 0);
                cell1.hidden = isEmpty;
                return cell1;
                //
            } else {
                NSDictionary *dic =
                    [enrolledArray objectAtIndex:indexPath.row - 1];

                NSString *startTimeTra = [self
                    transforTime:[[dic objectForKey:@"start_at"] stringValue]];
                NSString *endTimeTra =
                    [self transforTime:
                              [[dic objectForKey:@"conclude_at"] stringValue]];

                NSString *status = [dic objectForKey:@"status"];

                cell.timeLabel.text = [NSString
                    stringWithFormat:@"%@-%@", startTimeTra, endTimeTra];
                if ([status isEqualToString:@"close"]) {
                    [cell.statusImageView
                        setImage:[UIImage imageNamed:@"popup_icon_finish_dis"]];
                } else if ([status isEqualToString:@"enrolled"]) {
                    [cell.statusImageView
                        setImage:[UIImage
                                     imageNamed:@"popup_icon_intoClass_def"]];
                }
            }
        } else {
            if (indexPath.row == 0) {
                UITableViewCell *cell2 = [[UITableViewCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:@"cell2"];
                cell2.textLabel.text = @"可加入班次:";
                cell2.textLabel.font = [UIFont systemFontOfSize:14];
                cell2.left = 8;
                //
                return cell2;
            } else if (indexPath.row == unenrolledArray.count + 1) {

                cell.timeLabel.text = @"后续班次";

                [cell.statusImageView
                    setImage:[UIImage
                                 imageNamed:@"popup_icon_Addcollection_def"]];

                if (isCollectioned) {
                    [cell.statusImageView
                        setImage:
                            [UIImage
                                imageNamed:@"popup_icon_Addcollection_pres"]];
                }

            } else {
                NSDictionary *dic =
                    [unenrolledArray objectAtIndex:indexPath.row - 1];

                NSString *startTimeTra = [self
                    transforTime:[[dic objectForKey:@"start_at"] stringValue]];
                NSString *endTimeTra =
                    [self transforTime:
                              [[dic objectForKey:@"conclude_at"] stringValue]];

                [cell.statusImageView
                    setImage:[UIImage imageNamed:@"popup_icon_join_def"]];
                cell.timeLabel.text = [NSString
                    stringWithFormat:@"%@-%@", startTimeTra, endTimeTra];
            }
        }
        return cell;
    } else if ([tableView isEqual:self.infoTableView]) {
        if (indexPath.section == 0) {
            static NSString *cellIdentifier = @"CoursesIntroCell";
            CoursesIntroCell *cell =
                [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                NSArray *arr =
                    [[NSBundle mainBundle] loadNibNamed:@"CoursesIntroCell"
                                                  owner:self
                                                options:nil];
                cell = [arr objectAtIndex:0];
            }

            cell.courseName.text =
                [self.guideCourseDictionary objectForKey:@"name"];

            cell.courseLabel.text =
                [self.guideCourseDictionary objectForKey:@"intro"];
            return cell;

        } else if (indexPath.section == 1) {
            static NSString *cellIdentifier = @"TeacherIntroCell";
            TeacherIntroCell *cell =
                [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                NSArray *arr =
                    [[NSBundle mainBundle] loadNibNamed:@"TeacherIntroCell"
                                                  owner:self
                                                options:nil];
                cell = [arr objectAtIndex:0];
            }

            NSDictionary *dic = [techArray objectAtIndex:indexPath.row];

            NSString *imageUrl =
                [self iskindOfNullClass:[dic objectForKey:@"tech_img"]];
            cell.teacherName.text =
                [self iskindOfNullClass:[dic objectForKey:@"name"]];
            cell.teacherIntro.text =
                [self iskindOfNullClass:[dic objectForKey:@"intro"]];
            [cell.teacherImageVIew
                sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:[UIImage imageNamed:@"head_teacher"]];

            return cell;
        } else {
            static NSString *cellIdentifier = @"CertificationIntroCell";
            CertificationIntroCell *cell =
                [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                NSArray *arr = [[NSBundle mainBundle]
                    loadNibNamed:@"CertificationIntroCell"
                           owner:self
                         options:nil];
                cell = [arr objectAtIndex:0];
            }

            cell.certificationIntro.textColor =
                [UIColor colorWithRed:97 / 256.0
                                green:100 / 256.0
                                 blue:102 / 256.0
                                alpha:1];
            cell.certificationIntro.font = [UIFont systemFontOfSize:12];

            cell.certificationIntro.text =
                @"注" @"册并学习导学课、申请证书并提供身"
                @"份证明文件完成导学课下相关课程"
                @"学习并通过考核方可获得导学课证书";
            NSString *certImage =
                [self.guideCourseDictionary objectForKey:@"certificate_img"];
            [cell.certificationImageView
                sd_setImageWithURL:[NSURL URLWithString:certImage]
                  placeholderImage:[UIImage imageNamed:@"certificate_default"]];

            return cell;
        }
    }
    return nil;
}

- (float)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([tableView isEqual:_ThirdButtonBaseView]) {
        NSDictionary *dic = nil;
        if (commentArray != nil || commentArray.count != 0) {
            dic = [commentArray objectAtIndex:indexPath.section];
        }

        if (dic != nil) {
            NSString *text = [dic objectForKey:@"content"];
            return [self getCommentCellHeight:text];
        } else
            return 89;

    } else if ([tableView isEqual:_fourthButtonBaseView]) {
        return 107;
    } else if ([tableView isEqual:self.infoTableView]) {
        if (indexPath.section == 0) {
            return 115;
        } else if (indexPath.section == 1) {
            return 74;
        } else {
            return 313;
        }
    } else if ([tableView isEqual:self.learnButtonTableView] ||
               [tableView isEqual:self.CheckOtherClassTableView]) {
        if (enrolledArray == nil || enrolledArray.count == 0) {
            if (indexPath.section == 0) {
                return 0;
            }
        }
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([tableView isEqual:_fourthButtonBaseView]) {
        KCourseItem *aCourseItem = relativeCourseDataArray[indexPath.row];
        if (aCourseItem.type == 1) {
            GuideCourseViewController *guide =
                [[GuideCourseViewController alloc] init];
            guide.courseId = aCourseItem.courseId;
            [self.navigationController pushViewController:guide animated:YES];
        } else {
            NSDictionary *aCourseDict =
                [self.recommendDataArray objectAtIndex:indexPath.row];
            PublicClassViewController *public =
                [[PublicClassViewController alloc] init];
          public
            .currentCourse = aCourseDict;
            [self.navigationController pushViewController:public animated:YES];
        }
    } else if ([tableView isEqual:_secondButtonBaseView]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

    } else if ([tableView isEqual:self.infoTableView]) {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                NSURL *imageUrl =
                    [NSURL URLWithString:[self.guideCourseDictionary
                                             objectForKey:@"certificate_img"]];
                if (imageUrl) {
                    MJPhoto *photo = [[MJPhoto alloc] init];
                    photo.url = imageUrl;
                    photo.srcImageView = self.certificationImageView;

                    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
                    browser.currentPhotoIndex = 0;
                    browser.photos = [@[ photo ] mutableCopy];
                    [browser show];
                }
            }
        }
    } else if ([tableView isEqual:_CheckOtherClassTableView] ||
               [tableView isEqual:self.learnButtonTableView]) {
        if (indexPath.section == 0) {
            if (indexPath.row != 0) {
                NSDictionary *dic =
                    [enrolledArray objectAtIndex:indexPath.row - 1];
                NSString *status = [dic objectForKey:@"status"];
                if ([status isEqualToString:@"enrolled"]) {
                    GuideCourseEnrolledViewController *guideAfter =
                        [[GuideCourseEnrolledViewController alloc] init];
                    guideAfter.courseId = self.courseId;

                    guideAfter.classId =
                        [[dic objectForKey:@"lms_course_id"] stringValue];

                    [self.navigationController pushViewController:guideAfter
                                                         animated:YES];
                    //按钮View 复原
                    self.learnButtonView.top = G_SCREEN_HEIGHT -
                                               bottomButton_Height -
                                               navagationPlusStatusBar_Height;

                    self.checkOtherButton.frame =
                        CGRectMake(160, 0, 160, bottomButton_Height);
                    self.goOnStudyButton.left = 0;
                    self.checkOtherViewLine.left = 160;
                    self.checkOtherClassView.top =
                        G_SCREEN_HEIGHT - bottomButton_Height -
                        navagationPlusStatusBar_Height;
                    isCheckButtonFold = YES;
                    [_coverView setHidden:YES];
                    navigation.allowShowCoverView = NO;

                    isCheckButtonFold = YES;
                }
            }

        } else if (indexPath.section == 1) {

            if (unenrolledArray.count > 0) {

                if (indexPath.row != 0 &&
                    indexPath.row != unenrolledArray.count + 1) {
                    NSDictionary *dic =
                        [unenrolledArray objectAtIndex:indexPath.row - 1];

                    NSString *classId =
                        [[dic objectForKey:@"lms_course_id"] stringValue];

                    NSString *urlPath = [NSString
                        stringWithFormat:@"v1/userapply/register/course/%@",
                                         classId];

                    if (![AppUtilities isExistenceNetwork]) {
                        [self.netDisconnectView showInView:self.view];
                        return;
                    }

                    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
                        method:@"GET"
                        param:nil
                        fromCache:NO
                        success:^(id result,
                                  AFHTTPRequestOperation *operation) {
                            [self requestClassInfo:NO];
                            GuideCourseEnrolledViewController *guideAfter1 = [
                                [GuideCourseEnrolledViewController alloc] init];
                            guideAfter1.courseId = self.courseId;

                            guideAfter1.classId = classId;

                            [self.navigationController
                                pushViewController:guideAfter1
                                          animated:YES];
                            [_coverView setHidden:YES];
                            navigation.allowShowCoverView = NO;
                            self.learnButtonView.top =
                                G_SCREEN_HEIGHT - 40 - 64;

                            self.checkOtherButton.frame =
                                CGRectMake(160, 0, 160, bottomButton_Height);
                            self.goOnStudyButton.left = 0;
                            self.checkOtherViewLine.left = 160;
                            [self.checkOtherClassView
                                setFrame:CGRectMake(
                                             0,
                                             G_SCREEN_HEIGHT -
                                                 bottomButton_Height -
                                                 navagationPlusStatusBar_Height,
                                             320, 380)];
                            isCheckButtonFold = YES;
                            [[KKBHttpClient
                                    shareInstance] refreshMyGuideCourse];
                        }
                        failure:^(id result,
                                  AFHTTPRequestOperation *operation) {}];
                }
            }
            if (indexPath.row == unenrolledArray.count + 1) {

                CheckClassCell *cell = (CheckClassCell *)
                    [tableView cellForRowAtIndexPath:indexPath];
                if (isCollectioned) {
                    [self deleteFavourite:NO forCell:cell];
                } else {
                    [self joinFavourite:NO forCell:cell];
                }
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.infoTableView]) {
        return 54;
    } else if ([tableView isEqual:_ThirdButtonBaseView]) {
        return 12;
    } else if ([tableView isEqual:_CheckOtherClassTableView] ||
               [tableView isEqual:self.learnButtonTableView]) {
        return 1;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.infoTableView]) {
        UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 100, 18)];
        label.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:18];

        label.textColor = [UIColor colorWithRed:69 / 256.0
                                          green:73 / 256.0
                                           blue:76 / 256.0
                                          alpha:1.0];

        UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 108)];
        [view setBackgroundColor:[UIColor clearColor]];
        [view addSubview:label];
        if (section == 0) {
            label.text = @"课程简介";
        } else if (section == 1) {
            label.text = @"讲师简介";
        } else {
            label.text = @"证书";
        }
        return view;
    }
    return nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (float)getCommentCellHeight:(NSString *)text {
    float height = 89;
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.width = 290;
    [label setText:text];
    height += label.optimumSize.height - 14;
    return height;
}

- (void)joinFavourite:(BOOL)fromCache forCell:(CheckClassCell *)cell {
    NSString *jsonForJoinFavourite = @"v1/collections";
    NSString *user_id = [KKBUserInfo shareInstance].userId;
    NSString *course_id = self.courseId;
    NSMutableDictionary *dict = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:user_id, @"user_id", course_id,
                                     @"course_id", nil];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForJoinFavourite
        method:@"POST"
        param:dict
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {

            isCollectioned = YES;
            NSLog(@"result is %@", result);
            [collectionButton
                setBackgroundImage:
                    [UIImage imageNamed:@"kkb-iphone-instructivecourse-"
                             @"collection-selected"]
                          forState:UIControlStateNormal];

            [cell.statusImageView
                setImage:[UIImage imageNamed:@"popup_icon_Addcollection_pres"]];

            [self.learnButtonTableView reloadData];
            [self.CheckOtherClassTableView reloadData];
            [[KKBHttpClient shareInstance] refreshDynamic];
            [[KKBHttpClient shareInstance] refreshMyCollection];
            self.successView.successMessage.text = @"已收藏";
            [self.view bringSubviewToFront:self.successView];
            [self popSuccessView];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"error is %@", result);
        }];
}

- (void)deleteFavourite:(BOOL)fromCache forCell:(CheckClassCell *)cell {
    NSString *deleteFavourite = @"v1/collections/delete";
    NSString *user_id = [KKBUserInfo shareInstance].userId;
    NSString *course_id = self.courseId;
    NSMutableDictionary *dict = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:user_id, @"user_id", course_id,
                                     @"course_id", nil];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:deleteFavourite
        method:@"POST"
        param:dict
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result is %@", result);
            isCollectioned = NO;
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"popup_icon_Addcollection_def"]];
            [collectionButton
                setBackgroundImage:
                    [UIImage imageNamed:@"kkb-iphone-instructivecourse-"
                             @"collection-normal"]
                          forState:UIControlStateNormal];
            [self.learnButtonTableView reloadData];
            [self.CheckOtherClassTableView reloadData];

            [[KKBHttpClient shareInstance] refreshDynamic];
            [[KKBHttpClient shareInstance] refreshMyCollection];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"error is %@", result);
        }];
}

- (void)requestCollectionStatus:(BOOL)fromCache {

    if (![KKBUserInfo shareInstance].isLogin) {
        return;
    }

    if (fromCache) {
        [self.loadingView showInView:self.view];
    }

    NSString *urlPath = [NSString stringWithFormat:@"v1/collections/user"];

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        // return;
    }

    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSArray *array = result;
            for (NSDictionary *dic in array) {
                int courseId = [[dic objectForKey:@"id"] intValue];
                NSLog(@"%d,%@,%d", courseId, self.courseId,
                      courseId == [self.courseId intValue]);
                if (courseId == [self.courseId intValue]) {
                    isCollectioned = YES;
                    [_CheckOtherClassTableView reloadData];
                    [collectionButton
                        setBackgroundImage:
                            [UIImage imageNamed:@"kkb-iphone-instructivecourse-"
                                     @"collection-selected"]
                                  forState:UIControlStateNormal];

                    [self.loadingView hideView];
                    return;
                }
                isCollectioned = NO;

                [_CheckOtherClassTableView reloadData];
            }
            [collectionButton
                setBackgroundImage:
                    [UIImage imageNamed:@"kkb-iphone-instructivecourse-"
                             @"collection-normal"]
                          forState:UIControlStateNormal];

            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

#pragma mark - 处理旋转事件隐藏控件
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.buttonView.height = 0;
        [self.learnButtonView setHidden:YES];
        self.checkOtherClassView.hidden = YES;
    } else {
        [self.buttonView setHidden:NO];
        [self.learnButtonView setHidden:NO];
        self.checkOtherClassView.hidden = NO;
        self.buttonView.height = SEGEMENT_BAR_HEIGHT;

        [self restoreBasicInfoScrollViewContentSize];
    }
}

- (void)tapCover:(UIGestureRecognizer *)tap {
    //允许视频播放器横竖屏
    self.allowForceRotation = YES;
    if (self.player.state == VKVideoPlayerStateContentPaused) {
        [self.player playButtonPressed];
    }


    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;
    if (isCheckButtonFold == NO) {

        [self checkOtherButtonAnimationDown];
    }
    if (isLearnButtonFold == NO) {
        isLearnButtonFold = YES;
        [UIView animateWithDuration:0.5
            animations:^{
                self.learnButtonView.top = G_SCREEN_HEIGHT -
                                           bottomButton_Height -
                                           navagationPlusStatusBar_Height;
            }
            completion:^(BOOL finished) { isLearnButtonFold = YES; }];
    }
}

- (void)collectionAction:(UIButton *)button {

    if (![KKBUserInfo shareInstance].isLogin) {
        [AppUtilities pushToLoginViewController:self];
        return;
    }
    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    if (isCollectioned == YES) {
        [self deleteFavourite:NO forCell:nil];
    } else {
        [self joinFavourite:NO forCell:nil];
    }
}

- (void)shareAction:(UIButton *)button {

    NSString *shareDownloadUrl = [NSString
        stringWithFormat:@"http://www.kaikeba.com/courses/%@", self.courseId];

    NSString *shareTextForSina =
        [NSString stringWithFormat:@"#新课抢先知#"
                  @"这课讲的太屌了，朕灰常满意！小伙伴们"
                  @"不要太想我，我在@开课吧官方微博 "
                  @"虐学渣，快来和我一起吧！"];

    NSString *shareTextForOther =
        [NSString stringWithFormat:
                      @"我正在开课吧观看《%@"
                      @"》这门课，老师讲得吼赛磊呀！小伙伴们"
                      @"要不要一起来呀?",
                      [self.guideCourseDictionary objectForKey:@"name"]];

    self.allowForceRotation = NO;
    [self.player pauseButtonPressed];
    [[KKBShare shareInstance]
           shareWithImage:_shareImage
                  viewCtr:self
                 courseId:self.courseId
               courseName:[self.guideCourseDictionary objectForKey:@"name"]
         shareDownloadUrl:shareDownloadUrl
         shareTextForSina:shareTextForSina
        shareTextForOther:shareTextForOther];

    [KKBShare shareInstance].delegate = self;
}

#pragma 通知方法
- (void)navCoverViewTap {
    navigation.allowShowCoverView = NO;

    self.allowForceRotation = YES;
    if (self.player.state == VKVideoPlayerStateContentPaused) {
        [self.player playButtonPressed];
    }


    [_coverView setHidden:YES];

    if (isCheckButtonFold == NO) {

        [self checkOtherButtonAnimationDown];
    }
    if (isLearnButtonFold == NO) {
        isLearnButtonFold = YES;
        [UIView animateWithDuration:0.5
            animations:^{
                self.learnButtonView.top = G_SCREEN_HEIGHT -
                                           bottomButton_Height -
                                           navagationPlusStatusBar_Height;
            }
            completion:^(BOOL finished) { isLearnButtonFold = YES; }];
    }
}
#pragma mark -SLExpandableTableView dataSource
- (BOOL)tableView:(SLExpandableTableView *)tableView
    canExpandSection:(NSInteger)section {
    return YES;
}

- (BOOL)tableView:(SLExpandableTableView *)tableView
    needsToDownloadDataForExpandableSection:(NSInteger)section {
    return ![self.expandableSections containsIndex:section];
}

- (UITableViewCell<UIExpandingTableViewCell> *)
                  tableView:(SLExpandableTableView *)tableView
    expandingCellForSection:(NSInteger)section {

    static NSString *cellIdentifier = @"CourseDetailTreeOneCell";
    CourseDetailTreeOneCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *arr =
            [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTreeOneCell"
                                          owner:self
                                        options:nil];
        cell = [arr objectAtIndex:0];
    }

    NSDictionary *dic = [courseTreeArray objectAtIndex:section];

    cell.coursName.text = [dic objectForKey:@"name"];
    [cell.statusImageView
        setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-down"]];
    if ([self.expandableSections containsIndex:section]) {

        [cell.statusImageView
            setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-up"]];
    }

    return cell;
}
#pragma mark - SLExpandableTableViewDelegate

- (void)tableView:(SLExpandableTableView *)tableView
    downloadDataForExpandableSection:(NSInteger)section {
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 *
    //    NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self.expandableSections addIndex:section];
    //        [tableView expandSection:section animated:YES];
    //    });
    [self.expandableSections addIndex:section];
    [tableView expandSection:section animated:YES];
}

- (void)tableView:(SLExpandableTableView *)tableView
    didCollapseSection:(NSUInteger)section
              animated:(BOOL)animated {
    [self.expandableSections removeIndex:section];
}

@end
