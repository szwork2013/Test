//
//  UsersInCourseOperator.m
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "UsersInCourseOperator.h"
#import "JSONKit.h"


@implementation UsersInCourseOperator

@synthesize usersInCourse;



- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_USERSINCOURSE;
        self.usersInCourse = [[UsersInCourseStructs alloc] init];
    }
    
    return self;
}


//网络Url--------------------------------
//课程中教师、学生等url
- (NSString *)buildUsersInCourseUrl:(NSString *)courseId type:(NSString *)type
{
    NSString *url = [NSString stringWithFormat:@"%@courses/%@/users?enrollment_type=%@&include[]=avatar_url&include[]=email&per_page=99999", API_HOST, courseId, type];
    
    return url;
}


//网络请求 -------------------------------

//获取课程中学生
- (void)requestStudentsInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    NSString *jsonUrl = [self buildUsersInCourseUrl:courseId type:@"student"];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_STUDENTSINCOURSE jsonUrl:jsonUrl token:token];
}

//获取课程中老师
- (void)requestTeachersInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    NSString *jsonUrl = [self buildUsersInCourseUrl:courseId type:@"teacher"];
    //    [NSString stringWithFormat:@"%@courses/%@/users?enrollment_type=teacher&include[]=avatar_url&include[]=email", API_HOST, courseId];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_TEACHERSINCOURSE jsonUrl:jsonUrl token:token];
}

//获取课程中助教
- (void)requestTasInCourse:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    NSString *jsonUrl = [self buildUsersInCourseUrl:courseId type:@"ta"];
    //    [NSString stringWithFormat:@"%@courses/%@/users?enrollment_type=ta&include[]=avatar_url&include[]=email", API_HOST, courseId];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_TASINCOURSE jsonUrl:jsonUrl token:token];
}


//网络解析 -------------------------------

//课程中学生
- (void)parseStudentsInCourse:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [self.usersInCourse.students removeAllObjects];
    for(NSDictionary *dic in array)
    {
        User *item = [[User alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.name = [dic objectForKey:@"name"];
        item.sortable_name = [dic objectForKey:@"sortable_name"];
        item.short_name = [dic objectForKey:@"short_name"];
        item.sis_user_id = [dic objectForKey:@"sis_user_id"];
        item.login_id = [dic objectForKey:@"login_id"];
        item.avatar_url = [dic objectForKey:@"avatar_url"];
        item.email = [dic objectForKey:@"email"];
        item.locale = [dic objectForKey:@"locale"];
        item.last_login = [dic objectForKey:@"last_login"];
        
        [self.usersInCourse.students addObject:item];
    }
}

//课程中老师
- (void)parseTeachersInCourse:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [self.usersInCourse.teachers removeAllObjects];
    for(NSDictionary *dic in array)
    {
        User *item = [[User alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.name = [dic objectForKey:@"name"];
        item.sortable_name = [dic objectForKey:@"sortable_name"];
        item.short_name = [dic objectForKey:@"short_name"];
        item.sis_user_id = [dic objectForKey:@"sis_user_id"];
        item.login_id = [dic objectForKey:@"login_id"];
        item.avatar_url = [dic objectForKey:@"avatar_url"];
        item.email = [dic objectForKey:@"email"];
        item.locale = [dic objectForKey:@"locale"];
        item.last_login = [dic objectForKey:@"last_login"];
        
        [self.usersInCourse.teachers addObject:item];
    }
}

//课程中助教
- (void)parseTasInCourse:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [self.usersInCourse.tas removeAllObjects];
    for(NSDictionary *dic in array)
    {
        User *item = [[User alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.name = [dic objectForKey:@"name"];
        item.sortable_name = [dic objectForKey:@"sortable_name"];
        item.short_name = [dic objectForKey:@"short_name"];
        item.sis_user_id = [dic objectForKey:@"sis_user_id"];
        item.login_id = [dic objectForKey:@"login_id"];
        item.avatar_url = [dic objectForKey:@"avatar_url"];
        item.email = [dic objectForKey:@"email"];
        item.locale = [dic objectForKey:@"locale"];
        item.last_login = [dic objectForKey:@"last_login"];
        
        [self.usersInCourse.tas addObject:item];
    }
}


//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    if ([cmd compare:HTTP_CMD_COURSE_STUDENTSINCOURSE] == NSOrderedSame)
    {
        [self parseStudentsInCourse:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_COURSE_TEACHERSINCOURSE] == NSOrderedSame)
    {
        [self parseTeachersInCourse:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_COURSE_TASINCOURSE] == NSOrderedSame)
    {
        [self parseTasInCourse:jsonDatas];
    }
    
    [super requestFinished:subDelegate cmd:cmd jsonDatas:jsonDatas url:url];
}

@end
