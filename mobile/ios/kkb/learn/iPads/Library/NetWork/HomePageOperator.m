//
//  HomePageOperator.m
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "HomePageOperator.h"
#import "GlobalDefine.h"
#import "JSONKit.h"
#import "CourseUnitStructs.h"
#import "GlobalOperator.h"
#import "UpYun.h"
#import "AppUtilities.h"
#import "FileUtil.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"

@interface HomePageOperator()<UpYunDelegate>
{
    NSMutableDictionary *dictionary;
   
}

@end

@implementation HomePageOperator

@synthesize homePage;
@synthesize courseBriefIntroduction;
@synthesize introductionOfLecturer;
@synthesize isEntrolled;


- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_HOMEPAGE;
        self.homePage = [[HomePageStructs alloc] init];
        dictionary = [[NSMutableDictionary alloc] init];
    
    }
    
    return self;
}


//网络Url--------------------------------
//获取最新版本信息
//- (NSString *)getLatestVersionUrl
//{
//    NSString *url = [NSString stringWithFormat:@"%@latest-version.json", DUMMY_HOST];
//    
//    return url;
//}
//
////获取关于页面
//- (NSString *)getAboutPageUrl
//{
//    NSString *url = [NSString stringWithFormat:@"http://kaikeba-file.b0.upaiyun.com/pages/about4ipad.html"];
//    
//    return url;
//}
//
////获取评分URL
//- (NSString *)getStarMeUrl
//{
//    NSString *url = [NSString stringWithFormat:@"%@star-me.json", DUMMY_HOST];
//    
//    return url;
//}
//
//- (NSString *)getMyCoursesWithMetaUrl:(NSString *)courseId
//{
//    NSString *url = [NSString stringWithFormat:@"%@course/%@/meta.json", DUMMY_HOST, courseId];
//    
//    return url;
//}
//
////填充/获取课程元数据
//- (NSString *)getAllCourseMetaUrl:(NSString *)courseID
//{
//    NSString *url = [NSString stringWithFormat:@"%@courses/%@/all-courses-meta.json", @"http://www.kaikeba.com/api/v2/", courseID];
//    
//    return url;
//}
//
////登录的url
- (NSString *)loginUrl
{
    NSString *url = nil;
//    NSString *url = [NSString stringWithFormat:@"%@login/oauth2/auth?client_id=4&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob", SERVER_HOST];
    return url;
}
//
////获取BlueButtonUrl
//- (NSString *)getBlueButtonUrl:(NSString *)courseId
//{
//    NSString *url = [NSString stringWithFormat:@"%@course/%@/blue-button.json", DUMMY_HOST, courseId];
//    
//    return url;
//}
//


//网络请求 -------------------------------

- (void)requestEnrollments:(id)delegate token:(NSString *)token courseID:(NSString *)couseID  user_id:(NSString *)user_id

{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/enrollments?enrollment[user_id]=%@&enrollment[type]=StudentEnrollment&enrollment[enrollment_state]=active", API_HOST,couseID,user_id];
    
  
   NSString *json = @"";
    
   [self postJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_ENROLLUSER jsonUrl:jsonUrl token:token json:json];

    
}

- (void)requestAllCoursesCategory:(id)delegate token:(NSString *)token
{
    
//    NSString* a = @"http://superclass.kaikeba.com/ocw/srv/api.php?num=999&courseid=32&token=";
    NSString *jsonUrl = [NSString stringWithFormat:@"%@categories.json", @"http://www.kaikeba.com/api/v2/"];

    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_CATEGORY jsonUrl:jsonUrl token:token];
    
}

//首页推荐数据,轮播图信息
- (void)requestHeaderSliders:(id)delegate token:(NSString *)token
{
   
     NSString *jsonUrl = [NSString stringWithFormat:@"%@home-slider.json", @"http://www.kaikeba.com/api/v2/"];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_HEADERSLIDER jsonUrl:jsonUrl token:token];
    
}

