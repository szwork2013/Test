//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKVideoPlayer.h"
#import "VKVideoPlayerConfig.h"
#import "VKVideoPlayerCaption.h"
#import "VKVideoPlayerSettingsManager.h"
#import "VKVideoPlayerLayerView.h"
#import "VKVideoPlayerTrack.h"
#import "NSObject+VKFoundation.h"
#import "VKVideoPlayerExternalMonitor.h"

#define VKCaptionPadding 10
#define degreesToRadians(x) (M_PI * x / 180.0f)

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_WARN;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

NSString *kTracksKey = @"tracks";
NSString *kPlayableKey = @"playable";

static const NSString *ItemStatusContext;

typedef enum {
    VKVideoPlayerCaptionPositionTop = 1111,
    VKVideoPlayerCaptionPositionBottom
} VKVideoPlayerCaptionPosition;

@interface VKVideoPlayer ()
@property(nonatomic, assign) BOOL scrubbing;
@property(nonatomic, assign) NSTimeInterval beforeSeek;
@property(nonatomic, assign) NSTimeInterval previousPlaybackTime;
@property(nonatomic, assign) double previousIndicatedBandwidth;

@property(nonatomic, strong) id timeObserver;

@property(nonatomic, strong) id<VKVideoPlayerCaptionProtocol> captionTop;
@property(nonatomic, strong) id<VKVideoPlayerCaptionProtocol> captionBottom;
@property(nonatomic, strong) id captionTopTimer;
@property(nonatomic, strong) id captionBottomTimer;

#pragma mark - zmdd 在网络不佳的情况下防止控制器销毁时视频还在loading
@property(strong, nonatomic) AVURLAsset *urlAsset;

@end

@implementation VKVideoPlayer

- (id)init {
    self = [super init];
    if (self) {
        self.view = [[VKVideoPlayerView alloc] init];
        [self initialize];
    }
    return self;
}

- (id)initWithVideoPlayerView:(VKVideoPlayerView *)videoPlayerView {
    self = [super init];
    if (self) {
        self.view = videoPlayerView;
        [self initialize];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
    [self.externalMonitor deactivate];

    // TODO: byzm
    self.urlAsset = nil;

    self.timeObserver = nil;
    self.avPlayer = nil;
    self.captionTop = nil;
    self.captionBottom = nil;
    self.captionTopTimer = nil;
    self.captionBottomTimer = nil;

    self.playerItem = nil;

    [self pauseContent];
}

#pragma mark - 取消网络请求和seek
- (void)cancelAssetURLAndSeek {
    if (self.urlAsset) {
        [self.urlAsset cancelLoading];
    }
    if (self.playerItem) {
        [self.playerItem cancelPendingSeeks];
    }
}

#pragma mark - Property  zmadd为了给videoView
- (void)setPortraitFrame:(CGRect)portraitFrame {
    _portraitFrame = portraitFrame;
    if (_view) {
        _view.portraitFrame = _portraitFrame;
    }
}

- (void)setLandscapeFrame:(CGRect)landscapeFrame {
    _landscapeFrame = landscapeFrame;
    if (_view) {
        _view.landscapeFrame = _landscapeFrame;
    }
}

#pragma mark - initialize
- (void)initialize {
    [self initializeProperties];
    [self initializePlayerView];
    [self addObservers];
}

- (void)initializeProperties {
    self.state = VKVideoPlayerStateUnknown;
    self.scrubbing = NO;
    self.beforeSeek = 0.0;
    self.previousPlaybackTime = 0;
    self.supportedOrientations =
        VKSharedUtility.isPad ? UIInterfaceOrientationMaskAll
                              : UIInterfaceOrientationMaskAllButUpsideDown;

    self.forceRotate = NO;

    CGRect bounds = [UIScreen kkb_screenBoundsFixedToPortraitOrientation];
    //    CGRect bounds = [[UIScreen mainScreen] bounds];

    self.portraitFrame =
        CGRectMake(0, 0, MIN(bounds.size.width, bounds.size.height),
                   MAX(bounds.size.width, bounds.size.height));
    self.landscapeFrame =
        CGRectMake(0, 0, MAX(bounds.size.width, bounds.size.height),
                   MIN(bounds.size.width, bounds.size.height));
}

- (void)initializePlayerView {
    self.view.delegate = self;
    [self.view setPlayButtonsSelected:NO];
    [self.view.scrubber setValue:0.0f animated:NO];
    self.view.controlHideCountdown = kPlayerControlsAutoHideTime;

    if (!self.forceRotate) {
        self.view.fullscreenButton.hidden = YES;
    }
}

- (void)loadCurrentVideoTrack {
    __weak __typeof__(self) weakSelf = self;
    RUN_ON_UI_THREAD(^{ [weakSelf initPlayerWithTrack:self.videoTrack]; });
}

#pragma mark - Error Handling

- (NSString *)videoPlayerErrorCodeToString:(VKVideoPlayerErrorCode)code {
    switch (code) {
    case kVideoPlayerErrorVideoBlocked:
        return @"kVideoPlayerErrorVideoBlocked";
        break;
    case kVideoPlayerErrorFetchStreamError:
        return @"kVideoPlayerErrorFetchStreamError";
        break;
    case kVideoPlayerErrorStreamNotFound:
        return @"kVideoPlayerErrorStreamNotFound";
        break;
    case kVideoPlayerErrorAssetLoadError:
        return @"kVideoPlayerErrorAssetLoadError";
        break;
    case kVideoPlayerErrorDurationLoadError:
        return @"kVideoPlayerErrorDurationLoadError";
        break;
    case kVideoPlayerErrorAVPlayerFail:
        return @"kVideoPlayerErrorAVPlayerFail";
        break;
    case kVideoPlayerErrorAVPlayerItemFail:
        return @"kVideoPlayerErrorAVPlayerItemFail";
        break;
    case kVideoPlayerErrorUnknown:
    default:
        return @"kVideoPlayerErrorUnknown";
        break;
    }
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode
                  track:(id<VKVideoPlayerTrackProtocol>)track {
    [self handleErrorCode:errorCode track:track customMessage:nil];
}

- (void)handleErrorCode:(VKVideoPlayerErrorCode)errorCode
                  track:(id<VKVideoPlayerTrackProtocol>)track
          customMessage:(NSString *)customMessage {
    RUN_ON_UI_THREAD(^{

        // TODO: byzm 将当前状态改为失败状态
        self.state = VKVideoPlayerStateError;

        if ([self.delegate respondsToSelector:@selector(handleErrorCode:
                                                                  track:
                                                          customMessage:)]) {
            [self.delegate handleErrorCode:errorCode
                                     track:track
                             customMessage:customMessage];
        }
    });
}

#pragma mark - KVO

- (void)setTimeObserver:(id)timeObserver {
    if (_timeObserver) {
        DDLogVerbose(@"TimeObserver: remove %@", _timeObserver);
        [self.avPlayer removeTimeObserver:_timeObserver];
    }
    _timeObserver = timeObserver;
    if (timeObserver) {
        DDLogVerbose(@"TimeObserver: setup %@", _timeObserver);
    }
}

- (void)setCaptionBottomTimer:(id)captionBottomTimer {
    if (_captionBottomTimer)
        [self.avPlayer removeTimeObserver:_captionBottomTimer];
    _captionBottomTimer = captionBottomTimer;
}

- (void)setCaptionTopTimer:(id)captionTopTimer {
    if (_captionTopTimer)
        [self.avPlayer removeTimeObserver:_captionTopTimer];
    _captionTopTimer = captionTopTimer;
}

- (void)addObservers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    //  [defaultCenter addObserver:self
    //  selector:@selector(applicationWillResignActive)
    //  name:UIApplicationWillResignActiveNotification object:nil];
    //  [defaultCenter addObserver:self
    //  selector:@selector(applicationDidBecomeActive)
    //  name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter
        addObserver:self
           selector:@selector(volumeChanged:)
               name:@"AVSystemController_SystemVolumeDidChangeNotification"
             object:nil];

    [defaultCenter addObserver:self
                      selector:@selector(reachabilityChanged:)
                          name:kReachabilityChangedNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(playerItemReadyToPlay)
                          name:kVKVideoPlayerItemReadyToPlay
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(orientationChanged:)
                          name:UIDeviceOrientationDidChangeNotification
                        object:[UIDevice currentDevice]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:kVKSettingsSubtitlesEnabledKey
                  options:(NSKeyValueObservingOptionOld |
                           NSKeyValueObservingOptionNew)
                  context:nil];
    [defaults addObserver:self
               forKeyPath:kVKSettingsTopSubtitlesEnabledKey
                  options:(NSKeyValueObservingOptionOld |
                           NSKeyValueObservingOptionNew)
                  context:nil];
    [defaults addObserver:self
               forKeyPath:kVKSettingsSubtitleLanguageCodeKey
                  options:(NSKeyValueObservingOptionOld |
                           NSKeyValueObservingOptionNew)
                  context:nil];
    [defaults addObserver:self
               forKeyPath:kVKVideoQualityKey
                  options:(NSKeyValueObservingOptionOld |
                           NSKeyValueObservingOptionNew)
                  context:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:kVKSettingsSubtitlesEnabledKey];
    [defaults removeObserver:self forKeyPath:kVKSettingsTopSubtitlesEnabledKey];
    [defaults removeObserver:self
                  forKeyPath:kVKSettingsSubtitleLanguageCodeKey];
    [defaults removeObserver:self forKeyPath:kVKVideoQualityKey];
}

