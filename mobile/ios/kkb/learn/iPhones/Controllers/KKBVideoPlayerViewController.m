//
//  KKBVideoPlayerViewController.m
//  VideoPlayerDemo
//
//  Created by zengmiao on 8/12/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBVideoPlayerViewController.h"
#import "VKVideoPlayerView.h"
#import "LocalStorage.h"
#import "KKBUploader.h"
#import "KKBUserInfo.h"
#import "KKBDataBase.h"
#import "AFNetworkReachabilityManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VKVideoPlayerCaptionSRT.h"
#import "KKBDownloadVideo.h"
#import "KKBDownloadManager.h"
#import "KKBVideoSubtitleManager.h"

#define IOS8_DOWNLOADTEST

#define G_VIDEOVIEW_HEIGHT 180.0f //视频播放器的高度

static const int ddLogLevel = LOG_LEVEL_WARN;

// player Debug时打开
//#define DATA_DEBUG

@interface KKBVideoPlayerViewController () <
    VKVideoPlayerDelegate, UIScrollViewDelegate, KKBVideoSuTitleDelegate>

@property(nonatomic, strong) KKBVideoSubtitleManager *subtitleManager;

@property(assign) BOOL applicationIdleTimerDisabled;
#pragma mark - 内部使用
@property(nonatomic, assign) BOOL scrollingFroceFullScreen;
@property(nonatomic, assign) BOOL allowHandlePlayViewInAppear;
//在viewwillappear中是否允许加入PlayerView到view中

@property(nonatomic, assign)
    UIView *superOfPlayerView; // viewWillAppear时将视频加上视图
@property(nonatomic, assign) BOOL authorPlay; // 3g状态下是否允许播放
@property(nonatomic, assign)
    BOOL isPlayingLocalVideo; //当前的videoURL是否是本地地址

@property(nonatomic, assign) CGFloat screenHeight;
#pragma mark - ui相关临时变量
@property(strong, nonatomic) UIButton *playBtn;
@property(strong, nonatomic) UIImageView *coverImageView;
@property(nonatomic, weak) UIView *shadowCoverBgView;
@property(nonatomic, weak) UIView *bottomLine;

@property(strong, nonatomic) AFNetworkReachabilityManager *networkReachability;

@property(nonatomic, assign) NSTimeInterval playbackPosition; //当前视频播放进度
@property(nonatomic, assign) NSTimeInterval totalSecond; //总长度

//上传和记录视频时间时用到
@property(nonatomic, assign) CGFloat seekFrom;
@property(nonatomic, assign) CGFloat seekTo;
@property(nonatomic, assign) CGFloat seekView;
@end

@implementation KKBVideoPlayerViewController {
    float startTime;
    float endTime;
    UIView *progressView;
    UILabel *progressLabel;
    UILabel *totalTimeLabel;
    UIImageView *backGroundView;
    UIImageView *fastImage;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"panGestureEnd"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"panGestureMove"
                                                  object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handPanEnd:)
                                                 name:@"panGestureEnd"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handPanMove:)
                                                 name:@"panGestureMove"
                                               object:nil];

    //手指在播放器上滑动显示进度
    self.player.view.frame = CGRectMake(0, 0, 320, G_VIDEOVIEW_HEIGHT);
    progressView = [[UIView alloc] initWithFrame:CGRectMake(110, 40, 100, 100)];
    progressView.center = self.player.view.center;
    backGroundView = [[UIImageView alloc]
        initWithImage:
            [UIImage
                imageNamed:@"kkb-iphone-KKBVideoPlayer-panBackground.png"]];
    [backGroundView setFrame:CGRectMake(0, 0, 100, 100)];
    fastImage = [[UIImageView alloc]
        initWithImage:[UIImage
                          imageNamed:@"kkb-iphone-KKBVideoPlayer-forward.png"]];
    [fastImage setFrame:CGRectMake(30, 20, 40, 33)];
    progressView.userInteractionEnabled = NO;
    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 40, 12)];
    totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 70, 40, 12)];
    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    progressLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textColor = [UIColor whiteColor];
    NSString *colorString = @"#008eec";
    progressLabel.textColor =
        [UIColor kkb_colorwithHexString:colorString alpha:1.0];
    progressLabel.textAlignment = NSTextAlignmentRight;
    progressLabel.text = @"text";
    [progressView addSubview:backGroundView];
    [progressView addSubview:fastImage];
    [progressView addSubview:progressLabel];
    [progressView addSubview:totalTimeLabel];
    [self.player.view addSubview:progressView];
    progressView.hidden = YES;
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.allowRemovePlayer = YES;

    //设置屏幕高度
    self.screenHeight = self.view.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.applicationIdleTimerDisabled =
        [UIApplication sharedApplication].isIdleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if (self.contentScrollView) {
        self.contentScrollView.delegate = self;
    }

    if (self.allowRemovePlayer && self.allowHandlePlayViewInAppear) {
        [self.superOfPlayerView addSubview:self.player.view];
        [self.coverImageView
            sd_setImageWithURL:[NSURL URLWithString:self.coverImgURL]
              placeholderImage:[UIImage imageNamed:@"bg_video"]];
    }
    self.allowHandlePlayViewInAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled =
        self.applicationIdleTimerDisabled;
    [super viewWillDisappear:animated];

    [self dismissPlayer];

    if (self.allowRemovePlayer && self.allowHandlePlayViewInAppear) {
        self.videoStatus = VideoStatusDismiss;

        self.superOfPlayerView = self.player.view.superview;
        [self.player.view removeFromSuperview];
        _player = nil;
    }

    //恢复 显示状态栏 防止横屏退出状态栏隐藏的bug
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIInterfaceOrientation oriteation = self.player.visibleInterfaceOrientation;

    if (UIInterfaceOrientationIsLandscape(oriteation)) {
        self.player.view.frame = CGRectMake(0, 0, self.screenHeight, 320);

    } else {

        self.player.view.frame = CGRectMake(0, 0, 320, G_VIDEOVIEW_HEIGHT);
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    if (self.player.isFullScreen) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return NO;
    }
}