//首页全部课程数据
- (void)requestAllCourses:(id)delegate token:(NSString *)token
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@all-courses-meta.json", @"http://www.kaikeba.com/api/v2/"];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_ALLCOURSES jsonUrl:jsonUrl token:token];
}

//首页我的课程数据
- (void)requestMyCourses:(id)delegate token:(NSString *)token
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses?per_page=%d", API_HOST, PerPage];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_MYCOURSES jsonUrl:jsonUrl token:token];
}
//首页badge图标
- (void)requestBadge:(id)delegate token:(NSString *)token
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@badges-info.json",@"http://www.kaikeba.com/api/v2/"];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_MYBADGES jsonUrl:jsonUrl token:token];
}
//登出
- (void)requestLogout:(id)delegate token:(NSString *)token
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@logout", SERVER_HOST];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_LOGOUT jsonUrl:jsonUrl token:token];
}

//注册用户
- (void)requestCreateUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request
{
    [dictionary removeAllObjects];
    [dictionary setObject:delegate forKey:@"delegate"];
    [dictionary setObject:token forKey:@"token"];
    //    [dictionary setObject:user4Request forKey:@"user4Request"];
    
    [GlobalOperator sharedInstance].user4Request = user4Request;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[user4Request toDictionary]
                                                       options:0
                                                         error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    
    NSString *jsonUrl = [NSString stringWithFormat:@"%@accounts/%@/users", API_HOST, OpenAccountID];
//    NSString *jsonUrl = [NSString stringWithFormat:@"http://www-test.kaikeba.com/api/v3/users/sign_up"];
    
    [self postJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_CREATEUSER jsonUrl:jsonUrl token:token json:jsonString];
}

- (void)requestEditAfterCreateUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[user4Request toDictionary]
                                                       options:0
                                                         error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsonUrl = [NSString stringWithFormat:@"%@users/%@", API_HOST, [GlobalOperator sharedInstance].userId];
    
    [self putJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_EDITAFTERCREATEUSER jsonUrl:jsonUrl token:token json:jsonString];
}

//修改用户
- (void)requestEditUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request
{
    User4Request *user = [[User4Request alloc] init];
    user.pseudonym.unique_id = user4Request.pseudonym.unique_id;
    user.pseudonym.send_confirmation = user4Request.pseudonym.send_confirmation;
    user.pseudonym.password = user4Request.pseudonym.password;
    user.user.name = user4Request.user.name;
    user.user.time_zone = user4Request.user.time_zone;
    user.user.sortable_name = user4Request.user.sortable_name;
    user.user.short_name = user4Request.user.short_name;
    user.user.locale = user4Request.user.locale;
    user.user.avatar.token = nil;
    user.user.avatar.url = user4Request.user.avatar.url;
    
    NSString *json = [[user toDictionary] JSONString];
    
    NSString *jsonUrl = [NSString stringWithFormat:@"%@users/%@", API_HOST, [GlobalOperator sharedInstance].userId];
    
    [self putJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_EDITUSER jsonUrl:jsonUrl token:token json:json];
}

//修改用户WithAvatar
- (void)requestEditUserWithAvatar:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request
{
    UpYun *uy = [[UpYun alloc] init];
    uy.delegate = self;
    uy.expiresIn = UPYUN_EXPIRATION;
    uy.bucket = UPYUN_BUCKETNAME;
    uy.passcode = UPYUN_KEY;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"edit" forKey:@"type"];
    
    [dictionary removeAllObjects];
    [dictionary setObject:delegate forKey:@"delegate"];
    [dictionary setObject:token forKey:@"token"];
    //    [dictionary setObject:user4Request forKey:@"user4Request"];
    uy.params = params;
    
    NSString *savekey = [NSString stringWithFormat:@"/user-avatar/%@-%d", [GlobalOperator sharedInstance].userId, (int)[[NSDate date] timeIntervalSinceReferenceDate]];
    
    [GlobalOperator sharedInstance].user4Request.user.avatar.url = [NSString stringWithFormat:@"%@%@", UPYUN_URL, savekey];
    [uy uploadImagePath:[AppUtilities getAvatarPath] savekey:savekey];
}

