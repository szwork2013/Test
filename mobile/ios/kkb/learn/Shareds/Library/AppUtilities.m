//
//  ToolsObject.m
//  learn
//
//  Created by User on 13-5-20.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <SystemConfiguration/SCNetworkReachability.h>
#import <QuartzCore/QuartzCore.h>
#import "AppUtilities.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "GlobalDefine.h"
#import "ios-ntp.h"
#import "RegexKitLite.h"

#import "LoginViewController.h"

#define isRetinaPad                                                            \
    ([UIScreen instancesRespondToSelector:@selector(currentMode)]              \
         ? CGSizeEqualToSize(CGSizeMake(2048, 1536),                           \
                             [[UIScreen mainScreen] currentMode].size)         \
         : NO)
static BOOL isFirstIn = NO;
static BOOL isNotFromLoginView = NO;

NSUInteger DeviceSystemMajorVersion();
NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
            componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    NSLog(@"%lu", (unsigned long)_deviceSystemMajorVersion);
    return _deviceSystemMajorVersion;
}

@implementation AppUtilities
#pragma mark - 用来设置是否是第一次登陆
+ (void)setIsFirstIn:(BOOL)isIn {
    isFirstIn = isIn;
}

+ (BOOL)getIsFirstIn {
    return isFirstIn;
}
+ (void)setIsNotFromLoginView:(BOOL)isNotOrYes {
    isNotFromLoginView = isNotOrYes;
}
+ (BOOL)getIsNotFromLoginView {
    return isNotFromLoginView;
}

#pragma mark - not zxj
+ (NSString *)cleanHtml:(NSMutableString *)htmlStr {
    if (htmlStr != nil) {
        NSString *str = [NSString stringWithString:htmlStr];

        NSString *regEx = @"<([^>]*)>";
        NSString *stringWithoutHTML =
            [str stringByReplacingOccurrencesOfRegex:regEx withString:@""];
        return stringWithoutHTML;
    }
    return nil;
}

#pragma mark 检测网络连接状况

/*
 此函数用于判断网络连接状况
 连接正常返回YES
 无连接返回NO

 需要注意的是：函数为底层调用，只能判断手机是否接入网络，不能判断其他网络问题（如服务器响应与否）
 */
