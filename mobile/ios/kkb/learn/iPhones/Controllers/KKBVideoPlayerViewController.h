//
//  KKBVideoPlayerViewController.h
//  VideoPlayerDemo

// 1.用户切换视频 2.退出次页面 3.视频播放完成
// 1.上次记录  2.

//  Created by zengmiao on 8/12/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKVideoPlayer.h"
#import "KKBBaseViewController.h"

typedef enum {
    VideoStatusUNKnown = 0, //未准备好
    VideoStatusPlaying,
    VideoStatusPlayEnd,
    VideoStatusDismiss //当控制器Viewdisappear时的状态
} VideoStatus;

typedef enum {
    VideoPlaySingleType = 0,
    VideoPlayMutiType //支持续播
} VideoPlayType;

@interface KKBVideoPlayerViewController : KKBBaseViewController

@property(nonatomic, strong) VKVideoPlayer *player;
@property(nonatomic, assign) VideoStatus videoStatus;

@property(nonatomic, assign) BOOL allowForceRotation; //外部设置是否允许横竖屏
@property(nonatomic, assign) BOOL forceToFullScreen; //强制全屏＋强制横屏

@property(nonatomic, assign) VideoPlayType videoType; //类型 需要支持续播
@property(nonatomic, copy) NSString *coverImgURL;     //图片URL
@property(nonatomic, assign)
    BOOL allowRemovePlayer; //当控制器的view Dismiss时是否允许移除PlayerView
@property(nonatomic, assign) UIScrollView *contentScrollView;
//滑动的scrollView 用于旋转时禁止滑动

#pragma mark - 用于上传播放记录
@property(nonatomic, copy) NSMutableArray *videoURLs; //视频URL地址
@property(nonatomic, copy)
    NSArray *itemIDs; //视频URL对应的ID !!!必须保证ID为NSNumber类型!!!
@property(nonatomic, copy) NSString *videoURL; //当前正在播放的视频URL

// courseid classid 如果不存在的时候 传nil值
@property(nonatomic, copy) NSString *courseId; // 课程ID
@property(nonatomic, copy) NSString *classId;  // 班次ID

#pragma mark - 需要重写的方法
//需要重写的方法
- (void)playViewwillChangeOrientationTo:(UIInterfaceOrientation)orientation;

//用户进入视频页面第一次播放(包括点item切换视频)视频触发事件
//这个方法统一检测用户是否注册了这门课
- (void)bigPlayBtnTapped;

//当自动续播时将调用此方法 仅当 videoType 为VideoPlayMutiType时有效
- (void)videoEndWillToNextVideoIndex:(int)index;

- (void)videoWillStartPlayOfIndex:(NSUInteger)index;

#pragma mark - 外部调用的方法
//切换视频 仅当 videoType 为VideoPlayMutiType时有效
- (void)changeVideoToIndex:(int)index;

- (void)videoPlayerViewFullScreenDidPress;
- (void)handleError;

- (BOOL)shouldNotHandleNetworkMonitor; //是否不需要检查网络状态
                                       //只有在下载管理页面用到

/**
 *  弹出视图时控制视频暂停/播放
 *
 *  @param playing 播放/暂停
 *
 *  @return return value description
 */
- (void)presentViewShouldPlayContent:(BOOL)playing;

@end
