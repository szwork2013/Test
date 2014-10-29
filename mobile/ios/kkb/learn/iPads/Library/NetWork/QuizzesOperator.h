//
//  QuizzesOperator.h
//  learn
//
//  Created by User on 13-7-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"

@interface QuizzesOperator : BaseOperator

//网络Url--------------------------------
//获取测验的url
- (NSString *)getQuizzesUrl:(NSString *)courseId;

//网络请求 -------------------------------
- (void)requestQuizzes:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取测验

//网络解析 -------------------------------
- (void)parseQuizzes:(NSString *)jsonDatas; //测验

@end