+ (BOOL)connectedToNetwork {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability =
        SCNetworkReachabilityCreateWithAddress(NULL,
                                               (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags =
        SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags) {
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isWWAN = flags & kSCNetworkReachabilityFlagsIsWWAN;
    return (isReachable && (!needsConnection || isWWAN)) ? YES : NO;
}

//检测网络连接状况
+ (BOOL)isExistenceNetwork {
    BOOL isExistenceNetwork = NO;

    Reachability *reachability =
        [Reachability reachabilityForInternetConnection];

    switch ([reachability currentReachabilityStatus]) {
    case NotReachable:
        isExistenceNetwork = NO;
        // NSLog(@"没有网络");
        break;
    case ReachableViaWWAN:
        isExistenceNetwork = YES;
        // NSLog(@"当前网络为3G");
        break;
    case ReachableViaWiFi:
        isExistenceNetwork = YES;
        // NSLog(@"当前网络为Wifi");
        break;
    }

    return isExistenceNetwork;
}

// 检测可用的网络环境是否为wifi
+ (BOOL)IsEnableWIFI {
    return (
        [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] !=
        NotReachable);
}

// 检测可用的网络环境是否为3G
+ (BOOL)IsEnable3G {
    return (
        [[Reachability
                reachabilityForInternetConnection] currentReachabilityStatus] !=
        NotReachable);
}

#pragma mark 进度条信息显示
/*
 此函数为消息提示，用于进度条信息显示
 */
+ (void)showHUD:(NSString *)text andView:(UIView *)view {
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.frame = view.frame;
    hud.labelText = text;
    hud.dimBackground = YES;
    hud.square = YES;
    hud.color = [UIColor lightGrayColor];
    [hud setHidden:NO];
    [hud show:YES];
    [view addSubview:hud];
    [hud performSelector:@selector(removeFromSuperview)
              withObject:hud
              afterDelay:2.0];
}

//显示，关闭Loading
+ (void)showLoading:(NSString *)text andView:(UIView *)view {
    UIView *v = [view viewWithTag:0xff00aa01];
    if (v)
        return;

    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.frame = view.frame;
    hud.labelText = text;
    hud.dimBackground = YES;
    hud.square = YES;
    hud.color = [UIColor lightGrayColor];
    [hud setHidden:NO];
    [hud show:YES];
    hud.tag = 0xff00aa01;
    [view addSubview:hud];
}

+ (void)closeLoading:(UIView *)view {
    UIView *v = [view viewWithTag:0xff00aa01];
    if (v)
        [v removeFromSuperview];
}
//显示提示
#pragma mark 文件、目录处理
//返回程序Document目录
+ (NSString *)appDocDir {
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; //去处需要的路径
    return documentsDirectory;
}

+ (NSString *)cacheDir {
    NSString *writeDir =
        [[self appDocDir] stringByAppendingPathComponent:@"cache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:writeDir]) {
        [fileManager createDirectoryAtPath:writeDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return writeDir;
}

//写文件
+ (BOOL)writeFile:(NSString *)fileName
           subDir:(NSString *)subDir
         contents:(NSData *)data {
    //创建目录
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *writeDir =
        [[self appDocDir] stringByAppendingPathComponent:subDir];
    if (![fileManager fileExistsAtPath:writeDir]) {
        [fileManager createDirectoryAtPath:writeDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }

    NSString *_filename = [[self appDocDir]
        stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@/%@", subDir, fileName]];

    return [data writeToFile:_filename atomically:NO];
}

//判断文件是否存在
+ (BOOL)isFileExist:(NSString *)fileName subDir:(NSString *)subDir {
    NSString *_filename = [[AppUtilities appDocDir]
        stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@/%@", subDir, fileName]];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    return ([fileManager fileExistsAtPath:_filename]);
}

+ (NSString *)getTokenJSONFilePath {
    NSString *path = [[AppUtilities appDocDir]
        stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%@/%@", KAIKEBA_CONFIG_DIR,
                                       @"userInfo.json"]];

    return path;
}

+ (NSString *)getTokenJSONFilePathForPad {
    NSString *path = [[AppUtilities appDocDir]
        stringByAppendingPathComponent:
            [NSString
                stringWithFormat:@"%@/%@", KAIKEBA_CONFIG_DIR, @"token.json"]];
    return path;
}

+ (NSString *)getAvatarPath {
    NSString *avatarPath =
        [[AppUtilities cacheDir] stringByAppendingPathComponent:@"avatar"];
    return avatarPath;
}

+ (NSString *)getCookiesPath {
    NSString *cookiesPath =
        [[AppUtilities cacheDir] stringByAppendingPathComponent:@"cookie.json"];

    return cookiesPath;
}

#pragma mark 日期处理

+ (NSString *)currentSystemDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];

    return dateString;
}

+ (NSString *)currentNetworkDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate networkDate]];

    return dateString;
}

//转换时间格式，精确到天
+ (NSString *)convertTimeStyle:(NSString *)timeStr {
    if (timeStr == nil) {
        NSString *date = @"";
        return date;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateTime = [formatter dateFromString:timeStr];
    //    NSLog(@"====%@",dateTime);/Users/user/Desktop/learn副本

    [formatter setDateFormat:@"MM月dd日"];
    NSString *date = [formatter stringFromDate:dateTime];

    //    NSLog(@"====%@",date);
    return date;
}
+ (NSString *)convertTimeStyleToD:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime =
        [formatter dateFromString:[self applyTimezoneFixForDate:timeStr]];

    [formatter setDateFormat:@"MM月dd日"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}
+ (NSString *)convertTimeStyleTo:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime =
        [formatter dateFromString:[self applyTimezoneFixForDate:timeStr]];

    [formatter setDateFormat:@"MM月dd日 yyyy年"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}
+ (NSString *)convertTimeStyleGo:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime =
        [formatter dateFromString:[self applyTimezoneFixForDate:timeStr]];

    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}

+ (NSString *)convertTimeStyleToDayDetial:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateTime = [formatter dateFromString:timeStr];

    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}
+ (NSString *)convertTimeStyleToDay:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime =
        [formatter dateFromString:[self applyTimezoneFixForDate:timeStr]];

    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}
+ (NSString *)convertTimeStyleToM:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime =
        [formatter dateFromString:[self applyTimezoneFixForDate:timeStr]];

    [formatter setDateFormat:@"MM月dd日    HH:mm"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}
//转换时间格式，精确到天
+ (NSString *)convertTimeStyleToDayInAnnouncement:(NSString *)timeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateTime = [formatter dateFromString:timeStr];

    [formatter setDateFormat:@"MM月dd日 yyyy年"];
    NSString *date = [formatter stringFromDate:dateTime];

    return date;
}

+ (NSString *)applyTimezoneFixForDate:(NSString *)date {
    NSRange colonRange = [date
        rangeOfCharacterFromSet:[NSCharacterSet
                                    characterSetWithCharactersInString:@":"]
                        options:NSBackwardsSearch];
    return [date stringByReplacingCharactersInRange:colonRange withString:@""];
}

#pragma mark 判断处理

