//
//  PublicClassViewController.m
//  learn
//
//  Created by 翟鹏程 on 14-6-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "PublicClassViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppUtilities.h"
#import "UIImage+fixOrientation.h"
#import "AppDelegate.h"
#import "KKBHttpClient.h"
#import "MobClick.h"
#import "FilesDownManage.h"
#import "FileModel.h"
#import "LocalStorage.h"
#import "KKBUserInfo.h"
#import "UMSocial.h"
#import "LoginViewController.h"
#import "SDWebImageDownloader.h"
#import "InfoButtonOneCell.h"
#import "InfoButtonTwoCell.h"
#import "RTLabel.h"

#import "KKBCommentListViewController.h"
#import "UIViewController+KNSemiModal.h"

#import "KKBDownloadSingleHierarchyController.h"
#import "KKBDownloadControlViewController.h"

static const CGFloat infoCellHeight = 90;

static const CGFloat downloadButtonTag = 11000;
static const CGFloat commentButtonTag = 11001;
static const CGFloat shareButtonTag = 11002;
static const CGFloat collectionButtonTag = 11003;

static const CGFloat cellHeight = 50;

static const CGFloat cellImageOriginX = 6;
static const CGFloat cellImageOriginY = 11;
static const CGFloat cellImageHeight = 28;

static const CGFloat cellLabelOriginX = 40;
static const CGFloat cellLabelOriginY = 17;
static const CGFloat cellLabelHeight = 16;

static const CGFloat cellLabelRightMargin = 16;

static const int cellTitleLabelTag = 20001;

static const int ddLogLevel = LOG_LEVEL_WARN;

@interface PublicClassViewController () <
    UITableViewDataSource, UITableViewDelegate, KKBDownloadSingleVCDelegate> {
    UIWebView *myWebView;
    BOOL shareShow;
    UITableView *downloadTableView;
    BOOL downloadIsOpen;

    NSString *_favouriteCount;

    UIView *newBottomView;
    NSMutableArray *buttonArray;

    UIImageView *commentCountImageView;
    UILabel *countLabel;
    BOOL isCollectioned;

    UITableView *infoButtonTableView;
    NSArray *techArray;

    KKBCommentListView *commentListView;
    BOOL isPlayingWhenClick;
}

@property(weak, nonatomic)
    IBOutlet UIImageView *bottomBarImageView; //底部按钮背景
@property(weak, nonatomic) IBOutlet UILabel *commentNumsLabel;

@property(nonatomic, assign) BOOL isFavourite; //是否已经收藏

@property(strong, nonatomic) UITableView *tableView;

@property(strong, nonatomic) NSArray *videoItems;
// TODO: byzm 以后tableView中用此数组
@property(strong, nonatomic) NSMutableArray *courseItemIDs;
@property(strong, nonatomic) NSMutableArray *courseVideoURLs;

@end

@implementation PublicClassViewController {
    UIImage *_shareImage;
}

