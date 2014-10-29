//
//  BaseOperator.m
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"
#import "AppUtilities.h"

@implementation BaseOperator

@synthesize moduleType;
@synthesize commonHttp;

- (id)init
{
    if (self = [super init])
    {
        self.commonHttp = [[CommonHttp alloc] init];
        self.commonHttp.m_delegate = self;
    }
    
    return self;
}


- (void)getJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token
{
//    NSLog(@"%@", jsonUrl);
    
    if ([AppUtilities isExistenceNetwork])
    {
        //请求网络
        [commonHttp getJSONFromUrl:delegate command:command jsonUrl:jsonUrl token:token];
    }
}

- (void)postJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json
{
//   NSLog(@"%@", jsonUrl);
    
    if ([AppUtilities isExistenceNetwork])
    {
        //请求网络
        [commonHttp postJSONFromUrl:delegate command:command jsonUrl:jsonUrl token:token json:json];
    }
}

- (void)putJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json
{
//   NSLog(@"%@", jsonUrl);
    
    if ([AppUtilities isExistenceNetwork])
    {
        //请求网络
        [commonHttp putJSONFromUrl:delegate command:command jsonUrl:jsonUrl token:token json:json];
       
    }
}

- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
//    NSLog(@"BaseOperator::requestFinished~~~CMD:%@", cmd);
    //存文件
//    if (url)
//    {//url为空时，说明数据从本地读取,所以就不需要再写入文件
//        //        [m_globalOper updateFileLogsWith:url];
//        //        [ToolsObject writeWithUrl:url dirName:[ToolsObject cacheDir] content:jsonDatas];
//    }
    
    if (subDelegate && [subDelegate respondsToSelector:@selector(requestSuccess:)])
    {
        [subDelegate requestSuccess:cmd];
    }
}

- (void)requestFailed:(id)subDelegate cmd:(NSString *)cmd errMsg:(NSString *)errMsg
{
//   NSLog(@"BaseOperator::requestFailed~~~CMD:%@", cmd);
    
    if (subDelegate && [subDelegate respondsToSelector:@selector(requestFailure: errMsg:)])
    {
        //用户不操作的网络请求不提示失败
        [subDelegate requestFailure:cmd errMsg:@"网络请求失败"];
    }
}


- (void)requestCourseBriefIntroduction:(id)delegate token:(NSString *)token courseID:(NSString *)courseID
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/pages/course-introduction-4tablet", API_HOST, courseID];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION jsonUrl:jsonUrl token:token];
}

- (void)requestIntroductionOfLecturer:(id)delegate token:(NSString *)token courseID:(NSString *)courseID
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/pages/course-instructor-4tablet", API_HOST, courseID];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER jsonUrl:jsonUrl token:token];
}

//获取指定课程的单元Modules
- (void)requestModules:(id)delegate token:(NSString *)token courseID:(NSString *)courseID
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/modules?per_page=%d", API_HOST, courseID, PerPage];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_MODULES jsonUrl:jsonUrl token:token];
}

//获取指定课程的指定单元的条目Items
- (NSString *)getModuleItemsUrl:(NSString *)courseID moduleID:(NSString *)moduleID
{
    NSString *url = [NSString stringWithFormat:@"%@courses/%@/modules/%@/items?per_page=%d", API_HOST, courseID, moduleID, PerPage];
    
    return url;
}

@end
