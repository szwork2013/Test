
//
//  PlayerFrameView.m
//  learn
//
//  Created by zxj on 14-6-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "PlayerFrameView.h"
#import <QuartzCore/QuartzCore.h>
#import "KKBMoviePlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CourseUnitOperator.h"
#import "GlobalOperator.h"
#import "UIImageView+WebCache.h"
#import "AppUtilities.h"
#import "HomePageStructs.h"
#import "JSONKit.h"
#import "MobClick.h"
#import "VKVideoPlayer.h"
#import "UIView+GetNextResponder.h"
#import "KKBUserInfo.h"
#import "KKBDataBase.h"
#import "KKBUploader.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;

const CGFloat playbtnWidth = 70.f;
const CGFloat playbtnHeight = 70.f;
@interface PlayerFrameView () {
}

@property(nonatomic, retain) KKBMoviePlayerController *moviePlayer;

@end

@implementation PlayerFrameView {
    float startTime;
    float endTime;

    float seekFrom;
    float seekTo;
    float view;
}

@synthesize courseState;
@synthesize moviePlayer;
@synthesize imageURL;
@synthesize strCourseID;
@synthesize videoUrl;
@synthesize strUrl;
@synthesize promoVideoStr;
@synthesize codeDic;
@synthesize html;
@synthesize playView;
@synthesize isTheLastMovie;
@synthesize itemID, moduleID, userID, courseName;
@synthesize videoUrlArray, currentVideoUrl;
@synthesize playerFrameDelegate;
@synthesize videoTitleArray;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self initPlayerFrameView];
        [self initControls];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPlayerFrameView];
        [self initControls];
    }
    return self;
}

- (void)initPlayerFrameView {
    self.courseState = -1;
    videoTitleArray = [[NSMutableArray alloc] init];
}

- (KKBMoviePlayerController *)getMoviePlayer {
    if (self.moviePlayer) {
        return self.moviePlayer;
    }
    return nil;
}

//初始化界面界面控件
- (void)initControls {
    //    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,
    //    180)];
    //
    //    [self addSubview:self.playView];
    //    loadingView_ = [[UIActivityIndicatorView alloc]
    //    initWithFrame:CGRectMake(0.f, 0.f, 30, 30)];
    //    loadingView_.center = self.playView.center;
    courseImageView_ = [[UIImageView alloc] init];
    [courseImageView_ setFrame:CGRectMake(0, 0, 320, 180)];
    [courseImageView_ setTag:10000];

    //播放按钮
    //    btnPlay_ = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPlay_ = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPlay_.tag = 10001;
    [btnPlay_ setFrame:CGRectMake(0.0, 0.0, playbtnWidth, playbtnHeight)];
    [btnPlay_ setImage:[UIImage imageNamed:@"button_play"]
              forState:UIControlStateNormal];
    //    btnPlay_.center = self.center;
    btnPlay_.center = CGPointMake(160, 90);
    [btnPlay_ addTarget:self
                  action:@selector(playMovieAtURL)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:courseImageView_];
    [self addSubview:btnPlay_];
}

- (void)initImage {
    NSLog(@"%@", self.imageURL);

    [courseImageView_
        sd_setImageWithURL:
            [NSURL
                URLWithString:[AppUtilities adaptImageURLforPhone:self.imageURL]]
          placeholderImage:[UIImage imageNamed:@"allcourse_cover_default"]];
    //    courseImageView_.contentMode = UIViewContentModeRedraw;
    courseImageView_.contentMode = UIViewContentModeScaleToFill;
}

//- (void)enterFullScreen:(NSNotification*)notification
//{
//
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(exitFullScreen:)
//                                                 name:MPMoviePlayerDidExitFullscreenNotification
//                                               object:self.moviePlayer];
//
//}
//- (void)movieFinishedCallBack:(NSNotification*)notification
//{
//    [self stopMovie];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (float)getCurrentPlaybackTime {
    return self.moviePlayer.currentPlaybackTime;
}

- (NSString *)getPromoVideoStr {
    return self.promoVideoStr;
}

