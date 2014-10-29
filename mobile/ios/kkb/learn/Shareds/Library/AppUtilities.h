//
//  ToolsObject.h
//  learn
//
//  Created by User on 13-5-20.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

/*
 文件说明：
 此文件为函数库文件，只存放函数，
 包括全局变量和全局常量的获取函数以及其他地方常用的函数集合
 */

#import <Foundation/Foundation.h>
#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
@class MBProgressHUD;

@interface AppUtilities : NSObject
{
    
}
//清除html标签
+(NSString *)cleanHtml:(NSMutableString *)htmlStr;
//检测网络连接状况
+ (BOOL)connectedToNetwork;

//检测网络连接状况
+ (BOOL)isExistenceNetwork;

// 检测可用的网络环境是否为wifi
+ (BOOL) IsEnableWIFI;

// 检测可用的网络环境是否为3G
+ (BOOL) IsEnable3G;

//进度条信息显示
+ (void)showHUD:(NSString *)text andView:(UIView *)view;
//显示，关闭Loading
+ (void)showLoading:(NSString*)text andView:(UIView *)view;
+ (void)closeLoading:(UIView *)view;

//返回程序Document目录
+ (NSString *)appDocDir;
//缓存目录
+ (NSString *)cacheDir;

+ (BOOL)writeFile:(NSString *)fileName subDir:(NSString *)subDir contents:(NSData *)data;

//判断文件是否存在
+ (BOOL)isFileExist:(NSString *)fileName subDir:(NSString *)subDir;

+ (NSString *)getTokenJSONFilePath;

+ (NSString *)getTokenJSONFilePathForPad;

//获取头像的保存路径
+ (NSString *)getAvatarPath;

//获取Cookies的保存路径
+ (NSString *)getCookiesPath;

//得到系统当前时间
+ (NSString *)currentSystemDate;

//得到NTP网络当前时间
+ (NSString *)currentNetworkDate;

//设置是否学习过
+(void)setIsFirstIn:(BOOL)isIn;
+(BOOL)getIsFirstIn;
//判断是否从设置页面登陆
+(void)setIsNotFromLoginView:(BOOL)isNotFromLoginView;
+(BOOL)getIsNotFromLoginView;


//转换时间格式，精确到天
+ (NSString *)convertTimeStyleGo:(NSString *)timeStr;
+ (NSString *)convertTimeStyleToDayDetial:(NSString *)timeStr;
+ (NSString *)convertTimeStyleToD:(NSString *)timeStr;
+ (NSString *)convertTimeStyle:(NSString *)timeStr;
+ (NSString *)convertTimeStyleToDay:(NSString *)timeStr;
+ (NSString *)convertTimeStyleToDayInAnnouncement:(NSString *)timeStr;
+ (NSString *)convertTimeStyleToM:(NSString *)timeStr;
+ (NSString *)convertTimeStyleTo:(NSString *)timeStr;
//日期比较，若给定的日期晚于当前系统时间，返回YES
+ (BOOL)isLaterCurrentSystemDate:(NSString *)other;
// 判断是否是空字符串
+ (BOOL) isBlankString:(NSString *)string;

// 判断该email是否合法
+ (BOOL)isMatchedEmail:(NSString *)str;

+ (BOOL)isMatchedUserName:(NSString *)str;
+ (BOOL)isMatchedChinese:(NSString *)str;

+ (BOOL)isMatchedPassword:(NSString *)str;

//适配图片的URL
+ (NSString *)adaptImageURL:(NSString *)imageURL;

+ (NSString *)adaptImageURLforPhone:(NSString *)imageURL;

//从匿名首页进入到其他页面触发登录跳转逻辑
+ (void)pushToLoginViewController:(UIViewController *)viewController;

@end

@interface UITableViewCell (CellShadows)

/** adds a drop shadow to the background view of the (grouped) cell */
- (void)addShadowToCellInTableView:(UITableView *)tableView
                       atIndexPath:(NSIndexPath *)indexPath;

@end


#pragma mark VerticalAlign
@interface UILabel (VerticalAlign)
- (void)alignTop;
- (void)alignBottom;
@end

@implementation UILabel (VerticalAlign)
- (void)alignTop
{
    //CGSize size = [self.text sizeWithFont:self.font constrainedToSize:self.bounds.size lineBreakMode:self.lineBreakMode];
    CGRect rect1 = [self.text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]} context:nil];
    CGSize size = rect1.size;
   
    if (size.height < self.bounds.size.height)
    {
        self.text = [self.text stringByAppendingString:@"\n "];
    }
    //    CGSize fontSize = [self.text sizeWithFont:self.font];
    //    double finalHeight = fontSize.height * self.numberOfLines;
    //    double finalWidth = self.frame.size.width;    //expected width of label
    //    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    //    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    //    for(int i=0; i<newLinesToPad; i++)
    //        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)alignBottom
{
    //CGSize fontSize = [self.text sizeWithFont:self.font];
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    //CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    CGRect rect1 = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]} context:nil];
    CGSize theStringSize = rect1.size;
    
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}


@end
