//
//  AppDelegate.h
//  learn
//
//  Created by User on 13-5-16.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GexinSdk.h"
#import "WeiboSDK.h"

#define SinaAppKey @"2227742183"
#define SinaAppSecret @"ac015b7be910ae9ef8f25e05f026412c"
#define SinaAppRedirectURL @"http://sns.whalecloud.com/sina2/callback"

#define LoginVia @"LoginVia"
#define SinaWeibo @"com.sina.weibo"
#define TencentQQ @"TencentQQ"
#define Renren @"Renren"

#define APPDELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate

#define StatusBarHeight 20
#define NavigationBarHeight 44
#define TabBarHeight 49

#define NotificationProfileDidModify @"NotificationProfileDidModify"
//#define TabBarHeight 0

@class HomePageViewController;

//@class SidebarViewController;

@class SidebarViewControllerInPadViewController;

typedef enum { SdkStatusStoped, SdkStatusStarting, SdkStatusStarted } SdkStatus;

@interface AppDelegate
    : UIResponder <UIApplicationDelegate, GexinSdkDelegate, WeiboSDKDelegate>

@property(retain, nonatomic) UIWindow *window;
@property(assign, nonatomic) BOOL isReachable;

@property(retain, nonatomic) HomePageViewController *homePageViewController;
@property(assign, nonatomic) BOOL isFromActivityAnn;
@property(assign, nonatomic) BOOL isFromActivityDis;
@property(assign, nonatomic) BOOL isFromActivityMes;
@property(assign, nonatomic) BOOL isFromDownLoad;
@property(assign, nonatomic) BOOL isClickEntrollment;
@property(assign, nonatomic) NSString *annStr;

//@property(strong, nonatomic) SidebarViewController *viewController;

@property(strong, nonatomic)
    SidebarViewControllerInPadViewController *viewInPadController;
@property(assign, nonatomic) BOOL TwoLevel;

// add push
@property(strong, nonatomic) GexinSdk *gexinPusher;

@property(retain, nonatomic) NSString *kkbGeTuiAppKey;
@property(retain, nonatomic) NSString *kkbGeTuiAppSecret;
@property(retain, nonatomic) NSString *kkbGeTuiAppID;
@property(retain, nonatomic) NSString *kkbGeTuiClientId;
@property(assign, nonatomic) SdkStatus kkbGeTuiSdkStatus;

@property(assign, nonatomic) int kkbLastPayloadIndex;
@property(retain, nonatomic) NSString *kkbPayloadId;

- (void)startSdkWith:(NSString *)appID
              appKey:(NSString *)appKey
           appSecret:(NSString *)appSecret;
- (void)stopSdk;

- (void)setDeviceToken:(NSString *)aToken;
- (BOOL)setTags:(NSArray *)aTag error:(NSError **)error;
- (NSString *)sendMessage:(NSData *)body error:(NSError **)error;

- (BOOL)hasLogined;

- (UIView *)statusBar;

/**
 *  根据登录状态初始化window的rootViewController (only for iPhone)
 *
 *  @param isLogin isLogin description
 */
- (void)isiPhoneLoginSuccess:(BOOL)isLogin;

@end
