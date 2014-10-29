//
//  MiniMajorViewController.m
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MiniMajorViewController.h"
#import "MiniMajorCourse.h"
#import "UMSocial.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "AppUtilities.h"
#import "UIImageView+WebCache.h"
#import "GlobalOperator.h"
#import "LocalStorage.h"
#import "KKBUserInfo.h"
#import "GuideCourseViewController.h"
#import "KKBBaseNavigationController.h"
#import "CourseItemCell.h"
#import "KKBCourseItemCellModel.h" //桥接cell的model

#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "UIViewController+KNSemiModal.h"
#import "MobClick.h"
#import "KKBShare.h"
#import "SDWebImageDownloader.h"

#import "CheckMajorCourseCell.h"

#define Margin 8

#define TITLE_MARGIN_LEFT 17

#define INTRO_TITLE_MARGIN_TOP 16
#define INTRO_TEXT_MARGIN_LEFT 8
#define INTRO_TEXT_MARGIN_TOP 12
#define INTRO_TEXT_MARGIN_BOTTOM 16

#define CERTIFICATE_VIEW_MARGIN_TOP 21
#define CERTIFICATE_VIEW_HEIGHT 271
#define CERTIFICATE_VIEW_TITLE_HEIGHT 17
#define CERTIFICATE_BG_MARGIN_TOP 12
#define CERTIFICATE_BG_MARGIN_EDGE 8

#define CERTIFICATE_IMG_MARGIN 12

#define COURSE_VIEW_MARGIN_TOP 20
#define COURSETABLE_VIEW_MARGIN_TOP -7

#define BOTTOM_BUTTON_HEIGHT 48
#define OPEN_COURSE_TYPE @"OpenCourse" //公开课
#define COURSE_STATUS @"online"        // online

#define DegressToRadians(x) (M_PI * x / 180.0f)

static CGFloat const enrollButtonViewHeight = 270;
static CGFloat const courseListHeight = 220;
static CGFloat const listCellHeight = 44;

//#define DEBUGUI

@interface MiniMajorViewController ()
@property(strong, nonatomic) UIScrollView *scrollView;

@property(strong, nonatomic) UIView *introView;       //微专业简介
@property(strong, nonatomic) UIView *certificateView; //微专业证书
@property(strong, nonatomic) UIView *courseView;      //微专业课程

@property(strong, nonatomic)
    NSMutableArray *courses; // 里面存储的数据将被放入tableView中

@end

@implementation MiniMajorViewController {
    UIImage *_shareImage;
    UIView *enrollButtonView;
    UITableView *courseListTableView;
    BOOL isListFold;
    NSArray *courseListArray;
    UIView *_coverView;
    UIControl *certificateBackgroundView;
    __weak KKBBaseNavigationController *navigation;
}

#pragma mark - viewDidLoad Method

- (void)dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 微专业详情页

    [self.navigationController.navigationBar setHidden:NO];
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    self.view.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;
    [self addIntroView];

    [self.scrollView addSubview:self.player.view];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.allowRemovePlayer = YES;
    self.contentScrollView = self.scrollView;

    [self addCertificateView];
    [self addTableView];
    [self initCoverView];
    [self addEnrollCourseButton];

    //导航栏分享按钮
    [self addShareButton];
    [self initWithInfo];

    [[SDWebImageDownloader sharedDownloader]
        downloadImageWithURL:
            [NSURL URLWithString:[_currentMajor objectForKey:@"image_url"]]
        options:1
        progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
        completed:^(UIImage *image, NSData *data, NSError *error,
                    BOOL finished) {
            if (finished) {
                _shareImage = image;
            }
        }];

    /***************************** [ loading view ]
     * *******************************/

    [self.loadingView setViewStyle:GrayStyle];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"MicroCourseDetail"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navCoverViewTap)
                                                 name:navigationBarCoverTap
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    navigation.allowShowCoverView = NO;

    [MobClick endLogPageView:@"MicroCourseDetail"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:navigationBarCoverTap
                                                  object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    enrollCourseButton.frame =
        CGRectMake(0, 0, G_SCREEN_WIDTH, BOTTOM_BUTTON_HEIGHT);
    //    enrollButtonView.frame = CGRectMake(0,
    //    G_SCREEN_HEIGHT-gNavigationAndStatusHeight-BOTTOM_BUTTON_HEIGHT,
    //    G_SCREEN_WIDTH, enrollButtonViewHeight);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = YES;
        _scrollView.frame = self.view.bounds;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray *)courses {
    if (!_courses) {
        _courses = [[NSMutableArray alloc] init];
    }
    return _courses;
}

