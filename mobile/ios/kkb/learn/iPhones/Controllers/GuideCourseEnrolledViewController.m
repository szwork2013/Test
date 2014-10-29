//
//  GuideCourseAfterLoginViewController.m
//  learn
//
//  Created by zxj on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideCourseEnrolledViewController.h"
#import "AppUtilities.h"
#import "KKBUserInfo.h"
#import "UMSocial.h"
#import "GlobalOperator.h"
#import "KKBHttpClient.h"
#import "PublicDownloadView.h"
#import "GuideCourseDownloadView.h"
#import "GuideCourseAfterOneCell.h"
#import "GuideCourseAfterTwoCell.h"
#import "MobClick.h"
#import "SDWebImageDownloader.h"
#import "InfoButtonOneCell.h"
#import "InfoButtonTwoCell.h"
#import "KKBBaseNavigationController.h"

#import "UIViewController+KNSemiModal.h"

#import "KKBCommentListViewController.h"
#import "UIViewController+KNSemiModal.h"

#import "KKBDownloadTwolevelController.h"
#import "KKBDownloadControlViewController.h"
#import "KKBDownloadTreeViewModel.h"
#import "KKBDownloadVideoModel.h"
#import "KKBDownloadClassModel.h"

static const int ddLogLevel = LOG_LEVEL_WARN;

#define degreesToRadians(x) (M_PI * x / 180.0f)

static const CGFloat bottomButtonWidth = 60;
static const CGFloat bottomButtonSpace = 20;
static const CGFloat bottomButtonToScreen = 10;
static const CGFloat infoTableViewHeight = 280;
static const CGFloat introViewHeight = 300;
static const CGFloat infoTableViewWidth = 304;

static const CGFloat downloadButtonTag = 11000;
static const CGFloat commentButtonTag = 11001;
static const CGFloat shareButtonTag = 11002;
static const CGFloat collectionButtonTag = 11003;

static const CGFloat infoCellHeight = 90;

@interface GuideCourseEnrolledViewController () <
    KKBDownloadTwoLevelVCDelegate> {
    RATreeView *downloadTableView;
    UITableView *commentTableView;
    BOOL downloadIsOpen;
    GuideCourseDownloadView *_downLoadView;

    NSMutableArray *_openedWeeks;
    NSInteger openWeek;

    NSUInteger openWhichWeek;
    NSDictionary *openWhichItemDict;

    UIImage *_shareImage;
    UIView *introView;
    UITableView *infoButtonTableView;
    NSArray *techArray;
    UIView *_coverView;
    KKBBaseNavigationController *navigation;
    KKBCommentListView *commentListView;
    BOOL isPlayingWhenClick;
}

@property(strong, nonatomic) NSArray *downloadDatas;

@end

@implementation GuideCourseEnrolledViewController

