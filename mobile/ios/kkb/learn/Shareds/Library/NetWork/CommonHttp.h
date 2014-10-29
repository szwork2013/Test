//
//  CommonHttp.h
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;


@protocol CommonHttpDelegate <NSObject>

- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url;
- (void)requestFailed:(id)subDelegate cmd:(NSString *)cmd errMsg:(NSString *)errMsg;

@end


@interface CommonHttp : NSObject
{
    
}

@property (retain, nonatomic) NSMutableArray *netWorkArray;
@property (nonatomic, assign) id<CommonHttpDelegate> m_delegate;

- (void)getJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token;
- (void)postJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json;
- (void)putJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json;
- (void)addNetWorkRequest:(ASIHTTPRequest *)request;//将网络请求加扫网络队列里面
- (void)cancelNetWorkRequests;//退出所有的网络请求；
- (void)cancelNetworkRequestForDelegate:(id)delegate;//取消某一代理的网络请求

@end
