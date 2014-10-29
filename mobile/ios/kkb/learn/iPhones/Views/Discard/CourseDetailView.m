//
//  CourseDetailView.m
//  learn
//
//  Created by 翟鹏程 on 14-6-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GlobalOperator.h"
#import "ToolsObject.h"
#import "HomePageOperator.h"
#import "UIImageView+WebCache.h"
#import "UIImage+fixOrientation.h"
#import "CourseUnitOperator.h"
#import "FileUtil.h"
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
#import "LocalStorage.h"
#import "KKBActivityIndicatorView.h"
#import "KKBLoadingFailedView.h"
#import "KKBUserInfo.h"

#import "CourseInfoViewController.h"
#import "PublicClassViewController.h"

#define KKB_ACTIVITY_INDICATOR_VIEW_TAG 10
#define degreesToRadians(x) (M_PI * x / 180.0f)

#define CELL_HEIGHT 50.0f

@implementation CourseDetailView {
    NSString *itemID;
    NSString *_currentSelectedVideoUrl;
}

@synthesize playerFrameView;
@synthesize unitTableView;
@synthesize currentUnitList, currentSecondLevelUnitList,
    currentSecondLevelVideoList, currentAllCoursesItem, myCoursesDataArray;
@synthesize courseName, courseImage;
@synthesize selectVideoURL, selectIndex;
@synthesize progressLabelDict, downloadBtnDict;
@synthesize currentLocation;
@synthesize viewControllerArray;
@synthesize viewController;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initObjects];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initObjects];
    }
    return self;
}

- (void)initObjects {
    self.isOpen = NO;
    self.currentUnitList = [[NSArray alloc] init];
    self.currentSecondLevelUnitList = [[NSMutableArray alloc] init];
    self.currentSecondLevelVideoList = [[NSArray alloc] init];
    self.currentAllCoursesItem = [[NSDictionary alloc] init];
    self.progressLabelDict = [[NSMutableDictionary alloc] init];
    self.downloadBtnDict = [[NSMutableDictionary alloc] init];
    self.viewControllerArray = [[NSMutableArray alloc] init];
    _currentCourse = [[NSDictionary alloc] init];
}

#pragma mark - initMethod
- (void)initWithUI {
    [FilesDownManage sharedInstance].downloadDelegate = self;
    
    NSLog(@"%f",self.playRecordVideoDuration);
    //这样写frame会有问题
    playerFrameView = [[PlayerFrameView alloc]
        initWithFrame:CGRectMake(0, 0, self.bounds.size.width,
                                 G_VIDEOVIEW_HEIGHT)];
    playerFrameView.playerFrameDelegate = self;
    playerFrameView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:playerFrameView];

    unitTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, G_VIDEOVIEW_HEIGHT, self.bounds.size.width,
                                 self.bounds.size.height - G_VIDEOVIEW_HEIGHT)
                style:UITableViewStylePlain];
    unitTableView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin;
    unitTableView.separatorColor =
        [UIColor kkb_colorwithHexString:@"dbdbdb" alpha:1];
    unitTableView.separatorInset = UIEdgeInsetsZero;

    unitTableView.delegate = self;
    unitTableView.dataSource = self;
    [self addSubview:unitTableView];

    [KKBUserInfo shareInstance].courseId = [_currentCourse objectForKey:@"id"];

    if ([[_currentCourse objectForKey:@"videos"]
            isKindOfClass:[NSNull class]]) {
        _currentCourseVideoList = nil;
    } else {
        _currentCourseVideoList = [_currentCourse objectForKey:@"videos"];
        if ([_currentCourseVideoList count] > 0) {
            if (_playRecordVideoId != nil) {
                self.playerFrameView.itemID = _playRecordVideoId;
                for (NSDictionary *dict in _currentCourseVideoList) {
                    if ([[dict objectForKey:@"item_id"] longLongValue] == [_playRecordVideoId longLongValue]) {
                        self.playerFrameView.promoVideoStr = [dict objectForKey:@"video_url"];
                        
                        [self.playerFrameView playMovieAtURL];
                        break;
                    }
                }
            } else {
                self.playerFrameView.promoVideoStr = [[_currentCourseVideoList objectAtIndex:0] objectForKey:@"video_url"];
                self.playerFrameView.itemID = [[_currentCourseVideoList objectAtIndex:0] objectForKey:@"item_id"];
                self.playerFrameView.strCourseID = [KKBUserInfo shareInstance].courseId;
            }
        }
    }

    [self initbackImage];
}

- (void)initbackImage {
    self.playerFrameView.imageURL = [ToolsObject
        adaptImageURLforPhone:[_currentCourse objectForKey:@"cover_image"]];
    [self.playerFrameView initImage];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    playerFrameView.frame =
        CGRectMake(0, 0, self.bounds.size.width, G_VIDEOVIEW_HEIGHT);
    unitTableView.frame =
        CGRectMake(0, G_VIDEOVIEW_HEIGHT, self.bounds.size.width,
                   self.bounds.size.height - G_VIDEOVIEW_HEIGHT);
}