#pragma mark - View lifecycle
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
    // Do any additional setup after loading the view from its nib.
    isPlayingWhenClick = NO;
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    // videoplayer
    [self.view addSubview:self.player.view];
    self.videoType = VideoPlayMutiType;
    self.allowRemovePlayer = YES;

    //设置底部按钮背景
    self.view.backgroundColor = [UIColor whiteColor];
    self.bottomBarImageView.image = [[UIImage imageNamed:@"bg_tab"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(15, 3, 3, 3)];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"course_info"]
                   forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 24, 24)];
    [btn addTarget:self
                  action:@selector(btnInfoClick:)
        forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;

    // title
    self.title = [_currentCourse objectForKey:@"name"];

    [[SDWebImageDownloader sharedDownloader]
        downloadImageWithURL:
            [NSURL URLWithString:[_currentCourse objectForKey:@"cover_image"]]
        options:1
        progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
        completed:^(UIImage *image, NSData *data, NSError *error,
                    BOOL finished) {
            if (finished) {
                _shareImage = image;
            }
        }];

    if ([[UIDevice currentDevice].systemVersion hasPrefix:@"7"]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.introView.hidden = YES;
    self.coverView.hidden = YES;
    [self.view bringSubviewToFront:self.introView];

    [self.introView bringSubviewToFront:self.infoView];

    [self.introView bringSubviewToFront:self.infoWebView];

    myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 28, 300, 260)];
    myWebView.scrollView.showsHorizontalScrollIndicator = NO;
    myWebView.scrollView.showsVerticalScrollIndicator = NO;
    myWebView.scrollView.bounces = NO;
    myWebView.delegate = self;

    self.coverView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(coverViewClick:)];
    [self.coverView addGestureRecognizer:tapGesture];
    [tapGesture setNumberOfTapsRequired:1];

    // ******************* bottomButton *****************
    shareShow = NO;
    [self initBottomView];
    // **************
    [self loadComment:YES];
    [self loadComment:NO];

    /******************** downloadView ***************/
    // dictionary to model
    NSArray *items = [_currentCourse objectForKey:@"videos"];
    NSMutableArray *tempItems =
        [[NSMutableArray alloc] initWithCapacity:[items count]];
    for (int j = 0; j < [items count]; j ++) {
        NSDictionary *dic = items[j];
        KKBDownloadVideoModel *videoModel =
        [[KKBDownloadVideoModel alloc] init];
        // item_id 不统一为string类型
        NSString *itemID = dic[@"item_id"];
        // TODO: byzm item_idz最大值？
        videoModel.videoID = @([itemID integerValue]);
        videoModel.videoTitle = dic[@"item_title"];
        videoModel.downloadPath = dic[@"video_url"];
        videoModel.videoURL = dic[@"video_url"];
        videoModel.position = @(j);
        [tempItems addObject:videoModel];
    }
    self.videoItems = tempItems;

    // TODO: byzm
    [self.view bringSubviewToFront:_publicDownloadView];
    downloadIsOpen = NO;
    _publicDownloadView.delegate = self;
    _publicDownloadView.currentCourse = _currentCourse;
    if ([[_currentCourse objectForKey:@"videos"]
            isKindOfClass:[NSNull class]]) {
        _publicDownloadView.currentCourseVideoList = nil;
    } else {
        _publicDownloadView.currentCourseVideoList =
            [_currentCourse objectForKey:@"videos"];
    }
    [_publicDownloadView initWithUI];

    /*******************commentView消失通知**********************/
    //评论页消失的通知
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(commentViewDidHide)
               name:kSemiModalDidHideNotification
             object:nil];

    // ******************************** request ************

    self.isOpen = NO;
    // may delete start
    self.currentUnitList = [[NSArray alloc] init];
    self.currentSecondLevelUnitList = [[NSMutableArray alloc] init];
    self.currentSecondLevelVideoList = [[NSArray alloc] init];
    self.progressLabelDict = [[NSMutableDictionary alloc] init];
    self.downloadBtnDict = [[NSMutableDictionary alloc] init];

    // *************************** favourite *********
    [self requestCollectionStatus:YES];
    [self requestCollectionStatus:NO];

    //加载数据
    [KKBUserInfo shareInstance].courseId = [_currentCourse objectForKey:@"id"];

    if ([[_currentCourse objectForKey:@"videos"]
            isKindOfClass:[NSNull class]]) {
        _currentCourseVideoList = nil;
    } else {
        _currentCourseVideoList = [_currentCourse objectForKey:@"videos"];
        //
        self.coverImgURL = [_currentCourse objectForKey:@"cover_image"];

        // itemsId videoURLs
        self.courseItemIDs = [[NSMutableArray alloc]
            initWithCapacity:[_currentCourseVideoList count]];
        self.courseVideoURLs = [[NSMutableArray alloc]
            initWithCapacity:[_currentCourseVideoList count]];

        for (NSDictionary *dic in _currentCourseVideoList) {
            [self.courseItemIDs addObject:dic[@"item_id"]];
            [self.courseVideoURLs addObject:dic[@"video_url"]];
        }

        self.videoURLs = self.courseVideoURLs;
        self.itemIDs = self.courseItemIDs;

        if ([_currentCourseVideoList count] > 0) {

            //从动态页面进入续播
            if (_playRecordVideoId != nil) {
                for (int i = 0; i < [_currentCourseVideoList count]; i++) {
                    NSDictionary *dict = _currentCourseVideoList[i];
                    if ([[dict objectForKey:@"item_id"] longLongValue] ==
                        [_playRecordVideoId longLongValue]) {

                        //开始续播
                        [self changeVideoToIndex:i];
                        //选中cell
                        dispatch_after(
                            dispatch_time(DISPATCH_TIME_NOW,
                                          (int64_t)(1 * NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^{
                                //默认选中第一个cell
                                NSIndexPath *indexPath =
                                    [NSIndexPath indexPathForRow:i inSection:0];
                                [self.tableView
                                    selectRowAtIndexPath:indexPath
                                                animated:YES
                                          scrollPosition:
                                              UITableViewScrollPositionMiddle];
                            });
                        break;
                    }
                }

            } else {
                //从普通卡片进入
                self.classId =
                    [[[_currentCourse objectForKey:@"lms_course_list"]
                        objectAtIndex:0] objectForKey:@"lms_course_id"];
                self.courseId = [_currentCourse objectForKey:@"id"];
            }
        }
    }

    self.tableView; // 懒加载的方式，这行不能被删除，必须保留
    [self.loadingView showInView:self.view];
    [self.loadingView setViewStyle:GrayStyle];
    [self.view bringSubviewToFront:self.loadingView];

    [self initInfoButtonTableView];

    // comment count
    //评论数
    NSNumber *commentCount = _currentCourse[@"evaluations_count"];
    if ([commentCount isKindOfClass:[NSNumber class]]) {
        [self commentCount:[commentCount intValue]];
    }

    //    [self networkStatusDidChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"OpenCourse"];
    self.navigationController.navigationBar.hidden = NO;
    self.bottomView.backgroundColor = [UIColor clearColor];

    //更新视频地址信息
    self.videoURLs = self.courseVideoURLs;
    self.itemIDs = self.courseItemIDs;
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
    [MobClick endLogPageView:@"OpenCourse"];
}

#pragma mark - Custom Methods

- (void)handleError {

    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:@"提示"
                  message:@"视频文件被损坏了，无法播放"
                 delegate:nil
        cancelButtonTitle:@"我知道了"
        otherButtonTitles:nil];

    [alertView show];
}