#pragma mark - LifeCycle Methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [commentListView removeFromSuperview];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    isPlayingWhenClick = NO;
    /**统一查询course接口zeng**/
    [KKBCourseManager
          getCourseWithID:@([self.courseId intValue])
              forceReload:NO
        completionHandler:^(id model, NSError *error) {
            if (!error) {
                allCourseInfoDic = model;
                NSArray *lmsCourseArray =
                    [allCourseInfoDic objectForKey:@"lms_course_list"];
                for (NSDictionary *classInfoDict in lmsCourseArray) {
                    DDLogInfo(@"classinfoDict is %@", classInfoDict);
                    if ([[[classInfoDict
                            objectForKey:@"lms_course_id"] stringValue]
                            isEqualToString:self.classId]) {
                        courseTreeArray =
                            [classInfoDict objectForKey:@"course_arrange"];
                    }
                }

                [self.treeView reloadData];

                [self playVideoIfNeededLater];
                [self expandTreeViewIfNeededLater];
            }
        }];

    //评论页消失的通知
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(commentViewDidHide)
               name:kSemiModalDidHideNotification
             object:nil];

    //    courseTreeArray = [allCourseInfoDic objectForKey:@"course_outline"];
    [self requestCollectionStatus:YES];
    [self requestCollectionStatus:NO];

    [self openWeeksWithClassId];
    [self initGuideCourseDownloadView];

    [self initPlayerFrameView];
    [self initBottomView];
    [self initTreeView];

    //从动态页面进入续播
    if (_playRecordVideoId != nil) {
        for (int i = 0; i < [courseItemIDs count]; i++) {
            NSString *dict = [[courseItemIDs objectAtIndex:i] stringValue];
            if ([dict longLongValue] == [_playRecordVideoId longLongValue]) {

                //开始续播
                [self changeVideoToIndex:i];
                break;
            }
        }
    }
    self.navigationItem.title = [allCourseInfoDic objectForKey:@"name"];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"course_info"]
                   forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 24, 24)];
    [btn addTarget:self
                  action:@selector(btnInfoClick:)
        forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;

    [self initCoverView];
    [self initIntroView];

    [[SDWebImageDownloader sharedDownloader]
        downloadImageWithURL:
            [NSURL URLWithString:[allCourseInfoDic objectForKey:@"cover_image"]]
        options:1
        progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
        completed:^(UIImage *image, NSData *data, NSError *error,
                    BOOL finished) {
            if (finished) {
                _shareImage = image;
            }
        }];

    [self loadComment:YES];
    [self loadComment:NO];

    //评论数
    NSNumber *commentCount = allCourseInfoDic[@"evaluations_count"];
    if ([commentCount isKindOfClass:[NSNumber class]]) {
        [self commentCount:[commentCount intValue]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = NO;

    [MobClick beginLogPageView:@"GuideCourseLearn"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navCoverViewTap)
                                                 name:navigationBarCoverTap
                                               object:nil];

    //更新视频地址信息
    self.videoURLs = [courseVideoURLs mutableCopy];
    self.itemIDs = courseItemIDs;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([KKBUserInfo shareInstance].goToDownloadFromStudyVC == YES) {
        UIButton *downloadButton =
            (UIButton *)[self.bottomView viewWithTag:downloadButtonTag];
        [self buttonClick:downloadButton];
    }
    [KKBUserInfo shareInstance].goToDownloadFromStudyVC = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navigation.allowShowCoverView = NO;

    [MobClick endLogPageView:@"GuideCourseLearn"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:navigationBarCoverTap
                                                  object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.treeView.top = self.player.view.height;
    self.treeView.height =
        self.view.height - self.player.view.height - gBottomViewHeight;
    self.bottomView.top = self.treeView.bottom;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods
- (void)expandTreeViewIfNeeded {

    if (self.shouldExpandTreeViewTargetSection) {

        [self.treeView
            expandRowForItem:[courseTreeArray objectAtIndex:openWhichWeek]];
    }
}

- (void)expandTreeViewIfNeededLater {
    // 延迟执行以避免闪退
    [self performSelector:@selector(expandTreeViewIfNeeded)
               withObject:nil
               afterDelay:0.1f];
}

- (void)playVideoIfNeededLater {
    // 延迟执行以避免闪退
    [self performSelector:@selector(playVideoIfNeeded)
               withObject:nil
               afterDelay:0.1f];
}

- (void)playVideoIfNeeded {
    if (self.playVideoImmediately) {
        [self.player playButtonPressed];
    }
}

- (void)initCoverView {
    _coverView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
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

- (void)initIntroView {
    introView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, introViewHeight)];
    UIImageView *triangleView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"Triangle.png"]];
    UIImageView *cornerView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"rounded-rectangle.png"]];
    [triangleView setFrame:CGRectMake(293, 0, 15, 9)];
    [cornerView setFrame:CGRectMake(0, 9, 320, 289)];
    [introView addSubview:triangleView];
    [introView addSubview:cornerView];
    [self initInfoButtonTableView];
    [self.view addSubview:introView];
    [introView setHidden:YES];
}
- (void)initInfoButtonTableView {
    infoButtonTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(8, 9, infoTableViewWidth, infoTableViewHeight)
                style:UITableViewStyleGrouped];
    infoButtonTableView.backgroundColor = [UIColor clearColor];
    infoButtonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoButtonTableView.delegate = self;
    infoButtonTableView.dataSource = self;
    infoButtonTableView.showsVerticalScrollIndicator = NO;
    [introView addSubview:infoButtonTableView];
    techArray = [allCourseInfoDic objectForKey:@"tech"];
    [infoButtonTableView reloadData];
}