#pragma mark - 网络变化status
- (void)reachabilityChanged:(NSNotification *)notification {
    if (![self.delegate shouldMonitorNetWorkChange]) {
        return;
    }

    Reachability *curReachability = notification.object;

    // TODO: byzm 调整网络变化时的处理事件
    if ([curReachability isReachable]) {
        // TODO: byzpc 添加判断2G/3G
        if ([curReachability isReachableViaWWAN]) {
            [self pauseContent];
            UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:@""
                          message:@"您" @"当"
                          @"前处于非WiFi环境，播放视频可能产生"
                          @"额外的" @"流量费用"
                         delegate:self
                cancelButtonTitle:@"取消播放"
                otherButtonTitles:@"继续播放", nil];
            [alertView show];
        } else if ([curReachability isReachableViaWiFi]) {
            // 判断 换为WiFi时 需不需要自动开始播放
            [self playContent];
        }
    } else {
        [self pauseContent];
    }

    /*
    if (curReachability == VKSharedUtility.wifiReach) {
        DDLogVerbose(@"Reachability Changed: %@",
                     [VKSharedUtility.wifiReach isReachableViaWiFi]
                         ? @"Wifi Detected."
                         : @"Cellular Detected.");
        [self reloadCurrentVideoTrack];
        self.view.videoQualityButton.enabled = YES;
    } else {
        self.view.videoQualityButton.enabled = NO;
    }
     */
}

// TODO: byzpc 弹窗提示
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 取消
    } else {
        // 继续
        [self playContent];
    }
}

- (NSString *)observedBitrateBucket:(NSNumber *)observedKbps {
    NSString *observedKbpsString = @"";
    if ([observedKbps integerValue] <= 100) {
        observedKbpsString = @"0-100";
    } else if ([observedKbps integerValue] <= 200) {
        observedKbpsString = @"101-200";
    } else if ([observedKbps integerValue] <= 400) {
        observedKbpsString = @"201-400";
    } else if ([observedKbps integerValue] <= 600) {
        observedKbpsString = @"401-600";
    } else if ([observedKbps integerValue] <= 800) {
        observedKbpsString = @"601-800";
    } else if ([observedKbps integerValue] <= 1000) {
        observedKbpsString = @"801-1000";
    } else if ([observedKbps integerValue] > 1000) {
        observedKbpsString = @">1000";
    }
    return observedKbpsString;
}

- (void)periodicTimeObserver:(CMTime)time {
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    NSTimeInterval lastTimeInSeconds = _previousPlaybackTime;

    if (timeInSeconds <= 0) {
        return;
    }

    if ([self isPlayingVideo]) {
        NSTimeInterval interval = fabs(timeInSeconds - _previousPlaybackTime);
        if (interval < 2) {
            if (self.captionBottom) {
                VKVideoPlayerView *playerView = [self activePlayerView];
                [self updateCaptionView:playerView.captionBottomView
                                caption:self.captionBottom
                             playerView:playerView];
            }
        }

        _previousPlaybackTime = timeInSeconds;
    }

    if ([self.player currentItemDuration] > 1) {
        NSDictionary *info = [NSDictionary
            dictionaryWithObject:[NSNumber numberWithFloat:timeInSeconds]
                          forKey:@"scrubberValue"];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kVKVideoPlayerScrubberValueUpdatedNotification
                          object:self
                        userInfo:info];

        NSDictionary *durationInfo = [NSDictionary
            dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:self.track.hasPrevious],
                @"hasPreviousVideo",
                [NSNumber numberWithBool:self.track.hasNext], @"hasNextVideo",
                [NSNumber numberWithDouble:[self.player currentItemDuration]],
                @"duration", nil];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kVKVideoPlayerDurationDidLoadNotification
                          object:self
                        userInfo:durationInfo];
    }

    [self.view hideControlsIfNecessary];

    if ([self.delegate respondsToSelector:@selector(videoPlayer:
                                                   didPlayFrame:
                                                           time:
                                                       lastTime:)]) {
        [self.delegate videoPlayer:self
                      didPlayFrame:self.track
                              time:timeInSeconds
                          lastTime:lastTimeInSeconds];
    }
}

- (void)seekToTimeInSecond:(float)sec
                userAction:(BOOL)isUserAction
         completionHandler:(void (^)(BOOL finished))completionHandler {
    [self scrubbingBegin];
    [self scrubbingEndAtSecond:sec
                    userAction:isUserAction
             completionHandler:completionHandler];
}

- (void)scrubbingEndAtSecond:(float)sec
                  userAction:(BOOL)isUserAction
           completionHandler:(void (^)(BOOL finished))completionHandler {
    [self.player seekToTimeInSeconds:sec completionHandler:completionHandler];
}

#pragma mark - Playback position