#pragma mark - method
- (void)shareButtonDidPress:(id)sender {
    NSString *shareDownloadUrl = [NSString
        stringWithFormat:@"http://www.kaikeba.com/micro_specialties/%@",
                         [_currentMajor objectForKey:@"id"]];

    NSString *shareTextForSina = [NSString
        stringWithFormat:@"#新课抢先知#我已经快要拿到@开课吧官方微博 "
                         @"的“%@" @"”"
                         @"微专业证书了，好开森。这年头纸证书"
                         @"擦屁股都嫌硬" @"，" @"唯"
                         @"有电子证书才高端大气。",
                         [_currentMajor objectForKey:@"name"]];
    NSString *shareTextForOther =
        [NSString stringWithFormat:@"我"
                  @"参加了开课吧的微专业，小伙伴们有木有"
                  @"一起来哒？"];
    [[KKBShare shareInstance]
           shareWithImage:_shareImage
                  viewCtr:self
                 courseId:self.courseId
               courseName:[_currentMajor objectForKey:@"name"]
         shareDownloadUrl:shareDownloadUrl
         shareTextForSina:shareTextForSina
        shareTextForOther:shareTextForOther];
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:courseListTableView]) {
        return courseListArray.count;
    }
    return [self.courses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:courseListTableView]) {
        static NSString *cellIdentifier = @"CheckMajorCourseCell";
        CheckMajorCourseCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"CheckMajorCourseCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];

            // set selection color
            UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView = backgroundView;
            cell.selectedBackgroundView.backgroundColor =
                [UIColor tableViewCellSelectedColor];
        }
        NSDictionary *dic = [courseListArray objectAtIndex:indexPath.row];
        cell.courseName.text = [dic objectForKey:@"name"];

        [cell.statusImageView
            setImage:[UIImage imageNamed:@"kkb-iphone-miniMicroMajor-blue"]];
        if ([[dic objectForKey:@"id"] intValue] == 0) {
            [cell.statusImageView
                setImage:[UIImage
                             imageNamed:@"kkb-iphone-miniMicroMajor-gray"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        return cell;
    } else {
        CourseItemCell *cell =
            [tableView dequeueReusableCellWithIdentifier:COURSEITEMCELL_RESUEDID
                                            forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedBackgroundView =
            [[UIView alloc] initWithFrame:cell.bounds];

        MiniMajorCourse *aCourse = self.courses[indexPath.row];

        NSString *imageUrl =
            [AppUtilities adaptImageURLforPhone:aCourse.imageUrl];

        KKBCourseItemCellModel *model = [[KKBCourseItemCellModel alloc] init];
        model.headImageURL = imageUrl;
        model.cellTitle = aCourse.title;
        model.rating = aCourse.rating;
        model.itemType =
            aCourse.isOpenType ? CourseItemOpenType : CourseItemGuideType;
        model.isOnLine = aCourse.isOnline;
        model.enrollments = aCourse.enrollments_count;

        cell.model = model;

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSMutableDictionary *allCoursesItem = [NSMutableDictionary dictionary];

    NSDictionary *dict = subCoursesData[indexPath.row];

    [allCoursesItem setValue:[dict objectForKey:@"slogan"]
                      forKey:@"courseBrief"];
    [allCoursesItem setValue:[dict objectForKey:@"intro"]
                      forKey:@"courseIntro"];
    [allCoursesItem setValue:[dict objectForKey:@"name"] forKey:@"courseName"];
    [allCoursesItem setValue:[dict objectForKey:@"type"] forKey:@"courseType"];
    [allCoursesItem setValue:[dict objectForKey:@"coverImage"]
                      forKey:@"coverImage"];
    [allCoursesItem setValue:[dict objectForKey:@"id"] forKey:@"id"];
    [allCoursesItem setValue:[dict objectForKey:@"promotionalVideoUrl"]
                      forKey:@"promoVideo"];

    if ([[dict objectForKey:@"status"] isEqualToString:@"offline"]) {

    } else {
        GuideCourseViewController *controller =
            [[GuideCourseViewController alloc] init];

        controller.courseId = [dict objectForKey:@"id"];
        [self.navigationController pushViewController:controller animated:YES];
        [self ListAnimationDown];
        [_coverView setHidden:YES];
        navigation.allowShowCoverView = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:courseListTableView]) {
        return listCellHeight;
    } else {
        return COURSEITEMCELL_HEIGHT;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView
// heightForFooterInSection:(NSInteger)section{
//    return 0;
//}
- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:courseListTableView]) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Custom Methods

- (void)certificateViewDidTouchUpInside {

    [self clearColor];

    NSString *certificateUrl = [_currentMajor objectForKey:@"certificate_url"];
    NSURL *imageUrl = [NSURL URLWithString:certificateUrl];
    if (imageUrl) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = imageUrl;
        photo.srcImageView = certificat;
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = 0;
        browser.photos = [@[ photo ] mutableCopy];
        [browser show];
    }
}

- (void)certificateViewDidTouchDown {
    [certificateBackgroundView
        setBackgroundColor:[UIColor tableViewCellSelectedColor]];
}

- (void)certificateViewDidTouchCancel {
    [self performSelector:@selector(clearColor) withObject:nil afterDelay:0.2f];
}

- (void)clearColor {
    [certificateBackgroundView setBackgroundColor:[UIColor whiteColor]];
}

- (void)addIntroView {
    _introView = [[UIView alloc]
        initWithFrame:CGRectMake(0, G_VIDEOVIEW_HEIGHT, G_SCREEN_WIDTH, 100)];
    [_introView setBackgroundColor:[UIColor whiteColor]];

//    CGFloat offsetValue = 6.0f;
    //    UIImageView *bgImageView = [[UIImageView alloc]
    //        initWithFrame:CGRectMake(-offsetValue, -offsetValue,
    //                                 self.view.width + 2 * offsetValue,
    //                                 _introView.height + offsetValue)];
    //
    //    bgImageView.image = [[UIImage imageNamed:@"v3_card_shadow"]
    //        resizableImageWithCapInsets:UIEdgeInsetsMake(7, 10, 10, 9)];
    //    bgImageView.autoresizingMask =
    //        UIViewAutoresizingFlexibleLeftMargin |
    //        UIViewAutoresizingFlexibleWidth |
    //        UIViewAutoresizingFlexibleRightMargin |
    //        UIViewAutoresizingFlexibleTopMargin |
    //        UIViewAutoresizingFlexibleHeight |
    //        UIViewAutoresizingFlexibleBottomMargin;
    //    [_introView addSubview:bgImageView];

    UILabel *introlTitleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(TITLE_MARGIN_LEFT, INTRO_TITLE_MARGIN_TOP,
                                 G_SCREEN_WIDTH - 2 * TITLE_MARGIN_LEFT, 16)];
    introlTitleLabel.backgroundColor = [UIColor clearColor];
    introlTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    introlTitleLabel.textColor = UIColorRGB(69, 73, 76);
    introlTitleLabel.text = @"微专业简介:";
    [_introView addSubview:introlTitleLabel];

    introductionLabel = [[UILabel alloc] init];
    introductionLabel.backgroundColor = [UIColor clearColor];
    introductionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    introductionLabel.textAlignment = NSTextAlignmentLeft;
    introductionLabel.numberOfLines = 0;
    introductionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    introductionLabel.textColor = UIColorRGB(97, 100, 102);
    introductionLabel.frame =
        CGRectMake(INTRO_TEXT_MARGIN_LEFT,
                   INTRO_TEXT_MARGIN_TOP + introlTitleLabel.frame.origin.y +
                       introlTitleLabel.frame.size.height,
                   G_SCREEN_WIDTH - 2 * INTRO_TEXT_MARGIN_LEFT, 50);
    UIView *lineView = [[UIView alloc]
        initWithFrame:CGRectMake(8, INTRO_TITLE_MARGIN_TOP, 2, 16)];
    [lineView setBackgroundColor:[UIColor kkb_colorwithHexString:@"ffb726"
                                                           alpha:1.0]];

    [_introView addSubview:introductionLabel];
    [_introView addSubview:lineView];

    [self.scrollView addSubview:_introView];
}