- (void)initBottomView {
    newBottomView = [[UIView alloc] init];
    [newBottomView setBackgroundColor:[UIColor whiteColor]];
    newBottomView.frame = CGRectMake(0, G_SCREEN_HEIGHT - gBottomViewHeight -
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
        [button setFrame:CGRectMake((i * 80) + 10, 0, 60, gBottomViewHeight)];
        [button addTarget:self
                      action:@selector(buttonClick:)
            forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:array1[i]]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:array2[i]]
                          forState:UIControlStateHighlighted];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:14]];
        [buttonArray addObject:button];
        [newBottomView addSubview:button];

        UIView *lineView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, 1)];
        [lineView setBackgroundColor:[UIColor kkb_colorwithHexString:@"dbdbdb"
                                                               alpha:1]];
        [newBottomView addSubview:lineView];
        [self.view addSubview:newBottomView];
    }
}

- (void)loadComment:(BOOL)fromCache {
    NSString *jsonForComment =
        [NSString stringWithFormat:@"v1/evaluation/courseid/%@",
                                   [_currentCourse objectForKey:@"id"]];
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
                commentListView.backgroundColor = [UIColor clearColor];
                commentListView.delegate = self;
                UIWindow *window =
                    [[UIApplication sharedApplication] keyWindow];
                [window addSubview:commentListView];
            }
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
            [self.loadingView hideView];
        }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.tableView.frame =
        CGRectMake(0, G_VIDEOVIEW_HEIGHT, G_SCREEN_WIDTH,
                   self.view.height - G_VIDEOVIEW_HEIGHT - gBottomViewHeight);
    self.bottomView.frame = CGRectMake(0, self.tableView.bottom,
                                       self.view.width, gBottomViewHeight);
    self.coverView.frame = self.view.bounds;
    // self.introView.frame = CGRectMake(0, 0, G_SCREEN_WIDTH, 300);
}