- (void)openWeeksWithClassId {
    // 通过courseid 和 classid 获得已经开课的周数
    NSArray *classInfoArray =
        [allCourseInfoDic objectForKey:@"lms_course_list"];
    for (NSDictionary *classInfoDict in classInfoArray) {
        if ([self.classId
                isEqualToString:
                    [[classInfoDict
                        objectForKey:@"lms_course_id"] stringValue]]) {
            openWeek =
                [[classInfoDict objectForKey:@"opened_weeks"] integerValue];
        }
    }
    // 已结课
    if (openWeek == -1) {

    } else if (openWeek == -2) { // 即将开课
        if ([[[courseTreeArray objectAtIndex:0] objectForKey:@"name"]
                isEqualToString:@"了解课程"]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObject:[courseTreeArray objectAtIndex:0]];
            courseTreeArray = tempArray;
        } else {
        }
    } else { // 第几周
        // 如果是动态页面点击过来的
        if (self.courseNumberOfWeeks) {
            // 点击的周数
            openWhichWeek = self.courseNumberOfWeeks;
            // 如果有了解课程
            if ([[[courseTreeArray objectAtIndex:0] objectForKey:@"name"]
                    isEqualToString:@"了解课程"]) {
                openWeek++;
            }
            // 没有了解课程
            else {
                openWhichWeek--;
            }
            // 全部课程列表

            NSArray *lmsCourseArray =
                [allCourseInfoDic objectForKey:@"lms_course_list"];

            for (NSDictionary *classInfoDict in lmsCourseArray) {
                DDLogInfo(@"classinfoDict is %@", classInfoDict);
                NSArray *classArray =
                    [classInfoDict objectForKey:@"course_arrange"];

                if ([[[classInfoDict objectForKey:@"lms_course_id"] stringValue]
                        isEqualToString:self.classId]) {
                    _openedWeeks =
                        [[NSMutableArray alloc] initWithCapacity:openWeek + 1];
                    for (int i = 0; i < openWeek; i++) {
                        if (classArray.count > i) {
                            [_openedWeeks
                                addObject:[classArray objectAtIndex:i]];
                        }
                    }
                    courseTreeArray = _openedWeeks;
                }
            }

            openWhichItemDict = [[NSDictionary alloc] init];
            openWhichItemDict = [courseTreeArray objectAtIndex:openWhichWeek];
        } else {
            // 如果有了解课程
            if ([[[courseTreeArray objectAtIndex:0] objectForKey:@"name"]
                    isEqualToString:@"了解课程"]) {
                openWeek++;
            }
            // 没有了解课程
            else {
                openWhichWeek--;
            }
            // 全部课程列表
            NSArray *lmsCourseArray =
                [allCourseInfoDic objectForKey:@"lms_course_list"];
            for (NSDictionary *classInfoDict in lmsCourseArray) {
                DDLogInfo(@"classinfoDict is %@", classInfoDict);

                if ([[[classInfoDict objectForKey:@"lms_course_id"] stringValue]
                        isEqualToString:self.classId]) {
                    _openedWeeks =
                        [[NSMutableArray alloc] initWithCapacity:openWeek + 1];
                    for (int i = 0; i < openWeek; i++) {
                        [_openedWeeks
                            addObject:[[classInfoDict
                                          objectForKey:@"course_arrange"]
                                          objectAtIndex:i]];
                    }
                    courseTreeArray = _openedWeeks;
                }
            }
        }
    }
}

- (void)initGuideCourseDownloadView {
    _downLoadView = [[GuideCourseDownloadView alloc]
        initWithFrame:CGRectMake(0, G_SCREEN_HEIGHT, G_SCREEN_WIDTH,
                                 G_SCREEN_HEIGHT - gNavigationAndStatusHeight)];
    _downLoadView.delegate = self;
    _downLoadView.courseId = self.courseId;
    _downLoadView.currentCourseVideoList =
        [_currentCourse objectForKey:@"videos"];
    [_downLoadView initWithUI];
    [self.view addSubview:_downLoadView];
    [self.view bringSubviewToFront:_downLoadView];
}

