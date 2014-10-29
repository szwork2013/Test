//
//  KKBiPhoneUIConfig.h
//  learn

//  iPhone全局UI布局尺寸

//  Created by zengmiao on 8/6/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#ifndef learn_KKBUIConfig_h
#define learn_KKBUIConfig_h

#ifdef DEBUG
#define KKBGETUIAPPID @"cwxu7yXUvV8MpziUtwEJO9"
#define KKBGETUIAPPKEY @"2hl44VU7I484GNtPBfxs63"
#define KKBGETUIAPPSECRET @"uW00uaPjaA8voPYtDL9bV8"
#else
#define KKBGETUIAPPID @"KCj5oOcIaT8E9RaW80vTm2"
#define KKBGETUIAPPKEY @"v0dS7DeUUy9GZYekrH77g3"
#define KKBGETUIAPPSECRET @"UgAchEVdrAA9IPj57mzepA"
#endif

#define G_VIDEOVIEW_HEIGHT 180.0f //视频播放器的高度

//全局颜色
#define G_TABLEVIEW_BGCKGROUND_COLOR                                           \
    [UIColor colorWithRed:240 / 256.0                                          \
                    green:240 / 256.0                                          \
                     blue:240 / 256.0                                          \
                    alpha:1]

#define G_WHITE_COLOR                                                          \
    [UIColor colorWithRed:255 / 256.0                                          \
                    green:255 / 256.0                                          \
                     blue:255 / 256.0                                          \
                    alpha:1]

// 屏幕高度
#define G_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
// 屏幕宽度
#define G_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

// RGB数值相同
#define UIColorRGBTheSame(a)                                                   \
    [UIColor colorWithRed:(a / 255.0)green:(a / 255.0)blue:(a / 255.0)alpha:1]

// 全局常量

// 导航条高度
static CGFloat const gNavigationBarHeight = 44;
// 状态栏高度
static CGFloat const gStatusBarHeight = 20;
// 导航条+状态栏高度
static CGFloat const gNavigationAndStatusHeight =
    gNavigationBarHeight + gStatusBarHeight;
// tabbar高度
static CGFloat const gTabBarHeight = 49;

// 底部视图高度
static CGFloat const gBottomViewHeight = 48;
// 卡片离屏幕边框间距
static CGFloat const gScreenToCardLine = 8;

// 冷启动页面 图片起始位置
static CGFloat const gCoolStartImageOriginX = 80;

// 冷启动页面 图片宽
static CGFloat const gCoolStartImageOriginWidth = 160;

// 冷启动页面 图片高
static CGFloat const gCoolStartImageOriginHeight = 120;

// 冷启动页面 标题高度
static CGFloat const gCoolStartLabelHeight = 16;

// 专业卡片初始高度
static CGFloat const gMajorCardCloseHeight = 128;
// 专业卡片宽度
static CGFloat const gMajorCardWidth = 304;
// 专业卡片间距
static CGFloat const gMajorCardsSpaceHeight = 16;

static CGFloat const gMajorCardClosePlusSpaceHeight = 144;
//
static CGFloat const gMajorCardOpenHeight = 104;

// 微专业信息高度
static CGFloat const gMicroMajorInfoHeight = 64;

//下载管理中ui元素
static const float gDownloadStatusCell = 44.0f;

static const float gDownloadSectionCell = 48.0f;

static const float gPopDownloadViewMarginTop = 130.0f;

static const float addPageTopViewHeight = 40.0;
static const float addPageBottomViewHeight = 40.0;
static const float bottomPopViewCornerRadius = 5.0;

// info信息元素常量
static CGFloat const gInfoHeaderViewHeight = 29;
static CGFloat const gInfoHeaderViewImageViewOriginX = 8;
static CGFloat const gInfoHeaderViewImageViewOriginY = 12;
static CGFloat const gInfoHeaderViewImageViewWidth = 3;
static CGFloat const gInfoHeaderViewImageViewHeight = 16;

static CGFloat const gInfoHeaderViewLabelOriginX = 16;
static CGFloat const gInfoHeaderViewLabelOriginY = 12;
static CGFloat const gInfoHeaderViewLabelWidth = 75;
static CGFloat const gInfoHeaderViewLabelHeight = 16;

static CGFloat const gInfoHeaderViewLineHeight = 0.5;

#define ViewSelectedColor @"0xf5f5f5";

//下载文件夹名
#define DOWNLOAD_DIRECTORY_NAME @"kkbVideoDownload"

#define OpenCourse @"OpenCourse"               //公开课
#define InstructiveCourse @"InstructiveCourse" //导学课

#endif