#pragma mark - Property
- (UITableView *)tableView {
    if (!_tableView) {

        _tableView = [[UITableView alloc]
            initWithFrame:CGRectMake(0, G_VIDEOVIEW_HEIGHT, G_SCREEN_WIDTH,
                                     self.view.height - gBottomViewHeight -
                                         G_VIDEOVIEW_HEIGHT)
                    style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;

        _tableView.separatorColor =
            [UIColor kkb_colorwithHexString:@"dbdbdb" alpha:1];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;

        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Button Methods

- (void)buttonClick:(UIButton *)button {
    NSMutableArray *otherButtonArray =
        [NSMutableArray arrayWithArray:buttonArray];
    [otherButtonArray removeObject:button];

    if (button.tag == commentButtonTag) {
        DDLogInfo(@"评论！！！！");
        //禁止视频播放自动横屏
        self.allowForceRotation = NO;
        [commentListView showCommentView];
        [self pauseWhenPlaying];
    } else if (button.tag == shareButtonTag) {
        downloadIsOpen = NO;
        DDLogInfo(@"分享！！！");
        [self pauseWhenPlaying];
        //禁止视频旋转事件
        self.allowForceRotation = NO;
        NSString *shareDownloadUrl =
            [NSString stringWithFormat:@"http://www.kaikeba.com/courses/%@",
                                       [_currentCourse objectForKey:@"id"]];

        NSString *shareTextForSina =
            [NSString stringWithFormat:@"#新课抢先知#"
                      @"这课讲的太屌了，朕灰常满意！小伙伴们"
                      @"不要太想我，我在@开课吧官方微博 "
                      @"虐学渣，快来和我一起吧！"];
        NSString *shareTextForOther = [NSString
            stringWithFormat:
                @"我正在开课吧观看《%@"
                @"》这门课，老师讲得吼赛磊呀！小伙伴们"
                @"要不要一起来呀？",
                [_currentCourse objectForKey:@"name"]];
        [[KKBShare shareInstance]
               shareWithImage:_shareImage
                      viewCtr:self
                     courseId:self.courseId
                   courseName:[_currentCourse objectForKey:@"name"]
             shareDownloadUrl:shareDownloadUrl
             shareTextForSina:shareTextForSina
            shareTextForOther:shareTextForOther];
        [KKBShare shareInstance].delegate = self;

    } else if (button.tag == collectionButtonTag) {

        DDLogInfo(@"已收藏！！！");

        if ([self checkisLoginStatus]) {
            if (isCollectioned == YES) {
                [self deleteFavourite:NO];
            } else {
                [self joinFavourite:NO];
            }
        }
    } else if (button.tag == downloadButtonTag) {
        // TODO: byzm
        DDLogDebug(@"下载");
        /*
        [self.publicDownloadView
            setFrame:CGRectMake(0, G_SCREEN_HEIGHT - 504, G_SCREEN_WIDTH, 504)];
        [self.view bringSubviewToFront:self.publicDownloadView];
         */
        
        // 如果未登录，直接跳转至［登录页面］
        BOOL hasLogined = [self checkisLoginStatus];
        if (!hasLogined) {
            return;
        }
        //暂停播放
        [self presentViewShouldPlayContent:NO];
        KKBDownloadSingleHierarchyController *singleVC =
            [[KKBDownloadSingleHierarchyController alloc] init];
        singleVC.delegate = self;

        if ([[_currentCourse objectForKey:@"videos"]
                isKindOfClass:[NSNull class]]) {
            singleVC.videoItems = nil;
        } else {
            singleVC.videoItems = self.videoItems;
        }

        NSNumber *classID =
            [[[_currentCourse objectForKey:@"lms_course_list"] objectAtIndex:0]
                objectForKey:@"lms_course_id"];

        KKBDownloadClassModel *classModel =
            [[KKBDownloadClassModel alloc] init];
        classModel.classID = classID;
        classModel.classType = videoOpenCourse;
        classModel.name = [_currentCourse objectForKey:@"name"];
        singleVC.classModel = classModel;
        singleVC.view.frame =
            CGRectMake(0, 0, self.view.width, self.view.bounds.size.height -
                                                  gPopDownloadViewMarginTop);
        [self presentSemiViewController:singleVC
                            withOptions:@{
                                KNSemiModalOptionKeys.pushParentBack : @(NO),
                                KNSemiModalOptionKeys.parentAlpha : @(0.4),
                                KNSemiModalOptionKeys.animationDuration : @(0.4)
                            }];
    }
}

#pragma mark - KKBDownloadSingleVCDelegate
- (void)downloadControlTapped:(KKBDownloadSingleHierarchyController *)vc {
    NSNumber *classID =
        [[[_currentCourse objectForKey:@"lms_course_list"] objectAtIndex:0]
            objectForKey:@"lms_course_id"];

    [self dismissSemiModalViewWithCompletion:^{
        KKBDownloadControlViewController *downloadControl =
            [[KKBDownloadControlViewController alloc] init];
        downloadControl.classID = classID;
        downloadControl.fromStudyVC = YES;
        [self.navigationController pushViewController:downloadControl
                                             animated:YES];
    }];
}

- (void)initInfoButtonTableView {
    infoButtonTableView =
        [[UITableView alloc] initWithFrame:CGRectMake(8, 9, 304, 280)
                                     style:UITableViewStyleGrouped];
    infoButtonTableView.backgroundColor = [UIColor clearColor];
    infoButtonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoButtonTableView.delegate = self;
    infoButtonTableView.dataSource = self;
    infoButtonTableView.scrollEnabled = YES;
    infoButtonTableView.showsVerticalScrollIndicator = NO;
    [self.introView addSubview:infoButtonTableView];
    techArray = [_currentCourse objectForKey:@"tech"];
    [infoButtonTableView reloadData];
}

/**
 关闭当前页面之后

 @param fromViewControllerType 关闭的页面类型

 */
- (void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType {
    self.allowForceRotation = YES;

    [self.player playButtonPressed];
}

- (void)didFinishGetUMSocialDataInViewController:
            (UMSocialResponseEntity *)response {
    //分享完成之后视频旋转事件
    self.allowForceRotation = YES;
}

- (void)coverViewClick:(UITapGestureRecognizer *)tapG {
    //允许视频播放自动横屏
    self.allowForceRotation = YES;
    [self playIfPauseWhenPlaying];
    [UIView animateWithDuration:0.24 animations:^{ self.coverView.alpha = 0; }];

    [UIView animateWithDuration:0.24
        delay:0
        options:UIViewAnimationOptionTransitionNone
        animations:^{
            self.introView.frame = CGRectMake(0, -300, G_SCREEN_WIDTH, 300);
        }
        completion:^(BOOL finished) { self.introView.hidden = YES; }];
}

#pragma mark - 更新是否收藏状态
/**
 *  更新是否收藏状态
 *
 *  @param status YES 已收藏
 */
- (void)refreshFavtouriteBtnStatus:(BOOL)status {
    UIButton *favtorBtn = (UIButton *)[self.bottomView viewWithTag:1003];
    NSString *imageStr = nil;
    if (status) {
        //已收藏
        self.isFavourite = YES;
        imageStr = @"v3_collection_selected";
    } else {
        imageStr = @"v3_collection_default";
        self.isFavourite = NO;
    }
    [favtorBtn setImage:[UIImage imageNamed:imageStr]
               forState:UIControlStateNormal];
    [favtorBtn setImage:[UIImage imageNamed:imageStr]
               forState:UIControlStateSelected];
}

- (IBAction)btnInfoClick:(id)sender {
    [self.view bringSubviewToFront:self.coverView];
    self.coverView.hidden = NO;
    if (self.introView.hidden == YES) {
        //禁止视频播放自动横屏
        self.allowForceRotation = NO;
        [self pauseWhenPlaying];
        self.coverView.alpha = 0;
        self.introView.frame = CGRectMake(0, -300, G_SCREEN_WIDTH, 300);
        [UIView animateWithDuration:0
            animations:^{ self.coverView.alpha = 0.5; }
            completion:^(BOOL finished) {
                [self.view bringSubviewToFront:self.introView];
            }];
        [UIView animateWithDuration:0.24
            delay:0
            options:UIViewAnimationOptionTransitionNone
            animations:^{
                self.introView.hidden = NO;
                self.introView.frame = CGRectMake(0, 0, G_SCREEN_WIDTH, 300);
            }
            completion:^(BOOL finished) {
                [self.view bringSubviewToFront:self.introView];
            }];
    } else {
        //允许视频播放自动横屏
        self.allowForceRotation = YES;
        [self playIfPauseWhenPlaying];
        [self.view bringSubviewToFront:self.introView];
        [UIView animateWithDuration:0.24
            animations:^{
                self.introView.frame = CGRectMake(0, -300, G_SCREEN_WIDTH, 300);
            }
            completion:^(BOOL finished) { self.introView.hidden = YES; }];
        [UIView animateWithDuration:0.24
            delay:0
            options:UIViewAnimationOptionTransitionNone
            animations:^{ self.coverView.alpha = 0; }
            completion:^(BOOL finished) {}];
    }
}

#pragma mark - publicDownloadDelegate
- (void)downloadCoverViewClick {
    // TODO: <#byzm#>
    DDLogDebug(@"download delegate click");
    self.bottomView.hidden = NO;
    _publicDownloadView.frame =
        CGRectMake(0, G_SCREEN_HEIGHT, G_SCREEN_WIDTH, 524);
    downloadIsOpen = NO;
}

#pragma mark - CourseDetailDelegate
- (void)pushToLoginViewController {
    LoginViewController *loginVC =
        [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                              bundle:nil];
    [self.navigationController pushViewController:loginVC animated:YES];
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

    [newBottomView addSubview:commentCountImageView];
    [newBottomView addSubview:countLabel];
}

- (void)joinFavourite:(BOOL)fromCache {
    NSString *jsonForJoinFavourite = @"v1/collections";
    NSString *user_id = [KKBUserInfo shareInstance].userId;
    NSString *course_id = [_currentCourse objectForKey:@"id"];
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
    NSString *course_id = [_currentCourse objectForKey:@"id"];
    NSMutableDictionary *dict = [NSMutableDictionary
        dictionaryWithObjectsAndKeys:user_id, @"user_id", course_id,
                                     @"course_id", nil];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:deleteFavourite
        method:@"POST"
        param:dict
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"result is %@", result);
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"已取消收藏此课程"
                                           message:@""
                                          delegate:self
                                 cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
            [alert show];

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

- (void)loadDataIntroduction:(BOOL)fromCache {
    NSString *jsonUrlForIntr = nil;
    if ([[self.currentCourse objectForKey:@"lms_course_list"]
            isKindOfClass:[NSNull class]] ||
        [[self.currentCourse objectForKey:@"lms_course_list"] count] == 0) {

    } else {
        jsonUrlForIntr =
            [NSString stringWithFormat:
                          @"courses/%@/pages/course-introduction-4tablet",
                          [[[self.currentCourse objectForKey:@"lms_course_list"]
                              objectAtIndex:0] objectForKey:@"lms_course_id"]];
    }
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForIntr
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            NSDictionary *dictResult = (NSDictionary *)result;
            [myWebView loadHTMLString:[dictResult objectForKey:@"body"]
                              baseURL:nil];
        }
        failure:^(id result) {}];
}

#pragma mark - 匿名状态下的跳转逻辑
- (BOOL)checkisLoginStatus {
    if (![KKBUserInfo shareInstance].isLogin) {
        [AppUtilities pushToLoginViewController:self];

        return NO;
    } else {
        return YES;
    }
}

#pragma mark - KKBShare Delegate Methods
- (void)shareViewControllerDidDismiss {
    [self playIfPauseWhenPlaying];
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:infoButtonTableView]) {
        if (section == 0) {
            return 1;
        } else {
            return techArray.count;
        }
    } else {
        return [_currentCourseVideoList count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:infoButtonTableView]) {
        return 2;
    } else {
        return 1;
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
    if ([tableView isEqual:infoButtonTableView]) {
        if (indexPath.section == 0) {

            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"InfoButtonOneCell"
                                              owner:self
                                            options:nil];
            InfoButtonOneCell *cell = [arr objectAtIndex:0];
            cell.courseIntroLabel.text = [_currentCourse objectForKey:@"intro"];
            cell.courseIntroLabel.height =
                cell.courseIntroLabel.optimumSize.height;
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 0) {
                cell.teacherLineLabel.hidden = YES;
            }
            return cell;
        }

    } else {

        static NSString *CellIdentifier = @"cell";

        UITableViewCell *cell = (UITableViewCell *)
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        if (!cell) {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:CellIdentifier];

            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            UIImageView *cellImageView = [[UIImageView alloc]
                initWithFrame:CGRectMake(cellImageOriginX, cellImageOriginY,
                                         cellImageHeight, cellImageHeight)];
            [cell.contentView addSubview:cellImageView];
            cellImageView.image =
                [UIImage imageNamed:@"teachers_icon_video_dis"];

            UILabel *cellTitleLabel = [[UILabel alloc]
                initWithFrame:CGRectMake(cellLabelOriginX, cellLabelOriginY,
                                         G_SCREEN_WIDTH - cellLabelOriginY -
                                             cellLabelRightMargin,
                                         cellLabelHeight)];
            cellTitleLabel.tag = cellTitleLabelTag;
            cellTitleLabel.font = [UIFont systemFontOfSize:16];
            cellTitleLabel.textAlignment = NSTextAlignmentLeft;
            cellTitleLabel.textColor = UIColorRGB(92, 95, 102);
            [cell.contentView addSubview:cellTitleLabel];
        }

        if (_playRecordVideoId != nil) {
        }

        NSString *titleString = [(NSDictionary *)[_currentCourseVideoList
            objectAtIndex:indexPath.row] objectForKey:@"item_title"];
        UILabel *titleLabel =
            (UILabel *)[cell.contentView viewWithTag:cellTitleLabelTag];
        titleLabel.text =
            [titleString stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }

    return nil;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![tableView isEqual:infoButtonTableView]) {
        // 当前播放视频项
        DDLogInfo(@"current select video item is %@",
                  [_currentCourseVideoList objectAtIndex:indexPath.row]);

        if ([KKBUserInfo shareInstance].isLogin == NO && indexPath.row >= 2) {
            [self pushToLoginViewController];
        } else {
            NSString *classId =
                [[[self.currentCourse objectForKey:@"lms_course_list"]
                    objectAtIndex:0] objectForKey:@"lms_course_id"];

            if ([KKBUserInfo shareInstance].isLogin == YES) {
                if ([[LocalStorage shareInstance] getLearnStatusBy:classId] ==
                    NO) {
                    NSString *jsonForRegisterCourse = [NSString
                        stringWithFormat:@"v1/userapply/register/course/%@",
                                         classId];

                    [[KKBHttpClient shareInstance]
                        requestAPIUrlPath:jsonForRegisterCourse
                        method:@"GET"
                        param:nil
                        fromCache:NO
                        success:^(id result,
                                  AFHTTPRequestOperation *operation) {
                            [[LocalStorage shareInstance]
                                saveLearnStatus:YES
                                         course:classId];

                            [[KKBHttpClient
                                    shareInstance] refreshMyPublicCourse];
                        }
                        failure:^(id result,
                                  AFHTTPRequestOperation *operation) {}];
                }
            }
            // 切换视频
            [self changeVideoToIndex:indexPath.row];
        }
    } else {
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:infoButtonTableView]) {
        if (indexPath.section == 0) {
            NSString *text = [_currentCourse objectForKey:@"intro"];
            return [self getInfoCellHeight:text forSection:0];
        } else {
            NSDictionary *dic = [techArray objectAtIndex:indexPath.row];
            NSString *text = [dic objectForKey:@"desc"];
            return [self getInfoCellHeight:text forSection:1];
        }
    }
    return cellHeight;
}