- (void)initBottomView {
    self.bottomView = [[UIView alloc] init];
    [self.bottomView setBackgroundColor:[UIColor whiteColor]];
    self.bottomView.frame = CGRectMake(0, G_SCREEN_HEIGHT - gBottomViewHeight -
                                              gNavigationAndStatusHeight,
                                       G_SCREEN_WIDTH, gBottomViewHeight);
    // TODO: byzm
    buttonArray = [[NSMutableArray alloc] init];
    NSArray *array1 =
        [NSArray arrayWithObjects:@"kkb-iphone-study-download-normal",
                                  @"apprise_normalnew", @"share_normalnew",
                                  @"collection_normalnew", nil];

    NSArray *array2 =
        [NSArray arrayWithObjects:@"kkb-iphone-study-download-highlighted",
                                  @"", @"share_pressnew", @"", nil];

    for (int i = 0; i < 4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i + 11000;
        [button
            setFrame:CGRectMake(i * (bottomButtonWidth + bottomButtonSpace) +
                                    bottomButtonToScreen,
                                0, bottomButtonWidth, gBottomViewHeight)];
        [button addTarget:self
                      action:@selector(buttonClick:)
            forControlEvents:UIControlEventTouchUpInside];

        [button setBackgroundImage:[UIImage imageNamed:array1[i]]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:array2[i]]
                          forState:UIControlStateHighlighted];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:14]];
        [buttonArray addObject:button];
        [self.bottomView addSubview:button];

        UIView *lineView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, 1)];
        [lineView setBackgroundColor:[UIColor kkb_colorwithHexString:@"dbdbdb"
                                                               alpha:1]];
        [self.bottomView addSubview:lineView];
        [self.view addSubview:self.bottomView];
    }
}
- (void)buttonClick:(UIButton *)button {
    NSMutableArray *otherButtonArray =
        [NSMutableArray arrayWithArray:buttonArray];
    [otherButtonArray removeObject:button];

    if (button.tag == commentButtonTag) {

        self.allowForceRotation = NO;
        [self pauseWhenPlaying];
        DDLogInfo(@"评论！！！！");

        //禁止视频播放自动横屏
        self.allowForceRotation = NO;

        [commentListView showCommentView];

    } else if (button.tag == shareButtonTag) {
        self.allowForceRotation = NO;
        [self pauseWhenPlaying];
        downloadIsOpen = NO;
        DDLogInfo(@"分享！！！");

        NSString *shareDownloadUrl =
            [NSString stringWithFormat:@"http://www.kaikeba.com/courses/%@",
                                       self.courseId];

        NSString *shareTextForSina =
            [NSString stringWithFormat:@"#新课抢先知#"
                      @"这课讲的太屌了，朕灰常满意！小伙伴们"
                      @"不要太想我，我在@开课吧官方微博 "
                      @"虐学渣，快来和我一起吧！"];
        NSString *shareTextForOther = [NSString
            stringWithFormat:
                @"我正在开课吧观看《%@"
                @"》这门课，老师讲得吼赛磊呀！小伙伴们"
                @"要不要一起来呀?",
                [allCourseInfoDic objectForKey:@"name"]];

        [[KKBShare shareInstance]
               shareWithImage:_shareImage
                      viewCtr:self
                     courseId:self.courseId
                   courseName:[allCourseInfoDic objectForKey:@"name"]
             shareDownloadUrl:shareDownloadUrl
             shareTextForSina:shareTextForSina
            shareTextForOther:shareTextForOther];

        [KKBShare shareInstance].delegate = self;

    } else if (button.tag == collectionButtonTag) {
        DDLogInfo(@"已收藏！！！");

        if (isCollectioned == YES) {
            [self deleteFavourite:NO];
        } else {
            [self joinFavourite:NO];
        }

    } else if (button.tag == downloadButtonTag) {
        DDLogInfo(@"下载");
        //暂停播放
        [self presentViewShouldPlayContent:NO];
        
        // TODO: byzm
        // reset video selected status
        for (KKBDownloadTreeViewModel *model in self.downloadDatas) {
            for (KKBDownloadVideoModel *videoModel in model.childrens) {
                videoModel.isSelected = NO;
            }
        }
        
        KKBDownloadTwolevelController *downloadVC =
            [[KKBDownloadTwolevelController alloc] init];
        downloadVC.delegate = self;
        downloadVC.videoItems = self.downloadDatas;

        KKBDownloadClassModel *classModel =
            [[KKBDownloadClassModel alloc] init];
        classModel.name = [allCourseInfoDic objectForKey:@"name"];
        classModel.classID = @([self.classId longLongValue]);
        classModel.classType = videoGuideCourse;
        downloadVC.classModel = classModel;

        downloadVC.view.frame =
            CGRectMake(0, 0, self.view.width, self.view.bounds.size.height -
                                                  gPopDownloadViewMarginTop);
        [self presentSemiViewController:downloadVC
                            withOptions:@{
                                KNSemiModalOptionKeys.pushParentBack : @(NO),
                                KNSemiModalOptionKeys.parentAlpha : @(0.4),
                                KNSemiModalOptionKeys.animationDuration : @(0.4)
                            }];
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
#pragma mark - Request
- (void)loadComment:(BOOL)fromCache {
    NSString *jsonForComment =
        [NSString stringWithFormat:@"v1/evaluation/courseid/%@",
                                   [allCourseInfoDic objectForKey:@"id"]];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForComment
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"result is %@", result);
            NSArray *array = result;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                NSString *content = [dict objectForKey:@"content"];
                [tempArray addObject:content];
            }

            if (commentListView == nil) {
                commentListView = [[KKBCommentListView alloc]
                    initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                             G_SCREEN_HEIGHT)
                     CommentArray:array
                       CourseType:@"OpenCourse"];
                commentListView.delegate = self;
                commentListView.backgroundColor = [UIColor clearColor];
                UIWindow *window =
                    [[UIApplication sharedApplication] keyWindow];
                [window addSubview:commentListView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"error is %@", result);
            if (commentListView == nil) {
                commentListView = [[KKBCommentListView alloc]
                    initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                             G_SCREEN_HEIGHT)
                     CommentArray:nil
                       CourseType:@"OpenCourse"];
                commentListView.backgroundColor = [UIColor clearColor];
                UIWindow *window =
                    [[UIApplication sharedApplication] keyWindow];
                [window addSubview:commentListView];
            }
        }];
}

/**
 关闭当前页面之后

 @param fromViewControllerType 关闭的页面类型

 */