- (void)videoPlayEvent {
    NSString *user_id = self.userID;
    NSString *course_id = self.strCourseID;
    NSString *module_id = self.moduleID;
    NSString *item_id = self.itemID;
    NSString *course_name = self.courseName;
    int playtime = endTime - startTime;
    NSString *strPlaytime = [NSString stringWithFormat:@"%d", playtime];
    if (module_id == nil) {
        module_id = @"";
    }
    if (item_id == nil) {
        item_id = @"";
    }
    if (course_id == nil) {
        course_id = @"";
    }
    if (user_id == nil) {
        user_id = @"";
    }
    if (course_name == nil) {
        course_name = @"";
    }
    NSDictionary *dict = @{
        @"user_id" : user_id,
        @"course_id" : course_id,
        @"module_id" : module_id,
        @"item_id" : item_id,
        @"course_name" : course_name,
        @"play_time" : strPlaytime
    };
    //    NSDictionary *dict = @{@"user_id" : @"1234567",@"course_id" :
    //    @"111111",@"module_id" : @"111111",@"item_id" :
    //    @"1111111",@"play_time" : strPlaytime};

    if (playtime > 0) {
        NSLog(@"事件触发");
        [MobClick event:@"video_play" attributes:dict];
    }
}

//视频播放
- (IBAction)playMovieAtURL {
    /////
    ///如果该video已经下载，那么不管用户是在什么网络情况下（3G或者没有wifi），都不用提示用户以下信息
    BOOL alreadyInCache = [self.promoVideoStr hasPrefix:@"file://"];
    if (alreadyInCache) {
        [self continueWatchTheVideo];
        return;
    }

    if ([AppUtilities isExistenceNetwork]) {
        // 存在网络
        if ([AppUtilities IsEnableWIFI]) {
            [self continueWatchTheVideo];
        } else {
            UIAlertView *noWifi = [[UIAlertView alloc]
                    initWithTitle:@"提示"
                          message:@"您没有连接Wifi，确定要看视频么"
                         delegate:self
                cancelButtonTitle:@"取消观看视频"
                otherButtonTitles:@"继续观看视频", nil];
            noWifi.tag = 100001;
            [noWifi show];
        }
    } else {
        UIAlertView *noNetwork = [[UIAlertView alloc]
                initWithTitle:@"提示"
                      message:@"无网络连接，无法播放视频"
                     delegate:self
            cancelButtonTitle:@"取消观看"
            otherButtonTitles:@"请连接网络", nil];
        noNetwork.tag = 100000;
        [noNetwork show];
    }
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100001) {
        if (buttonIndex == 1) {
            [self continueWatchTheVideo];
        }
    }
}