- (void)addCertificateView {

    _certificateView = [[UIView alloc]
        initWithFrame:CGRectMake(0, _introView.frame.origin.y +
                                        _introView.frame.size.height +
                                        CERTIFICATE_VIEW_MARGIN_TOP,
                                 G_SCREEN_WIDTH, CERTIFICATE_VIEW_HEIGHT)];
    [_certificateView setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(TITLE_MARGIN_LEFT, 0,
                                 G_SCREEN_WIDTH - 2 * TITLE_MARGIN_LEFT, 18)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = UIColorRGB(69, 73, 76);
    titleLabel.text = @"微专业证书";
    [_certificateView addSubview:titleLabel];

    certificateBackgroundView = [[UIControl alloc]
        initWithFrame:CGRectMake(CERTIFICATE_BG_MARGIN_EDGE,
                                 titleLabel.frame.origin.y +
                                     titleLabel.frame.size.height +
                                     CERTIFICATE_BG_MARGIN_TOP,
                                 G_SCREEN_WIDTH -
                                     2 * CERTIFICATE_BG_MARGIN_EDGE,
                                 CERTIFICATE_VIEW_HEIGHT - titleLabel.bottom -
                                     CERTIFICATE_BG_MARGIN_TOP)];

    certificateBackgroundView.layer.cornerRadius = 2.0f;
    certificateBackgroundView.layer.masksToBounds = YES;

    [certificateBackgroundView addTarget:self
                                  action:@selector(certificateViewDidTouchDown)
                        forControlEvents:UIControlEventTouchDown];
    [certificateBackgroundView
               addTarget:self
                  action:@selector(certificateViewDidTouchCancel)
        forControlEvents:UIControlEventTouchCancel];
    [certificateBackgroundView
               addTarget:self
                  action:@selector(certificateViewDidTouchCancel)
        forControlEvents:UIControlEventTouchUpOutside];
    [certificateBackgroundView
               addTarget:self
                  action:@selector(certificateViewDidTouchUpInside)
        forControlEvents:UIControlEventTouchUpInside];

    [_certificateView addSubview:certificateBackgroundView];
    [certificateBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [_certificateView addSubview:certificateBackgroundView];
    // add
    certificat = [[UIImageView alloc]
        initWithFrame:CGRectInset(certificateBackgroundView.frame,
                                  CERTIFICATE_IMG_MARGIN,
                                  CERTIFICATE_IMG_MARGIN)];
    NSString *certificateUrl =
        [self.currentMajor objectForKey:@"certificate_url"];
    //改用异步获取图片
    [certificat sd_setImageWithURL:[NSURL URLWithString:certificateUrl]
                  placeholderImage:[UIImage imageNamed:@"certificate_default"]];
    [_certificateView addSubview:certificat];

    [_scrollView addSubview:_certificateView];

#ifdef DEBUGUI
    bgImageView.backgroundColor = [UIColor grayColor];
    _certificateView.backgroundColor = [UIColor blueColor];
    titleLabel.backgroundColor = [UIColor yellowColor];
#else
    _certificateView.backgroundColor = [UIColor clearColor];
    titleLabel.backgroundColor = [UIColor clearColor];

#endif
}

- (void)addTableView {
    _courseView = [[UIView alloc]
        initWithFrame:CGRectMake(0, _certificateView.frame.origin.y +
                                        _certificateView.frame.size.height,
                                 G_SCREEN_WIDTH, 100)];

    UILabel *titleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(TITLE_MARGIN_LEFT, 0,
                                 G_SCREEN_WIDTH - 2 * TITLE_MARGIN_LEFT, 18)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = UIColorRGB(69, 73, 76);
    titleLabel.text = @"微专业课程";
    [_courseView addSubview:titleLabel];

    coursesTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, titleLabel.bottom +
                                        COURSETABLE_VIEW_MARGIN_TOP,
                                 G_SCREEN_WIDTH, 30)];
    coursesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    coursesTableView.backgroundView = nil;
    coursesTableView.backgroundView.backgroundColor = [UIColor clearColor];
    [coursesTableView registerNib:[CourseItemCell cellNib]
           forCellReuseIdentifier:COURSEITEMCELL_RESUEDID];
    coursesTableView.delegate = self;
    coursesTableView.dataSource = self;
    [coursesTableView setScrollEnabled:NO];
    [_courseView addSubview:coursesTableView];

    [self.scrollView addSubview:_courseView];

#ifdef DEBUGUI
    _courseView.backgroundColor = [UIColor yellowColor];
    titleLabel.backgroundColor = [UIColor greenColor];
    coursesTableView.backgroundColor = [UIColor grayColor];
#else
    _courseView.backgroundColor = [UIColor clearColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    coursesTableView.backgroundColor = [UIColor clearColor];
#endif
}

- (void)addEnrollCourseButton {
    isListFold = YES;
    enrollButtonView = [[UIView alloc]
        initWithFrame:CGRectMake(0,
                                 G_SCREEN_HEIGHT - gNavigationAndStatusHeight -
                                     BOTTOM_BUTTON_HEIGHT,
                                 G_SCREEN_WIDTH, enrollButtonViewHeight)];
    courseListTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, BOTTOM_BUTTON_HEIGHT, G_SCREEN_WIDTH,
                                 courseListHeight)
                style:UITableViewStyleGrouped];
    courseListTableView.dataSource = self;
    courseListTableView.delegate = self;
    courseListTableView.showsVerticalScrollIndicator = NO;
    courseListTableView.separatorStyle =
        UITableViewCellSeparatorStyleSingleLine;
    [courseListTableView setBackgroundColor:[UIColor whiteColor]];
    courseListArray = [_currentMajor objectForKey:@"courses"];
    enrollCourseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enrollCourseButton.frame =
        CGRectMake(0, 0, G_SCREEN_WIDTH, BOTTOM_BUTTON_HEIGHT);

    [enrollCourseButton setTitle:@"参加该微专业" forState:UIControlStateNormal];
    enrollCourseButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [enrollCourseButton setTitleColor:UIColorRGB(0, 142, 236)
                             forState:UIControlStateNormal];
    [enrollCourseButton addTarget:self
                           action:@selector(enrollCourseButtonDidPress:)
                 forControlEvents:UIControlEventTouchUpInside];

    [enrollCourseButton
        setBackgroundImage:[UIImage imageNamed:@"kkb-iphone-miniMicroMajor-button-normal"]
                  forState:UIControlStateNormal];

    [enrollCourseButton
        setBackgroundImage:[UIImage imageNamed:@"kkb-iphone-miniMicroMajor-button-pressed"]
                  forState:UIControlStateHighlighted];
    [enrollCourseButton setBackgroundColor:[UIColor clearColor]];
    [enrollCourseButton
        setImage:[UIImage imageNamed:@"suspension_icon_jointmpro"]
        forState:UIControlStateNormal];

    [enrollButtonView setBackgroundColor:[UIColor whiteColor]];
    [self setEnrollCourseButtonHiddenIfEnrolled];
    [enrollButtonView addSubview:enrollCourseButton];
    [enrollButtonView addSubview:courseListTableView];
    [self.view addSubview:enrollButtonView];
}