- (void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType {
    self.allowForceRotation = YES;
}

- (void)didFinishGetUMSocialDataInViewController:
            (UMSocialResponseEntity *)response {
    //分享完成之后视频旋转事件
    self.allowForceRotation = YES;
}

- (void)joinFavourite:(BOOL)fromCache {
    NSString *jsonForJoinFavourite = @"v1/collections";
    NSString *user_id = [KKBUserInfo shareInstance].userId;
    NSString *course_id = self.courseId;
    NSMutableDictionary *dict = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:user_id, @"user_id", course_id,
                                     @"course_id", nil];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForJoinFavourite
        method:@"POST"
        param:dict
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"result is %@", result);
            UIButton *button = [buttonArray objectAtIndex:3];
            [button
                setBackgroundImage:[UIImage imageNamed:@"collection_selected"]
                          forState:UIControlStateNormal];

            isCollectioned = YES;
            [[KKBHttpClient shareInstance] refreshDynamic];
            [[KKBHttpClient shareInstance] refreshMyCollection];
            self.successView.successMessage.text = @"已收藏";
            [self.view bringSubviewToFront:self.successView];
            [self popSuccessView];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"error is %@", result);
            NSDictionary *errorResult = result;
            DDLogInfo(@"error is %@", errorResult);
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"已收藏此课程"
                                           message:@""
                                          delegate:self
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
            [alert show];
        }];
}

- (void)deleteFavourite:(BOOL)fromCache {
    NSString *deleteFavourite = @"v1/collections/delete";
    NSString *user_id = [KKBUserInfo shareInstance].userId;
    NSString *course_id = self.courseId;
    NSMutableDictionary *dict = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:user_id, @"user_id", course_id,
                                     @"course_id", nil];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:deleteFavourite
        method:@"POST"
        param:dict
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"result is %@", result);
            isCollectioned = NO;
            UIButton *button = [buttonArray objectAtIndex:3];
            [button
                setBackgroundImage:[UIImage imageNamed:@"collection_normalnew"]
                          forState:UIControlStateNormal];

            [[KKBHttpClient shareInstance] refreshDynamic];
            [[KKBHttpClient shareInstance] refreshMyCollection];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"error is %@", result);
        }];
}

- (void)requestCollectionStatus:(BOOL)fromCache {
    NSString *urlPath = [NSString stringWithFormat:@"v1/collections/user"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            // hid hub
            [self.loadingView hideView];

            NSArray *array = result;
            for (NSDictionary *dic in array) {
                int courseId = [[dic objectForKey:@"id"] intValue];

                if (courseId == [self.courseId intValue]) {
                    isCollectioned = YES;
                    UIButton *button = [buttonArray objectAtIndex:3];
                    [button setBackgroundImage:
                                [UIImage imageNamed:@"collection_selected"]
                                      forState:UIControlStateNormal];
                }
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            // hid hub
            [self.loadingView hideView];
        }];
}

- (void)initTreeView {
    self.treeView = [[RATreeView alloc]
        initWithFrame:CGRectMake(0, 175, G_SCREEN_WIDTH, G_SCREEN_HEIGHT - 235)
                style:RATreeViewStylePlain];
    self.treeView.delegate = self;
    self.treeView.dataSource = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    self.treeView.showsVerticalScrollIndicator = NO;
    self.treeView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.treeView];
}

- (void)initPlayerFrameView {
    [self.view addSubview:self.player.view];
    self.videoType = VideoPlayMutiType;

    courseItemIDs = [[NSMutableArray alloc]
        initWithCapacity:[_currentCourseVideoList count]];
    courseVideoURLs = [[NSMutableArray alloc]
        initWithCapacity:[_currentCourseVideoList count]];

    // TODO: byzm
    NSMutableArray *tmpDownloadVideos =
        [[NSMutableArray alloc] initWithCapacity:[courseTreeArray count]];

    for (NSDictionary *itemsDict in courseTreeArray) {

        KKBDownloadTreeViewModel *treeViewModel =
            [[KKBDownloadTreeViewModel alloc] init];
        treeViewModel.sectionName = itemsDict[@"name"];

        NSArray *itemArray = [itemsDict objectForKey:@"items"];

        NSMutableArray *tempVideos =
            [[NSMutableArray alloc] initWithCapacity:[itemArray count]];
        treeViewModel.childrens = tempVideos;

        for (NSDictionary *itemDict in itemArray) {
            if ([[itemDict objectForKey:@"type"]
                    isEqualToString:@"ExternalTool"]) {
                KKBDownloadVideoModel *videoModel =
                    [[KKBDownloadVideoModel alloc] init];
                videoModel.videoURL = [itemDict objectForKey:@"url"];
                videoModel.videoID = [itemDict objectForKey:@"id"];
                videoModel.videoTitle = [itemDict objectForKey:@"title"];
                [tempVideos addObject:videoModel];

                [courseItemIDs addObject:[itemDict objectForKey:@"id"]];
                [courseVideoURLs addObject:[itemDict objectForKey:@"url"]];
            }
        }

        //如果tempVideos中没视频则不加入到tmpDownloadVideos数组中
        if ([tempVideos count]) {
            [tmpDownloadVideos addObject:treeViewModel];
        }
    }

    self.videoURLs = [courseVideoURLs mutableCopy];
    self.itemIDs = courseItemIDs;

    self.downloadDatas = tmpDownloadVideos;
    self.coverImgURL = [AppUtilities
        adaptImageURLforPhone:[allCourseInfoDic objectForKey:@"cover_image"]];
}

