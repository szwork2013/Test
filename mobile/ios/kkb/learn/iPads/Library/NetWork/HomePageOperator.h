//
//  HomePageOperator.h
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseOperator.h"
#import "HomePageStructs.h"

@class User4Request;

@interface HomePageOperator : BaseOperator

@property (nonatomic, retain) HomePageStructs *homePage;
@property (nonatomic, copy) NSString *courseBriefIntroduction; //课程简介Page，用在首页课程简介浮层中的课程简介
@property (nonatomic, copy) NSString *introductionOfLecturer; //讲师简介Page，用在首页课程简介浮层中的讲师简介
@property BOOL isEntrolled;


//网络Url--------------------------------
//获取最新版本信息
//- (NSString *)getLatestVersionUrl;
//获取关于页面
//- (NSString *)getAboutPageUrl;
//获取评分URL
//- (NSString *)getStarMeUrl;
//- (NSString *)getMyCoursesWithMetaUrl:(NSString *)courseId;
//填充/获取课程元数据
//- (NSString *)getAllCourseMetaUrl:(NSString *)courseID;
//登录的url
- (NSString *)loginUrl;
//获取BlueButtonUrl
//- (NSString *)getBlueButtonUrl:(NSString *)courseId;


//网络请求 -------------------------------
- (void)requestEnrollments:(id)delegate token:(NSString *)token courseID:(NSString *)couseID  user_id:(NSString *)user_id;

- (void)requestBadge:(id)delegate token:(NSString *)token;
- (void)requestAllCoursesCategory:(id)delegate token:(NSString *)token; //课程类型
- (void)requestHeaderSliders:(id)delegate token:(NSString *)token; //首页推荐数据
- (void)requestAllCourses:(id)delegate token:(NSString *)token; //首页全部课程数据
- (void)requestMyCourses:(id)delegate token:(NSString *)token; //首页我的课程数据
- (void)requestLogout:(id)delegate token:(NSString *)token; //登出
- (void)requestCreateUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request; //注册用户
- (void)requestEditAfterCreateUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request; //修改用户
- (void)requestEditUser:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request; //修改用户
- (void)requestEditUserWithAvatar:(id)delegate token:(NSString *)token user4Request:(User4Request *)user4Request; //修改用户WithAvatar
- (void)requestAccountProfiles:(id)delegate token:(NSString *)token accoundId:(NSString *)accoundId;//获取账户的详细信息
- (void)requestExchangeToken:(id)delegate token:(NSString *)token code:(NSString *)code;//根据code获得用户的token

- (void)requestActivityStream:(id)delegate token:(NSString *)token; //个人中心


//网络解析 -------------------------------
- (void)parseHeaderSliders:(NSString *)jsonDatas; //首页推荐数据
- (void)parseAllCourses:(NSString *)jsonDatas; //首页全部课程数据
- (void)parseMyCourses:(NSString *)jsonDatas; //首页我的课程数据
- (void)parseCourseBriefIntroduction:(NSString *)jsonDatas; //课程简介Page，用在首页课程简介浮层中的课程简介
- (void)parseIntroductionOfLecturer:(NSString *)jsonDatas; //讲师简介Page，用在首页课程简介浮层中的讲师简介
- (void)parseModules:(NSString *)jsonDatas; //指定课程的单元Modules
- (void)parseCreateUser:(NSString *)jsonDatas; //注册用户
- (void)parseAccountProfiles:(NSString *)jsonDatas; //账户的详细信息
- (void)parseExchangeToken:(NSString *)jsonDatas; //根据code获得用户的token
- (void)parseActivityStream:(NSString *)jsonDatas; //个人中心

//缓存Data
-(void)cacheHeaderSliders;


@end