//获取账户的详细信息
- (void)requestAccountProfiles:(id)delegate token:(NSString *)token accoundId:(NSString *)accoundId
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@users/%@/profile", API_HOST, accoundId];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES jsonUrl:jsonUrl token:token];
}

//根据code获得用户的token
- (void)requestExchangeToken:(id)delegate token:(NSString *)token code:(NSString *)code
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@login/oauth2/token?client_id=4&client_secret=znuZbCRiLGbsUiCWP64eM2CwwnSfW87LkvRu8EfwENjFkFUbztChqQnuMcTFw1VH&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=%@", SERVER_HOST, code];    
    [self postJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_EXCHANGETOKEN jsonUrl:jsonUrl token:token json:nil];
}
//获取个人中心列表
- (void)requestActivityStream:(id)delegate token:(NSString *)token
{
     NSString *jsonUrl = [NSString stringWithFormat:@"%@users/self/activity_stream?per_page=%d", API_HOST,PerPage];
    
     [self getJSONFromUrl:delegate command:HTTP_CMD_ACTIVITY_STREAM jsonUrl:jsonUrl token:token];
}

//网络解析 -------------------------------

-(void)parseEnrollments:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    NSLog(@"dic == %@",[dic objectForKey:@"course_id"]);
    if([dic objectForKey:@"course_id"]){
    
   
    MyCourseItem *item = [[MyCourseItem alloc] init];
    
 
    for (AllCoursesItem * allCoursesItem in homePage.allCoursesArray) {

        if([[dic objectForKey:@"course_id"] integerValue] == [allCoursesItem.courseId intValue])
        {
            item.courseId = [dic objectForKey:@"course_id"] ;
            item.courseName = allCoursesItem.courseName;
            item.schoolName = allCoursesItem.schoolName;
            item.courseType = allCoursesItem.courseType;
            item.courseBrief = allCoursesItem.courseBrief;
            item.start_at = allCoursesItem.startDate;
            if([item.courseType isEqualToString:@"guide"]){
                NSString * num =  [allCoursesItem.estimate substringToIndex:1];
                NSLog(@"%@",item.start_at);
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate* date = [formatter dateFromString:item.start_at];
                NSLog(@"%@",date);
                
                NSTimeInterval some_day = 24*60*60*[num intValue]*7;
                
                NSDate *end_at = [date dateByAddingTimeInterval: some_day];
                NSLog(@"%@",end_at);
                
                
                NSString *confromTimespStr = [formatter stringFromDate:end_at];
                NSLog(@"confromTimespStr =  %@",confromTimespStr);
                
                item.end_at = confromTimespStr;
            }
            
            item.instructorAvatar = allCoursesItem.instructorAvatar;
            item.instructorName = allCoursesItem.instructorName;
            item.instructorTitle = allCoursesItem.instructorTitle;
            item.coverImage = allCoursesItem.coverImage;
            
            if(![homePage.myCoursesArray containsObject:item]){
            [homePage.myCoursesArray addObject:item];
            }
        }
      
    }
    
    [self cacheMyCourse];
   
    }
    
}
//个人中心
- (void)parseActivityStream:(NSString *)jsonDatas
{
     NSArray *array = [jsonDatas objectFromJSONString];
//    NSLog(@"%@",jsonDatas);
     [homePage.announcementArray removeAllObjects];
    
    for(NSDictionary *dic in array)
    {
//       if([@"Announcement" isEqualToString:[dic objectForKey:@"type"]]){
        MyAnnouncement *myAnnouncement = [[MyAnnouncement alloc] init];
        myAnnouncement.type = [dic objectForKey:@"type"];
        myAnnouncement.course_id = [dic objectForKey:@"course_id"];
        if ([myAnnouncement.type isEqualToString:@"Announcement"]) {
            myAnnouncement.announcement_id = [dic objectForKey:@"announcement_id"];
        }else if ([myAnnouncement.type isEqualToString:@"DiscussionTopic"])
        {
             myAnnouncement.announcement_id = [dic objectForKey:@"discussion_topic_id"];
        }else if ([myAnnouncement.type isEqualToString:@"Message"]) {
            myAnnouncement.url = [dic objectForKey:@"html_url"];
            //            NSLog(@"%@",myAnnouncement.url);
            NSArray *arr=[myAnnouncement.url componentsSeparatedByString:@"/"];
            //            NSLog(@"===%@",[arr objectAtIndex:arr.count-1]);
            myAnnouncement.announcement_id = [arr objectAtIndex:arr.count-1];
        }
        myAnnouncement.title = [dic objectForKey:@"title"];
        myAnnouncement.created_at = [dic objectForKey:@"created_at"];
        myAnnouncement.hasRead = NO;
//        NSLog(@"%@",myAnnouncement.type);
//         NSLog(@"%@",self.homePage.myCoursesArray);
        
        for (MyCourseItem *myCourseItem in self.homePage.myCoursesArray) {
            if([myAnnouncement.course_id intValue]== [myCourseItem.courseId intValue])
            {
                [self.homePage.announcementArray addObject:myAnnouncement];
            }
        }

//        }
    }
//    NSLog(@"%@",self.homePage.announcementArray);
}
//首页推荐数据
- (void)parseHeaderSliders:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    
    for(NSDictionary *dic in array)
    {
        HomePageSliderItem *sliderItem = [[HomePageSliderItem alloc] init];
        
        sliderItem.courseBrief = [dic objectForKey:@"courseBrief"];
        sliderItem.courseTitle = [dic objectForKey:@"courseTitle"];
        sliderItem._id = [dic objectForKey:@"id"];
        sliderItem.sliderImage = [dic objectForKey:@"sliderImage"];
        
        [self.homePage.headerSliderArray addObject:sliderItem];
    }
    [self cacheHeaderSliders];
}