#pragma mark - KKBShare Delegate Methods
- (void)shareViewControllerDidDismiss {
    [self playIfPauseWhenPlaying];
}

#pragma mark - KKBDownloadTwoLevelVCDelegate
- (void)downloadControlTapped:(KKBDownloadTwolevelController *)vc {
    __weak typeof(self) weakSelf = self;
    [self dismissSemiModalViewWithCompletion:^{
        KKBDownloadControlViewController *downloadControl =
            [[KKBDownloadControlViewController alloc] init];
        downloadControl.classID = @([weakSelf.courseId longLongValue]);
        downloadControl.fromStudyVC = YES;
        [self.navigationController pushViewController:downloadControl
                                             animated:YES];
    }];
}

#pragma mark - RATreeView Delegate Methods
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [courseTreeArray count];
    }

    NSDictionary *dic = (NSDictionary *)item;
    NSArray *itemArray = [dic objectForKey:@"items"];
    return [itemArray count];
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
    return NO;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {

    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell =
        [treeView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier];
    }

    NSInteger treeDepthLevel = [self.treeView levelForCellForItem:item];

    if (treeDepthLevel == 0) {
        static NSString *cellIdentifier = @"GuideCourseAfterOneCell";
        GuideCourseAfterOneCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"GuideCourseAfterOneCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        NSDictionary *dic = (NSDictionary *)item;

        cell.courseName.text = [dic objectForKey:@"name"];
        [cell.statusImageView
            setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-down"]];
        if ([treeView isCellForItemExpanded:item]) {

            [cell.statusImageView
                setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-up"]];
        }

        return cell;
    }

    if (treeDepthLevel == 1) {
        static NSString *cellIdentifier = @"GuideCourseAfterTwoCell";
        GuideCourseAfterTwoCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"GuideCourseAfterTwoCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        NSDictionary *dic = (NSDictionary *)item;
        NSString *courseName = [dic objectForKey:@"title"];
        cell.courseName.text = courseName;

        NSString *type = [dic objectForKey:@"type"];
        if ([type isEqualToString:@"ExternalTool"]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"teachers_icon_video_dis"]];
        } else if ([type isEqualToString:@"Discussion"]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"teachers_icon_talk_dis"]];
        } else if ([type isEqualToString:@"Assignment"]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"teachers_icon_homework_dis"]];
        } else if ([type isEqualToString:@"Quiz"]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"teachers_icon_test_dis"]];
        } else if ([type isEqualToString:@"Page"] ||
                   [type isEqualToString:@"WikiPage"] ||
                   [type isEqualToString:@"Attachment"]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"teachers_icon_document_dis"]];
        }

        return cell;
    }
    return nil;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [courseTreeArray objectAtIndex:index];
    }

    NSDictionary *dic = (NSDictionary *)item;
    NSArray *itemArray = [dic objectForKey:@"items"];
    return [itemArray objectAtIndex:index];
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item;
{
    NSInteger treeDepthLevel = [self.treeView levelForCellForItem:item];
    if (treeDepthLevel == 0) {
        GuideCourseAfterOneCell *cell =
            (GuideCourseAfterOneCell *)[treeView cellForItem:item];
        if ([treeView isCellForItemExpanded:item]) {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-down"]];

        } else {
            [cell.statusImageView
                setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-up"]];
        }

        [treeView deselectRowForItem:item animated:YES];
    }

    if (treeDepthLevel == 1) {
        NSDictionary *dic = (NSDictionary *)item;
        if ([[dic objectForKey:@"type"] isEqualToString:@"ExternalTool"]) {

            for (int i = 0; i < courseItemIDs.count; i++) {

                if ([[dic objectForKey:@"id"] intValue] ==
                    [[courseItemIDs objectAtIndex:i] intValue]) {

                    [self changeVideoToIndex:i];
                }
            }
        } else {
            NSString *title =
                [NSString stringWithFormat:@"程" @"序"
                          @"猿们正在努力完善，请先到开"
                          @"课吧网站查看"];
            UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:title
                                           message:nil
                                          delegate:self
                                 cancelButtonTitle:@"我知道了"
                                 otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item {

    return YES;
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return techArray.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:infoButtonTableView]) {
        if (section == 1) {
            UIView *headerView = [[UIView alloc]
                initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                         gInfoHeaderViewHeight)];

            UILabel *lineLabel = [[UILabel alloc]
                initWithFrame:CGRectMake(gScreenToCardLine, 0, gMajorCardWidth,
                                         gInfoHeaderViewLineHeight)];
            lineLabel.backgroundColor = UIColorRGBTheSame(219);
            [headerView addSubview:lineLabel];

            UIImageView *imageView = [[UIImageView alloc]
                initWithFrame:CGRectMake(gInfoHeaderViewImageViewOriginX,
                                         gInfoHeaderViewImageViewOriginY,
                                         gInfoHeaderViewImageViewWidth,
                                         gInfoHeaderViewImageViewHeight)];
            imageView.backgroundColor = UIColorRGB(0, 142, 236);
            [headerView addSubview:imageView];

            UILabel *titleLabel = [[UILabel alloc]
                initWithFrame:CGRectMake(gInfoHeaderViewLabelOriginX,
                                         gInfoHeaderViewLabelOriginY,
                                         gInfoHeaderViewLabelWidth,
                                         gInfoHeaderViewLabelHeight)];
            titleLabel.text = @"导师简介";
            titleLabel.textColor = UIColorRGB(0, 142, 236);
            titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [headerView addSubview:titleLabel];

            return headerView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:infoButtonTableView]) {
        if (section == 1) {
            return 28;
        } else {
            return 0.1;
        }
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {

        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"InfoButtonOneCell"
                                                     owner:self
                                                   options:nil];
        InfoButtonOneCell *cell = [arr objectAtIndex:0];
        cell.courseIntroLabel.text = [allCourseInfoDic objectForKey:@"intro"];
        cell.courseIntroLabel.height = cell.courseIntroLabel.optimumSize.height;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {

        static NSString *cellIdentifier = @"InfoButtonTwoCell";
        InfoButtonTwoCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"InfoButtonTwoCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backView;
        cell.selectedBackgroundView.backgroundColor =
            [UIColor tableViewCellSelectedColor];

        NSDictionary *dic = [techArray objectAtIndex:indexPath.row];

        NSString *imageUrl =
            [self iskindOfNullClass:[dic objectForKey:@"tech_img"]];
        [cell.teacherHeadImageView
            sd_setImageWithURL:[NSURL URLWithString:imageUrl]
              placeholderImage:[UIImage imageNamed:@"head_teacher"]];
        cell.teacherName.text =
            [self iskindOfNullClass:[dic objectForKey:@"name"]];
        cell.teacherTitle.text =
            [self iskindOfNullClass:[dic objectForKey:@"intro"]];

        cell.teacherDetailLabel.text = [dic objectForKey:@"desc"];

        cell.teacherDetailLabel.height =
            cell.teacherDetailLabel.optimumSize.height;

        if (indexPath.row == 0) {
            cell.teacherLineLabel.hidden = YES;
        }
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *text = [allCourseInfoDic objectForKey:@"intro"];
        return [self getInfoCellHeight:text:0];
    } else {
        NSDictionary *dic = [techArray objectAtIndex:indexPath.row];
        NSString *text = [dic objectForKey:@"desc"];
        return [self getInfoCellHeight:text:1];
    }
}

#pragma mark - publicCommentDelegate
- (void)commentCoverViewClick {
    [self.loadingView hideView];

    self.allowForceRotation = YES;
    [self.player playButtonPressed];
    DDLogInfo(@"comment delegate click");
    self.bottomView.hidden = NO;
}

#pragma mark - refresh comment label
- (void)commentCount:(int)commentCount {
    commentCountImageView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"apprise_normal2new"]];
    [commentCountImageView setFrame:CGRectMake(97, 34, 20, 10)];

    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(118, 34, 30, 10)];
    [countLabel setFont:[UIFont systemFontOfSize:10]];
    [countLabel setText:[NSString stringWithFormat:@"(%d)", commentCount]];

    if (commentCount >= 0 && commentCount < 10) {
        commentCountImageView.left = 90 + 13;
        countLabel.left = commentCountImageView.right + 3;
    } else if (commentCount >= 10 && commentCount < 100) {
        commentCountImageView.left = 90 + 10;
        countLabel.left = commentCountImageView.right + 3;
    } else if (commentCount >= 100 && commentCount < 1000) {
        commentCountImageView.left = 90 + 7;
        countLabel.left = commentCountImageView.right + 3;
    }

    [self.bottomView addSubview:commentCountImageView];
    [self.bottomView addSubview:countLabel];
}
#pragma mark - downLoadViewDelegate
- (void)downloadCoverViewClick {
    DDLogInfo(@"download delegate click");
    self.bottomView.hidden = NO;
    _downLoadView.frame =
        CGRectMake(0, G_SCREEN_HEIGHT - gNavigationAndStatusHeight,
                   G_SCREEN_WIDTH, G_SCREEN_HEIGHT - gNavigationBarHeight);
    downloadIsOpen = NO;
}