/**
 *  点击参加该微专业
 *
 *  @param button button description
 */
- (void)enrollCourseButtonDidPress:(UIButton *)button {
    NSLog(@"enrollCourseButtonDidPress");

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    //判断是否登录
    if (![KKBUserInfo shareInstance].isLogin) {
        [AppUtilities pushToLoginViewController:self];

    } else {

        if ([enrollCourseButton.titleLabel.text
                isEqualToString:@"已加入该微专业,开始学习"]) {

            if (isListFold == YES) {
                self.allowForceRotation = NO;
                [self ListAnimationUp];
                [_coverView setHidden:NO];
                navigation.allowShowCoverView = YES;
            } else {
                self.allowForceRotation = YES;
                [self ListAnimationDown];
                [_coverView setHidden:YES];
                navigation.allowShowCoverView = NO;
            }

        } else {
            NSString *urlPath = @"v1/micro_specialties/join";
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            NSString *userId = [[KKBUserInfo shareInstance] userId];

            [userInfo setValue:userId forKey:@"user_id"];
            [userInfo setValue:[_currentMajor objectForKey:@"id"]
                        forKey:@"micro_specialty_id"];
            [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
                method:@"POST"
                param:userInfo
                fromCache:NO
                success:^(id result, AFHTTPRequestOperation *operation) {
                    NSLog(@"result:%@", result);
                    [[LocalStorage shareInstance]
                        setEnrollCourseStatus:[_currentMajor objectForKey:@"id"]
                                       userId:userId];
                    isListFold = NO;
                    [enrollCourseButton
                        setBackgroundImage:
                            [UIImage imageNamed:@"kkb-iphone-miniMicroMajor-button-normal"]
                                  forState:UIControlStateNormal];
                    [enrollCourseButton
                        setTitle:@"已加入该微专业,开始学习"
                        forState:UIControlStateNormal];
                    [self ListAnimationUp];
                    [_coverView setHidden:NO];
                    navigation.allowShowCoverView = YES;
                }
                failure:^(id result, AFHTTPRequestOperation *operation) {

                    [self.loadingView markAsFailure];

                    [self performSelector:@selector(hideLoadingView)
                               withObject:nil
                               afterDelay:2.0f];
                }];
        }
    }
}