#pragma mark - Property
- (VKVideoPlayer *)player {
    if (!_player) {
        VKVideoPlayerView *playerView = [[VKVideoPlayerView alloc]
            initWithFrame:CGRectMake(0, 0, 320, G_VIDEOVIEW_HEIGHT)];

        _player = [[VKVideoPlayer alloc] initWithVideoPlayerView:playerView];
        _player.portraitFrame = CGRectMake(0, 0, 320, G_VIDEOVIEW_HEIGHT);
        _player.forceRotate = NO;
        _player.isFullScreen = NO;
        _player.delegate = self;

        [_player.view removeControlView:_player.view.topControlOverlay];
        [_player.view removeControlView:_player.view.topPortraitControlOverlay];
        [_player.view removeControlView:_player.view.videoQualityButton];

        // botom Line
        //在视频下载管理页面不需要分割线
        if (![self shouldNotHandleNetworkMonitor]) {
            UIView *bottomLine = [[UIView alloc]
                initWithFrame:CGRectMake(0, G_VIDEOVIEW_HEIGHT - 1,
                                         playerView.width, 1)];
            bottomLine.backgroundColor =
                [UIColor kkb_colorwithHexString:@"dbdbdb" alpha:1];
            _bottomLine = bottomLine;
            [_player.view addSubview:bottomLine];
        }

        UIImageView *imageView =
            [[UIImageView alloc] initWithFrame:playerView.bounds];
        imageView.image = [UIImage imageNamed:@"bg_video"];
        self.coverImageView = imageView;
        self.coverImageView.userInteractionEnabled = YES;
        [playerView.view addSubview:imageView];

        UIView *shadowBgView = [[UIView alloc] initWithFrame:self.coverImageView.bounds];
        shadowBgView.backgroundColor = UIColorRGBA(0, 0, 0, 0.3);
        _shadowCoverBgView = shadowBgView;
        [self.coverImageView addSubview:shadowBgView];

        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _playBtn.center = playerView.center;
        [_playBtn addTarget:self
                      action:@selector(internalPlayBtnTap)
            forControlEvents:UIControlEventTouchUpInside];

        [_playBtn setImage:[UIImage imageNamed:@"video_play"]
                  forState:UIControlStateNormal];
        [self.coverImageView addSubview:_playBtn];

        [_player.view.bigPlayButton setImage:[UIImage imageNamed:@"video_play"]
                                    forState:UIControlStateNormal];
        [_player.view.bigPlayButton setImage:[UIImage imageNamed:@"video_play"]
                                    forState:UIControlStateHighlighted];

        _videoStatus = VideoStatusUNKnown;
    }
    return _player;
}

- (void)setClassId:(NSString *)classId {
    if (_classId != classId) {
        _classId = classId;

        //实例化subtitleManager
        // classID 有可能是NSNumber类型
        _subtitleManager = [[KKBVideoSubtitleManager alloc]
            initWithClassID:@([_classId longLongValue])
                andDelegate:self];
    }
}

- (void)setCoverImgURL:(NSString *)coverImgURL {
    if (_coverImgURL != coverImgURL) {
        _coverImgURL = coverImgURL;

        NSURL *imageUrl = [NSURL URLWithString:_coverImgURL];
        if (imageUrl) {
            [self.coverImageView
                sd_setImageWithURL:imageUrl
                  placeholderImage:[UIImage imageNamed:@"bg_video"]];
        }
    }
}

- (void)setVideoURLs:(NSMutableArray *)videoURLs {
    if (_videoURLs != videoURLs) {
        _videoURLs = [videoURLs mutableCopy];
        //设置默认播放地址
        if ([_videoURLs count] > 0) {
            if (_videoURL == nil) {
                _videoURL = _videoURLs[0];
            }
        }
    }
}

