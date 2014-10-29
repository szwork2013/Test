//
//  AppDelegate.m
//  learn
//
//  Created by User on 13-5-16.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "GlobalOperator.h"
#import "HomePageViewController.h"
#import "UMFeedback.h"
#import "AWVersionAgent.h"
#import "ios-ntp.h"
#import "AppUtilities.h"
#import "UMSocialData.h"
#import "UMSocialRenrenHandler.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "MiniMajorViewController.h"
#import "CoursesViewController.h"
#import "CourseHomeViewController.h"
#import "DynamicsViewController.h"
#import "CategoriesViewController.h"
#import "ViewController.h"

//#import "SidebarViewController.h"
#import "SidebarViewControllerInPadViewController.h"
#import "AFHTTPRequestOperationManager.h"

#import "iflyMSC/iflySetting.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KKBHttpClient.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "FindCourseViewController.h"
#import "MicroMajorViewController.h"
#import "MeViewController.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialTencentWeiboHandler.h"

#import "KKBBaseNavigationController.h"
#import "KKBBaseTabBarViewController.h"

#import "KKBCourseManager.h"

#import <TencentOpenAPI/TencentOAuth.h>

#import <AdSupport/ASIdentifierManager.h>
#import "KKBHttpClient.h"
#import "KKBDataBase.h"
#import "KKBUploader.h"
#import "KKBUserInfo.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "KKBDownloadManager.h"

#ifdef DEBUG
#define KKBGETUIAPPID @"cwxu7yXUvV8MpziUtwEJO9"
#define KKBGETUIAPPKEY @"2hl44VU7I484GNtPBfxs63"
#define KKBGETUIAPPSECRET @"uW00uaPjaA8voPYtDL9bV8"
#else
#define KKBGETUIAPPID @"KCj5oOcIaT8E9RaW80vTm2"
#define KKBGETUIAPPKEY @"v0dS7DeUUy9GZYekrH77g3"
#define KKBGETUIAPPSECRET @"UgAchEVdrAA9IPj57mzepA"
#endif

#define KKBIFLYAPPID @"53c7c41d"
#define KKBIFLYTIMEOUT @"20000" // timeout      连接超时的时间，以ms为单位
#define KKBUrlScheme @"kaikeba"
#define SinaWeiboUrlScheme @"wb2227742183"
#define TencentQQUrlScheme @"tencent1101760842"

static NSString *const appDelegateContext = @"appDelegateContext";

@implementation AppDelegate {
    NSString *kkbDeviceToken;
    BOOL isPostSuccess;
}

@synthesize window;
@synthesize homePageViewController;
@synthesize isFromActivityAnn, isFromActivityDis, isFromActivityMes,
    isFromDownLoad, isClickEntrollment;
@synthesize annStr;

// add push
@synthesize kkbGeTuiAppSecret, kkbGeTuiAppKey, kkbGeTuiAppID;
@synthesize kkbLastPayloadIndex;
@synthesize kkbPayloadId;
@synthesize kkbGeTuiSdkStatus;
@synthesize kkbGeTuiClientId;
@synthesize gexinPusher;

- (BOOL)theDeviceWhatIs {
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone) {
        return YES;
    }
    return NO;
}

