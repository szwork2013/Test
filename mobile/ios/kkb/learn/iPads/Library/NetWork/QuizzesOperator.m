//
//  QuizzesOperator.m
//  learn
//
//  Created by User on 13-7-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "QuizzesOperator.h"

@implementation QuizzesOperator



- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_QUIZZES;
    }
    
    return self;
}


//网络Url--------------------------------
//获取测验的url
- (NSString *)getQuizzesUrl:(NSString *)courseId
{
    NSString *url = [NSString stringWithFormat:@"%@courses/%@/quizzes", API_HOST, courseId];
    
    return url;
}


//网络请求 -------------------------------
//获取测验
- (void)requestQuizzes:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    
}


//网络解析 -------------------------------
//测验
- (void)parseQuizzes:(NSString *)jsonDatas
{
    
}


//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    
}

@end