- (void)setItemIDs:(NSArray *)itemIDs {
    if (_itemIDs != itemIDs) {
        _itemIDs = [itemIDs copy];
        [self filterDownloadedItemURLs];
    }
}

- (void)filterDownloadedItemURLs {

    if ([_itemIDs count] > 0) {
        //过滤视频是否下载好
        NSPredicate *filterVideos =
            [NSPredicate predicateWithFormat:@"videoID IN %@ AND status = %d",
                                             _itemIDs, videoDownloadFinish];
        NSArray *results =
            [KKBDownloadVideo MR_findAllWithPredicate:filterVideos];

        if ([results count] > 0) {
            DDLogInfo(@"此课程有下载记录%@", self.classId);
            NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
            NSMutableArray *localURLs =
                [[NSMutableArray alloc] initWithCapacity:[results count]];

            for (int i = 0; i < [_itemIDs count]; i++) {
                // ID有可能为string类型或者number类型
                id itemID = _itemIDs[i];
                if ([itemID isKindOfClass:[NSString class]]) {
                    itemID = @([(NSString *)itemID longLongValue]);
                }

                for (int j = 0; j < [results count]; j++) {
                    KKBDownloadVideo *downloadVideoItem = results[j];
                    if ([itemID isEqualToNumber:downloadVideoItem.videoID]) {
                        [indexSets addIndex:i];

#ifdef IOS8_DOWNLOADTEST
                        NSString *videoNameStr =
                            [downloadVideoItem.downloadPath lastPathComponent];
                        NSString *newVideoPath =
                            [[KKBDownloadManager videoDownbloadPath]
                                stringByAppendingPathComponent:videoNameStr];
                        [localURLs addObject:newVideoPath];
#else
                        [localURLs addObject:downloadVideoItem.downloadPath];
#endif
                        break;
                    }
                }
            }

            [_videoURLs replaceObjectsAtIndexes:indexSets
                                    withObjects:localURLs];

            //重置当前准备播放的URL
            _videoURL = _videoURLs[0];
        } else {
            DDLogInfo(@"此课程无下载记录%@", self.classId);
        }
    }
}

- (NSString *)videoURL {
    if ([_videoURL isKindOfClass:[NSString class]]) {
        return _videoURL;
    }
    DDLogError(@"videoURL传入错误!!!");
    return nil;
}

- (void)setAllowForceRotation:(BOOL)allowForceRotation {
    if (allowForceRotation) {
        if (self.videoStatus != VideoStatusUNKnown) {
            self.player.forceRotate = YES;
        }
    } else {
        self.player.forceRotate = NO;
    }
}

#pragma mark - btn Mehtod