- (void)installUmengSDK {
    if ([self theDeviceWhatIs]) {
        [MobClick startWithAppkey:UMENG_APPKEY_IPHONE
                     reportPolicy:SEND_INTERVAL
                        channelId:nil];
    } else {
        [MobClick startWithAppkey:UMENG_APPKEY_IPAD
                     reportPolicy:SEND_INTERVAL
                        channelId:nil];
    }

    [MobClick checkUpdate];
    [MobClick setLogEnabled:NO];
    NSString *version = [[[NSBundle mainBundle] infoDictionary]
        objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

- (void)startMonitorNetworkStatus {
    AFNetworkReachabilityManager *afNetworkReachabilityManager =
        [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];
}

- (CourseHomeViewController *)courseHomeViewControler {
    CourseHomeViewController *courseHomeViewControler =
        [[CourseHomeViewController alloc]
            initWithNibName:@"CourseHomeViewController"
                     bundle:nil];
    return courseHomeViewControler;
}

- (DynamicsViewController *)dynamicsViewController {
    DynamicsViewController *controller = [[DynamicsViewController alloc] init];
    return controller;
}

- (CategoriesViewController *)categoriesViewController {
    CategoriesViewController *controller = [[CategoriesViewController alloc]
        initWithNibName:@"CategoriesViewController"
                 bundle:nil];
    return controller;
}

- (LoginViewController *)loginViewController {
    LoginViewController *controller =
        [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                              bundle:nil];
    return controller;
}

- (RegisterViewController *)loginAndReigstVC {
    RegisterViewController *controller = [[RegisterViewController alloc]
        initWithNibName:@"RegisterViewController"
                 bundle:nil];
    return controller;
}

//- (UINavigationController *) miniMajorViewController{
//    MiniMajorViewController *controller = [[MiniMajorViewController alloc]
//    init];
//    UINavigationController *navController = [[UINavigationController alloc]
//    initWithRootViewController:controller];
//
//    return navController;
//}

- (MiniMajorViewController *)miniMajorViewController {

    MiniMajorViewController *controller = [[MiniMajorViewController alloc]
        initWithNibName:@"MiniMajorViewController"
                 bundle:nil];

    return controller;
}

//- (CoursesViewController *) coursesViewController{
//    CoursesViewController *v = [[CoursesViewController alloc]
//    initWithNibName:@"CoursesViewController" bundle:nil];
//    return v;
//}

- (BOOL)hasLogined {
    BOOL hasLogined =
        [[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"];

    return hasLogined;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // init allCourseData
    [KKBCourseManager updateAllCoursesForceReload:NO
                                completionHandler:^(BOOL success) {}];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    //    [WeiboSDK enableDebugMode:YES];
    //    [WeiboSDK registerApp:SinaAppKey];

    [UMSocialData setAppKey:UMENG_APPKEY_IPHONE];

    [self installUmengSDK];
    [self startMonitorNetworkStatus];

    [UMSocialRenrenHandler openSSO];

    [UMSocialWechatHandler setWXAppId:@"wxef4c838d5f6cb77f"
                                  url:@"http://www.kaikeba.com"];
    [UMSocialSinaHandler openSSOWithRedirectURL:nil];
    [UMSocialQQHandler setQQWithAppId:@"1101760842"
                               appKey:@"fE56BxnhusHyT3RX"
                                  url:@"http://www.kaikeba.com"];
    [UMSocialTencentWeiboHandler
        openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    [UMSocialQQHandler setSupportWebView:YES];
    //设置支持没有客户端情况下使用SSO授权

    self.window =
        [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.clipsToBounds = YES;

    if ([self theDeviceWhatIs]) {

        self.TwoLevel = NO;

        //        [[AWVersionAgent sharedAgent]
        //        checkNewVersionForApp:KAIKEBA_APPSTORE_APPID];

        //单例实例化
        [GlobalOperator sharedInstance];

        //  友盟的方法本身是异步执行，所以不需要再异步调用
        [self umengTrack];

        //设置Nav全局图片
        [self customiPhoneAppearanceBar];

        //检测接口401错误
        [self registerNetworkResponse401Error];

        //暂时注掉 改版之前未登录进侧滑页 现在为匿名首页
        {
            //        self.viewController = [[SidebarViewController alloc]
            //            initWithNibName:@"SidebarViewController"
            //                     bundle:nil];
            //        self.window.rootViewController = self.viewController;

            //    self.navigationController= [[[UINavigationController
            //    alloc]initWithRootViewController:self.viewController]autorelease];
            //    self.window.rootViewController = self.navigationController;

            //        if ([self hasLogined]) {
            //            self.window.rootViewController = [self
            //            tabBarController];
            //        } else {
            //            self.window.rootViewController = [self
            //            courseHomeViewControler];
            //        }

            //        self.window.rootViewController = [self
            //        miniMajorViewController];
            //        self.window.rootViewController = [self
            //        coursesViewController];
            //        ViewController *scanVC = [[ViewController alloc]
            //        initWithNibName:@"ViewController" bundle:nil];
            //        self.window.rootViewController = scanVC;

            // new
            //        CourseHomeViewController *courseHomeVC =
            //        [[CourseHomeViewController alloc]
            //        initWithNibName:@"CourseHomeViewController" bundle:nil];
            //        self.window.rootViewController = courseHomeVC;
            // add
        }

        if ([[NSFileManager defaultManager]
                fileExistsAtPath:[AppUtilities getTokenJSONFilePath]]) {
            NSLog(@"file exist ******* 已登录 ");

            [GlobalOperator sharedInstance].isLogin = YES;
            [KKBUserInfo shareInstance].isLogin = YES;

            NSError *error = nil;
            NSString *jsonStr = [NSString
                stringWithContentsOfFile:[AppUtilities getTokenJSONFilePath]
                                encoding:NSUTF8StringEncoding
                                   error:&error];
            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *userInfoDict =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&error];

            [KKBUserInfo shareInstance].isLogin = YES;
            [KKBUserInfo shareInstance].userId =
                [userInfoDict objectForKey:@"userId"];
            [KKBUserInfo shareInstance].userName =
                [userInfoDict objectForKey:@"userName"];
            [KKBUserInfo shareInstance].userEmail =
                [userInfoDict objectForKey:@"email"];
            if ([[userInfoDict objectForKey:@"avatar_url"]
                    isKindOfClass:[NSNull class]]) {
                [KKBUserInfo shareInstance].avatar_url = nil;
            } else {
                [KKBUserInfo shareInstance].avatar_url =
                    [userInfoDict objectForKey:@"avatar_url"];
            }
            [KKBUserInfo shareInstance].userPassword =
                [userInfoDict objectForKey:@"password"];

            [self isiPhoneLoginSuccess:YES];

        } else {
            NSLog(@"file not exit ********* 未登录");
            [self isiPhoneLoginSuccess:NO];
        }

        //初始化数据库
        [KKBDownloadManager setUpDownloadManager];

    } else {

        //        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=
        //        7) {
        //            self.window.frame =
        //            CGRectMake(20,0,self.window.frame.size.width-20,self.window.frame.size.height);
        //        }

        //        [NetworkClock sharedNetworkClock];

        //单例实例化
        [GlobalOperator sharedInstance];

        if ([AppUtilities isExistenceNetwork]) {
            //  友盟的方法本身是异步执行，所以不需要再异步调用
            [self umengTrack];

            [UMFeedback setLogEnabled:YES];

            [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(umCheck:)
                       name:UMFBCheckFinishedNotification
                     object:nil];
        }

        self.window.backgroundColor = [UIColor blackColor];

        self.viewInPadController =
            [[SidebarViewControllerInPadViewController alloc]
                initWithNibName:@"SidebarViewControllerInPadViewController"
                         bundle:nil];

        self.window.rootViewController = self.viewInPadController;

        /*

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]
bounds]] autorelease];
    // Override point for customization after application

    [[UIApplication sharedApplication] setStatusBarHidden:NO
withAnimation:UIStatusBarAnimationFade];
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
//    NSLog(@"%@", NSHomeDirectory());

//        NSInteger dWidth = [UIScreen mainScreen].currentMode.size.width;
//        NSInteger dheight = [UIScreen mainScreen].currentMode.size.height;

//        NSLog(@"dWidth = %d",dWidth);
//        NSLog(@"dheight = %d",dheight);

    //NTP
// [NetworkClock sharedNetworkClock];

    //    NSMutableArray *cookieArray = [[NSUserDefaults standardUserDefaults]
valueForKey:@"cookieArray"];
    //
    //    for (int i = 0; i < [cookieArray count]; i++)
    //    {
    //        NSMutableDictionary *cookieProperties = [[NSUserDefaults
standardUserDefaults] valueForKey:[cookieArray objectAtIndex:i]];
    //        NSHTTPCookie *cookie = [NSHTTPCookie
cookieWithProperties:cookieProperties];
    //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    //    }

//    [[AWVersionAgent sharedAgent]
checkNewVersionForApp:KAIKEBA_APPSTORE_APPID];

    //单例实例化
    [GlobalOperator sharedInstance];

        if([ToolsObject isExistenceNetwork]){
            //  友盟的方法本身是异步执行，所以不需要再异步调用
            [self umengTrack];

            [UMFeedback setLogEnabled:YES];
            [UMFeedback checkWithAppkey:UMENG_APPKEY];
            [[NSNotificationCenter defaultCenter] addObserver:self
selector:@selector(umCheck:) name:UMFBCheckFinishedNotification object:nil];
        }

    self.homePageViewController = [[[HomePageViewController alloc] init]
autorelease];

    UINavigationController *navigationController = [[UINavigationController
alloc] initWithRootViewController:self.homePageViewController];
    self.window.rootViewController = navigationController;
    [navigationController release];



    self.window.backgroundColor = [UIColor whiteColor];

        */
    }

    [self.window makeKeyAndVisible];

    // 科大讯飞
    NSString *initString = [[NSString alloc]
        initWithFormat:@"appid=%@,timeout=%@", KKBIFLYAPPID, KKBIFLYTIMEOUT];
    [IFlySpeechUtility createUtility:initString];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                                forKey:@"firstLaunch"];
        NSLog(@"第一次启动");

        [[KKBUploader sharedInstance] bufferCPAInfoWithUserID:@""
                                                       action:@"firstOpen"];
        // TODO: byzpc
        // 去掉判断是否开启推送
        // 用户第一次启动默认开启推送
        [self startSdkWith:KKBGETUIAPPID
                    appKey:KKBGETUIAPPKEY
                 appSecret:KKBGETUIAPPSECRET];

    } else {
        NSLog(@"已经不是第一次启动了");
    }

    [[KKBUploader sharedInstance] startUpload];

    // add push
    // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    // TODO:byzpc
    // 根据用户选择判断是否开启个推推送SDK
    if ([[LocalStorage shareInstance] pushSwitchIsOpen] == YES) {
        [self startSdkWith:KKBGETUIAPPID
                    appKey:KKBGETUIAPPKEY
                 appSecret:KKBGETUIAPPSECRET];
    }
    // [2]:注册APNS
    [self registerRemoteNotification];
    // [2-EXT]: 获取启动时收到的APN
    NSDictionary *message = [launchOptions
        objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        // NSString *payloadMsg = [message objectForKey:@"payload"];
        // NSString *record = [NSString stringWithFormat:@"[APN]%@, %@", [NSDate
        // date], payloadMsg];
    }

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    return YES;
}

- (void)registerRemoteNotification {
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(
        UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:apn_type];
}

- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行

    //    [MobClick setLogEnabled:YES];  //
    //    打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString *
                                              //类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取

    if ([self theDeviceWhatIs]) {
        [MobClick startWithAppkey:UMENG_APPKEY_IPHONE
                     reportPolicy:(ReportPolicy)BATCH
                        channelId:nil];
    } else {
        [MobClick startWithAppkey:UMENG_APPKEY_IPAD
                     reportPolicy:(ReportPolicy)BATCH
                        channelId:nil];
    }
    //   reportPolicy为枚举类型,可以为 REALTIME,
    //   BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App
    //   Store"渠道

    //      [MobClick checkUpdate];   //自动更新检查,
    //      如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary
    //      *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self
    //    selector:@selector(updateMethod:)];

    [MobClick updateOnlineConfig]; //在线参数配置
    // [MobClick setLogEnabled:YES];   // 调试模式

    //[[NSNotificationCenter defaultCenter] addObserver:self
    // selector:@selector(onlineConfigCallBack:)
    // name:UMOnlineConfigDidFinishedNotification object:nil];
}

//- (void)alertView:(UIAlertView *)alertView
// clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//        NSLog(@"查看feedback");
//        [self.viewController webFeedback:nil];
//    } else {
//
//    }
//}

- (void)umCheck:(NSNotification *)notification {
    UIAlertView *alertView;
    if (notification.userInfo) {
        NSArray *newReplies =
            [notification.userInfo objectForKey:@"newReplies"];
        //        NSLog(@"newReplies = %@", newReplies);
        NSString *title =
            [NSString stringWithFormat:@"有%ld条新回复",
                                       (unsigned long)[newReplies count]];
        NSMutableString *content = [NSMutableString string];
        for (NSUInteger i = 0; i < [newReplies count]; i++) {
            NSString *dateTime =
                [[newReplies objectAtIndex:i] objectForKey:@"datetime"];
            NSString *_content =
                [[newReplies objectAtIndex:i] objectForKey:@"content"];
            [content
                appendString:
                    [NSString stringWithFormat:@"%lu .......%@.......\r\n",
                                               (unsigned long)i + 1, dateTime]];
            [content appendString:_content];
            [content appendString:@"\r\n\r\n"];
        }

        alertView = [[UIAlertView alloc] initWithTitle:title
                                               message:content
                                              delegate:self
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@"查看", nil];
        ((UILabel *)[[alertView subviews] objectAtIndex:1]).textAlignment =
            NSTextAlignmentLeft;
        [alertView show];
    }
    //    else
    //    {
    //        alertView = [[UIAlertView alloc] initWithTitle:@"没有新回复"
    //        message:nil delegate:nil cancelButtonTitle:@"确定"
    //        otherButtonTitles:nil];
    //    }
}

- (UIView *)statusBar {
    UIView *statusBar =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [statusBar setBackgroundColor:UIColorFromRGB(0x288BE6)];

    return statusBar;
}

- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
    //    [[AWVersionAgent sharedAgent]
    //    upgradeAppWithNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the
    // application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    // [EXT] 切后台关闭SDK，让SDK第一时间断线，让个推先用APN推送
    [self stopSdk];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive
    // state; here you can undo many of the changes made on entering the
    // background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
    // [EXT] 重新上线
    // 根据用户选择判断是否要重新上线
    // TODO: byzpc
    if ([[LocalStorage shareInstance] pushSwitchIsOpen]) {
        [self startSdkWith:kkbGeTuiAppID
                    appKey:kkbGeTuiAppKey
                 appSecret:kkbGeTuiAppSecret];
    }
    //更新 all courses
    [KKBCourseManager updateAllCoursesForceReload:YES
                                completionHandler:^(BOOL success) {}];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
    //    [[NetworkClock sharedNetworkClock] finishAssociations]; // be nice and
    //    let
    // all the servers
    // go ...
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description]
        stringByTrimmingCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    kkbDeviceToken =
        [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", kkbDeviceToken);
    // [3]:向个推服务器注册deviceToken
    if (gexinPusher) {
        [gexinPusher registerDeviceToken:kkbDeviceToken];
    }
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    if (gexinPusher) {
        [gexinPusher registerDeviceToken:@""];
    }
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userinfo {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    // [4-EXT]:处理APN
    NSString *payloadMsg = [userinfo objectForKey:@"payload"];
    NSString *record =
        [NSString stringWithFormat:@"[APN]%@, %@", [NSDate date], payloadMsg];
    NSLog(@"record is %@", record);
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {

    if (url == nil) {
        return NO;
    }

    // Tencent QQ
    if (url != nil && [[url absoluteString] hasPrefix:TencentQQUrlScheme]) {
        return [TencentOAuth HandleOpenURL:url];
    }

    // KKB
    if (url != nil && [[url absoluteString] hasPrefix:KKBUrlScheme]) {
        return YES;
    }

    return [UMSocialSnsService handleOpenURL:url];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    //    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    //    {
    //        ProvideMessageForWeiboViewController *controller =
    //        [[[ProvideMessageForWeiboViewController alloc] init] autorelease];
    //        [self.viewController presentModalViewController:controller
    //        animated:YES];
    //    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    //    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    //    {
    //        NSString *title = @"发送结果";
    //        NSString *message = [NSString stringWithFormat:@"响应状态:
    //        %d\n响应UserInfo数据: %@\n原请求UserInfo数据:
    //        %@",(int)response.statusCode, response.userInfo,
    //        response.requestUserInfo];
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
    //                                                        message:message
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"确定"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //        [alert release];
    //    }
    //    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    //    {
    //        NSString *title = @"认证结果";
    //        NSString *message = [NSString stringWithFormat:@"响应状态:
    //        %d\nresponse.userId: %@\nresponse.accessToken:
    //        %@\n响应UserInfo数据: %@\n原请求UserInfo数据:
    //        %@",(int)response.statusCode,[(WBAuthorizeResponse *)response
    //        userID], [(WBAuthorizeResponse *)response accessToken],
    //        response.userInfo, response.requestUserInfo];
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
    //                                                        message:message
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"确定"
    //                                              otherButtonTitles:nil];
    //
    //        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
    //
    //        [alert show];
    //        [alert release];
    //    }
}

- (void)startSdkWith:(NSString *)appID
              appKey:(NSString *)appKey
           appSecret:(NSString *)appSecret {
    if (!gexinPusher) {
        kkbGeTuiSdkStatus = SdkStatusStoped;

        self.kkbGeTuiAppID = appID;
        self.kkbGeTuiAppKey = appKey;
        self.kkbGeTuiAppSecret = appSecret;

        kkbGeTuiClientId = nil;

        NSError *err = nil;
        gexinPusher = [GexinSdk createSdkWithAppId:kkbGeTuiAppID
                                            appKey:kkbGeTuiAppKey
                                         appSecret:kkbGeTuiAppSecret
                                        appVersion:@"0.0.0"
                                          delegate:self
                                             error:&err];
        if (!gexinPusher) {
        } else {
            kkbGeTuiSdkStatus = SdkStatusStarting;
        }
    }
}

- (void)stopSdk {
    if (gexinPusher) {
        [gexinPusher destroy];
        gexinPusher = nil;

        kkbGeTuiSdkStatus = SdkStatusStoped;

        kkbGeTuiClientId = nil;
    }
}

- (BOOL)checkSdkInstance {
    if (!gexinPusher) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"错误"
                                       message:@"SDK未启动"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)setDeviceToken:(NSString *)aToken {
    if (![self checkSdkInstance]) {
        return;
    }

    [gexinPusher registerDeviceToken:aToken];
}

- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return NO;
    }

    return [gexinPusher setTags:aTags];
}

- (NSString *)sendMessage:(NSData *)body error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return nil;
    }

    return [gexinPusher sendMessage:body error:error];
}