//首页全部课程数据
- (void)parseAllCourses:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [homePage.allCoursesArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        AllCoursesItem *item = [[AllCoursesItem alloc] init];
        
        item.courseId = [dic objectForKey:@"id"];
        item.courseName = [dic objectForKey:@"courseName"];
        item.courseType = [dic objectForKey:@"courseType"];
        item.courseBrief = [dic objectForKey:@"courseBrief"];
        item.coverImage = [dic objectForKey:@"coverImage"];
        item.promoVideo = [dic objectForKey:@"promoVideo"];
        item.price = [dic objectForKey:@"price"];
        item.startDate = [dic objectForKey:@"startDate"];
        item.schoolName = [dic objectForKey:@"schoolName"];
        item.trialURL = [dic objectForKey:@"trialURL"];
        item.payURL = [dic objectForKey:@"payURL"];
        item.instructorAvatar = [dic objectForKey:@"instructorAvatar"];
        item.instructorName = [dic objectForKey:@"instructorName"];
        item.instructorTitle = [dic objectForKey:@"instructorTitle"];
        item.courseIntro = [dic objectForKey:@"courseIntro"];
        item.estimate = [dic objectForKey:@"estimate"];
        item.courseKeywords =[dic objectForKey:@"courseKeywords"];
        item.courseNum =[dic objectForKey:@"courseNum"];
        item.courseBadges = [dic objectForKey:@"courseBadges"];
        item.visible = [dic objectForKey:@"visible"];
        item.courseCategory = [dic objectForKey:@"courseCategory"];
        [homePage.allCoursesArray addObject:item];
    }
    [self cacheAllCourse];
}
-(void)parseMyBadges:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [homePage.badgesArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        MyBadges *item = [[MyBadges alloc] init];
        
        item.badge_id = [dic objectForKey:@"id"];
        item.badgeTitle = [dic objectForKey:@"badgeTitle"];
        item.image4small = [dic objectForKey:@"image4small"];
        item.image4big = [dic objectForKey:@"image4big"];
        
        [homePage.badgesArray addObject:item];
    }
    [self cacheBadges];
    
}
//首页我的课程数据
- (void)parseMyCourses:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [homePage.myCoursesArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        
        //         AllCoursesItem * allCoursesItem = [[[AllCoursesItem alloc] init] autorelease];
        
        MyCourseItem *item = [[MyCourseItem alloc] init];
        //        NSLog(@"%@",[dic objectForKey:@"id"]);
        item.courseId = [dic objectForKey:@"id"];
        //        NSLog(@"%@",homePage.allCoursesArray);
        for (AllCoursesItem * allCoursesItem in homePage.allCoursesArray) {
            //             NSLog(@"%@",allCoursesItem.courseId);
            //            NSLog(@"====%d",[item.courseId intValue]);
            if([item.courseId intValue] == [allCoursesItem.courseId intValue])
            {
                item.courseName = allCoursesItem.courseName;
                item.schoolName = allCoursesItem.schoolName;
                item.courseType = allCoursesItem.courseType;
                item.courseBrief = allCoursesItem.courseBrief;
                item.start_at = allCoursesItem.startDate;
                if([item.courseType isEqualToString:@"guide"]){
                    NSString * num =  [allCoursesItem.estimate substringToIndex:1];
                    NSLog(@"%@",item.start_at);
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                    [formatter setDateStyle:NSDateFormatterMediumStyle];
//                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                     [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate* date = [formatter dateFromString:item.start_at];
                     NSLog(@"%@",date);
                   
                    NSTimeInterval some_day = 24*60*60*[num intValue]*7;
    
                    NSDate *end_at = [date dateByAddingTimeInterval: some_day];
                    NSLog(@"%@",end_at);

                 
                    NSString *confromTimespStr = [formatter stringFromDate:end_at];
                    NSLog(@"confromTimespStr =  %@",confromTimespStr);
                    
                    item.end_at = confromTimespStr;
                }
                
                item.instructorAvatar = allCoursesItem.instructorAvatar;
                item.instructorName = allCoursesItem.instructorName;
                item.instructorTitle = allCoursesItem.instructorTitle;
                item.coverImage = allCoursesItem.coverImage;
                
                [homePage.myCoursesArray addObject:item];
            }
            //        item.courseName = [dic objectForKey:@"name"];
            
            //        item.account_id = [dic objectForKey:@"account_id"];
            //        item.course_code = [dic objectForKey:@"course_code"];
            //        item.start_at = [dic objectForKey:@"start_at"];
            //        item.end_at = [dic objectForKey:@"end_at"];
            //        item.hide_final_grades = [dic objectForKey:@"hide_final_grades"];
        }
    }
   [self cacheMyCourse];
}