#pragma mark - PlayerFrameView Methods
- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    willChangeOrientationTo:(UIInterfaceOrientation)orientation {
    CGFloat degrees = [self degreesForOrientation:orientation];
    UIInterfaceOrientation lastOrientation =
        self.playerFrameView.player.visibleInterfaceOrientation;
    self.playerFrameView.player.visibleInterfaceOrientation = orientation;
    [UIView animateWithDuration:0.3f
        animations:^{
            CGRect bounds = [[UIScreen mainScreen] bounds];
            CGRect parentBounds;
            CGRect viewBoutnds;
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                viewBoutnds = CGRectMake(
                    0, 0,
                    CGRectGetWidth(self.playerFrameView.player.landscapeFrame) -
                        20,
                    CGRectGetHeight(
                        self.playerFrameView.player.landscapeFrame));
                parentBounds = CGRectMake(0, 0, CGRectGetHeight(bounds) - 20,
                                          CGRectGetWidth(bounds));
                CGRect wvFrame = self.frame;
                if (wvFrame.origin.y > 0) {
                    wvFrame.size.height = CGRectGetHeight(bounds);
                    wvFrame.origin.y = 0;
                    self.frame = wvFrame;
                }
            } else {
                viewBoutnds = CGRectMake(0, 0, 320, 180);
                parentBounds = CGRectMake(0, 0, 320, 180);
                CGRect wvFrame = self.frame;
                wvFrame.origin.y = 44;
                self.frame = wvFrame;
            }
            self.playerFrameView.transform =
                CGAffineTransformMakeRotation(degreesToRadians(degrees));
            self.playerFrameView.bounds = parentBounds;
            [self.playerFrameView setFrameOriginX:0.0f];
            [self.playerFrameView setFrameOriginY:0.0f];
            self.playerFrameView.player.view.bounds = viewBoutnds;
            [self.playerFrameView.player.view setFrameOriginX:0.0f];
            [self.playerFrameView.player.view setFrameOriginY:0.0f];
            [self.playerFrameView.player.view layoutForOrientation:orientation];
        }
        completion:^(BOOL finished) {
            if ([self.playerFrameView.player.delegate
                    respondsToSelector:@selector(videoPlayer:
                                           didChangeOrientationFrom:)]) {
                [self.playerFrameView.player.delegate
                                 videoPlayer:self.playerFrameView.player
                    didChangeOrientationFrom:lastOrientation];
            }
        }];
    NSLog(@"videoPlayer is %@", videoPlayer);
    NSLog(@"orientation is %d", orientation);
    NSLog(@"viewControllerArray is %@", viewControllerArray);
    NSLog(@"viewController is %@", viewController);
    viewController = [self courseInfoViewController];
    if ([viewController isKindOfClass:[CourseInfoViewController class]]) {
        NSLog(@"it is courseinfoviewcontroller");
        CourseInfoViewController *courseInfoVC =
            (CourseInfoViewController *)viewController;
        //        courseInfoVC = [self courseInfoViewController];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            self.frame = CGRectMake(0, 0, 548, 320);
            [courseInfoVC.myScrollView setScrollEnabled:NO];
            courseInfoVC.shadowView.hidden = YES;
            [courseInfoVC.btnEntroll setHidden:YES];
            [courseInfoVC.enrollButtonView setHidden:YES];
            self.playerFrameView.player.view.view.frame =
                self.playerFrameView.player.view.frame;
            self.playerFrameView.player.view.view.clipsToBounds = NO;
            [self.playerFrameView.player.view.view becomeFirstResponder];
        } else {
            self.frame = CGRectMake(0, 94, 320, 366);
            [courseInfoVC.btnEntroll setHidden:NO];
            [courseInfoVC.enrollButtonView setHidden:YES];
            [courseInfoVC.btnEntroll setHidden:YES];
            [courseInfoVC.myScrollView setScrollEnabled:YES];
            courseInfoVC.shadowView.hidden = NO;
        }
    } else if ([viewController
                   isKindOfClass:[PublicClassViewController class]]) {
        NSLog(@"it is publicclassviewcontroller");
    }
}