#pragma mark - GexinSdkDelegate
- (void)GexinSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册
    kkbGeTuiSdkStatus = SdkStatusStarted;
    kkbGeTuiClientId = clientId;
    [KKBUserInfo shareInstance].geTuiClientId = clientId;

    NSString *userId;
    if ([KKBUserInfo shareInstance].userId == nil) {
        userId = @"";
    } else {
        userId = [KKBUserInfo shareInstance].userId;
    }
    NSString *userEmail;
    if ([KKBUserInfo shareInstance].userEmail == nil) {
        userEmail = @"";
    } else {
        userEmail = [KKBUserInfo shareInstance].userEmail;
    }
    [[KKBUploader sharedInstance]
        bufferPushNotificationInfoWithUserID:userId
                                    clientID:clientId
                                   userEmail:userEmail];
    [[KKBUploader sharedInstance] startUpload];
}

- (void)GexinSdkDidReceivePayload:(NSString *)payloadId
                  fromApplication:(NSString *)appId {
    // [4]: 收到个推消息
    kkbPayloadId = payloadId;

    NSData *payload = [gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    NSString *record =
        [NSString stringWithFormat:@"%d, %@, %@", ++kkbLastPayloadIndex,
                                   [NSDate date], payloadMsg];
    NSLog(@"收到个人信息 record is %@", record);
}

- (void)GexinSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *record =
        [NSString stringWithFormat:@"Received sendmessage:%@ result:%d",
                                   messageId, result];
    NSLog(@"反馈record is %@", record);
}