- (void)continueWatchTheVideo {

    //[self stopMovie];
    if (self.player != nil) {
        [self.player pauseContent];
    }

    [self courseImageViewIsHidden:YES andBtnPlayIsHidden:YES];

    [playView setBackgroundColor:[UIColor blackColor]];
    NSURL *url;

    url = [NSURL URLWithString:promoVideoStr];

    self.player = [[VKVideoPlayer alloc] init];
    self.player.delegate = self;
    // player.view.frame = self.bounds;
    self.player.view.frame = CGRectMake(0, 0, 320, 180);
    self.player.forceRotate = YES;

    [self.player.view.nextButton setHidden:YES];

    // self.moviePlayer = [[KKBMoviePlayerController alloc]
    // initWithContentURL:url];

    // self.moviePlayer.view.tag = 10002;

    //    self.moviePlayer.movieSourceType=MPMovieSourceTypeFile;

    //[self.moviePlayer.view setFrame:CGRectMake(0, 0,320, 180)];
    //    theMoviePlayer.initialPlaybackTime = -1;
    // self.moviePlayer.endPlaybackTime = -1;
    //[self.playView addSubview:self.moviePlayer.view];
    [self addSubview:self.player.view];
    //[self.playView addSubview:player.view];
    //[self addSubview:player.view];
    //[self.playView addSubview:loadingView_];
    //[loadingView_ startAnimating];

    NSLog(@"%f", self.playRecordDuration);
    float playbackPosition = [self getPlaybackPosition];
    startTime = playbackPosition;

    // add seek to
    seekTo = startTime;

    NSNumber *playDuration =
        (NSNumber *)[NSString stringWithFormat:@"%f", playbackPosition];
    //    [self.player.track setLastDurationWatchedInSeconds:playDuration];

    //        [self.player seekToLastWatchedDuration];
    // NSLog(@"%@", [[self.player track] lastDurationWatchedInSeconds]);

    VKVideoPlayerTrack *track =
        [[VKVideoPlayerTrack alloc] initWithStreamURL:url];
    [track setLastDurationWatchedInSeconds:playDuration];
    track.hasNext = YES;
    [self.player loadVideoWithTrack:track];

    //    [self.player seekToTimeInSecond:playbackPosition
    //                         userAction:YES
    //                  completionHandler:^(BOOL finished) {
    //
    //                      DDLogDebug(@"currentTime %f", [self.player
    //                      currentTime]);
    //                      DDLogDebug(@"seekTo Finished");
    //                  }];

    //    [self.moviePlayer setInitialPlaybackTime:playbackPosition];
    //    [self.moviePlayer prepareToPlay];

    // added by guojun
    //    float playbackPosition = [self getPlaybackPosition];
    //    startTime = playbackPosition;
    //    [self.moviePlayer setInitialPlaybackTime:playbackPosition];
    //    [self.moviePlayer prepareToPlay];
    //    [self.moviePlayer play];

    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(movieFinished:)
    //                                                 name:MPMoviePlayerPlaybackDidFinishNotification
    //                                               object:self.moviePlayer];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(enterFullScreen:)
    //                                                 name:MPMoviePlayerDidEnterFullscreenNotification
    //                                               object:self.moviePlayer];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(playbackStateDidChange:)
    //                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
    //                                               object:self.moviePlayer];
}

//- (void) movieFinished:(NSNotification *) notification{
//    NSLog(@"Play Next video");
//
//    [self stopMovie];
//[self savePlaybackPosition:0];
//    [self exitFullScreen:nil];
//    [loadingView_ stopAnimating];
//    [self courseImageViewIsHidden:NO andBtnPlayIsHidden:NO];
//}

//- (void) exitFullScreen:(NSNotification *) notification{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:self.moviePlayer];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerDidExitFullscreenNotification
//                                                  object:self.moviePlayer];
//    self.moviePlayer.fullscreen = NO;
//    if (self.hiddenMode) {
//        self.moviePlayer.view.hidden = YES;
//        self.frame = CGRectZero;
//    }
//    [self.moviePlayer.view removeFromSuperview];
//}

//- (void) playbackStateDidChange:(NSNotification *) notification{
//    [loadingView_ stopAnimating];
//
//    NSLog(@"Fast forward/Fast rewind");
//}

- (float)getPlaybackPosition {
    NSString *key = self.promoVideoStr;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    float playbackPosition = [prefs floatForKey:key];

    return playbackPosition;
}

- (void)savePlaybackPosition:(float)playbackPosition {
    NSString *key = self.promoVideoStr;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:playbackPosition forKey:key];
}

