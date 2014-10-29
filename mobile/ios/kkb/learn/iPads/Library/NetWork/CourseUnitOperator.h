//
//  CourseUnitOperator.h
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"
#import "CourseUnitStructs.h"
#import "DiscussionTopicStructs.h"


@interface CourseUnitOperator : BaseOperator

@property (nonatomic, retain) CourseUnitStructs *courseUnit;
@property (nonatomic, copy) NSString *courseBriefIntroduction; //课程简介Page
@property (nonatomic, copy) NSString *introductionOfLecturer; //讲师简介Page
@property (nonatomic, copy) NSString *page; //指定的Page，用在课程框架、课程单元点击某些页面时Modules


//网络Url--------------------------------


//网络请求 -------------------------------
- (void)requestPage:(id)delegate token:(NSString *)token courseId:(NSString *)courseId pageURL:(NSString *)pageURL; //获取指定的Page，用在课程框架、课程单元点击某些页面时Modules

- (void)requestCourseVideo:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取课程视频信息

//网络解析 -------------------------------
- (void)parseCourseBriefIntroduction:(NSString *)jsonDatas; //课程简介Page
- (void)parseIntroductionOfLecturer:(NSString *)jsonDatas; //讲师简介Page
- (void)parseModules:(NSString *)jsonDatas; //指定课程的单元Modules
- (void)parsePage:(NSString *)jsonDatas; //指定的Page
- (void)parseCourseVideo:(NSString *)jsonDatas;//解析视频

@end
