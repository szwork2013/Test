//
//  GlobalDefine.h
//  learn
//
//  Created by User on 13-5-20.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalDefine : NSObject

typedef enum
{
    KAIKEBA_MODULE_HOMEPAGE = 0x0001, //首页
    KAIKEBA_MODULE_COURSEUNIT= 0x0002,  //课程单元
    KAIKEBA_MODULE_ANNOUNCEMENT = 0x0004, //通知
    KAIKEBA_MODULE_USERSINCOURSE = 0x0008, //人员
    KAIKEBA_MODULE_QUIZZES = 0x0010,
    KAIKEBA_MODULE_SETTING = 0x0020,
    KAIKEBA_MODULE_WEIBO = 0x0040,
    KAIKEBA_MODULE_DISCUSSION = 0x0050,
    KAIKEBA_MODULE_ASSIGNMENT = 0x0060,
}KAIKEBA_MODULE_TYPE;

typedef enum
{
    COURSE_SCENE_TYPE_COURSEINTRODUCTION = 0, //课程简介
    COURSE_SCENE_TYPE_LECTURERINTRODUCTION, //讲师简介
    COURSE_SCENE_TYPE_UNIT, //单元
    COURSE_SCENE_TYPE_ANNOUNCEMENT, //通知
    COURSE_SCENE_TYPE_USER, //人员
    COURSE_SCENE_TYPE_QUIZ, //测验
    COURSE_SCENE_TYPE_TASK, //作业
    COURSE_SCENE_TYPE_DISCUSS, //讨论
   
}COURSE_SCENE_TYPE;

//判断是否是Retina屏幕
//#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(2048, 1536), [[UIScreen mainScreen] currentMode].size) : NO)
//#define isRetina1 ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)



#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(960, 640), [[UIScreen mainScreen] currentMode].size) : NO)
#define isRetinaForMINI ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define KAIKEBA_APPSTORE_URL @"https://itunes.apple.com/us/app/kai-ke-ba/id659238439?ls=1&mt=8"

#define KAIKEBA_APPSTORE_APPID @"659238439"

#define KAIKEBA_CONFIG_DIR  @"UserInfo"
#define UMENG_APPKEY_IPAD @"516b9d8256240ba82504fb2d"    // ipad
#define UMENG_APPKEY_IPHONE @"52649f3956240b87ae165e00"    // iphone
#define NOTIFICATION_UPDATE_SETTING_VIEW @"updateSettingView"

#define SERVER_HOST @"http://learn.kaikeba.com/"        // change
#define API_HOST @"http://learn.kaikeba.com/api/v1/"    // change

#define OpenAccountID @"1"
#define RootAccountID @"1"

#define ARCHIVER_DIR @"archiver"

#define ARCHIVER_HOMEPAGE_HEADERSLIDER @"homepage_headerslider"

#define PerPage 999999

#define DEVELOPER_TOKEN @"sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I"
#define PUBLIC_TOKEN @"YBl8FwVapvl5c3dpnFwPNybXCjhbLvUQ4uNMXytDy3NN0Pi3kPH6as3GrRArDXZR"
#define TEST_TOKEN @"fhJrKrmzOo4BLsW3r5nnwMzkzYF6YzGd5cnst9R7pLX5DRLsFHAVxKkXytZs0AA7"
#define GUEST_TOKEN @"CZA1LpNyK7CVz2aWnmuPekz5dC0yvju83DlJcOvsloYdxEbkKqwSd42Hqht03luA"

#define UPYUN_KEY @"zw8G3hrYN4rp/jC821FMFcxOuRo="
#define UPYUN_BUCKETNAME @"kaikeba-photo"
#define UPYUN_USERNAME @"kaikeba"
#define UPYUN_USERPASSWORD @"kkb654321"
#define UPYUN_EXPIRATION 200
#define UPYUN_URL @"http://kaikeba-photo.b0.upaiyun.com"


#define ALLCOURSE @"http://192.168.1.124/api/v1/accounts"//所有账户


//-------------------------------------------------------------


//-------------首页 -------------



//课程类型
#define HTTP_CMD_HOMEPAGE_CATEGORY  @"CMD_HOMEPAGE_CATEGORY"
//首页推荐数据
#define HTTP_CMD_HOMEPAGE_HEADERSLIDER  @"CMD_HOMEPAGE_HEADERSLIDER"

//首页全部课程
#define HTTP_CMD_HOMEPAGE_ALLCOURSES  @"CMD_HOMEPAGE_ALLCOURSES"

//首页我的课程
#define HTTP_CMD_HOMEPAGE_MYCOURSES  @"CMD_HOMEPAGE_MYCOURSES"

//登出
#define HTTP_CMD_HOMEPAGE_LOGOUT  @"CMD_HOMEPAGE_LOGOUT"
//badge图标
#define HTTP_CMD_HOMEPAGE_MYBADGES @"CMD_HOMEPAGE_BADGE"
//注册用户
#define HTTP_CMD_HOMEPAGE_CREATEUSER  @"CMD_HOMEPAGE_CREATEUSER"