- (void)seekToLastWatchedDuration {
    RUN_ON_UI_THREAD(^{

        [self.view setPlayButtonsEnabled:NO];

        CGFloat lastWatchedTime =
            [self.track.lastDurationWatchedInSeconds floatValue];
        if (lastWatchedTime > 5)
            lastWatchedTime -= 5;

        DDLogVerbose(@"Seeking to last watched duration: %f", lastWatchedTime);
        [self.view.scrubber
            setValue:([self.player currentItemDuration] > 0)
                         ? lastWatchedTime / [self.player currentItemDuration]
                         : 0.0f
            animated:NO];

        [self.player
            seekToTimeInSeconds:lastWatchedTime
              completionHandler:^(BOOL finished) {
                  if (finished)
                      [self playContent];
                  [self.view setPlayButtonsEnabled:YES];

                  if ([self.delegate
                          respondsToSelector:@selector(videoPlayer:
                                                     didStartVideo:)]) {
                      [self.delegate videoPlayer:self didStartVideo:self.track];
                  }
              }];
    });
}

- (void)playerDidPlayToEnd:(NSNotification *)notification {
    DDLogVerbose(@"Player: Did play to the end");
    RUN_ON_UI_THREAD(^{

        self.track.isPlayedToEnd = YES;
        [self pauseContent:NO
            completionHandler:^{
                if ([self.delegate
                        respondsToSelector:@selector(videoPlayer:
                                                    didPlayToEnd:)]) {
                    [self.delegate videoPlayer:self didPlayToEnd:self.track];
                }
            }];
    });
}

#pragma mark - AVPlayer wrappers

- (BOOL)isPlayingVideo {
    return (self.avPlayer && self.avPlayer.rate != 0.0);
}

#pragma mark - Airplay

- (VKVideoPlayerView *)activePlayerView {
    if (self.externalMonitor.isConnected) {
        return self.externalMonitor.externalView;
    } else {
        return self.view;
    }
}

- (BOOL)isPlayingOnExternalDevice {
    return self.externalMonitor.isConnected;
}

#pragma mark - Handle Videos
- (void)loadVideoWithTrack:(id<VKVideoPlayerTrackProtocol>)track {
    VoidBlock completionHandler = ^{
        self.track = track;
        [self initPlayerWithTrack:self.track];
    };

    switch (self.state) {
    case VKVideoPlayerStateUnknown:
    case VKVideoPlayerStateSuspended:
    case VKVideoPlayerStateError:
    case VKVideoPlayerStateContentPaused:
    case VKVideoPlayerStateContentLoading:
        completionHandler();
        break;
    case VKVideoPlayerStateContentPlaying:
        [self pauseContent:NO completionHandler:completionHandler];
        break;
    default:
        break;
    };
}
- (void)loadVideoWithStreamURL:(NSURL *)streamURL {
    [self loadVideoWithTrack:[[VKVideoPlayerTrack alloc]
                                 initWithStreamURL:streamURL]];
}

- (void)setTrack:(id<VKVideoPlayerTrackProtocol>)track {
    // Clear player before loading new track
    [self clearPlayer];

    // Load new track and update views
    _track = track;
    self.view.titleLabel.text = [track title];
    [self updateTrackControls];

    // Post notification once track has been changed
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kVKVideoPlayerUpdateVideoTrack
                      object:track];
}

- (void)clearPlayer {
    // TODO: byzm 取消正在loading的AVURLAsset 和 快进快退操作
    [self cancelAssetURLAndSeek];
    /*******************************/
    self.urlAsset = nil;
    self.playerItem = nil;
    self.avPlayer = nil;
    self.player = nil;
}

// NOTE: This method can be overridden if you want to selecti6vely init
// different
// players
- (void)initPlayerWithTrack:(id<VKVideoPlayerTrackProtocol>)track {
    // Reset isReadyToPlay property
    self.isReadyToPlay = NO;

    if (!track.isVideoLoadedBefore) {
        track.isVideoLoadedBefore = YES;
    }

    // Get the stream url
    NSURL *streamURL = [track streamURL];

    // If no stream found, handle error
    if (!streamURL) {
        [self handleErrorCode:kVideoPlayerErrorFetchStreamError track:track];
        DDLogWarn(@"Unable to fetch stream");
        return;
    }

    // Content now loading
    self.state = VKVideoPlayerStateContentLoading;

    // Get asset to create AVPlayerItem and AVPlayer
    AVURLAsset *asset = [[AVURLAsset alloc]
        initWithURL:streamURL
            options:@{
                AVURLAssetPreferPreciseDurationAndTimingKey : @YES
            }];

    // TODO: byzm
    self.urlAsset = asset;

    [asset loadValuesAsynchronouslyForKeys:@[
        kTracksKey,
        kPlayableKey
    ] completionHandler:^{
        // Completion handler block.
        RUN_ON_UI_THREAD(^{
            if (self.state == VKVideoPlayerStateDismissed)
                return;
            if (![asset.URL.absoluteString
                    isEqualToString:streamURL.absoluteString]) {
                DDLogVerbose(@"Ignore stream load success. "
                             @"Requested to load: %@ but the "
                             @"current stream should be %@.",
                             asset.URL.absoluteString,
                             streamURL.absoluteString);
                return;
            }
            NSError *error = nil;
            AVKeyValueStatus status =
                [asset statusOfValueForKey:kTracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                // Init AVPlayerItem and AVPlayer
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                self.avPlayer = [self playerWithPlayerItem:self.playerItem];
                self.player = (id<VKPlayer>)self.avPlayer;
                [[self activePlayerView].playerLayerView
                    setPlayer:self.avPlayer];
            } else {
                // You should deal with the error appropriately.

                // TODO: byzm
                // 在这里需要处理assetURL取消的状态，不能都抛错误
                if (status == AVKeyValueStatusCancelled) {
                    DDLogWarn(@"AVKeyValueStatusCancelled");
                }

                if (status == AVKeyValueStatusFailed) {
                    [self handleErrorCode:kVideoPlayerErrorAssetLoadError
                                    track:track];
                    DDLogWarn(@"The asset's tracks were not loaded:\n%@",
                              error);
                }
            }
        });
    }];
}