- (void)GexinSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"GexinSdk error is %@", [error localizedDescription]);
}

/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)application:(UIApplication *)application
supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([GlobalOperator sharedInstance].isLandscape)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

#endif
*/
#pragma mark - 屏幕旋转

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

        return UIInterfaceOrientationMaskAll;

    else /* iphone */

        return UIInterfaceOrientationMaskPortrait;
}

#endif

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - 设置iPhone的全局导航栏
- (void)customiPhoneAppearanceBar {
    [[UINavigationBar appearance]
        setBackgroundImage:[UIImage imageNamed:@"iPhone_nav_bg"]
             forBarMetrics:UIBarMetricsDefault];

    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent];

    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent];

    //设置导航栏中title的字体
    [[UINavigationBar appearance]
        setTitleTextAttributes:@{
                                  NSFontAttributeName :
                                      [UIFont boldSystemFontOfSize:18.0],
                                  NSForegroundColorAttributeName :
                                      [UIColor whiteColor]
                               }];

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

#pragma mark - 初始化iPhone登录成功之后的TabBarController
- (UITabBarController *)customInitiPhoneTabBarController {
    DynamicsViewController *tab1 = [[DynamicsViewController alloc]
        initWithNibName:@"DynamicsViewController"
                 bundle:nil];
    FindCourseViewController *findCourseViewCtr =
        [[FindCourseViewController alloc] init];
    MicroMajorViewController *microMajorViewCtr =
        [[MicroMajorViewController alloc] init];
    MeViewController *meViewCtr = [[MeViewController alloc] init];

    UIImage *imageOne = [UIImage imageNamed:@"kkb-iphone-tab-active"];
    UIImage *imageOneSelected =
        [UIImage imageNamed:@"kkb-iphone-tab-active-selected"];
    UIImage *imageTwo = [UIImage imageNamed:@"kkb-iphone-tab-findcourses"];
    UIImage *imageTwoSelected =
        [UIImage imageNamed:@"kkb-iphone-tab-findcourses-selected"];
    UIImage *imageThree = [UIImage imageNamed:@"kkb-iphone-tab-micromajor"];
    UIImage *imageThreeSelected =
        [UIImage imageNamed:@"kkb-iphone-tab-micromajor-selected"];
    UIImage *imageFour = [UIImage imageNamed:@"kkb-iphone-tab-mine"];
    UIImage *imageFourSelected =
        [UIImage imageNamed:@"kkb-iphone-tab-mine-selected"];

    tab1.tabBarItem = [tab1.tabBarItem initWithTitle:@"动态"
                                               image:imageOne
                                       selectedImage:imageOneSelected];
    findCourseViewCtr.tabBarItem =
        [findCourseViewCtr.tabBarItem initWithTitle:@"发现课程"
                                              image:imageTwo
                                      selectedImage:imageTwoSelected];
    microMajorViewCtr.tabBarItem =
        [microMajorViewCtr.tabBarItem initWithTitle:@"微专业"
                                              image:imageThree
                                      selectedImage:imageThreeSelected];
    meViewCtr.tabBarItem =
        [meViewCtr.tabBarItem initWithTitle:@"我的"
                                      image:imageFour
                              selectedImage:imageFourSelected];
    KKBBaseNavigationController *tabVC1 =
        [[KKBBaseNavigationController alloc] initWithRootViewController:tab1];

    KKBBaseNavigationController *tabVC3 = [[KKBBaseNavigationController alloc]
        initWithRootViewController:findCourseViewCtr];
    KKBBaseNavigationController *tabVC4 = [[KKBBaseNavigationController alloc]
        initWithRootViewController:microMajorViewCtr];
    KKBBaseNavigationController *tabVC5 = [[KKBBaseNavigationController alloc]
        initWithRootViewController:meViewCtr];

    [tabVC1.navigationBar setHidden:YES];
    [tabVC3.navigationBar setHidden:YES];
    [tabVC4.navigationBar setHidden:YES];
    [tabVC5.navigationBar setHidden:YES];

    KKBBaseTabBarViewController *tabBarController =
        [[KKBBaseTabBarViewController alloc] init];
    NSArray *controllers =
        [NSArray arrayWithObjects:tabVC1, tabVC3, tabVC4, tabVC5, nil];
    [tabBarController setViewControllers:controllers];
    return tabBarController;
}