//课程简介Page，用在首页课程简介浮层中的课程简介
- (void)parseCourseBriefIntroduction:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    self.courseBriefIntroduction = [dic objectForKey:@"body"];
}

//讲师简介Page，用在首页课程简介浮层中的讲师简介
- (void)parseIntroductionOfLecturer:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    self.introductionOfLecturer = [dic objectForKey:@"body"];
}

//指定课程的单元Modules
- (void)parseModules:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [homePage.modulesArray removeAllObjects];
    
    for(NSDictionary *dic in array)
    {
        UnitItem *item = [[UnitItem alloc] init];
        
        item.item_id = [[dic objectForKey:@"id"] stringValue];
        item.name = [dic objectForKey:@"name"];
        item.position = [dic objectForKey:@"position"];
        item.prerequisite_module_ids = [dic objectForKey:@"prerequisite_module_ids"];
        item.require_sequential_progress = [dic objectForKey:@"require_sequential_progress"];
        item.unlock_at = [dic objectForKey:@"unlock_at"];
        item.workflow_state = [dic objectForKey:@"workflow_state"];
        
        [homePage.modulesArray addObject:item];
    }
}

//注册用户
- (void)parseCreateUser:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
//    NSLog(@"%@",jsonDatas);
    [GlobalOperator sharedInstance].userId = [dic objectForKey:@"id"];
    [KKBUserInfo shareInstance].userId = [dic objectForKey:@"id"];
    