- (void)playerItemReadyToPlay {
    DDLogVerbose(@"Player: playerItemReadyToPlay");

    // Set isReadyToPlay property to true to signify that media is ready
    self.isReadyToPlay = YES;

    RUN_ON_UI_THREAD(^{
        switch (self.state) {
        case VKVideoPlayerStateContentLoading:
        case VKVideoPlayerStateError: {
            /**
             * If player is loading or in error state
             * Pause player and then check if should auto play
             */
            [self pauseContent:NO
                completionHandler:^{
                    // If should not auto start video, return
                    if ([self.delegate
                            respondsToSelector:@selector(shouldVideoPlayer:
                                                                startVideo:)]) {
                        if (![self.delegate shouldVideoPlayer:self
                                                   startVideo:self.track]) {
                            return;
                        }
                    }
                    // Start the video by seeking to last watched duration
                    if ([self.delegate
                            respondsToSelector:@selector(videoPlayer:
                                                      willStartVideo:)]) {
                        [self.delegate videoPlayer:self
                                    willStartVideo:self.track];
                    }
                    [self seekToLastWatchedDuration];
                }];
            break;
        }
        default:
            /**
             * Do nothing if player is:
             * Unknown
             * Paused
             * Playing
             * Suspended
             * Dismissed
             */
            break;
        }
    });
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:AVPlayerItemDidPlayToEndTimeNotification
                object:_playerItem];
    _playerItem = playerItem;
    _previousIndicatedBandwidth = 0.0f;

    if (!playerItem) {
        return;
    }
    [_playerItem addObserver:self
                  forKeyPath:@"status"
                     options:0
                     context:&ItemStatusContext];
    [_playerItem addObserver:self
                  forKeyPath:@"playbackBufferEmpty"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [_playerItem addObserver:self
                  forKeyPath:@"playbackLikelyToKeepUp"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(playerDidPlayToEnd:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:_playerItem];
}

- (void)setAvPlayer:(AVPlayer *)avPlayer {
    self.timeObserver = nil;
    self.captionTopTimer = nil;
    self.captionBottomTimer = nil;
    [_avPlayer removeObserver:self forKeyPath:@"status"];
    _avPlayer = avPlayer;
    if (avPlayer) {
        __weak __typeof(self) weakSelf = self;
        [avPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
        self.timeObserver = [avPlayer
            addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                         queue:NULL
                                    usingBlock:^(CMTime time) {
                                        [weakSelf periodicTimeObserver:time];
                                    }];

        if (self.captionTop) {
            [self setCaption:self.captionTop
                toCaptionView:self.activePlayerView.captionTopView
                   playerView:self.activePlayerView];
        }
        if (self.captionBottom) {
            [self setCaption:self.captionBottom
                toCaptionView:self.activePlayerView.captionBottomView
                   playerView:self.activePlayerView];
        }
        [self clearCaptionView:self.activePlayerView.captionTopView];
        [self clearCaptionView:self.activePlayerView.captionBottomView];
    }
}

- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem {
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    if ([player respondsToSelector:@selector(setAllowsAirPlayVideo:)])
        player.allowsAirPlayVideo = NO;
    if ([player respondsToSelector:@selector(setAllowsExternalPlayback:)])
        player.allowsExternalPlayback = NO;
    return player;
}

- (void)reloadCurrentVideoTrack {
    __weak __typeof__(self) weakSelf = self;
    RUN_ON_UI_THREAD(^{
        VoidBlock completionHandler = ^{
            weakSelf.state = VKVideoPlayerStateContentLoading;
            [weakSelf initPlayerWithTrack:self.videoTrack];
        };

        switch (self.state) {
        case VKVideoPlayerStateUnknown:
        case VKVideoPlayerStateContentLoading:
        case VKVideoPlayerStateContentPaused:
        case VKVideoPlayerStateError:
            DDLogVerbose(@"Reload stream now.");
            completionHandler();
            break;
        case VKVideoPlayerStateContentPlaying:
            DDLogVerbose(@"Reload stream after pause.");
            [self pauseContent:NO completionHandler:completionHandler];
            break;
        case VKVideoPlayerStateDismissed:
        case VKVideoPlayerStateSuspended:
            break;
        }
    });
}

- (float)currentBitRateInKbps {
    return [self.playerItem.accessLog.events.lastObject observedBitrate] / 1000;
}

#pragma mark -

- (NSTimeInterval)currentTime {
    if (!self.track.isVideoLoadedBefore) {
        return [self.track.lastDurationWatchedInSeconds doubleValue] > 0
                   ? [self.track.lastDurationWatchedInSeconds doubleValue]
                   : 0.0f;
    } else
        return CMTimeGetSeconds([self.player currentCMTime]);
}

#pragma mark - captions
- (void)clearCaptions {
    [self setCaptionToTop:nil];
    [self setCaptionToBottom:nil];
}

- (void)setCaption:(id<VKVideoPlayerCaptionProtocol>)caption
     toCaptionView:(DTAttributedLabel *)captionView
        playerView:(VKVideoPlayerView *)playerView {
    if (!caption.boundryTimes.count) {
        [self clearCaptionView:captionView];
        if (captionView.tag == VKVideoPlayerCaptionPositionTop) {
            self.captionTopTimer = nil;
            self.captionTop = nil;
        } else if (captionView.tag == VKVideoPlayerCaptionPositionBottom) {
            self.captionBottomTimer = nil;
            self.captionBottom = nil;
        }
        return;
    }

    __weak id weakSelf = self;

    DDLogVerbose(@"Subs: %@ - segment count %d", caption,
                 (int)caption.segments.count);
    id captionTimer = [self.avPlayer
        addBoundaryTimeObserverForTimes:caption.boundryTimes
                                  queue:NULL
                             usingBlock:^{
                                 [weakSelf updateCaptionView:captionView
                                                     caption:caption
                                                  playerView:playerView];
                             }];

    if (captionView.tag == VKVideoPlayerCaptionPositionTop) {
        self.captionTopTimer = captionTimer;
        self.captionTop = caption;
    } else if (captionView.tag == VKVideoPlayerCaptionPositionBottom) {
        self.captionBottomTimer = captionTimer;
        self.captionBottom = caption;
    }
    [self updateCaptionView:captionView caption:caption playerView:playerView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == [NSUserDefaults standardUserDefaults]) {
        if ([keyPath isEqualToString:kVKSettingsSubtitlesEnabledKey]) {
            NSString *fromLang, *toLang;
            if ([[change valueForKeyPath:NSKeyValueChangeNewKey] boolValue]) {
                fromLang = @"null";
                toLang =
                    VKSharedVideoPlayerSettingsManager.subtitleLanguageCode;
            } else {
                self.captionBottomTimer = nil;
                self.captionBottom = nil;
                [self clearCaptionView:self.view.captionBottomView];
                fromLang =
                    VKSharedVideoPlayerSettingsManager.subtitleLanguageCode;
                toLang = @"null";
            }

            if ([self.delegate
                    respondsToSelector:@selector(videoPlayer:
                                           didChangeSubtitleFrom:
                                                              to:)]) {
                [self.delegate videoPlayer:self
                     didChangeSubtitleFrom:fromLang
                                        to:toLang];
            }
        }
        if ([keyPath isEqualToString:kVKSettingsTopSubtitlesEnabledKey]) {
            if ([[change valueForKeyPath:NSKeyValueChangeNewKey] boolValue]) {
                //        self.track.topSubtitleEnabled = @YES;
            } else {
                self.captionTopTimer = nil;
                self.captionTop = nil;
                //        self.track.topSubtitleEnabled = @NO;
                [self clearCaptionView:[self activePlayerView].captionTopView];
            }
        }
        if ([keyPath isEqualToString:kVKSettingsSubtitleLanguageCodeKey]) {
            [self.view.captionButton
                setTitle:[VKSharedVideoPlayerSettingsManager
                                 .subtitleLanguageCode uppercaseString]
                forState:UIControlStateNormal];
        }
        if ([keyPath isEqualToString:kVKVideoQualityKey]) {
            [self reloadCurrentVideoTrack];
            [self.view.videoQualityButton
                setTitle:[VKSharedVideoPlayerSettingsManager
                             videoQualityShortDescription:
                                 [VKSharedVideoPlayerSettingsManager streamKey]]
                forState:UIControlStateNormal];
        }
    }

    // Observer AVPlayer and AVPlayerItem to determine when media is ready to
    // play
    if (object == self.avPlayer) {
        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.avPlayer status]) {
            case AVPlayerStatusReadyToPlay:
                DDLogVerbose(@"AVPlayerStatusReadyToPlay");
                if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:kVKVideoPlayerItemReadyToPlay
                                      object:nil];
                }
                break;
            case AVPlayerStatusFailed:
                DDLogVerbose(@"AVPlayerStatusFailed");
                [self handleErrorCode:kVideoPlayerErrorAVPlayerFail
                                track:self.track];
            default:
                break;
            }
        }
    }

    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            DDLogVerbose(@"playbackBufferEmpty: %@",
                         self.playerItem.isPlaybackBufferEmpty ? @"yes"
                                                               : @"no");
            if (self.playerItem.isPlaybackBufferEmpty &&
                [self currentTime] > 0 &&
                [self currentTime] < [self.player currentItemDuration] - 1 &&
                self.state == VKVideoPlayerStateContentPlaying) {
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:kVKVideoPlayerPlaybackBufferEmpty
                                  object:nil];
            }
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            DDLogVerbose(@"playbackLikelyToKeepUp: %@",
                         self.playerItem.playbackLikelyToKeepUp ? @"yes"
                                                                : @"no");
            if (self.playerItem.playbackLikelyToKeepUp) {
                if (self.state == VKVideoPlayerStateContentPlaying &&
                    ![self isPlayingVideo]) {
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:
                            kVKVideoPlayerPlaybackLikelyToKeepUp
                                      object:nil];
                    [self.player play];
                }
            }
        }

        if ([keyPath isEqualToString:@"status"]) {
            switch ([self.playerItem status]) {
            case AVPlayerItemStatusReadyToPlay:
                DDLogVerbose(@"AVPlayerItemStatusReadyToPlay");
                // TODO: byzm 有bug
                if ([self.avPlayer status] == AVPlayerStatusReadyToPlay) {
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:kVKVideoPlayerItemReadyToPlay
                                      object:nil];
                }
                break;
            case AVPlayerItemStatusFailed:
                DDLogVerbose(@"AVPlayerItemStatusFailed");
                [self handleErrorCode:kVideoPlayerErrorAVPlayerItemFail
                                track:self.track];
            default:
                break;
            }
        }
    }
}