- (void)initCoverView {
    _coverView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, 320,
                                 G_SCREEN_HEIGHT - gNavigationBarHeight)];
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
- (void)tapCover:(UIGestureRecognizer *)tap {
    //允许视频播放器横竖屏
    self.player.forceRotate = YES;

    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;
    [self ListAnimationDown];
}

- (void)navCoverViewTap {
    self.player.forceRotate = YES;

    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;

    [self ListAnimationDown];
}

- (void)ListAnimationUp {
    [UIView animateWithDuration:0.2
        animations:^{
            [enrollButtonView setTop:G_SCREEN_HEIGHT - enrollButtonViewHeight -
                                     gNavigationAndStatusHeight];
        }
        completion:^(BOOL finished) { isListFold = NO; }];
}

- (void)ListAnimationDown {
    [UIView animateWithDuration:0.2
        animations:^{
            [enrollButtonView setTop:G_SCREEN_HEIGHT - BOTTOM_BUTTON_HEIGHT -
                                     gNavigationAndStatusHeight];
        }
        completion:^(BOOL finished) { isListFold = YES; }];
}

- (void)hideLoadingView {
    [self.loadingView markAsLoading];
    [self.loadingView hideView];
}

- (void)addShareButton {
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton
        setBackgroundImage:[UIImage
                               imageNamed:@"kkb-iphone-common-share-normal"]
                  forState:UIControlStateNormal];

    [shareButton
        setBackgroundImage:[UIImage
                               imageNamed:@"kkb-iphone-common-share-selected"]
                  forState:UIControlStateSelected];

    [shareButton setFrame:CGRectMake(0, 0, 28, 28)];

    [shareButton addTarget:self
                    action:@selector(shareButtonDidPress:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 =
        [[UIBarButtonItem alloc] initWithCustomView:shareButton];

    self.navigationItem.rightBarButtonItem = item2;
}

- (void)setEnrollCourseButtonHiddenIfEnrolled {

    if ([KKBUserInfo shareInstance].isLogin == YES) {
        if ([[_currentMajor objectForKey:@"join_status"] integerValue] == 1 ||
            [[LocalStorage shareInstance]
                getEnrollCourseStatus:[_currentMajor objectForKey:@"id"]
                               userId:[KKBUserInfo shareInstance].userId]) {
            [enrollCourseButton
                setBackgroundImage:[UIImage
                                       imageNamed:@"kkb-iphone-miniMicroMajor-button-normal"]
                          forState:UIControlStateNormal];
            [enrollCourseButton setTitle:@"已加入该微专业,开始学习"
                                forState:UIControlStateNormal];
        }
    }
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = 0;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - gNavigationBarHeight - gStatusBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

#pragma mark - load data

- (float)calculateintroductionLabelHeight {
    // TODO: byzm deprecated iOS7
    CGSize size = [introductionLabel.text
             sizeWithFont:introductionLabel.font
        constrainedToSize:CGSizeMake(G_SCREEN_WIDTH - 2 * TITLE_MARGIN_LEFT,
                                     MAXFLOAT)
            lineBreakMode:NSLineBreakByWordWrapping];

    return ceil(size.height);
}

- (void)refreshSize {
    // introduction View size
    float labelHeight = [self calculateintroductionLabelHeight];
    CGRect frame = introductionLabel.frame;
    frame.size.height = labelHeight;
    introductionLabel.frame = frame;

    CGFloat introHeight = introductionLabel.bottom + INTRO_TEXT_MARGIN_BOTTOM;
    self.introView.height = introHeight;

    self.certificateView.top =
        self.introView.bottom + CERTIFICATE_VIEW_MARGIN_TOP;

    self.courseView.top = self.certificateView.bottom + COURSE_VIEW_MARGIN_TOP;

    CGFloat tableViewHeight = self.courses.count * COURSEITEMCELL_HEIGHT;
    coursesTableView.height = tableViewHeight;

    self.courseView.height = coursesTableView.bottom;

    // set scrollview contentSize
    self.scrollView.contentSize = CGSizeMake(
        self.view.width, self.courseView.bottom + BOTTOM_BUTTON_HEIGHT + 10);
}

- (void)initWithInfo {
    if (!_currentMajor) {
        self.scrollView.hidden = YES;
        return;
    }

    NSDictionary *majorInfo = _currentMajor;
    _majorTitle = [majorInfo objectForKey:@"name"];

    dispatch_async(dispatch_get_main_queue(),
                   ^{ [self setTitle:_majorTitle]; });

    NSString *majorIntro = [majorInfo objectForKey:@"intro"];
    introductionLabel.text = majorIntro;

    NSString *videoUrl = [majorInfo objectForKey:@"url_about_video"];

    NSString *imageUrl = [majorInfo objectForKey:@"image_url"];
    NSString *certificateUrl = [majorInfo objectForKey:@"certificate_url"];
    //改用异步获取图片
    [certificat sd_setImageWithURL:[NSURL URLWithString:certificateUrl]
                  placeholderImage:nil];

    self.videoURLs = [@[ videoUrl ] mutableCopy];
    self.coverImgURL = [AppUtilities adaptImageURLforPhone:imageUrl];

    subCoursesData = nil;
    subCoursesData = (NSArray *)[majorInfo objectForKey:@"courses"];

    [self.courses removeAllObjects];
    for (NSDictionary *aCourse in subCoursesData) {
        NSString *courseName = [aCourse objectForKey:@"name"];
        NSString *courseIntro = [aCourse objectForKey:@"intro"];
        NSString *courseImage = [aCourse objectForKey:@"cover_image"];
        NSString *courseStatus = [aCourse objectForKey:@"status"];
        NSString *typeStr = aCourse[@"type"];

        BOOL isOnline = [courseStatus isEqualToString:COURSE_STATUS];

        MiniMajorCourse *mCourse = [[MiniMajorCourse alloc] initWith:courseImage
                                                           withTitle:courseName
                                                           andDetail:courseIntro
                                                              onLine:isOnline];
        mCourse.isOpenType = [typeStr isEqualToString:OPEN_COURSE_TYPE];
        NSNumber *arating = aCourse[@"rating"];
        int rating = [arating intValue];
        CGFloat covertRating = rating / 2.0;
        if (covertRating > 5) {
            covertRating = 5;
        }
        mCourse.rating = covertRating;
        mCourse.enrollments_count = aCourse[@"enrollments_count"];

        [self.courses addObject:mCourse];
    }

    [coursesTableView reloadData];
    //刷新控件尺寸
    [self refreshSize];
}

#pragma mark - 处理旋转事件隐藏控件
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        enrollCourseButton.hidden = YES;
        enrollButtonView.hidden = YES;
    } else {
        enrollCourseButton.hidden = NO;
        enrollButtonView.hidden = NO;
    }
}
@end