//- (void)playingDidChange
//{
//    [loadingView_ stopAnimating];
// add
//    count++;
//    if(count == 2)
//    {
//        btnPlay_.hidden = NO;
//        courseImageView_.hidden = NO;
//    }
// end
//}
//- (void)myMoviebeginPlay
//{
//    [loadingView_ stopAnimating];
//    [loadingView_ removeFromSuperview];
//    NSLog(@"开始播放");
//}
//- (void)myMovieFinishedCallback:(NSNotification *)notify
//{
//    [self stopMovie];
//视频播放对象
//    KKBMoviePlayerController *theMoviePlayer = [notify object];

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                name:MPMoviePlayerDidEnterFullscreenNotification
//                                                  object:theMoviePlayer];
//    if (isTheLastMovie == YES) {
//        // 销毁播放通知
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                      object:theMoviePlayer];
//        theMoviePlayer.fullscreen = NO;
//        if (theMoviePlayer.fullscreen == NO) {
//            [self courseImageViewIsHidden:NO andBtnPlayIsHidden:NO];
//        }
//        [theMoviePlayer.view removeFromSuperview];
//        // 释放视频对象
//        //    [theMoviePlayer release];
//        self.moviePlayer = nil;
//    } else {
//        // add
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                      object:theMoviePlayer];
//        theMoviePlayer.fullscreen = NO;
//        if (theMoviePlayer.fullscreen == NO) {
//            [self courseImageViewIsHidden:NO andBtnPlayIsHidden:NO];
//        }
//        self.moviePlayer = nil;
//        [theMoviePlayer.view removeFromSuperview];
//
//        for (int i = 0;i < videoUrlArray.count;i++) {
//            NSLog(@"count is %d",videoUrlArray.count);
//
//            NSString *theVideoUrl = [videoUrlArray objectAtIndex:i];
//            NSString *lastVideoUrl = [videoUrlArray lastObject];
//            NSLog(@"theVideoUrl is %@",theVideoUrl);
//            // add section row
//            NSString *theVideoTitle = [videoTitleArray objectAtIndex:i];
//            if ([theVideoUrl isEqualToString:lastVideoUrl]) {
//                self.promoVideoStr = theVideoUrl;
//                [playerFrameDelegate sendVideoTitle:theVideoTitle];
//                currentVideoUrl = theVideoUrl;
//                NSLog(@"currentVideoUrl is %@",currentVideoUrl);
//                break;
//            } else if ([currentVideoUrl isEqualToString:theVideoUrl]) {
//                theVideoUrl = [videoUrlArray objectAtIndex:i+1];
//                theVideoTitle = [videoTitleArray objectAtIndex:i+1];
//                [playerFrameDelegate sendVideoTitle:theVideoTitle];
//                self.promoVideoStr = theVideoUrl;
//                currentVideoUrl = theVideoUrl;
//                break;
//            }
//        }
//        NSURL *url =  [NSURL URLWithString:promoVideoStr];
//        KKBMoviePlayerController *theMoviePlayer = [[KKBMoviePlayerController
//        alloc] initWithContentURL:url];
//        self.moviePlayer = theMoviePlayer;
//        [theMoviePlayer.view setFrame:CGRectMake(0, 0,320, 180)];
//        theMoviePlayer.initialPlaybackTime = -1;
//        theMoviePlayer.endPlaybackTime = -1;
//        [self.playView addSubview:theMoviePlayer.view];
//        [self.playView addSubview:loadingView_];
//        [loadingView_ startAnimating];
//        [theMoviePlayer prepareToPlay];
//        [theMoviePlayer play];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(myMovieFinishedCallback:)
//                                                     name:MPMoviePlayerPlaybackDidFinishNotification
//                                                   object:theMoviePlayer];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(myMoviebeginPlay)
//                                                     name:MPMoviePlayerReadyForDisplayDidChangeNotification
//                                                   object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(playingDidChange)
//                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                                   object:nil];
//    }
//
//    NSLog(@"currentUrl %@",currentVideoUrl);
//    NSLog(@"videoUrlArr %@",videoUrlArray);
//    NSLog(@"videoTitleArray %@",videoTitleArray);