- (void)backBtnTapped {
    self.allowHandlePlayViewInAppear = NO;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissPlayer {
    if (self.player.state == VKVideoPlayerStateContentPlaying ||
        self.player.state == VKVideoPlayerStateContentPaused) {

        self.playbackPosition = [self.player currentTime];

        [self userTerminateThisPage];

    } else {
    }

    self.player.forceRotate = NO;

    if (self.videoStatus != VideoStatusUNKnown) {
        //如果播放了视频则取消他
        [self.player dismiss];
    }
}

- (void)internalPlayBtnTap {
    [self playVideoWithStreamURL];
    //传递事件
    if (self.videoURL) {
        [self bigPlayBtnTapped];
    }
}

- (void)playVideoWithStreamURL {
    //判断是否为nil
    if (!self.videoURL) {
        return;
    }

    NSURL *videoUrl = nil;
    if ([self.videoURL rangeOfString:DOWNLOAD_DIRECTORY_NAME].location !=
        NSNotFound) {
        self.isPlayingLocalVideo = YES;
        videoUrl = [NSURL fileURLWithPath:self.videoURL];

    } else {
        self.isPlayingLocalVideo = NO;
        videoUrl = [NSURL URLWithString:self.videoURL];
    }

    if (videoUrl) {
        // 读取历史时间
        VKVideoPlayerTrack *track =
            [[VKVideoPlayerTrack alloc] initWithStreamURL:videoUrl];

#ifndef DATA_DEBUG
        NSNumber *playDuration = (NSNumber *)[NSString
            stringWithFormat:@"%f", [[LocalStorage shareInstance]
                                        getPlaybackPosition:self.courseId
                                                    classId:self.classId
                                                   videoUrl:self.videoURL]];
        [track setLastDurationWatchedInSeconds:playDuration];
        DDLogInfo(@"url:%@ playerDuration:%@", self.videoURL, playDuration);
#endif

        track.hasNext = YES;

        //取消正在loading的assetURL 和 playeItem的seek
        [self.player cancelAssetURLAndSeek];

        //检测是否播放本地文件
        if (self.isPlayingLocalVideo) {
            [self playReachableViaEnable:track];
            return;
        }

        //检测网络
        AFNetworkReachabilityManager *netWorkManager =
            [AFNetworkReachabilityManager sharedManager];

        if (!netWorkManager.isReachable) {
            //无网络
            [UIAlertView
                alertViewWithTitle:@"提示"
                           message:@"无网络，请检查网络连接!"];
            return;
        }

        if (netWorkManager.isReachableViaWiFi) {
            [self playReachableViaEnable:track];

        } else {
            // 3g
            [UIAlertView alertViewWithTitle:@"提示"
                message:@"您目前网络为非Wifi环境!"
                cancelButtonTitle:@"取消观看"
                otherButtonTitles:@[ @"我知道了" ]
                onDismiss:^(int buttonIndex) {
                    [self playReachableViaEnable:track];
                }
                onCancel:^{
                    self.coverImageView.hidden = NO;
                }];
        }

    } else {

        DDLogError(@"videoURL is nil");
    }
}

- (void)playReachableViaEnable:(VKVideoPlayerTrack *)track {
    _player.forceRotate = YES;
    self.coverImageView.hidden = YES;

    [self.player loadVideoWithTrack:track];
    self.videoStatus = VideoStatusPlaying;

    //字幕
    NSInteger index = [self.videoURLs indexOfObject:self.videoURL];
    NSNumber *videoID = self.itemIDs[index];
    [self.subtitleManager requestSubtitleWithVideoID:videoID];
     
//    [self.subtitleManager requestSubtitleWithMainBundleForName:@"English"];
}

- (void)continuePlayVideo __deprecated_msg("改成统一的播放便于管理") {
    NSURL *videoUrl = [NSURL URLWithString:self.videoURL];
    [self.player loadVideoWithTrack:[[VKVideoPlayerTrack alloc]
                                        initWithStreamURL:videoUrl]];
}

#pragma mark - 检测网络变化

- (void)networkStatusDidChange {
    __weak KKBVideoPlayerViewController *weakSelf = self;

    [[AFNetworkReachabilityManager sharedManager]
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                if (weakSelf.player.state == VKVideoPlayerStateContentPlaying ||
                    weakSelf.player.state == VKVideoPlayerStateContentLoading) {

                } else {
                    [weakSelf.netDisconnectView
                        showInView:weakSelf.view
                         LabelText:@"当前使用2G/3G网络"];
                }
            } break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                if (weakSelf.player.state == VKVideoPlayerStateContentPlaying ||
                    weakSelf.player.state == VKVideoPlayerStateContentLoading) {

                } else {
                }

            } break;
            case AFNetworkReachabilityStatusNotReachable: {
                if (weakSelf.player.state == VKVideoPlayerStateContentPlaying ||
                    weakSelf.player.state == VKVideoPlayerStateContentLoading) {

                } else {
                    [weakSelf.netDisconnectView showInView:weakSelf.view];
                }

            } break;
            default:
                break;
            }
        }];
}

//重写了父类的方法
/*
- (void)networkStatusDidChange {
    __weak KKBVideoPlayerViewController *weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager]
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"AFNetworkReachabilityStatusReachableViaWWAN");

                // 3g状态
                if (weakSelf.player.state == VKVideoPlayerStateContentPlaying) {
                    //暂停正在的播放
                    [weakSelf.player pauseContent];

                    [UIAlertView alertViewWithTitle:@"提示"
                        message:
                            @"您目前处于非Wifi网络环境,是否继续?"
                        cancelButtonTitle:@"取消"
                        otherButtonTitles:@[ @"继续" ]
                        onDismiss:^(int buttonIndex) {
                            [weakSelf.player playContent];
                        }
                        onCancel:^{}];

                } else if (weakSelf.player.state ==
                           VKVideoPlayerStateContentPaused) {
                    [UIAlertView
                        alertViewWithTitle:@"提示"
                                   message:
                                       @"您目前处于非Wifi网络环境!"];
                } else if (weakSelf.player.state ==
                           VKVideoPlayerStateContentLoading) {
                    //取消加载
                    [weakSelf.player.urlAsset cancelLoading];
                    [UIAlertView alertViewWithTitle:@"提示"
                                            message:
                     @"您目前处于非Wifi网络环境,是否继续?"
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@[ @"继续" ]
                                          onDismiss:^(int buttonIndex) {
                                              [weakSelf.player playContent];
                                          }
                                           onCancel:^{
                                               //显示播放大按钮
                                               weakSelf.coverImageView.hidden =
NO;
                                           }];
                }

            } break;

            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"AFNetworkReachabilityStatusReachableViaWiFi");

            } break;
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"AFNetworkReachabilityStatusNotReachable");
                [weakSelf.netDisconnectView showInView:weakSelf.view];
            } break;
            case AFNetworkReachabilityStatusUnknown: {
                NSLog(@"AFNetworkReachabilityStatusUnknown");

            } break;

            default:
                break;
            }
        }];
}
*/

//新增的手势方法-yqJiang