// 判断是否是空字符串
+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }

    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }

    if ([[string stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isLaterCurrentSystemDate:(NSString *)other {
    //    NSLog(@"%@",other);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *otherDate = [dateFormatter dateFromString:other];
    NSDate *currentSystemDate =
        [dateFormatter dateFromString:[self currentNetworkDate]];
    //    NSDate *currentSystemDate = [NSDate date];
    //    NSLog(@"%@",otherDate);

    if ([currentSystemDate compare:otherDate] == NSOrderedDescending) {
        return NO;
    } else if ([currentSystemDate compare:otherDate] == NSOrderedSame ||
               [currentSystemDate compare:otherDate] == NSOrderedAscending) {
        return YES;
    }

    return NO;
}

/*
 判断该email是否合法
 输入参数：要判断的内容
 输出参数：true为合法，false为不合法
 */
+ (BOOL)isMatchedEmail:(NSString *)str {
    /*
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^([\\w-])++(\\.?[\\w-])*+\\+{1}+([\\w-])++(\\.?[\\w-])*@([\\w-])+((\\.[\\w-]+)+)$\
                                              |^([\\w-])++(\\.?[\\w-])*+@([\\w-])+((\\.[\\w-]+)+)$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0,
    str.length)];
    [regularexpression release];

    if (numberofMatch == 0)
    {
        return NO;
    }

    return YES;
     */
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:str];
}

+ (BOOL)isMatchedUserName:(NSString *)str {
    if (str.length < 3 || str.length > 18) {
        return NO;
    }

    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
        initWithPattern:@"^[a-zA-Z0-9\\u4e00-\\u9fa5][\\u4e00-\\u9fa5\\w\\.-]*$"
                options:NSRegularExpressionCaseInsensitive
                  error:nil];
    NSUInteger numberofMatch =
        [regularexpression numberOfMatchesInString:str
                                           options:NSMatchingReportProgress
                                             range:NSMakeRange(0, str.length)];

    if (numberofMatch == 0) {
        return NO;
    }

    return YES;
}

+ (BOOL)isMatchedChinese:(NSString *)str {
    if (str.length < 2 || str.length > 6) {
        return NO;
    }
    //    NSLog(@"%d",str.length);
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
        initWithPattern:@"^[\\u4e00-\\u9fa5]*$"
                options:NSRegularExpressionCaseInsensitive
                  error:nil];
    NSUInteger numberofMatch =
        [regularexpression numberOfMatchesInString:str
                                           options:NSMatchingReportProgress
                                             range:NSMakeRange(0, str.length)];

    //    NSLog(@"%d",numberofMatch);

    if (numberofMatch == 0) {
        return NO;
    }

    return YES;
}

+ (BOOL)isMatchedPassword:(NSString *)str {
    if (str.length < 6 || str.length > 16) {
        return NO;
    }

    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
        initWithPattern:
            @"^[~`!@#%&()-={};:'\",<>/\\\\|\\[\\]\\.\\*\\+\\?\\^\\$\\w]*$"
                options:NSRegularExpressionCaseInsensitive
                  error:nil];
    NSUInteger numberofMatch =
        [regularexpression numberOfMatchesInString:str
                                           options:NSMatchingReportProgress
                                             range:NSMakeRange(0, str.length)];

    if (numberofMatch == 0) {
        return NO;
    }

    return YES;
}

#pragma mark 图片处理