- (void)stopMovie {
    if (self.player) {
        endTime = [self.player currentTime];
        //    endTime = [moviePlayer currentPlaybackTime];

        // add view
        view = endTime;

        DDLogDebug(
            @"\n seekFrom is %f \n seekTo is %f \n view is %f \n email is %@ "
            @"\n courseId is %@\n currentVideoId is %@\n videoLen is %lld\n ",
            seekFrom, seekTo, view, [KKBUserInfo shareInstance].userEmail,
            [KKBUserInfo shareInstance].courseId, self.itemID,
            self.player.playerItem.duration.value /
                self.player.playerItem.duration.timescale);
        long long videoLenth = self.player.playerItem.duration.value /
                               self.player.playerItem.duration.timescale;

        NSMutableDictionary *videoInfoDict = [[NSMutableDictionary alloc] init];

        NSMutableArray *viewPeriodsArray = [[NSMutableArray alloc] init];

        NSDictionary *seekFromDict = @{
            @"action" : @"seekfrom",
            @"vtime" : [NSString stringWithFormat:@"%f", seekFrom]
        };
        NSDictionary *seekToDict = @{
            @"action" : @"seekto",
            @"vtime" : [NSString stringWithFormat:@"%f", seekTo]
        };
        NSDictionary *viewDict = @{
            @"action" : @"view",
            @"vtime" : [NSString stringWithFormat:@"%f", view]
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
        [videoInfoDict setObject:self.itemID forKey:@"last_video_id"];
        [videoInfoDict setObject:[NSString stringWithFormat:@"%lld", videoLenth]
                          forKey:@"videolen"];
        [videoInfoDict setObject:[KKBUserInfo shareInstance].courseId
                          forKey:@"course_id"];
        DDLogInfo(@"%@", videoInfoDict);

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoInfoDict
                                                           options:0
                                                             error:&error];
        NSString *jsonString =
            [[NSString alloc] initWithData:jsonData
                                  encoding:NSUTF8StringEncoding];

        [[KKBDataBase sharedInstance] addRecordWithJsonString:jsonString
                                                         type:@"VIDEO"];

        [[KKBUploader sharedInstance] startUpload];

        float playbackPosition = [self.player currentTime];
        [self savePlaybackPosition:playbackPosition];

        [[self.player player] pause];
        self.player = nil;
    }

    [self videoPlayEvent];
    //    if (self.moviePlayer) {
    //        //销毁播放通知
    //        [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                        name:MPMoviePlayerDidExitFullscreenNotification
    //                                                      object:self.moviePlayer];
    //        [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                        name:MPMoviePlayerPlaybackStateDidChangeNotification
    //                                                      object:self.moviePlayer];
    //        [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                        name:MPMoviePlayerPlaybackDidFinishNotification
    //                                                      object:self.moviePlayer];
    //        [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                        name:MPMoviePlayerDidEnterFullscreenNotification
    //                                                      object:self.moviePlayer];
    //        NSLog(@"moviePlayer is %@",self.player);
    //        // save current play position
    //        float playbackPosition = [self.moviePlayer currentPlaybackTime];
    //        [self savePlaybackPosition:playbackPosition];
    //
    //        [self.moviePlayer stop];
    //        self.moviePlayer.fullscreen = NO;
    //        [self.moviePlayer.view removeFromSuperview];
    //        self.moviePlayer = nil;
    //    }
    [self courseImageViewIsHidden:NO andBtnPlayIsHidden:NO];
}