#pragma mark - iPhone切换window的rootViewController
/**
 *  根据登录状态初始化window的rootViewController
 *
 *  @param isLogin isLogin description
 */
- (void)isiPhoneLoginSuccess:(BOOL)isLogin {
    UIViewController *rootViewController = nil;
    if (isLogin) {
        rootViewController = [self customInitiPhoneTabBarController];

    } else {
        //清理用户数据
        [GlobalOperator sharedInstance].userId = nil;
        [KKBUserInfo shareInstance].userId = nil;
        [GlobalOperator sharedInstance].user4Request.user.avatar.token =
            GUEST_TOKEN;
        [[KKBHttpClient shareInstance] setGuestToken:GUEST_TOKEN];
        [GlobalOperator sharedInstance].isLogin = NO;
        [KKBUserInfo shareInstance].isLogin = NO;

        if ([AppUtilities isFileExist:@"userInfo.json" subDir:@"UserInfo"]) {
            [[NSFileManager defaultManager]
                removeItemAtPath:[AppUtilities getTokenJSONFilePath]
                           error:nil];
        }

        CourseHomeViewController *courseHomeVC =
            [[CourseHomeViewController alloc]
                initWithNibName:@"CourseHomeViewController"
                         bundle:nil];
        KKBBaseNavigationController *navVC =
            [[KKBBaseNavigationController alloc]
                initWithRootViewController:courseHomeVC];
        rootViewController = navVC;
    }
    self.window.rootViewController = rootViewController;
}

#pragma mark - 检测接口是否返回401错误
- (void)registerNetworkResponse401Error {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(notificationNetworkResponse401Error)
               name:GB_NETWORK_RESPONSE_404ERR
             object:nil];
}

- (void)notificationNetworkResponse401Error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.window.rootViewController
                isKindOfClass:[UITabBarController class]]) {
            [self isiPhoneLoginSuccess:NO];
        }
    });
}
@end