#pragma mark - Ad State Support
- (BOOL)beginAdPlayback {
    switch (self.state) {
    case VKVideoPlayerStateDismissed:
    case VKVideoPlayerStateError:
        // Do not play ad in these states
        return NO;
    case VKVideoPlayerStateContentPlaying:
        [self pauseContent];
    case VKVideoPlayerStateContentLoading:
    case VKVideoPlayerStateContentPaused:
        self.state = VKVideoPlayerStateSuspended;
        return YES;
    default:
        return NO;
    }
}

- (BOOL)endAdPlayback {
    if (self.state == VKVideoPlayerStateSuspended) {
        [self pauseContent];
        [self playContent];
        return YES;
    }
    return NO;
}

#pragma mark - Controls

- (NSString *)playerStateDescription:(VKVideoPlayerState)playerState {
    switch (playerState) {
    case VKVideoPlayerStateUnknown:
        return @"Unknown";
        break;
    case VKVideoPlayerStateContentLoading:
        return @"ContentLoading";
        break;
    case VKVideoPlayerStateContentPaused:
        return @"ContentPaused";
        break;
    case VKVideoPlayerStateContentPlaying:
        return @"ContentPlaying";
        break;
    case VKVideoPlayerStateSuspended:
        return @"Player Stay";
        break;
    case VKVideoPlayerStateDismissed:
        return @"Player Dismissed";
        break;
    case VKVideoPlayerStateError:
        return @"Player Error";
        break;
    }
}

- (void)setState:(VKVideoPlayerState)newPlayerState {
    if ([self.delegate
            respondsToSelector:@selector(shouldVideoPlayer:changeStateTo:)]) {
        if (![self.delegate shouldVideoPlayer:self
                                changeStateTo:newPlayerState]) {
            return;
        }
    }
    RUN_ON_UI_THREAD(^{
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:willChangeStateTo:)]) {
            [self.delegate videoPlayer:self willChangeStateTo:newPlayerState];
        }

        VKVideoPlayerState oldPlayerState = self.state;
        if (oldPlayerState == newPlayerState)
            return;

        switch (oldPlayerState) {
        case VKVideoPlayerStateContentLoading:
            [self setLoading:NO];
            break;
        case VKVideoPlayerStateContentPlaying:
            break;
        case VKVideoPlayerStateContentPaused:
            // TODO: byzm 暂停时的遮罩
            self.view.bigPlayButton.hidden = YES;
            self.view.bigPlayBGView.hidden = YES;

            break;
        case VKVideoPlayerStateDismissed:
            break;
        case VKVideoPlayerStateError:
            self.view.messageLabel.hidden = YES;
            break;
        default:
            break;
        }

        DDLogVerbose(@"Player State: %@ -> %@",
                     [self playerStateDescription:self.state],
                     [self playerStateDescription:newPlayerState]);
        _state = newPlayerState;

        // TODO: byzm 先隐藏错误
        self.view.failedView.hidden = YES;

        switch (newPlayerState) {
        case VKVideoPlayerStateUnknown:
            break;
        case VKVideoPlayerStateContentLoading:
            [self setLoading:YES];
            self.playerControlsEnabled = NO;
            break;
        case VKVideoPlayerStateContentPlaying: {
            self.view.controlHideCountdown = kPlayerControlsAutoHideTime;
            self.playerControlsEnabled = YES;
            [self.view setPlayButtonsSelected:NO];
            self.view.playerLayerView.hidden = NO;
            self.view.captionBottomView.hidden = NO;
            self.view.captionTopContainerView.hidden = NO;
            self.view.messageLabel.hidden = YES;
            self.view.externalDeviceView.hidden =
                ![self isPlayingOnExternalDevice];
        } break;
        case VKVideoPlayerStateContentPaused:
            self.playerControlsEnabled = YES;
            [self.view setPlayButtonsSelected:YES];
            self.view.playerLayerView.hidden = NO;
            self.view.captionBottomView.hidden = NO;
            self.view.captionTopContainerView.hidden = NO;
            self.track.lastDurationWatchedInSeconds =
                [NSNumber numberWithFloat:[self currentTime]];
            // TODO: byzm 暂停时的遮罩
            self.view.bigPlayButton.hidden = NO;
            self.view.bigPlayBGView.hidden = NO;

            self.view.messageLabel.hidden = YES;
            self.view.externalDeviceView.hidden =
                ![self isPlayingOnExternalDevice];
            break;
        case VKVideoPlayerStateSuspended:
            break;
        case VKVideoPlayerStateError: {
            self.view.failedView.hidden = NO;
            self.view.externalDeviceView.hidden = YES;
            self.view.playerLayerView.hidden = YES;
            self.playerControlsEnabled = NO;
            // TODO: byzm 失败时隐藏messageLabel
            //            self.view.messageLabel.hidden = NO;
            self.view.messageLabel.hidden = YES;
            self.view.controlHideCountdown = kPlayerControlsDisableAutoHide;
            break;
        }
        case VKVideoPlayerStateDismissed:
            self.view.playerLayerView.hidden = YES;
            self.playerControlsEnabled = NO;
            [self clearPlayer];
            break;
        }

        if ([self.delegate respondsToSelector:@selector(videoPlayer:
                                                  didChangeStateFrom:)]) {
            [self.delegate videoPlayer:self didChangeStateFrom:oldPlayerState];
        }
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kVKVideoPlayerStateChanged
                          object:nil
                        userInfo:@{
                            @"oldState" :
                                [NSNumber numberWithInteger:oldPlayerState],
                            @"newState" :
                                [NSNumber numberWithInteger:newPlayerState]
                        }];
    });
}

