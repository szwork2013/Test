//
//  PlayerFrameView.h
//  learn
//
//  Created by zxj on 14-6-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VKVideoPlayer;

@protocol PlayerFrameViewDelegate <NSObject>

@optional
- (void)sendVideoTitle:(NSString *)videoTitle;
- (void)videoPlayer:(VKVideoPlayer*)videoPlayer willChangeOrientationTo:(UIInterfaceOrientation)orientation;
@end

#import <MediaPlayer/MediaPlayer.h>
#import "VKVideoPlayer.h"

@class AllCoursesItem;
@class KKBMoviePlayerController;
@interface PlayerFrameView : UIView <UIAlertViewDelegate, VKVideoPlayerDelegate>
{
    UIImageView* courseImageView_;
    UIButton* btnPlay_;
    UIActivityIndicatorView* loadingView_;
//    VKVideoPlayer *player;
}
@property (nonatomic,retain)VKVideoPlayer *player;
@property(nonatomic,retain)NSString* imageURL;
@property(retain,nonatomic) NSString *strCourseID;
@property (nonatomic,copy)NSString *moduleID;
@property (nonatomic,copy)NSString *itemID;
@property (nonatomic,copy)NSString *userID;
@property (nonatomic,copy)NSString *courseName;
@property(retain,nonatomic) NSString *videoUrl;
@property(retain,nonatomic) NSString *strUrl;
@property(retain,nonatomic) NSString *promoVideoStr;
@property (nonatomic, retain)NSDictionary *codeDic;
@property(nonatomic,retain)UIView* playView;
@property (nonatomic, retain) NSString *html;
@property (nonatomic, assign)int courseState;
@property (nonatomic, assign) BOOL hiddenMode;

- (IBAction)playMovieAtURL;
-(void)initImage;
- (void)stopMovie;
- (NSString *) getPromoVideoStr;
- (float) getCurrentPlaybackTime;
- (KKBMoviePlayerController *) getMoviePlayer;

@property (nonatomic,assign)BOOL isTheLastMovie;
@property (nonatomic,retain)NSMutableArray *videoUrlArray;
@property (nonatomic,copy) NSString *currentVideoUrl;
@property (nonatomic,retain)NSMutableArray *videoTitleArray;
@property (nonatomic,assign)id <PlayerFrameViewDelegate>playerFrameDelegate;

@property (nonatomic,assign) NSTimeInterval playRecordDuration;

@end
