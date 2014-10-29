//
//  UsersInCourseOperator.h
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"
#import "UsersInCourseStructs.h"


@interface UsersInCourseOperator : BaseOperator

@property (nonatomic, retain) UsersInCourseStructs *usersInCourse; //人员结构体


//网络请求 -------------------------------
- (void)requestStudentsInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取课程中学生
- (void)requestTeachersInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取课程中老师
- (void)requestTasInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取课程中助教


//网络解析 -------------------------------
- (void)parseStudentsInCourse:(NSString *)jsonDatas; //课程中学生
- (void)parseTeachersInCourse:(NSString *)jsonDatas; //课程中老师
- (void)parseTasInCourse:(NSString *)jsonDatas; //课程中助教


@end