- (void)playContent {
    if (self.state == VKVideoPlayerStateContentPaused && self.isReadyToPlay) {
        [self.player play];
        self.state = VKVideoPlayerStateContentPlaying;
    }
}

- (void)pauseContent {
    [self pauseContent:NO completionHandler:nil];
}

- (void)pauseContentWithCompletionHandler:(void (^)())completionHandler {
    [self pauseContent:NO completionHandler:completionHandler];
}

- (void)pauseContent:(BOOL)isUserAction
    completionHandler:(void (^)())completionHandler {

    RUN_ON_UI_THREAD(^{

        switch ([self.playerItem status]) {
        case AVPlayerItemStatusFailed:
            [self.player pause];
            self.state = VKVideoPlayerStateError;
            return;
            break;
        case AVPlayerItemStatusUnknown:
            DDLogVerbose(
                @"Trying to pause content but AVPlayerItemStatusUnknown.");
            // TODO: byzm
            // 如果AVURLAsset正在加载此时Pause视频则state状态应该为loading
            //            self.state = VKVideoPlayerStateUnknown;
            if (self.state != VKVideoPlayerStateContentLoading) {
                self.state = VKVideoPlayerStateUnknown;
            }
            return;
            break;
        default:
            break;
        }

        switch ([self.avPlayer status]) {
        case AVPlayerStatusFailed:
            [self.player pause];
            self.state = VKVideoPlayerStateError;
            return;
            break;
        case AVPlayerStatusUnknown:
            DDLogVerbose(@"Trying to pause content but AVPlayerStatusUnknown.");
            self.state = VKVideoPlayerStateUnknown;
            return;
            break;
        default:
            break;
        }

        switch (self.state) {
        case VKVideoPlayerStateContentLoading:
        case VKVideoPlayerStateContentPlaying:
        case VKVideoPlayerStateContentPaused:
        case VKVideoPlayerStateSuspended:
        case VKVideoPlayerStateError:
            [self.player pause];
            // TODO: byzm 解决不能断点续播问题
            //        self.state = VKVideoPlayerStateContentPaused;
            if (completionHandler)
                completionHandler();
            self.state = VKVideoPlayerStateContentPaused;
            break;

        default:
            break;
        }
    });
}

- (void)setPlayerControlsEnabled:(BOOL)enabled {
    [self.view setControlsEnabled:enabled];
}

- (void)updateTrackControls {
    RUN_ON_UI_THREAD(^{
        if (self.view.isControlsEnabled) {
            self.view.previousButton.enabled = self.track.hasPrevious;
            self.view.nextButton.enabled = self.track.hasNext;
        }
    });
}

- (void)dismiss {
    self.state = VKVideoPlayerStateDismissed;
}

#pragma mark - VKScrubberDelegate

- (void)scrubbingBegin {

    // TODO: byzm
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate
                respondsToSelector:@selector(videoPlayerScrubbingBegin:)]) {
            [self.delegate videoPlayerScrubbingBegin:self];
        }
    });

    [self pauseContent:NO
        completionHandler:^{
            _scrubbing = YES;
            self.view.controlHideCountdown = -1;
            _beforeSeek = [self currentTime];
        }];
}

- (void)scrubbingEnd {
    // TODO: byzm
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate
                respondsToSelector:@selector(videoPlayerScrubbingEnd:)]) {
            [self.delegate videoPlayerScrubbingEnd:self];
        }
    });

    _scrubbing = NO;
    self.state = VKVideoPlayerStateContentLoading;
    float afterSeekTime = self.view.scrubber.value;

    __weak VKVideoPlayer *weakSelf = self;

    [self scrubbingEndAtSecond:afterSeekTime
                    userAction:YES
             completionHandler:^(BOOL finished) {

                 if (finished) {
                     // TODO: byzm 解决快进不能播放问题
                     weakSelf.state = VKVideoPlayerStateContentPaused;
                     [self playContent];
                 }
             }];
}

- (void)zoomInPressed {
    ((AVPlayerLayer *)self.view.layer).videoGravity =
        AVLayerVideoGravityResizeAspectFill;
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
        self.view.frame = self.view.frame;
    }
}

- (void)zoomOutPressed {
    ((AVPlayerLayer *)self.view.layer).videoGravity =
        AVLayerVideoGravityResizeAspect;
    if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"5"]) {
        self.view.frame = self.view.frame;
    }
}

#pragma mark - VKVideoPlayerViewDelegate
- (id<VKVideoPlayerTrackProtocol>)videoTrack {
    return self.track;
}

- (void)videoQualityButtonTapped {
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapVideoQuality];
    }
}

- (void)fullScreenButtonTapped {
    self.isFullScreen = self.view.fullscreenButton.selected;

    if (self.isFullScreen) {
        [self performOrientationChange:UIInterfaceOrientationLandscapeRight];
    } else {
        [self performOrientationChange:UIInterfaceOrientationPortrait];
    }

    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapFullScreen];
    }
}

- (void)captionButtonTapped {
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapCaption];
    }
}

- (void)playButtonPressed {
    [self playContent];
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapPlay];
    }
}

- (void)pauseButtonPressed {
    switch (self.state) {
    case VKVideoPlayerStateContentPlaying:
        [self pauseContent:YES completionHandler:nil];
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
            [self.delegate videoPlayer:self
                     didControlByEvent:VKVideoPLayerControlEventTapPause];
        }
        break;
    default:
        break;
    }
}

- (void)nextTrackButtonPressed {
    if (self.track.hasNext) {
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
            [self.delegate videoPlayer:self
                     didControlByEvent:VKVideoPlayerControlEventTapNext];
        }
    }
}

- (void)previousTrackButtonPressed {
    if (self.track.hasPrevious) {
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
            [self.delegate videoPlayer:self
                     didControlByEvent:VKVideoPlayerControlEventTapPrevious];
        }
    }
}

- (void)nextTrackBySwipe {
    if (self.track.hasNext) {
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
            [self.delegate videoPlayer:self
                     didControlByEvent:VKVideoPlayerControlEventSwipeNext];
        }
    }
}

- (void)previousTrackBySwipe {
    if (self.track.hasPrevious) {
        if ([self.delegate
                respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
            [self.delegate videoPlayer:self
                     didControlByEvent:VKVideoPlayerControlEventSwipePrevious];
        }
    }
}

- (void)rewindButtonPressed {

    float seekToTime = [self currentTime] - 30;
    [self seekToTimeInSecond:seekToTime
                  userAction:YES
           completionHandler:^(BOOL finished) {
               if (finished)
                   [self playContent];
           }];
}

- (void)doneButtonTapped {
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapDone];
    }
}