#pragma mark - 处理旋转事件隐藏控件
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.bottomView.hidden = YES;
        introView.hidden = YES;
        _coverView.hidden = YES;
        navigation.allowShowCoverView = NO;
    } else {
        self.bottomView.hidden = NO;
    }
}

#pragma mark - 当自动续播时将调用此方法 仅当 videoType 为VideoPlayMutiType时有效
- (void)videoWillStartPlayOfIndex:(NSUInteger)index {
    NSNumber *itemID = self.itemIDs[index];

    NSDictionary *sectionDic = [self getTreeSectionFrom:[itemID integerValue]];
    NSDictionary *rowDic = [self getTreeItemFrom:[itemID integerValue]];

    [self.treeView expandRowForItem:sectionDic
                   withRowAnimation:RATreeViewRowAnimationTop];
    [self.treeView selectRowForItem:rowDic
                           animated:YES
                     scrollPosition:RATreeViewScrollPositionMiddle];
}

- (void)collectionAction:(UIButton *)button {
    if (isCollectioned == YES) {
        [self deleteFavourite:NO];
    } else {
        [self joinFavourite:NO];
    }
}

- (void)btnInfoClick:(UIButton *)button {
    if (introView.hidden == YES) {
        [introView setHidden:NO];
        [_coverView setHidden:NO];
        [self.view bringSubviewToFront:_coverView];
        [self.view bringSubviewToFront:introView];

        navigation.allowShowCoverView = YES;
        self.allowForceRotation = NO;
        introView.top = -300;
        [UIView animateWithDuration:0.25
            animations:^{ introView.top = 0; }
            completion:^(BOOL finished) {}];
        [self pauseWhenPlaying];
    }
}