//滑动结束时触发
- (void)handPanEnd:(NSNotification *)notification {
    [progressView setHidden:YES];
    NSDictionary *dic = [notification userInfo];
    NSNumber *lengthNum = [dic objectForKey:@"distance"];
    NSNumber *audioLengthNum = [dic objectForKey:@"audioDistance"];
    //横向滑动时快退快进
    if (self.totalSecond > 0) {

        if (lengthNum != nil || lengthNum != NULL) {
            float length = [lengthNum floatValue];
            //滑动的时间长度与滑动的距离成正比
            float timeLength = length * self.totalSecond / G_SCREEN_WIDTH;
            float currentTime = [self.player currentTime];
            [self.player seekToTimeInSecond:currentTime + timeLength
                                 userAction:YES
                          completionHandler:^(BOOL finished) {
                              [self.player playContent];
                          }];
            //纵向滑动时调整音量
        } else if (audioLengthNum != nil || audioLengthNum != NULL) {
            float audioNum = [audioLengthNum floatValue];
            float audioNumPercent = audioNum / 180;

            float currentAudioLevel =
                [MPMusicPlayerController applicationMusicPlayer].volume;
            [[MPMusicPlayerController applicationMusicPlayer]
                setVolume:currentAudioLevel - audioNumPercent];
        }
    }
}

// 滑动过程中触发
- (void)handPanMove:(NSNotification *)notification {

    NSDictionary *dic = [notification userInfo];
    NSValue *movePoint = [dic objectForKey:@"movePoint"];
    NSValue *startPoint = [dic objectForKey:@"startPoint"];
    CGPoint mPoint = [movePoint CGPointValue];
    CGPoint sPoint = [startPoint CGPointValue];
    float length = mPoint.x - sPoint.x;
    if (length < 0) {
        [fastImage
            setImage:[UIImage
                         imageNamed:@"kkb-iphone-KKBVideoPlayer-rewind.png"]];
    } else {
        [fastImage
            setImage:[UIImage
                         imageNamed:@"kkb-iphone-KKBVideoPlayer-forward.png"]];
    }
    //滑动的时间长度与滑动的距离成正比
    float timeLength = length * self.totalSecond / G_SCREEN_WIDTH;
    float currentTime = [self.player currentTime];
    int moveTime = currentTime + timeLength;
    if (moveTime < 0) {
        moveTime = 0;
    } else if (moveTime > self.totalSecond) {
        moveTime = self.totalSecond;
    }
    NSString *timeFormat = [self timeFormate:moveTime];
    NSString *totalTimeFormat = [self timeFormate:self.totalSecond];
    if (self.totalSecond > 0) {
        [progressView setHidden:NO];
        progressLabel.text = [NSString stringWithFormat:@"%@/", timeFormat];
        totalTimeLabel.text =
            [NSString stringWithFormat:@"%@", totalTimeFormat];
    }
}

// 将秒转化为 01：23 这种格式
- (NSString *)timeFormate:(int)sec {
    int minute = sec / 60;
    int second = sec % 60;
    NSString *minString = [NSString stringWithFormat:@"%d", minute];
    if (minute > 0 && minute < 10) {
        minString = [NSString stringWithFormat:@"0%d", minute];
    } else if (minute == 0) {
        minString = [NSString stringWithFormat:@"00"];
    }
    NSString *secString = [NSString stringWithFormat:@"%d", second];
    if (second > 0 && second < 10) {
        secString = [NSString stringWithFormat:@"0%d", second];
    } else if (second == 0) {
        secString = [NSString stringWithFormat:@"00"];
    }

    NSString *timeFormateString =
        [NSString stringWithFormat:@"%@:%@", minString, secString];
    return timeFormateString;
}

#pragma mark - 字幕
- (VKVideoPlayerCaption *)loadCaption:(NSString *)captionName {
    NSString *filePath =
        [[NSBundle mainBundle] pathForResource:captionName ofType:@"srt"];
    NSData *testData = [NSData dataWithContentsOfFile:filePath];
    NSString *rawString =
        [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];

    VKVideoPlayerCaption *caption =
        [[VKVideoPlayerCaptionSRT alloc] initWithRawString:rawString];
    return caption;
}

#pragma mark - VKVideoPlayerDelegate
// 网络变化是是否允许外部检查网络变化处理
- (BOOL)shouldMonitorNetWorkChange {
    return YES;
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    didControlByEvent:(VKVideoPlayerControlEvent)event {

    __weak __typeof(self) weakSelf = self;

    if (event == VKVideoPlayerControlEventTapPlay) {
        //当播放本地视频时不需检查网络
        if ([AFNetworkReachabilityManager sharedManager].reachable ||
            [self shouldNotHandleNetworkMonitor] || self.isPlayingLocalVideo) {
            DDLogDebug(@"linkNetWork");
            RUN_ON_UI_THREAD(^{
                if (weakSelf.videoStatus == VideoStatusUNKnown) {
                    [weakSelf playVideoWithStreamURL];

                } else if (weakSelf.videoStatus == VideoStatusPlayEnd) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                 (int64_t)(1 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(),
                                   ^{ [weakSelf playVideoWithStreamURL]; });
                }
            });
        } else {
            DDLogDebug(@"noNetWork");
            NSString *message = [NSString
                stringWithFormat:@"已"
                @"断开网络连接，请检查您的网络连接状态"];
            UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:@"我知道了"
                                 otherButtonTitles:nil, nil];
            [alertView show];
        }

    } else if (event == VKVideoPlayerControlEventTapPlay) {
    } else if (event == VKVideoPlayerControlEventTapDone) {

    } else if (event == VKVideoPlayerControlEventTapFullScreen) {
        RUN_ON_UI_THREAD(^{

            if (self.forceToFullScreen) {
                self.forceToFullScreen = NO;
            } else {
                [self videoPlayerViewFullScreenDidPress];
            }
        });
    }
}