+ (NSString *)adaptImageURL:(NSString *)imageURL {
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", UPYUN_URL]
            evaluateWithObject:imageURL]) {
        if ([[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"/cover"]
                evaluateWithObject:imageURL]) {
            if (isRetinaPad) {
                //                  NSLog(@"%@",[NSString
                //                  stringWithFormat:@"%@!cc.ipad.2",
                //                  imageURL]);
                return [NSString stringWithFormat:@"%@!cc.ipad.2", imageURL];

            } else if (isRetinaForMINI) {
                //                 NSLog(@"%@",[NSString
                //                 stringWithFormat:@"%@!cc.ipad.2", imageURL]);
                return [NSString stringWithFormat:@"%@!cc.ipad.2", imageURL];
            } else {
                //                NSLog(@"%@",[NSString
                //                stringWithFormat:@"%@!cc.ipad", imageURL]);
                return [NSString stringWithFormat:@"%@!cc.ipad", imageURL];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",
                                                     @"/instructor-avatar"]
                       evaluateWithObject:imageURL]) {
            if (isRetinaPad) {
                return [NSString stringWithFormat:@"%@!ia.ipad.2", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!ia.ipad", imageURL];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",
                                                     @"/home-slider/"]
                       evaluateWithObject:imageURL] &&
                   ![[NSPredicate
                       predicateWithFormat:@"SELF ENDSWITH %@", @"!hs.ipad"]
                       evaluateWithObject:imageURL]) {
            if (isRetinaPad) {
                //                NSLog(@"%@",imageURL);
                NSRange range = [imageURL rangeOfString:@""];
                NSString *str = [imageURL substringToIndex:range.location];
                return
                    [NSString stringWithFormat:@"%@.tablet.png!hs.ipad.2", str];

            } else if (isRetinaForMINI) {

                NSRange range = [imageURL rangeOfString:@""];
                NSString *str = [imageURL substringToIndex:range.location];
                //                   NSLog(@"%@",[NSString
                //                   stringWithFormat:@"%@.tablet.png!hs.ipad.2",
                //                   str]);
                return
                    [NSString stringWithFormat:@"%@.tablet.png!hs.ipad.2", str];
            } else {
                NSRange range = [imageURL rangeOfString:@""];
                NSString *str = [imageURL substringToIndex:range.location];
                //                NSLog(@"%@",str);

                //                 NSLog(@"===%@",[NSString
                //                 stringWithFormat:@"%@.tablet.png!hs.ipad",
                //                 str]);
                return
                    [NSString stringWithFormat:@"%@.tablet.png!hs.ipad", str];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",
                                                     @"/user-avatar/"]
                       evaluateWithObject:imageURL] &&
                   ![[NSPredicate
                       predicateWithFormat:@"SELF ENDSWITH %@", @"!sa.ipad"]
                       evaluateWithObject:imageURL]) {
            if (isRetinaPad || isRetinaForMINI) {
                return [NSString stringWithFormat:@"%@!sa.ipad.2", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!sa.ipad", imageURL];
            }
        }
    }

    return imageURL;
}
+ (NSString *)adaptImageURLforPhone:(NSString *)imageURL {
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", UPYUN_URL]
            evaluateWithObject:imageURL]) {
        if ([[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"/cover"]
                evaluateWithObject:imageURL]) {
            if (isRetina) {
                return [NSString stringWithFormat:@"%@!cc.iphone", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!cc.iphone", imageURL];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",
                                                     @"/instructor-avatar"]
                       evaluateWithObject:imageURL]) {
            if (isRetina) {
                return [NSString stringWithFormat:@"%@!ia.iphone", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!ia.iphone", imageURL];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",
                                                     @"/home-slider/"]
                       evaluateWithObject:imageURL] &&
                   ![[NSPredicate
                       predicateWithFormat:@"SELF ENDSWITH %@", @"!hs.ipad"]
                       evaluateWithObject:imageURL]) {
            if (isRetina) {
                return [NSString stringWithFormat:@"%@!hs.iphone", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!hs.iphone", imageURL];
            }
        } else if ([[NSPredicate predicateWithFormat:@"SELF CONTAINS %@",
                                                     @"/user-avatar/"]
                       evaluateWithObject:imageURL] &&
                   ![[NSPredicate
                       predicateWithFormat:@"SELF ENDSWITH %@", @"!sa.ipad"]
                       evaluateWithObject:imageURL]) {
            if (isRetina) {
                return [NSString stringWithFormat:@"%@!sa.iphone", imageURL];
            } else {
                return [NSString stringWithFormat:@"%@!sa.iphone", imageURL];
            }
        }
    }

    return imageURL;
}

//从匿名首页进入到其他页面触发登录跳转逻辑
+ (void)pushToLoginViewController:(UIViewController *)viewController {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [viewController.navigationController pushViewController:loginVC
                                                   animated:YES];
}

@end

@implementation UITableViewCell (CellShadows)

/** adds a drop shadow to the background view of the (grouped) cell */
- (void)addShadowToCellInTableView:(UITableView *)tableView
                       atIndexPath:(NSIndexPath *)indexPath {
    BOOL isFirstRow = !indexPath.row;
    BOOL isLastRow = (indexPath.row ==
                      [tableView numberOfRowsInSection:indexPath.section] - 1);

    // the shadow rect determines the area in which the shadow gets drawn
    CGRect shadowRect = CGRectInset(self.backgroundView.bounds, 0, -10);
    if (isFirstRow)
        shadowRect.origin.y += 10;
    else if (isLastRow)
        shadowRect.size.height -= 10;

    // the mask rect ensures that the shadow doesn't bleed into other table
    // cells
    CGRect maskRect = CGRectInset(self.backgroundView.bounds, -20, 0);
    if (isFirstRow) {
        maskRect.origin.y -= 10;
        maskRect.size.height += 10;
    } else if (isLastRow)
        maskRect.size.height += 10;

    // now configure the background view layer with the shadow
    CALayer *layer = self.backgroundView.layer;
    layer.shadowColor = [UIColor redColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 3;
    layer.shadowOpacity = 0.75;
    layer.shadowPath =
        [UIBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:5]
            .CGPath;
    layer.masksToBounds = NO;

    // and finally add the shadow mask
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRect:maskRect].CGPath;
    layer.mask = maskLayer;
}

@end