//enroll用户
#define HTTP_CMD_HOMEPAGE_ENROLLUSER  @"CMD_HOMEPAGE_ENROLLUSER"

//修改用户
#define HTTP_CMD_HOMEPAGE_EDITAFTERCREATEUSER  @"CMD_HOMEPAGE_EDITAFTERCREATEUSER"

//修改用户
#define HTTP_CMD_HOMEPAGE_EDITUSER  @"CMD_HOMEPAGE_EDITUSER"

//获取账户的详细信息
#define HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES  @"CMD_HOMEPAGE_ACCOUNTPROFILES"

//根据code获得用户的token
#define HTTP_CMD_HOMEPAGE_EXCHANGETOKEN  @"CMD_HOMEPAGE_EXCHANGETOKEN"

//课程简介Page，用在首页课程简介浮层中的课程简介
#define HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION  @"CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION"

//讲师简介Page，用在首页课程简介浮层中的讲师简介
#define HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER  @"CMD_HOMEPAGE_INTRODUCTIONOFLECTURER"

//个人中心
#define HTTP_CMD_ACTIVITY_STREAM  @"CMD_ACTIVITY_STREAM"

//-------------我的课程详情-------------
//获取指定课程的单元Modules
#define HTTP_CMD_COURSE_MODULES  @"CMD_COURSEUNIT_MODULES"

//课程单元
#define HTTP_CMD_COURSEUNIT_PAGE  @"CMD_COURSEUNIT_PAGE"

//课程视频
#define HTTP_CMD_COURSEUNIT_VIDEO  @"CMD_COURSEUNIT_VIDEO"


//作业
#define HTTP_CMD_COURSE_ASSIGNMENT  @"CMD_COURSEUNIT_ASSIGNMENT "

//通告
#define HTTP_CMD_COURSE_ANNOUNCEMENTS  @"CMD_COURSEUNIT_ANNOUNCEMENTS"
//发送通告回复
#define HTTP_CMD_COURSE_REPLYANNOUNCEMENTS  @"CMD_COURSEUNIT_REPLYANNOUNCEMENTS"
//发送单个回复
#define HTTP_CMD_COURSE_REPLYPEOPLE @"CMD_COURSEUNIT_REPLYPEOPLE"

//讨论
#define HTTP_CMD_COURSE_DISCUSSION  @"CMD_COURSEUNIT_DISCUSSION"
//通告ALLTOPICENTRY
#define HTTP_CMD_COURSE_ANNOUNCEMENTS_ALLTOPICENTRY  @"CMD_COURSEUNIT_ANNOUNCEMENTS_ALLTOPICENTRY"

//讨论ALLTOPICENTRY
#define HTTP_CMD_COURSE_DISSCUSSION_ALLTOPICENTRY  @"CMD_COURSEUNIT_DISSCUSSION_ALLTOPICENTRY"

//课程中学生
#define HTTP_CMD_COURSE_STUDENTSINCOURSE  @"CMD_COURSE_STUDENTSINCOURSE"

//课程中老师
#define HTTP_CMD_COURSE_TEACHERSINCOURSE  @"CMD_COURSE_TEACHERSINCOURSE"

//课程中助教
#define HTTP_CMD_COURSE_TASINCOURSE  @"CMD_COURSE_TASINCOURSE"


//缓存轮播图
#define CACHE_HOMEPAGE_HEADERSLIDER  @"CACHE_HOMEPAGE_HEADERSLIDER"
//缓存全部课程
#define CACHE_HOMEPAGE_ALLCOURSE  @"CACHE_HOMEPAGE_ALLCOURSE"
//缓存课程分类
#define CACHE_HOMEPAGE_CATEGORY  @"CACHE_HOMEPAGE_CATEGORY"
//缓存我的课程
#define CACHE_HOMEPAGE_MYCOURSE  @"CACHE_HOMEPAGE_MYCOURSE"
//缓存Badge图标
#define CACHE_HOMEPAGE_BADGE @"CACHE_HOMEPAGE_BADGE"
//缓存个人信息
#define CACHE_HOMEPAGE_SELFINFO @"CACHE_HOMEPAGE_SELFINFO"
//缓存课程单元
#define CACHE_COURSEUNIT_MODULES @"CACHE_COURSEUNIT_MODULES"


//通知
#define NOTIFICATION_BEGIN_GETVIDEO_INFO @"beginGetVideoInfo"
#define NOTIFICATION_RELEASE_PLAYER @"pleaseReleasePlayer"


//数据库
#define SQLITE_DATA_NAME @"selectedIndex"

#define SQLITE_CREATE_DATA_LAG @"CREATE TABLE IF EXIST SELECTEDINDEX(ID INTEGER PRIMARY KEY ID)"
#define SQLITE_INSERT_DATA_LAG @"INSERT TO SELECTEDINDEX(%d)VALUES(%d)"
#define SQLITE_DELETE_DATA_LAG @"DELETE FROM SELECTEDINDEX WHERE "

//通知
#define GB_NETWORK_RESPONSE_404ERR @"GB_NETWORK_RESPONSE_404ERR"

@end