/*
- (BOOL)shouldVideoPlayer:(VKVideoPlayer *)videoPlayer
            changeStateTo:(VKVideoPlayerState)toState {

    if (toState == VKVideoPlayerStateContentLoading | toState ==
VKVideoPlayerStateContentPlaying) {

        //检测网络
        AFNetworkReachabilityManager *netWorkManager =
        [AFNetworkReachabilityManager sharedManager];

        if (!netWorkManager.isReachable) {
            self.authorPlay = NO;
            //无网络
            [UIAlertView
             alertViewWithTitle:@"提示"
             message:@"无网络，请检查网络连接!"];
            return NO;
        }

        if (netWorkManager.isReachableViaWiFi) {
            self.authorPlay = YES;
            return YES;

        } else {
            // 3g
            [UIAlertView alertViewWithTitle:@"提示"
                                    message:@"您目前网络为非Wifi环境!"
                          cancelButtonTitle:@"取消观看"
                          otherButtonTitles:@[ @"我知道了" ]
                                  onDismiss:^(int buttonIndex) {
                                      self.authorPlay = YES;
                                      self.authorPlay = YES;
                                  }
                                   onCancel:^{
                                       self.authorPlay = NO;
                                       self.coverImageView.hidden = NO;
                                   }];
            return NO;
        }


    }
    return YES;
}
 */

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    willChangeOrientationTo:(UIInterfaceOrientation)orientation {
    UIView *contentView = self.player.view.superview;

    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        self.bottomLine.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];

        self.player.view.frame = CGRectMake(0, 0, self.screenHeight, 320);
        progressView.center = self.player.view.center;

        if ([contentView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)contentView;
            scrollView.scrollEnabled = NO;
        }

    } else if (orientation == UIInterfaceOrientationPortrait) {
        self.player.view.frame = CGRectMake(0, 0, 320, G_VIDEOVIEW_HEIGHT);
        progressView.center = self.player.view.center;
        [[UIApplication sharedApplication]
            setStatusBarOrientation:UIInterfaceOrientationPortrait
                           animated:NO];
        [self.navigationController setNavigationBarHidden:NO];

        self.bottomLine.hidden = NO;

        [[UIApplication sharedApplication] setStatusBarHidden:NO];

        if ([contentView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)contentView;
            scrollView.scrollEnabled = YES;
        }
    }
    [self playViewwillChangeOrientationTo:orientation];
}

/**
 *  视频播放结束的回调
 *
 *  @param videoPlayer videoPlayer description
 *  @param track       track description
 */
- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
       didPlayToEnd:(id<VKVideoPlayerTrackProtocol>)track {
    __weak KKBVideoPlayerViewController *weakSelf = self;
    weakSelf.videoStatus = VideoStatusPlayEnd;

    // time
    weakSelf.playbackPosition = 0.0;
    [weakSelf videoDidPlayToEnd];

    if (weakSelf.videoType == VideoPlayMutiType) {
        //完成续播
        int currentIndex = [self.videoURLs indexOfObject:self.videoURL];
        if (currentIndex < [self.videoURLs count] - 1) {
            currentIndex++;
            weakSelf.videoURL = self.videoURLs[currentIndex];

            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                dispatch_get_main_queue(),
                ^{ [weakSelf playVideoWithStreamURL]; });

            dispatch_async(dispatch_get_main_queue(), ^{
                //触发外部事件
                [self videoEndWillToNextVideoIndex:currentIndex];
            });
        }
    }
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
      didStartVideo:(id<VKVideoPlayerTrackProtocol>)track {
    self.videoStatus = VideoStatusPlaying;

    self.totalSecond = self.player.playerItem.duration.value /
                       self.player.playerItem.duration.timescale;
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
     willStartVideo:(id<VKVideoPlayerTrackProtocol>)track {

    NSUInteger index = [self.videoURLs indexOfObject:self.videoURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        //触发外部事件
        [self videoWillStartPlayOfIndex:index];
    });
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode
                  track:(id<VKVideoPlayerTrackProtocol>)track
          customMessage:(NSString *)customMessage {
    NSLog(@"Error currentURL:%@", self.videoURL);

    dispatch_async(dispatch_get_main_queue(), ^{

        switch (errorCode) {
        case kVideoPlayerErrorFetchStreamError:
            DDLogError(@"视频URL错误");
            break;
        case kVideoPlayerErrorAssetLoadError:
            DDLogError(@"kVideoPlayerErrorAssetLoadError");
            [self shouldHandleLocalFileBroken];
            break;
        case kVideoPlayerErrorDurationLoadError:
            DDLogError(@"kVideoPlayerErrorDurationLoadError");
            break;
        case kVideoPlayerErrorAVPlayerFail:
            DDLogError(@"kVideoPlayerErrorAVPlayerFail");
            break;

        case kVideoPlayerErrorAVPlayerItemFail:
            DDLogError(@"kVideoPlayerErrorAVPlayerItemFail");
            break;
        default:
            break;
        }
    });
}

- (void)videoPlayerViewFullScreenDidPress {
    if (self.isPlayingLocalVideo) {
        [self handleError];
    }
}

- (void)shouldHandleLocalFileBroken {
}

- (void)handleError {
    //    [self cancelUrlAssetRequest];
    //    [self.player pauseContent];
}

- (BOOL)shouldNotHandleNetworkMonitor {
    return NO;
}

#pragma mark - zmadd 操作滑块时的回调事件 用于保存播放时间
- (void)videoPlayerScrubbingBegin:(VKVideoPlayer *)videoPlayer {
    //保存视频记录
    [self userTerminateThisPage];
}

- (void)videoPlayerScrubbingEnd:(VKVideoPlayer *)videoPlayer {
}

#pragma mark - 子类重写的方法
//需要重写的方法
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation {
}

//需要重写的方法 大播放按钮点击了
- (void)bigPlayBtnTapped {
}

//当自动续播时将调用此方法 仅当 videoType 为VideoPlayMutiType时有效
- (void)videoEndWillToNextVideoIndex:(int)index {
}

- (void)videoWillStartPlayOfIndex:(NSUInteger)index {
}

//切换视频 仅当 videoType 为VideoPlayMutiType时有效
- (void)changeVideoToIndex:(int)index {
    // 将currentTimeLabel设置为00:00
    self.player.view.currentTimeLabel.text = @"00:00";
    //检测数组是否越界
    if ([self.videoURLs count] <= index) {

        DDLogError(@"videoURLs数组越界:%d", index);
        return;
    }

    NSString *url = self.videoURLs[index];
    if ([self.videoURL isEqualToString:url] &&
        (self.videoStatus != VideoStatusUNKnown)) {
        return;
    }

    // 获取正在播放的视频时间
    if (self.videoStatus != VideoStatusUNKnown) {

        self.playbackPosition = [self.player currentTime];

        //触发内部切换方法
        // check current Video is not loading
        if ((self.player.state == VKVideoPlayerStateContentPlaying) ||
            (self.player.state == VKVideoPlayerStateContentPaused)) {

            [self changeVideoItem];
        }

        //如果有正在loading的视频，先cancel
        [self.player cancelAssetURLAndSeek];

        //先pause
        [self.player pauseContent];
        //获取url
        self.videoURL = self.videoURLs[index];

        [self playVideoWithStreamURL];
    } else {
        //获取url
        self.videoURL = self.videoURLs[index];
        //进此页面第一次播放 相当于第一次播放
        [self internalPlayBtnTap];
    }
}

- (void)presentViewShouldPlayContent:(BOOL)playing {
    //如果当前视频没有播放不做处理
    if (self.videoStatus == VideoStatusUNKnown) {
        return;
    }
    
    //设置允许旋转屏
    self.allowForceRotation = playing;
    
    if (playing) {
        self.coverImageView.hidden = YES;
        self.shadowCoverBgView.hidden = YES;
        self.playBtn.hidden = YES;
        [self.player playContent];
    } else {
        self.coverImageView.hidden = NO;
        self.shadowCoverBgView.hidden = NO;
        self.playBtn.hidden = NO;
        UIImage *image = [self.player loadCurrentVideoThumbnail];
        if (image) {
            self.coverImageView.image = image;
        }
        [self.player pauseContent];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.contentScrollView) {
        if (self.player.forceRotate) {
            self.scrollingFroceFullScreen = YES;
            self.player.forceRotate = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.contentScrollView) {
        if (self.scrollingFroceFullScreen) {
            self.player.forceRotate = YES;
            self.scrollingFroceFullScreen = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (self.contentScrollView) {
        if (!decelerate) {
            if (self.scrollingFroceFullScreen) {
                self.player.forceRotate = YES;
                self.scrollingFroceFullScreen = NO;
            }
        }
    }
}

#pragma mark - 视频进度逻辑
/**
 *  视频播放结束触发的方法
 */
- (void)videoDidPlayToEnd {

#ifndef DATA_DEBUG
    //需要重置视频进度为0
    if (self.courseId == nil || self.classId == nil) {

    } else {
        _seekFrom = 0;
        _seekTo =
            [[LocalStorage shareInstance] getPlaybackPosition:self.courseId
                                                      classId:self.classId
                                                     videoUrl:self.videoURL];
        _seekView = (float)self.totalSecond;
        endTime = (float)self.playbackPosition;
        [[LocalStorage shareInstance] savePlaybackPosition:endTime
                                                  courseId:self.courseId
                                                   classId:self.classId
                                                  videoUrl:self.videoURL];

        [self savePlayRecordInfoWithSeekFrom:_seekFrom
                                      seekTo:_seekTo
                                    seekView:_seekView];
    }

#endif
}

/**
 *  用户主动切换视频
 */
- (void)changeVideoItem {

#ifndef DATA_DEBUG
    _seekFrom = 0;
    startTime =
        [[LocalStorage shareInstance] getPlaybackPosition:self.courseId
                                                  classId:self.classId
                                                 videoUrl:self.videoURL];

    _seekTo = startTime;

    endTime = (float)self.playbackPosition;
    [[LocalStorage shareInstance] savePlaybackPosition:endTime
                                              courseId:self.courseId
                                               classId:self.classId
                                              videoUrl:self.videoURL];
    _seekView = endTime;

    [self savePlayRecordInfoWithSeekFrom:_seekFrom
                                  seekTo:_seekTo
                                seekView:_seekView];
#endif
}

/**
 *  用户退出次页面时调用 self.player.state == VKVideoPlayerStateContentPlaying
                    self.player.state == VKVideoPlayerStateContentPaused
 */
- (void)userTerminateThisPage {

#ifndef DATA_DEBUG
    if (self.player.state == VKVideoPlayerStateContentPlaying ||
        self.player.state == VKVideoPlayerStateContentPaused) {
        //在此页中用户已经播放了视频 否则用户没有点播放按钮
        if (self.courseId == nil || self.classId == nil) {

        } else {
            _seekFrom = 0;
            _seekTo = [[LocalStorage shareInstance]
                getPlaybackPosition:self.courseId
                            classId:self.classId
                           videoUrl:self.videoURL];
            endTime = (float)self.playbackPosition;
            _seekView = endTime;
            [[LocalStorage shareInstance] savePlaybackPosition:endTime
                                                      courseId:self.courseId
                                                       classId:self.classId
                                                      videoUrl:self.videoURL];

            [self savePlayRecordInfoWithSeekFrom:_seekFrom
                                          seekTo:_seekTo
                                        seekView:_seekView];
        }
    }

#endif
}

- (void)savePlayRecordInfoWithSeekFrom:(float)sFrom
                                seekTo:(float)sTo
                              seekView:(float)sView {
    NSMutableDictionary *videoInfoDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *viewPeriodsArray = [[NSMutableArray alloc] init];
    NSDictionary *seekFromDict = @{
        @"action" : @"seekfrom",
        @"vtime" : [NSString stringWithFormat:@"%f", sFrom]
    };
    NSDictionary *seekToDict = @{
        @"action" : @"seekto",
        @"vtime" : [NSString stringWithFormat:@"%f", sTo]
    };
    NSDictionary *viewDict = @{
        @"action" : @"view",
        @"vtime" : [NSString stringWithFormat:@"%f", sView]
    };
    [viewPeriodsArray addObject:seekFromDict];
    [viewPeriodsArray addObject:seekToDict];
    [viewPeriodsArray addObject:viewDict];

    [videoInfoDict setObject:viewPeriodsArray forKey:@"viewperiods"];
    if ([KKBUserInfo shareInstance].userEmail == nil) {
        [videoInfoDict setObject:@"" forKey:@"email"];
    } else {
        [videoInfoDict setObject:[KKBUserInfo shareInstance].userEmail
                          forKey:@"email"];
    }

    // itemID
    int index = [self.videoURLs indexOfObject:self.videoURL];
    NSString *itemID = self.itemIDs[index];
    [videoInfoDict setObject:itemID forKey:@"last_video_id"];

    long long videoLenth = (long long)_totalSecond;
    [videoInfoDict setObject:[NSString stringWithFormat:@"%lld", videoLenth]
                      forKey:@"videolen"];
    [videoInfoDict setObject:self.classId forKey:@"course_id"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoInfoDict
                                                       options:0
                                                         error:&error];
    NSString *jsonString =
        [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[KKBDataBase sharedInstance] addRecordWithJsonString:jsonString
                                                     type:@"VIDEO"];

    [[KKBUploader sharedInstance] startUpload];
}

#pragma mark - KKBVideoSuTitleDelegate
- (void)subTitleDidLoad:(VKVideoPlayerCaptionSRT *)caption
                manager:(KKBVideoSubtitleManager *)manager {
    [self.player setCaptionToBottom:caption];
}

- (void)subTitleLoadFailedWithManager:(KKBVideoSubtitleManager *)manager
                            errorCode:(SubtitlesError)errCode {
}
@end