- (id)iskindOfNullClass:(id) class {
    if ([class isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return class;
    }

} - (float)getInfoCellHeight : (NSString *)text : (NSInteger)section {
    float height = 0;
    if (section == 0) {
        height = 56;
    } else if (section == 1) {
        height = infoCellHeight;
    }
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.width = 304;
    [label setText:text];
    height += label.optimumSize.height;
    return height;
}

#pragma mark - 返回需要选中的item
- (NSDictionary *)getTreeItemFrom:(NSInteger)videoId {
    NSArray *array = [NSArray array];

    for (NSDictionary *dic in courseTreeArray) {
        array = [dic objectForKey:@"items"];
        for (NSDictionary *dic1 in array) {
            if ([[dic1 objectForKey:@"id"] intValue] == videoId) {
                return dic1;
            }
        }
    }
    return nil;
}

- (void)tapCover:(UIGestureRecognizer *)tap {
    //允许视频播放器横竖屏
    self.player.forceRotate = YES;

    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;
    [UIView animateWithDuration:0.25
        animations:^{ introView.top = -300; }
        completion:^(BOOL finished) {
            [_coverView setHidden:YES];
            [introView setHidden:YES];
        }];
    [self playIfPauseWhenPlaying];

    self.allowForceRotation =
        (self.player.state == VKVideoPlayerStateContentPlaying);
}
- (NSDictionary *)getTreeSectionFrom:(NSInteger)videoId {
    NSArray *array = [NSArray array];

    for (NSDictionary *dic in courseTreeArray) {
        array = [dic objectForKey:@"items"];
        for (NSDictionary *dic1 in array) {
            if ([[dic1 objectForKey:@"id"] intValue] == videoId) {
                return dic;
            }
        }
    }
    return nil;
}

#pragma mark - download关闭的通知
- (void)commentViewDidHide {
    //继续播放
    [self presentViewShouldPlayContent:YES];
}

#pragma mark - CommentListViewDelegate
- (void)commentListViewCoverViewClick {
    [self playIfPauseWhenPlaying];
}

#pragma 通知方法
- (void)navCoverViewTap {
    self.player.forceRotate = YES;

    [_coverView setHidden:YES];
    navigation.allowShowCoverView = NO;
    [UIView animateWithDuration:0.25
        animations:^{ introView.top = -300; }
        completion:^(BOOL finished) {
            [_coverView setHidden:YES];
            [introView setHidden:YES];
        }];
    [self playIfPauseWhenPlaying];

    self.allowForceRotation =
        (self.player.state == VKVideoPlayerStateContentPlaying);
}

#pragma mark - pauseWhenPlaying
- (void)pauseWhenPlaying {
    if (self.player.state == VKVideoPlayerStateContentPlaying) {
        isPlayingWhenClick = YES;
        [self.player pauseButtonPressed];
    } else {
        isPlayingWhenClick = NO;
    }
}

- (void)playIfPauseWhenPlaying {
    if (isPlayingWhenClick == YES) {
        [self.player playButtonPressed];
    }
    isPlayingWhenClick = NO;
}
@end
