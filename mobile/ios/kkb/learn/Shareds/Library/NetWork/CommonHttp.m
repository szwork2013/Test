//
//  CommonHttp.m
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "CommonHttp.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface CommonHttp()

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end


@implementation CommonHttp

@synthesize netWorkArray;
@synthesize m_delegate;

- (id)init
{
    if (self = [super init])
    {
        self.netWorkArray = [[NSMutableArray alloc] init];
        self.m_delegate = nil;
    }
    
    return self;
}



- (void)addNetWorkRequest:(ASIHTTPRequest *)request//将网络请求加扫网络队列里面
{
    [self.netWorkArray addObject:request];
}

- (void)removeRequest:(ASIHTTPRequest*)request
{
    [self.netWorkArray removeObject:request];
}

-(void)cancelNetWorkRequests//退出所有的网络请求
{
    if(self.netWorkArray == nil)
        return;
    
    for (int i = 0; i < [self.netWorkArray count]; i++)
    {
        ASIHTTPRequest *request = (ASIHTTPRequest *)[self.netWorkArray objectAtIndex:i];
        if (request)
        {
            [request clearDelegatesAndCancel];
        }
    }
    
    [self.netWorkArray removeAllObjects];
}

- (void)cancelNetworkRequestForDelegate:(id)delegate//取消某一代理的网络请求
{
    if(self.netWorkArray == nil) return;
    
    for (int i = 0; i<[self.netWorkArray count]; i++)
    {
        ASIHTTPRequest *request =(ASIHTTPRequest *)[self.netWorkArray objectAtIndex:i];
        if (request != nil)
        {
            NSDictionary *dict = request.userInfo;
            id del = [dict objectForKey:@"delegate"];
            if (del == delegate)
            {
                [request clearDelegatesAndCancel];
                [self.netWorkArray removeObject:request];
            }
        }
    }
}

- (void)getJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token
{
    NSURL *url = [NSURL URLWithString:jsonUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setObject:delegate forKey:@"delegate"];
    [dictionary setObject:command forKey:@"command"];
    [request setUserInfo:dictionary];
    
    [self addNetWorkRequest:request];
    [request setDelegate:self];
    [request setTimeOutSeconds:5.0];
    [request addRequestHeader:@"referer" value:@"www.kaikeba.com"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Request" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request setDidFinishSelector:@selector(requestFinished:)];// 到不了finished
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}
- (void)postJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json
{
    NSURL *url = [NSURL URLWithString:jsonUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setObject:delegate forKey:@"delegate"];
    [dictionary setObject:command forKey:@"command"];
    [request setUserInfo:dictionary];
    
    [self addNetWorkRequest:request];
    [request setDelegate:self];
    [request setTimeOutSeconds:5.0];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Request" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}

- (void)putJSONFromUrl:(id)delegate command:(NSString *)command jsonUrl:(NSString *)jsonUrl token:(NSString *)token json:(NSString *)json
{
    NSURL *url = [NSURL URLWithString:jsonUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setObject:delegate forKey:@"delegate"];
    [dictionary setObject:command forKey:@"command"];
    [request setUserInfo:dictionary];
    
    [self addNetWorkRequest:request];
    [request setDelegate:self];
//    [request ]
    [request setRequestMethod:@"PUT"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Request" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDidFinishSelector:@selector(requestFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *dic = request.userInfo;
    id delegate = [dic objectForKey:@"delegate"];
    NSString *cmd = [dic objectForKey:@"command"];
    // 注意
    [m_delegate requestFinished:delegate cmd:cmd jsonDatas:[request responseString] url:[request.url absoluteString]];
    [self removeRequest:request];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSDictionary *dic = request.userInfo;
    id delegate = [dic objectForKey:@"delegate"];
    NSString *cmd = [dic objectForKey:@"command"];
    NSError *error = [request error];
    [request cancel];
    
    [m_delegate requestFailed:delegate cmd:cmd errMsg:[error localizedDescription]];
    [self removeRequest:request];
}

@end