//    NSLog(@"%@",[GlobalOperator sharedInstance].userId );
    
    if([GlobalOperator sharedInstance].userId != nil){
        UpYun *uy = [[UpYun alloc] init];
        uy.delegate = self;
        uy.expiresIn = UPYUN_EXPIRATION;
        uy.bucket = UPYUN_BUCKETNAME;
        uy.passcode = UPYUN_KEY;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"create" forKey:@"type"];
        uy.params = params;
        
        NSString *savekey = [NSString stringWithFormat:@"/user-avatar/%@-%d", [GlobalOperator sharedInstance].userId, (int)[[NSDate date] timeIntervalSinceReferenceDate]];
        
        [GlobalOperator sharedInstance].user4Request.user.avatar.url = [NSString stringWithFormat:@"%@%@", UPYUN_URL, savekey];
        [uy uploadImagePath:[AppUtilities getAvatarPath] savekey:savekey];
        
        return;

    }
}

//账户的详细信息
- (void)parseAccountProfiles:(NSString *)jsonDatas
{
    NSDictionary *accountProfilesDictionary = [jsonDatas objectFromJSONString];
    
    [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id = [accountProfilesDictionary objectForKey:@"login_id"];
    
    [GlobalOperator sharedInstance].user4Request.user.name = [accountProfilesDictionary objectForKey:@"name"];
    [GlobalOperator sharedInstance].user4Request.user.short_name = [accountProfilesDictionary objectForKey:@"short_name"];
    [GlobalOperator sharedInstance].user4Request.user.sortable_name = [GlobalOperator sharedInstance].user4Request.user.name;
    
    NSString *regex = @"upaiyun.com";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
    if ([predicate evaluateWithObject:[accountProfilesDictionary objectForKey:@"avatar_url"]])
    {
        [GlobalOperator sharedInstance].user4Request.user.avatar.url = [accountProfilesDictionary objectForKey:@"avatar_url"];
        
    }
    else
    {
        //本地默认的头像
        [GlobalOperator sharedInstance].user4Request.user.avatar.url = [[NSBundle mainBundle] pathForResource:@"icon_login_normal" ofType:@"png"];
    }
    
    [self cacheAccountProfiles];
}

//根据code获得用户的token
- (void)parseExchangeToken:(NSString *)jsonDatas
{
    [AppUtilities writeFile:@"token.json" subDir:KAIKEBA_CONFIG_DIR contents:[jsonDatas dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSDictionary *tokenDictionary = [jsonDatas objectFromJSONString];
    
    [GlobalOperator sharedInstance].userId = [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
    [KKBUserInfo shareInstance].userId = [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
    [GlobalOperator sharedInstance].user4Request.user.avatar.token = [tokenDictionary objectForKey:@"access_token"];

    [[KKBHttpClient shareInstance] setUserToken:[tokenDictionary objectForKey:@"access_token"]];
}
- (void)parseCategory:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    homePage.categoryArray = (NSMutableArray *)array;
//    NSLog(@"%@",[homePage.categoryArray objectAtIndex:0]);
    [self cacheCourseCategory];
}

//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    if ([cmd compare:HTTP_CMD_HOMEPAGE_HEADERSLIDER] == NSOrderedSame)
    {
        [self parseHeaderSliders:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_ENROLLUSER] == NSOrderedSame)
    {
        [self parseEnrollments:jsonDatas];
    }else if ([cmd compare:HTTP_CMD_HOMEPAGE_ALLCOURSES] == NSOrderedSame)
    {
        [self parseAllCourses:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_MYCOURSES] == NSOrderedSame)
    {
        [self parseMyCourses:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES] == NSOrderedSame)
    {
        [self parseAccountProfiles:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_EXCHANGETOKEN] == NSOrderedSame)
    {
        [self parseExchangeToken:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_COURSE_MODULES] == NSOrderedSame)
    {
        [self parseModules:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] == NSOrderedSame)
    {
        [self parseCourseBriefIntroduction:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] == NSOrderedSame)
    {
        [self parseIntroductionOfLecturer:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_CREATEUSER] == NSOrderedSame)
    {
        [self parseCreateUser:jsonDatas];
        
    }
    //    else if ([cmd compare:HTTP_CMD_HOMEPAGE_EDITUSER] == NSOrderedSame)
    //    {
    //        NSLog(@"%@", jsonDatas);
    //    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_MYBADGES] == NSOrderedSame)
    {
        [self parseMyBadges:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_ACTIVITY_STREAM] == NSOrderedSame)
    {
        [self parseActivityStream:jsonDatas];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_CATEGORY] == NSOrderedSame)
    {
         [self parseCategory:jsonDatas];
        NSLog(@"++++%@",jsonDatas);
    }
    
    [super requestFinished:subDelegate cmd:cmd jsonDatas:jsonDatas url:url];
}

- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error
{
    NSString *string = nil;
    if ([ERROR_DOMAIN isEqualToString:error.domain])
    {
        string = [error.userInfo objectForKey:@"message"];
    }
    else
    {
        string = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                    message:@"上传头像失败"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result
{
    //清楚旧的缓存文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[AppUtilities getAvatarPath] error:nil];
    
    if ([[upYun.params objectForKey:@"type"] isEqual:@"edit"])
    {
        [self requestEditUser:[dictionary objectForKey:@"delegate"] token:[dictionary objectForKey:@"token"] user4Request:[GlobalOperator sharedInstance].user4Request];
    }
    else if ([[upYun.params objectForKey:@"type"] isEqual:@"create"])
    {
        [self requestEditAfterCreateUser:[dictionary objectForKey:@"delegate"] token:[dictionary objectForKey:@"token"] user4Request:[GlobalOperator sharedInstance].user4Request];
    }
}

#pragma mark -
#pragma mark cache data
-(void)cacheHeaderSliders
{
    NSString* cacheFileName= CACHE_HOMEPAGE_HEADERSLIDER;
    //archiver
    NSString* homeSliderPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,ARCHIVER_HOMEPAGE_HEADERSLIDER ,nil];
    [NSKeyedArchiver archiveRootObject:self.homePage.headerSliderArray toFile:homeSliderPath];

}
-(void)cacheAllCourse
{
    NSString* cacheFileName= CACHE_HOMEPAGE_ALLCOURSE;
    //archiver
    NSString* allCoursePath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_ALLCOURSE ,nil];
    [NSKeyedArchiver archiveRootObject:self.homePage.allCoursesArray toFile:allCoursePath];
    
}
-(void)cacheMyCourse
{
    NSString* cacheFileName= CACHE_HOMEPAGE_MYCOURSE;
    //archiver
    NSString* myCoursePath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_MYCOURSE ,nil];
    [NSKeyedArchiver archiveRootObject:self.homePage.myCoursesArray toFile:myCoursePath];
}
-(void)cacheCourseCategory
{
    NSString* cacheFileName= CACHE_HOMEPAGE_CATEGORY;
    //archiver
    NSString* courseCategoryPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_CATEGORY ,nil];
    [NSKeyedArchiver archiveRootObject:self.homePage.categoryArray toFile:courseCategoryPath];
    
}
-(void)cacheBadges
{
    NSString* cacheFileName= CACHE_HOMEPAGE_BADGE;
    //archiver
    NSString* courseCategoryPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_BADGE ,nil];
    [NSKeyedArchiver archiveRootObject:self.homePage.badgesArray toFile:courseCategoryPath];
    
}
-(void)cacheAccountProfiles
{
    NSString* cacheFileName= CACHE_HOMEPAGE_SELFINFO;
    //archiver
    NSString* courseCategoryPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_SELFINFO ,nil];
    NSArray *accountProfilesArr = [NSArray arrayWithObjects:[GlobalOperator sharedInstance].user4Request.pseudonym.unique_id,[GlobalOperator sharedInstance].user4Request.user.name,[GlobalOperator sharedInstance].user4Request.user.short_name,[GlobalOperator sharedInstance].user4Request.user.avatar.url,nil];
    
    [NSKeyedArchiver archiveRootObject:accountProfilesArr toFile:courseCategoryPath];
    
}


@end