- (float)getInfoCellHeight:(NSString *)text forSection:(NSInteger)section {
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

- (id)iskindOfNullClass:(id) class {
    if ([class isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return class;
    }
}

#pragma mark - 点击按钮注册课程
- (void)bigPlayBtnTapped {

    if ([KKBUserInfo shareInstance].isLogin == YES) {
        NSString *classId =
            [[[self.currentCourse objectForKey:@"lms_course_list"]
                objectAtIndex:0] objectForKey:@"lms_course_id"];
        if ([[LocalStorage shareInstance] getLearnStatusBy:classId] == NO) {
            NSString *jsonForRegisterCourse = [NSString
                stringWithFormat:@"v1/userapply/register/course/%@", classId];

            [[KKBHttpClient shareInstance]
                requestAPIUrlPath:jsonForRegisterCourse
                method:@"GET"
                param:nil
                fromCache:NO
                success:^(id result, AFHTTPRequestOperation *operation) {
                    [[LocalStorage shareInstance] saveLearnStatus:YES
                                                           course:classId];

                    [[KKBHttpClient shareInstance] refreshMyPublicCourse];
                }
                failure:^(id result, AFHTTPRequestOperation *operation) {}];
        }
    }
}

#pragma mark - 处理续播时选中事件
- (void)videoWillStartPlayOfIndex:(NSUInteger)index {
    
    if (![KKBUserInfo shareInstance].isLogin && index > 1) {
        //未登录不能看第三个视频
        [AppUtilities pushToLoginViewController:self];
        return;
    }
    
    if (index < [_currentCourseVideoList count]) {
        NSIndexPath *indexPath =
            [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - 处理旋转事件隐藏控件
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;

        self.introView.hidden = YES;
        self.coverView.hidden = YES;
    } else {
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
    }
}

#pragma mark - commentView关闭的通知
- (void)commentViewDidHide {
    [self presentViewShouldPlayContent:YES];
}

#pragma mark - CommentListViewDelegate
- (void)commentListViewCoverViewClick {
    [self playIfPauseWhenPlaying];
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
