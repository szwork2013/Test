//
//  BaseOperator.h
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHttp.h"
#import "GlobalDefine.h"

@protocol BaseOperatorDelegate <NSObject>

- (void)requestSuccess:(NSString *)cmd;
- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg;

@end

@interface BaseOperator : NSObject<CommonHttpDelegate>
{
    
}

@property (nonatomic, assign) KAIKEBA_MODULE_TYPE moduleType;
@property (nonatomic, retain) CommonHttp *commonHttp;

//公用数据请求函数
- (void)getJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token;
- (void)postJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json;
- (void)putJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json;

//****************公用方法，后期可移除****************************

//获取课程简介Page
- (void)requestCourseBriefIntroduction:(id)delegate token:(NSString *)token courseID:(NSString *)courseID;
//获取讲师简介Page
- (void)requestIntroductionOfLecturer:(id)delegate token:(NSString *)token courseID:(NSString *)courseID;

- (void)requestModules:(id)delegate token:(NSString *)token courseID:(NSString *)courseID; //获取指定课程的单元Modules



//获取指定课程的指定单元的条目Items
- (NSString *)getModuleItemsUrl:(NSString *)courseID moduleID:(NSString *)moduleID;

@end