- (UIViewController *)courseInfoViewController {
    id next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
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

- (NSString *)getUserId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId = [prefs objectForKey:@"USER_ID"];

    return userId;
}
#pragma mark - Request
//- (void)loadData:(BOOL)fromCache {
//    if ([KKBUserInfo shareInstance].courseId == nil) {
//        return;
//    }
//    if (fromCache == YES) {
//        [self showLoadingView];
//    }
//    NSString *jsonUrlForCourses = @"v1/courses";
//    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonUrlForCourses
//    method:@"GET" param:nil fromCache:fromCache success:^(id result) {
//        NSArray *array = result;
//        NSMutableArray *idArray = [NSMutableArray array];
//        for (NSDictionary *dict in array) {
//            [idArray addObject:[dict objectForKey:@"id"]];
//            if ([[dict
//            objectForKey:@"name"]isEqualToString:@"大数据基础概论"]) {
//                _currentCourse = dict;
//            }
//        }
//        _currentCourseVideoList = [_currentCourse objectForKey:@"videos"];
//        if (fromCache == YES) {
//            [self removeLoadingView];
//        }
//        [unitTableView reloadData];
//    } failure:^(id result) {
//        if (fromCache == YES) {
//            [self removeLoadingView];
//            [self showLoadingFailedView];
//        }
//    }];
//}

- (void)saveAllVideosToLocalStorage:(NSArray *)result {
    NSString *courseId = [KKBUserInfo shareInstance].courseId;
    NSString *tempCourseName =
        [currentAllCoursesItem objectForKey:@"name"];
    [[LocalStorage shareInstance] saveCourseName:tempCourseName
                                          course:courseId];
    for (NSDictionary *aModule in result) {
        NSArray *videos = (NSArray *)[aModule objectForKey:@"videos"];
        for (NSDictionary *aVideo in videos) {
            NSString *videoId = [aVideo objectForKey:@"item_id"];
            NSString *videoTitle = [aVideo objectForKey:@"item_title"];
            [[LocalStorage shareInstance] saveVideoName:videoTitle
                                                 course:courseId
                                                videoId:videoId];
        }
    }
}

- (void)savePlaybackPosition:(PlayerFrameView *)localPlayerFrameView {
    NSString *key = [localPlayerFrameView getPromoVideoStr];
    float playbackPosition =
        [localPlayerFrameView getCurrentPlaybackTime]; // error here,
                                                       // moviePlayer = nil
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:playbackPosition forKey:key];
}

#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    return self.bounds;
}

- (void)showLoadingView {
    if (_loadingView == nil) {
        _loadingView = [KKBActivityIndicatorView sharedInstance];
        [_loadingView updateFrame:[self loadingViewFrame]];
        [self addSubview:_loadingView];
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
    [self addSubview:_loadingFailedView];

    [_loadingFailedView setHidden:NO];
}

- (void)removeLoadingFailedView {
    KKBLoadingFailedView *_loadingFailedView =
        [KKBLoadingFailedView sharedInstance];
    [_loadingFailedView setHidden:YES];
}

- (void)refresh {
    [self removeLoadingFailedView];
    //    [self loadData:true];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return [_currentCourseVideoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"cell";

    UITableViewCell *cell = (UITableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];

        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        cell.textLabel.textColor = UIColorRGB(92, 95, 102);
    }
    
    if (_playRecordVideoId != nil) {
        
    }

    cell.textLabel.text =
        [(NSDictionary *)[_currentCourseVideoList objectAtIndex:indexPath.row]
            objectForKey:@"item_title"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.playerFrameView stopMovie];
    // 当前播放视频项
    _currentSelectedVideoUrl = [_currentCourseVideoList objectAtIndex:indexPath.row];
    NSLog(@"current select video item is %@",[_currentCourseVideoList objectAtIndex:indexPath.row]);
    
    
    
    if ([KKBUserInfo shareInstance].isLogin == NO && indexPath.row >= 2) {
            [_delegate pushToLoginViewController];
    } else {
        NSString *classId = [[[self.currentCourse objectForKey:@"lms_course_list"] objectAtIndex:0] objectForKey:@"lms_course_id"];
        
        if ([KKBUserInfo shareInstance].isLogin == YES) {
            if([[LocalStorage shareInstance] getLearnStatusBy:classId] == NO) {
                NSString *jsonForRegisterCourse = [NSString stringWithFormat:@"v1/userapply/register/course/%@",classId];
                
                [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForRegisterCourse method:@"GET" param:nil fromCache:NO success:^(id result, AFHTTPRequestOperation *operation) {
                    [[LocalStorage shareInstance] saveLearnStatus:YES
                                                           course:classId];
                    
                    [[KKBHttpClient shareInstance] refreshMyPublicCourse];
                } failure:^(id result, AFHTTPRequestOperation *operation) {                    
                }];

            }
        }
        // 选中的视频URL
        selectVideoURL = [[_currentCourseVideoList objectAtIndex:indexPath.row]
                          objectForKey:@"video_url"];
        itemID = [[_currentCourseVideoList objectAtIndex:indexPath.row]
                  objectForKey:@"item_id"];
        
        self.playerFrameView.promoVideoStr = selectVideoURL;
        self.playerFrameView.strCourseID = [KKBUserInfo shareInstance].courseId;
        self.playerFrameView.itemID = itemID;
        self.playerFrameView.userID = [KKBUserInfo shareInstance].userId;
        [self.playerFrameView playMovieAtURL];
    }
    
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