- (void)courseImageViewIsHidden:(BOOL)courseIsHidden
             andBtnPlayIsHidden:(BOOL)btnPlayIsHidden {
    courseImageView_.hidden = courseIsHidden;
    btnPlay_.hidden = btnPlayIsHidden;
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    willChangeOrientationTo:(UIInterfaceOrientation)orientation {

    [playerFrameDelegate videoPlayer:videoPlayer
             willChangeOrientationTo:orientation];

    //    CourseInfoViewController* controller = [self
    //    courseInfoViewController];
    //    if (UIInterfaceOrientationIsLandscape(orientation)){
    ////        [self.superview resignFirstResponder];
    ////        [self->player.view becomeFirstResponder];
    //
    ////        UITapGestureRecognizer *tap = [[UITapGestureRecognizer
    /// alloc]initWithTarget:self action:@selector(videoTap:)];
    ////        [self.playView addGestureRecognizer:tap];
    //
    //        self.frame = CGRectMake(0, 0, 548, 320);
    //        //playView.frame = CGRectMake(0, 0, 548, 320);
    //
    //        [controller.myScrollView setScrollEnabled:NO];
    //
    //        controller.shadowView.hidden = YES;
    //
    //        //[self superview].frame = CGRectMake(0, 0, 568, 320);
    //        [controller.btnEntroll setHidden:YES];
    //        [controller.enrollButtonView setHidden:YES];
    //        player.view.view.frame = player.view.frame;
    //        player.view.view.clipsToBounds =NO;
    //        [player.view.view becomeFirstResponder];
    //    }else{
    //
    //        [controller.btnEntroll setHidden:NO];
    //        [controller.enrollButtonView setHidden:NO];
    //
    //        [controller.myScrollView setScrollEnabled:YES];
    //        controller.shadowView.hidden = NO;
    //    }
}
//-(CourseInfoViewController *)courseInfoViewController{
//    id next = [self nextResponder];
//    do {
//        if ([next isKindOfClass:[CourseInfoViewController class]]){
//            return next;
//        }else {next = [next nextResponder];
//        }
//
//    } while (next!=nil);
//
//    return nil;
//
//}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
       didPlayToEnd:(id<VKVideoPlayerTrackProtocol>)track {
    //    NSURL *url;
    //
    //    url =  [NSURL URLWithString:promoVideoStr];
    //
    //
    //        [player loadVideoWithStreamURL:url];
    view = self.player.playerItem.duration.value /
           self.player.playerItem.duration.timescale;
    long long videoLenth = self.player.playerItem.duration.value /
                           self.player.playerItem.duration.timescale;
    DDLogDebug(@"\n seekFrom is %f \n seekTo is %f \n view is %f \n email is "
               @"%@ \n courseId is %@\n currentVideoId is %@\n videoLen is "
               @"%lld\n ",
               seekFrom, seekTo, view, [KKBUserInfo shareInstance].userEmail,
               [KKBUserInfo shareInstance].courseId, self.itemID,
               self.player.playerItem.duration.value /
                   self.player.playerItem.duration.timescale);

    NSMutableDictionary *videoInfoDict = [[NSMutableDictionary alloc] init];

    NSMutableArray *viewPeriodsArray = [[NSMutableArray alloc] init];

    NSDictionary *seekFromDict = @{
        @"action" : @"seekfrom",
        @"vtime" : [NSString stringWithFormat:@"%f", seekFrom]
    };
    NSDictionary *seekToDict = @{
        @"action" : @"seekto",
        @"vtime" : [NSString stringWithFormat:@"%f", seekTo]
    };
    NSDictionary *viewDict = @{
        @"action" : @"view",
        @"vtime" : [NSString stringWithFormat:@"%f", view]
    };

    [viewPeriodsArray addObject:seekFromDict];
    [viewPeriodsArray addObject:seekToDict];
    [viewPeriodsArray addObject:viewDict];

    [videoInfoDict setObject:viewPeriodsArray forKey:@"viewPeriods"];
    [videoInfoDict setObject:@"0" forKey:@"id"];
    if ([KKBUserInfo shareInstance].userEmail == nil) {
        [videoInfoDict setObject:@"" forKey:@"email"];
    } else {
        [videoInfoDict setObject:[KKBUserInfo shareInstance].userEmail
                          forKey:@"email"];
    }
    [videoInfoDict setObject:self.itemID forKey:@"last_video_id"];
    [videoInfoDict setObject:[NSString stringWithFormat:@"%lld", videoLenth]
                      forKey:@"videolen"];
    [videoInfoDict setObject:[KKBUserInfo shareInstance].courseId
                      forKey:@"course_id"];
    DDLogInfo(@"%@", videoInfoDict);

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoInfoDict
                                                       options:0
                                                         error:&error];
    NSString *jsonString =
        [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[KKBDataBase sharedInstance] addRecordWithJsonString:jsonString
                                                     type:@"VIDEO"];

    [[KKBUploader sharedInstance] startUpload];

    [self savePlaybackPosition:0];

    [self courseImageViewIsHidden:NO andBtnPlayIsHidden:NO];
    [self bringSubviewToFront:courseImageView_];
    [self bringSubviewToFront:btnPlay_];
    [videoPlayer performOrientationChange:UIInterfaceOrientationPortrait];
    [self.player.view removeFromSuperview];
    self.player = nil;
    //    if
    //    (UIInterfaceOrientationIsLandscape(player.visibleInterfaceOrientation)){
    //        btnPlay_.center = self.center;
    //        courseImageView_.hidden = YES;
    //
    //    }else{
    //        btnPlay_.center = CGPointMake(160, 90);
    //        courseImageView_.hidden = NO;
    //    }
    //
    //}

    //-(void)videoTap:(UITapGestureRecognizer *)tap{
    //    [player.view handleSingleTap:tap];
    //}
}
@end
