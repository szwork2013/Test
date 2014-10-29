//
//  KKBHttpClient.h
//  learn
//
//  Created by zxj on 6/14/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef void (^successBlock)(id result);
typedef void (^failureBlock)(id result);
#define HOST_SERVER @"http://learn.kaikeba.com"

typedef void (^successedBlock)(id result, AFHTTPRequestOperation *operation);
typedef void (^failuredBlock)(id result, AFHTTPRequestOperation *operation);

#define HOST_LMS @"http://learn.kaikeba.com/api/v1"
#define HOST_CMS @"http://www.kaikeba.com/api/v3"
#define HOST_ACT @"http://learn.kaikeba.com/api/v2"
#define HOST_SUPERCLASS @"http://superclass.kaikeba.com/ocw/srv"

#ifdef DEBUG
#define HOST_API @"http://api-stg.kaikeba.com"
#else
#define HOST_API @"https://api.kaikeba.com"
#endif

#define TOKEN_ACCESS                                                           \
    @"sdbxc5Hszykx5lrifwq4Cw4sGALufP9vvWHc5dOn9FsLIYHbXMp1p0OcapfPZ94I"
#define TOKEN_ACT @"d0b6e22f940747825d51210c16a57284"

#define KKB_TOKEN_KEY @"kkb-token"
#define KKB_TOKEN_VALUE @"5191880744949296554"

@interface KKBHttpClient : AFHTTPRequestOperationManager {
    NSString *guestToken;
}

@property(strong) NSString *userToken;
@property(nonatomic, assign) BOOL is401Response;

// response的statusCodel 是否是401
// appDelegate里检测的这个属性用于statusCode401跳到匿名首页

- (void)requestSuperClassUrlPath:(NSString *)urlPath
                          method:(NSString *)method
                           param:(NSMutableDictionary *)param
                       fromCache:(BOOL)fromCache
                         success:(successBlock)successBlock
                         failure:(failureBlock)failureBlock;

- (void)enrollCourseId:(NSString *)courseId
                userId:(NSString *)userId
               success:(successBlock)successBlock
               failure:(failureBlock)failureBlock;

- (void)requestCMSUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successBlock)successBlock
                  failure:(failureBlock)failureBlock;

- (void)requestLMSUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successBlock)successBlock
                  failure:(failureBlock)failureBlock;

- (void)requestACTUrlPathfromCache:(BOOL)fromCache
                           success:(successBlock)successBlock
                           failure:(failureBlock)failureBlock;

- (void)requestRegistUrlPathfromCache:(BOOL)fromCache
                              success:(successBlock)successBlock
                              failure:(failureBlock)failureBlock;

- (void)requestExchangeTokenWithCode:(NSString *)authcode
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock;

//[homePageOperator requestLogout:self token:PUBLIC_TOKEN];
- (void)requestLogoutSuccess:(successBlock)successBlock
                     failure:(failureBlock)failureBlock;

- (void)requestPostUrlPath:(NSString *)urlPath
                    method:(NSString *)method
                     param:(NSMutableDictionary *)param
                   success:(successBlock)successBlock
                   failure:(failureBlock)failureBlock;
//- (void) requestSpecialites:(NSString *) urlPath fromCache:(BOOL)fromCache
// success:(successBlock)successBlock failure:(failureBlock)failureBlock;

//- (void)requestPostCPAUrlPath:(NSString *)urlPath param:(NSMutableDictionary
//*)param success:(successBlock)successBlock failure:(failureBlock)failureBlock;

- (void)requestUrlPath:(NSString *)urlPath
                  host:(NSString *)host
                method:(NSString *)method
                 param:(NSMutableDictionary *)param
             fromCache:(BOOL)fromCache
                 token:(NSString *)token
               success:(successBlock)successBlock
               failure:(failureBlock)failureBlock;

//- (void)requestAPIUrlPath:(NSString *)urlPath method:(NSString *)method
// param:(NSMutableDictionary *)param
//                fromCache:(BOOL)fromCache success:(successBlock)successBlock
//                failure:(failureBlock)failureBlock;
- (void)requestCertificationFromCache:(BOOL)fromCache
                              success:(successBlock)successBlock
                              failure:(failureBlock)failureBlock;
- (void)requestMyCollectionFromCache:(BOOL)fromCache
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock;
- (void)requestMyMicroMajorFromCache:(BOOL)fromCache
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock;

#pragma mark - 所有的API请求都通过此方法调用
- (void)requestAPIUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successedBlock)successBlock
                  failure:(failuredBlock)failureBlock;

//- (void)requestPostUrlPath:(NSString *)urlPath method:(NSString *)method
// param:(NSMutableDictionary *)param success:(successBlock)successBlock
// failure:(failureBlock)failureBlock;
// CPA注册
- (void)requestPostCPAUrlPath:(NSString *)urlPath
                        param:(NSMutableDictionary *)param
                      success:(successedBlock)successBlock
                      failure:(failuredBlock)failureBlock;

- (void)setGuestToken:(NSString *)_token;

- (void)setUserToken:(NSString *)_token;

- (void)refreshDynamic;

- (void)refreshMyPublicCourse;

- (void)refreshMyGuideCourse;

- (void)refreshMyCollection;

#pragma mark - 取消指定的网络请求任务（如果指定的任务正在请求）
- (void)cancelCurrentRequesetInQueueWithRequestURL:(NSString *)urlStr;

+ (KKBHttpClient *)shareInstance;

@end