- (void)playerViewSingleTapped {
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapPlayerView];
    }
}

- (void)presentSubtitleLangaugePickerFromButton:(VKPickerButton *)button {
    if ([self.delegate
            respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self
                 didControlByEvent:VKVideoPlayerControlEventTapDone];
    }
}

// TODO: byzm
- (void)reloadPlayButtonTapped {
    [self reloadCurrentVideoTrack];
}

- (void)layoutNavigationAndStatusBarForOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    [[UIApplication sharedApplication]
        setStatusBarOrientation:interfaceOrientation
                       animated:NO];
}

#pragma mark - Auto hide controls

- (void)setForceRotate:(BOOL)forceRotate {
    if (_forceRotate != forceRotate) {
        _forceRotate = forceRotate;
    }

    // TODO: byzm
    // 不隐藏全屏按钮，这样在旋转的时候bottomControlOverlay里的控件布局会有重叠情况
    //    self.view.fullscreenButton.hidden = !self.forceRotate;
    self.view.fullscreenButton.hidden = NO;
}

- (void)setLoading:(BOOL)loading {
    [self.view setLoading:loading];
}

#pragma mark - Handle volume change

- (void)volumeChanged:(NSNotification *)notification {
    self.view.controlHideCountdown = kPlayerControlsAutoHideTime;
}

#pragma mark - Remote Control Events handler

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [self playButtonPressed];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pauseButtonPressed];
        case UIEventSubtypeRemoteControlStop:
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self nextTrackButtonPressed];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previousTrackButtonPressed];
            break;
        case UIEventSubtypeRemoteControlBeginSeekingForward:
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self scrubbingBegin];
            break;
        case UIEventSubtypeRemoteControlEndSeekingForward:
        case UIEventSubtypeRemoteControlEndSeekingBackward:
            self.view.scrubber.value = receivedEvent.timestamp;
            [self scrubbingEnd];
            break;
        default:
            break;
        }
    }
}

- (DTCSSStylesheet *)captionStyleSheet:(NSString *)color {
    float fontSize = 1.3f;
    float shadowSize = 1.0f;

    switch (
        [[VKSharedUtility setting:kVKSettingsSubtitleSizeKey] integerValue]) {
    case 1:
        fontSize = 1.5f;
        break;
    case 2:
        fontSize = 2.0f;
        shadowSize = 1.2f;
        break;
    case 3:
        fontSize = 3.5f;
        shadowSize = 1.5f;
        break;
    }

    DTCSSStylesheet *stylesheet = [[DTCSSStylesheet alloc]
        initWithStyleBlock:
            [NSString stringWithFormat:@"body{\
    text-align: center;\
    font-size: %fem;\
    font-family: Helvetica Neue;\
    font-weight: bold;\
    color: %@;\
    text-shadow: -%fpx -%fpx %fpx #000, %fpx -%fpx %fpx #000, -%fpx %fpx %fpx #000, %fpx %fpx %fpx #000;\
    vertical-align: bottom;\
    }",
                                       fontSize, color, shadowSize, shadowSize,
                                       shadowSize, shadowSize, shadowSize,
                                       shadowSize, shadowSize, shadowSize,
                                       shadowSize, shadowSize, shadowSize,
                                       shadowSize]];
    return stylesheet;
}

- (void)clearCaptionView:(DTAttributedLabel *)captionView {
    [captionView
        setAttributedString:
            [[NSAttributedString alloc]
                  initWithHTMLData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                           options:nil
                documentAttributes:NULL]];
}

- (CGFloat)captionPadding:(DTAttributedLabel *)captionView {
    CGFloat aspectRatio = self.playerItem.presentationSize.width /
                          self.playerItem.presentationSize.height;
    if (isnan(aspectRatio)) {
        return 0.0f;
    }
    CGFloat activePlayerViewWidth =
        CGRectGetWidth([self activePlayerView].frame);
    CGFloat videoHeight = activePlayerViewWidth / aspectRatio;
    CGFloat padding =
        (CGRectGetHeight([self activePlayerView].frame) - videoHeight) / 2;

    if ([self activePlayerView] == self.view) {
        if (captionView.tag == VKVideoPlayerCaptionPositionBottom &&
            !self.view.isControlsHidden) {
            padding = MAX(CGRectGetHeight(self.view.bottomControlOverlay.frame),
                          padding);
        }
    }

    return MAX(padding, 0.0f);
}

- (void)updateCaptionView:(DTAttributedLabel *)captionView
                  caption:(id<VKVideoPlayerCaptionProtocol>)caption
               playerView:(VKVideoPlayerView *)playerView {
    float timeInSeconds = CMTimeGetSeconds([self.player currentCMTime]);
    float timeInMilliseconds = timeInSeconds * 1000;
    NSString *html = [caption contentAtTime:timeInMilliseconds];
    int padding = VKCaptionPadding;
    CGFloat extraPadding = [self captionPadding:captionView];
    NSString *color = nil;
    if (captionView.tag == VKVideoPlayerCaptionPositionTop) {
        color = @"#CCC";
        [captionView setFrameHeight:CGRectGetHeight(playerView.frame)];
    } else {
        color = @"#FFF";
        captionView.frame = CGRectMake(
            padding, padding, playerView.frame.size.width - padding * 2,
            playerView.frame.size.height - padding - extraPadding);
    }

    NSMutableDictionary *options =
        [NSMutableDictionary dictionaryWithObject:[self captionStyleSheet:color]
                                           forKey:DTDefaultStyleSheet];
    NSAttributedString *string = [[NSAttributedString alloc]
          initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]
                   options:options
        documentAttributes:NULL];
    captionView.attributedString = string;
    captionView.isAccessibilityElement = YES;
    captionView.accessibilityLabel = [html stripHtml];

    if (captionView.tag == VKVideoPlayerCaptionPositionTop) {
        [captionView setFrameOriginY:padding + extraPadding];
        DDLogVerbose(@"Set top caption: %@", [html stripHtml]);
    } else if (captionView.tag == VKVideoPlayerCaptionPositionBottom) {
        [captionView sizeToFit];
        captionView.center = CGPointMake(playerView.frame.size.width * 0.5f,
                                         captionView.center.y);
        [captionView setFrameOriginY:playerView.frame.size.height -
                                     captionView.frame.size.height - padding -
                                     extraPadding];
        DDLogVerbose(@"Set bottom caption: %@", [html stripHtml]);
    }

    [playerView.captionTopContainerView
        setFrameHeight:MIN(playerView.captionBottomView.frame.origin.y -
                               padding,
                           playerView.captionTopView.frame.size.height +
                               padding + extraPadding)];
}

- (void)setCaptionToBottom:(id<VKVideoPlayerCaptionProtocol>)caption {
    [self setCaptionToBottom:caption playerView:[self activePlayerView]];
}

- (void)setCaptionToBottom:(id<VKVideoPlayerCaptionProtocol>)caption
                playerView:(VKVideoPlayerView *)playerView {
    [self setCaption:caption
        toCaptionView:playerView.captionBottomView
           playerView:playerView];
}

- (void)setCaptionToTop:(id<VKVideoPlayerCaptionProtocol>)caption {
    [self setCaptionToTop:caption playerView:[self activePlayerView]];
}
- (void)setCaptionToTop:(id<VKVideoPlayerCaptionProtocol>)caption
             playerView:(VKVideoPlayerView *)playerView {
    [self setCaption:caption
        toCaptionView:playerView.captionTopView
           playerView:playerView];
}

#pragma mark - Orientation
- (void)orientationChanged:(NSNotification *)note {
    UIDevice *device = note.object;

    UIInterfaceOrientation rotateToOrientation;
    switch (device.orientation) {
    case UIDeviceOrientationPortrait:
        DDLogVerbose(@"ORIENTATION: Portrait");
        rotateToOrientation = UIInterfaceOrientationPortrait;
        break;
    case UIDeviceOrientationPortraitUpsideDown:
        DDLogVerbose(@"ORIENTATION: PortraitDown");
        rotateToOrientation = UIInterfaceOrientationPortraitUpsideDown;
        break;
    case UIDeviceOrientationLandscapeLeft:
        DDLogVerbose(@"ORIENTATION: LandscapeRight");
        rotateToOrientation = UIInterfaceOrientationLandscapeRight;
        break;
    case UIDeviceOrientationLandscapeRight:
        DDLogVerbose(@"ORIENTATION: LandscapeLeft");
        rotateToOrientation = UIInterfaceOrientationLandscapeLeft;
        break;
    default:
        rotateToOrientation = self.visibleInterfaceOrientation;
        break;
    }

    if ((1 << rotateToOrientation) & self.supportedOrientations &&
        rotateToOrientation != self.visibleInterfaceOrientation) {
        [self performOrientationChange:rotateToOrientation];
    }
}

- (void)performOrientationChange:(UIInterfaceOrientation)deviceOrientation {
    if (!self.forceRotate) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(videoPlayer:
                                              willChangeOrientationTo:)]) {
        [self.delegate videoPlayer:self
            willChangeOrientationTo:deviceOrientation];
    }

    CGFloat degrees = [self degreesForOrientation:deviceOrientation];
    __weak __typeof__(self) weakSelf = self;

    // TODO: byzm view会莫名其妙上移
    if (self.visibleInterfaceOrientation == UIDeviceOrientationUnknown &&
        deviceOrientation == UIDeviceOrientationPortrait) {
        return;
    }

    UIInterfaceOrientation lastOrientation = self.visibleInterfaceOrientation;
    self.visibleInterfaceOrientation = deviceOrientation;

    // TODO: byzm
    weakSelf.forceRotate = NO;
    weakSelf.view.backgroundColor = [UIColor clearColor];

    [UIView animateWithDuration:0.3f
        animations:^{
            // TODO: byzm
            // iOS8 中UIScreen 的尺寸和方向相关
            //            CGRect bounds = [[UIScreen mainScreen] bounds];
            CGRect bounds =
                [UIScreen kkb_screenBoundsFixedToPortraitOrientation];
            CGRect parentBounds;
            CGRect viewBoutnds;
            if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
                viewBoutnds =
                    CGRectMake(0, 0, CGRectGetWidth(self.landscapeFrame),
                               CGRectGetHeight(self.landscapeFrame));
                parentBounds = CGRectMake(0, 0, CGRectGetHeight(bounds),
                                          CGRectGetWidth(bounds));
            } else {
                viewBoutnds =
                    CGRectMake(0, 0, CGRectGetWidth(self.portraitFrame),
                               CGRectGetHeight(self.portraitFrame));
                parentBounds = CGRectMake(0, 0, CGRectGetWidth(bounds),
                                          CGRectGetHeight(bounds));
            }

            weakSelf.view.superview.transform =
                CGAffineTransformMakeRotation(degreesToRadians(degrees));
            weakSelf.view.superview.bounds = parentBounds;
            [weakSelf.view.superview setFrameOriginX:0.0f];
            [weakSelf.view.superview setFrameOriginY:0.0f];

            CGRect wvFrame = weakSelf.view.superview.superview.frame;
            if (wvFrame.origin.y > 0) {
                wvFrame.size.height = CGRectGetHeight(bounds);
                wvFrame.origin.y = 0;
                weakSelf.view.superview.superview.frame = wvFrame;
            }

            weakSelf.view.bounds = viewBoutnds;
            [weakSelf.view setFrameOriginX:0.0f];
            [weakSelf.view setFrameOriginY:0.0f];

            // TODO: byzm 旋转时，时间布局有问题
            //    [weakSelf.view layoutForOrientation:deviceOrientation];
        }
        completion:^(BOOL finished) {
            // TODO: byzm
            weakSelf.forceRotate = YES;
            weakSelf.view.backgroundColor = [UIColor blackColor];

            if ([self.delegate
                    respondsToSelector:@selector(videoPlayer:
                                           didChangeOrientationFrom:)]) {
                [self.delegate videoPlayer:self
                    didChangeOrientationFrom:lastOrientation];
            }

            // TODO: byzm
            if ([self.delegate respondsToSelector:@selector(videoPlayer:
                                                      didChangeOrientation:)]) {
                [self.delegate videoPlayer:self
                      didChangeOrientation:deviceOrientation];
            }
        }];

    [[UIApplication sharedApplication]
        setStatusBarOrientation:self.visibleInterfaceOrientation
                       animated:YES];
    [self updateCaptionView:self.view.captionBottomView
                    caption:self.captionBottom
                 playerView:self.view];
    [self updateCaptionView:self.view.captionTopView
                    caption:self.captionTop
                 playerView:self.view];
    self.view.fullscreenButton.selected = self.isFullScreen =
        UIInterfaceOrientationIsLandscape(deviceOrientation);
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

// TODO: byzm
- (UIImage *)loadCurrentVideoThumbnail {
    if (self.state == VKVideoPlayerStateContentPlaying ||
        self.state == VKVideoPlayerStateContentPaused) {

        if (!self.urlAsset) {
            return nil;
        }

        AVAssetImageGenerator *imageGenerator =
            [[AVAssetImageGenerator alloc] initWithAsset:self.urlAsset];
        imageGenerator.appliesPreferredTrackTransform = YES;

        NSError *error = nil;
        CMTime actualTime;

        CGImageRef image =
            [imageGenerator copyCGImageAtTime:[self.player currentCMTime]
                                   actualTime:&actualTime
                                        error:&error];
        if (error) {
            DDLogError(@"VideoThumbnail err:%@", [error debugDescription]);
            return nil;
        }

        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    }

    return nil;
}

@end

@implementation AVPlayer (VKPlayer)

- (void)seekToTimeInSeconds:(float)time
          completionHandler:(void (^)(BOOL finished))completionHandler {
    if ([self respondsToSelector:@selector(seekToTime:
                                       toleranceBefore:
                                        toleranceAfter:
                                     completionHandler:)]) {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1)
              toleranceBefore:kCMTimeZero
               toleranceAfter:kCMTimeZero
            completionHandler:completionHandler];
    } else {
        [self seekToTime:CMTimeMakeWithSeconds(time, 1)
            toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero];
        completionHandler(YES);
    }
}

- (NSTimeInterval)currentItemDuration {
    return CMTimeGetSeconds([self.currentItem duration]);
}

- (CMTime)currentCMTime {
    return [self currentTime];
}

@end
