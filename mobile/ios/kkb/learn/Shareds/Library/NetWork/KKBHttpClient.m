//
//  KKBHttpClient.m
//  learn
//
//  Created by zxj on 6/14/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBHttpClient.h"
#import "GlobalDefine.h"
#import "GlobalOperator.h"
#import "KKBUserInfo.h"
#import <AdSupport/ASIdentifierManager.h>
#import "CommonCrypto/CommonDigest.h"
#import "AppUtilities.h"
#import "AFHTTPRequestOperationManager.h"
#import "KKBUserInfo.h"
#import "DDLog.h"
#import "MobClick.h"

#import "AppDelegate.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation KKBHttpClient

+ (KKBHttpClient *)shareInstance {
    static KKBHttpClient *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[KKBHttpClient alloc] init];
        NSURLCache *cache =
            [[NSURLCache alloc] initWithMemoryCapacity:200 * 1024 * 1024
                                          diskCapacity:320 * 1024 * 1024
                                              diskPath:@"app_cache"];
        [NSURLCache setSharedURLCache:cache];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInitPublicConfig];
    }
    return self;
}

- (void)customInitPublicConfig {
    //设置公共的请求设置
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.requestSerializer.HTTPMethodsEncodingParametersInURI =
        [NSSet setWithObjects:@"GET", @"HEAD", nil];
    [self.requestSerializer setTimeoutInterval:30];
    [self.requestSerializer setValue:@"5191880744949296554"
                  forHTTPHeaderField:@"kkb-token"];
    [self.requestSerializer setValue:@"application/json"
                  forHTTPHeaderField:@"Content-Type"];

    [self.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"kkb-platform"];
    [self.requestSerializer setValue:[UIDevice currentDevice].model
                  forHTTPHeaderField:@"kkb-model"];

    self.responseSerializer = [AFJSONResponseSerializer serializer];
}

- (void)refreshDynamic {
    NSString *urlPath = [NSString stringWithFormat:@"v1/userapply/dynamic"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"refreshDynamic success");
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)refreshMyPublicCourse {
    NSString *urlForMyPublicCourse =
        [NSString stringWithFormat:@"v1/open_courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlForMyPublicCourse
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"refreshMyPublicCourse success");
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)refreshMyGuideCourse {
    NSString *urlForMyGuideCourse =
        [NSString stringWithFormat:@"v1/instructive_courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlForMyGuideCourse
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"refreshMyGuideCourse success");
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)refreshMyCollection {
    NSString *urlPath = [NSString stringWithFormat:@"v1/collections/user"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"refreshMyCollection success");
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)requestSuperClassUrlPath:(NSString *)urlPath
                          method:(NSString *)method
                           param:(NSMutableDictionary *)param
                       fromCache:(BOOL)fromCache
                         success:(successBlock)successBlock
                         failure:(failureBlock)failureBlock {
    [self requestUrlPath:urlPath
                    host:HOST_SUPERCLASS
                  method:method
                   param:param
               fromCache:fromCache
                   token:nil
                 success:successBlock
                 failure:failureBlock];
}

- (void)enrollCourseId:(NSString *)courseId
                userId:(NSString *)userId
               success:(successBlock)successBlock
               failure:(failureBlock)failureBlock {
    NSString *urlPath = [NSString
        stringWithFormat:@"courses/%@/" @"enrollments?enrollment[user_id]=%@&"
                         @"enrollment[type]=StudentEnrollment&"
                         @"enrollment[enrollment_state]=active",
                         courseId, userId];
    [self requestUrlPath:urlPath
                    host:HOST_LMS
                  method:@"POST"
                   param:nil
               fromCache:NO
                   token:TOKEN_ACCESS
                 success:successBlock
                 failure:failureBlock];
}

- (void)requestCMSUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successBlock)successBlock
                  failure:(failureBlock)failureBlock {
    [self requestUrlPath:urlPath
                    host:HOST_CMS
                  method:method
                   param:param
               fromCache:fromCache
                   token:nil
                 success:successBlock
                 failure:failureBlock];
}

- (void)requestLMSUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successBlock)successBlock
                  failure:(failureBlock)failureBlock {
    NSString *token = self.userToken;
    if ([urlPath rangeOfString:@"course-introduction-4tablet"].location !=
            NSNotFound ||
        [urlPath rangeOfString:@"modules?per_page"].location != NSNotFound ||
        [urlPath rangeOfString:@"items?per_page"].location != NSNotFound ||
        [method caseInsensitiveCompare:@"PUT"] == NSOrderedSame ||
        [urlPath rangeOfString:@"course-instructor-4tablet"].location !=
            NSNotFound) {
        token = TOKEN_ACCESS;
    }

    [self requestUrlPath:urlPath
                    host:HOST_LMS
                  method:method
                   param:param
               fromCache:fromCache
                   token:token
                 success:successBlock
                 failure:failureBlock];
}
- (void)requestACTUrlPathfromCache:(BOOL)fromCache
                           success:(successBlock)successBlock
                           failure:(failureBlock)failureBlock {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    DDLogDebug(@"%@", strDate);
    NSString *token = [NSString stringWithFormat:@"%@+'uniquedu'", strDate];
    NSString *token1 = [self md5:token];
    // NSString *ifv = (NSString *)[UIDevice currentDevice].identifierForVendor;
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    NSString *ifv = [uuid UUIDString];
    NSString *idfaString = (NSString *)[
        [[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *urlPath = [NSString
        stringWithFormat:@"activation?from={%@}&token={%@}", @"kkB", token1];
    NSString *pathUTF8 = [urlPath
        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *param = [[NSMutableDictionary alloc]
        initWithObjectsAndKeys:@"iPhone", @"device", ifv, @"ifv", idfaString,
                               @"ifa", nil];
    [self requestUrlPath:pathUTF8
                    host:HOST_ACT
                  method:@"POST"
                   param:param
               fromCache:NO
                   token:token1
                 success:successBlock
                 failure:failureBlock];
    DDLogDebug(@"%@", urlPath);
}
- (void)requestRegistUrlPathfromCache:(BOOL)fromCache
                              success:(successBlock)successBlock
                              failure:(failureBlock)failureBlock {
    NSString *urlPath =
        [NSString stringWithFormat:@"/accounts/%@/users", OpenAccountID];
    //    NSString *urlPath = [NSString stringWithFormat:@"accounts/1/users"];
    NSString *ifv = (NSString *)[UIDevice currentDevice].identifierForVendor;
    NSMutableDictionary *param = [[NSMutableDictionary alloc]
        initWithObjectsAndKeys:@"iPhone", @"device", ifv, @"ifv", nil];
    [self requestUrlPath:urlPath
                    host:HOST_LMS
                  method:@"POST"
                   param:param
               fromCache:NO
                   token:self.userToken
                 success:successBlock
                 failure:failureBlock];
}

- (void)requestPostUrlPath:(NSString *)urlPath
                    method:(NSString *)method
                     param:(NSMutableDictionary *)param
                   success:(successBlock)successBlock
                   failure:(failureBlock)failureBlock {
    [self requestUrlPathForPost:urlPath
                           host:nil
                         method:method
                          param:param
                      fromCache:NO
                          token:TOKEN_ACCESS
                        success:successBlock
                        failure:failureBlock];
}

- (void)requestAPIUrlPath:(NSString *)urlPath
                fromCache:(BOOL)fromCache
                  success:(successBlock)successBlock
                  failure:(failureBlock)failureBlock {
    [self requestUrlPath:urlPath
                    host:HOST_API
                  method:@"GET"
                   param:nil
               fromCache:fromCache
                   token:nil
                 success:successBlock
                 failure:failureBlock];
}

//- (void) requestCategories:(NSString *) urlPath fromCache:(BOOL)fromCache
// method:(NSString *) method success:(successBlock)successBlock
// failure:(failureBlock)failureBlock{
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
//                                    [NSURL URLWithString:
//                                     [NSString stringWithFormat:@"%@%@",
//                                     HOST_SPECIALITIES, urlPath]]];
//    [request setTimeoutInterval:10.0];
//
//    //设值request请求头
//    NSDictionary *header = [NSDictionary dictionary];
//    header = [NSDictionary dictionaryWithObjectsAndKeys:KKB_TOKEN_VALUE,
//    KKB_TOKEN_KEY, nil];
//
//    [request setAllHTTPHeaderFields:header];
//
//    if (fromCache) {
//        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
//    } else {
//        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    }
//
//    [request setHTTPMethod:method];
//
//    if ([method caseInsensitiveCompare:@"GET"] == NSOrderedSame)
//    {
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:nil
//        options:0 error:nil];
//        [request setHTTPBody:jsonData];
//    }
//
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
//    initWithRequest:request];
//
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation
//    *operation,id responseObject){
//        if (successBlock !=nil && responseObject !=nil) {
//            successBlock([self toArrayOrNSDictionary:responseObject]);
//        }
//
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        if (failureBlock != nil) {
//            failureBlock(error);
//        }
//    }];
//    [operation start];
//}

//- (void) requestCategories:(NSString *) urlPath
//                 fromCache:(BOOL)fromCache
//                  tokenKey:(NSString *)tokenKey
//                tokenValue:(NSString *) token
//                   success:(successBlock)successBlock
//                   failure:(failureBlock)failureBlock{
//
//}
//- (void)requestRegistUrlPathParam:(NSMutableDictionary *)param
// success:(successBlock)successBlock failure:(failureBlock)failureBlock{
////    NSString *urlPath = [NSString
/// stringWithFormat:@"accounts/%@/users",OpenAccountID];
//
//    NSString *testPath = [NSString
//    stringWithFormat:@"http://www-test.kaikeba.com/api/v3/users/sign_up"];
//
//    [self requestUrlPathForPost:testPath host:nil method:@"POST" param:param
//    fromCache:NO token:TOKEN_ACCESS success:successBlock
//    failure:failureBlock];
//}

- (void)requestUrlPathForPost:(NSString *)urlPath
                         host:(NSString *)host
                       method:(NSString *)method
                        param:(NSMutableDictionary *)param
                    fromCache:(BOOL)fromCache
                        token:(NSString *)token
                      success:(successBlock)successBlock
                      failure:(failureBlock)failureBlock {
    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];

    if ([method isEqualToString:@"PUT"]) {
        [manager PUT:urlPath
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DDLogDebug(@"JSON: %@", responseObject);
            }
            failure:^(AFHTTPRequestOperation *operation,
                      NSError *error) { DDLogDebug(@"JSON: %@", error); }];

        [manager GET:urlPath
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {}
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    } else {
        [manager POST:urlPath
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DDLogDebug(@"JSON: %@", responseObject);
                if (successBlock != nil && responseObject != nil) {
                    successBlock(responseObject);
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DDLogDebug(@"Error: %@", error.description);
                if (failureBlock != nil) {
                    failureBlock(error);
                }
            }];
    }
}
- (void)requestExchangeTokenWithCode:(NSString *)code
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock {
    NSString *jsonUrl = [NSString
        stringWithFormat:@"%@login/oauth2/" @"token?client_id=4&client_secret="
                         @"znuZbCRiLGbsUiCWP64eM2CwwnSfW87LkvRu8EfwENj"
                         @"FkFUbztChqQnuMcTFw1VH&redirect_uri=urn:"
                         @"ietf:wg:oauth:2.0:oob&code=%@",
                         SERVER_HOST, code];
    [self requestUrlPathForPost:jsonUrl
                           host:nil
                         method:@"POST"
                          param:nil
                      fromCache:NO
                          token:nil
                        success:successBlock
                        failure:failureBlock];
}
- (void)requestLogoutSuccess:(successBlock)successBlock
                     failure:(failureBlock)failureBlock {

    [self requestUrlPath:@"logout"
                    host:HOST_SERVER
                  method:@"GET"
                   param:nil
               fromCache:NO
                   token:PUBLIC_TOKEN
                 success:successBlock
                 failure:failureBlock];
}

// CPA注册
- (void)requestPostCPAUrlPath:(NSString *)urlPath
                        param:(NSMutableDictionary *)param
                      success:(successedBlock)successBlock
                      failure:(failuredBlock)failureBlock {
    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"5191880744949296554"
                     forHTTPHeaderField:@"kkb-token"];
    [manager.requestSerializer setValue:@"application/json"
                     forHTTPHeaderField:@"Content-Type"];

    [manager.requestSerializer setValue:@"App Store"
                     forHTTPHeaderField:@"kkb-platform"];
    [manager.requestSerializer setValue:[UIDevice currentDevice].model
                     forHTTPHeaderField:@"kkb-model"];

    NSString *userId = [KKBUserInfo shareInstance].userId;
    NSString *password = [KKBUserInfo shareInstance].userPassword;
    BOOL isLogined = [[NSFileManager defaultManager]
        fileExistsAtPath:[AppUtilities getTokenJSONFilePath]];
    if (userId && isLogined) {
        [manager.requestSerializer
                      setValue:[NSString
                                   stringWithFormat:@"%@:%@", userId, password]
            forHTTPHeaderField:@"kkb-user"];
    }

    [manager POST:urlPath
        parameters:param
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            successBlock(responseObject, operation);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failureBlock != nil) {
                failureBlock(error, operation);
            }
        }];
}

- (void)requestUrlPath:(NSString *)urlPath
                  host:(NSString *)host
                method:(NSString *)method
                 param:(NSMutableDictionary *)param
             fromCache:(BOOL)fromCache
                 token:(NSString *)token
               success:(successBlock)successBlock
               failure:(failureBlock)failureBlock {

    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:[NSString
                                                stringWithFormat:@"%@/%@", host,
                                                                 urlPath]]];
    [request setTimeoutInterval:10.0];

    //设值request请求头
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    if (token != nil) {
        header = [NSMutableDictionary
            dictionaryWithObjectsAndKeys:
                @"www.kaikeba.com", @"referer", @"application/json", @"Accept",
                @"application/json", @"Request", @"application/json",
                @"Content-Type",
                [NSString stringWithFormat:@"Bearer %@", token],
                @"Authorization", nil];

    } else {
        header = [NSMutableDictionary
            dictionaryWithObjectsAndKeys:@"www.kaikeba.com", @"referer",
                                         @"application/json", @"Accept",
                                         @"application/json", @"Request",
                                         @"application/json", @"Content-Type",
                                         nil];
    }

    if ([host isEqualToString:HOST_API]) {
        [header setObject:KKB_TOKEN_VALUE forKey:KKB_TOKEN_KEY];
    }

    [request setAllHTTPHeaderFields:header];

    if (fromCache) {
        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    } else {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }

    [request setHTTPMethod:method];
    if ([method caseInsensitiveCompare:@"POST"] == NSOrderedSame &&
        param != nil) {
        NSData *jsonData =
            [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];

        [request setHTTPBody:jsonData];
    }
    if ([method caseInsensitiveCompare:@"GET"] == NSOrderedSame &&
        param != nil) {

        NSData *jsonData =
            [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];

        [request setHTTPBody:jsonData];
    }

    AFHTTPRequestOperation *operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *
                                                   operation,
                                               id responseObject) {
        if (successBlock != nil && responseObject != nil) {
            successBlock([self toArrayOrNSDictionary:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogDebug(@"error:%@", error);
        if (failureBlock != nil) {
            failureBlock(error);
        }
    }];
    [operation start];
}

- (void)requestCertificationFromCache:(BOOL)fromCache
                              success:(successBlock)successBlock
                              failure:(failureBlock)failureBlock {
    NSString *urlPath =
        [NSString stringWithFormat:@"v1/certificate/userid/%@",
                                   [KKBUserInfo shareInstance].userId];
    [self requestAPIUrlPath:urlPath
                  fromCache:fromCache
                    success:successBlock
                    failure:failureBlock];
}

- (void)requestMyCollectionFromCache:(BOOL)fromCache
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"v1/collections/user"];
    [self requestAPIUrlPath:urlPath
                  fromCache:fromCache
                    success:successBlock
                    failure:failureBlock];
}

- (void)requestMyMicroMajorFromCache:(BOOL)fromCache
                             success:(successBlock)successBlock
                             failure:(failureBlock)failureBlock {
    NSString *urlPath =
        [NSString stringWithFormat:@"v1/micro_specialties/user/%@",
                                   [KKBUserInfo shareInstance].userId];
    [self requestAPIUrlPath:urlPath
                  fromCache:fromCache
                    success:successBlock
                    failure:failureBlock];
}

// ************************** API *****************
- (void)requestAPIUrlPath:(NSString *)urlPath
                   method:(NSString *)method
                    param:(NSMutableDictionary *)param
                fromCache:(BOOL)fromCache
                  success:(successedBlock)successBlock
                  failure:(failuredBlock)failureBlock {
    // 友盟监测网络请求响应时间
    NSDictionary *dic =
        [NSDictionary dictionaryWithObject:urlPath forKey:@"url"];
    NSString *clickEvent = @"api_response";
    [MobClick beginEvent:clickEvent primarykey:@"url" attributes:dic];

    self.is401Response = NO;

    NSString *url = [NSString stringWithFormat:@"%@/%@", HOST_API, urlPath];

    NSString *userId = [KKBUserInfo shareInstance].userId;
    NSString *password = [KKBUserInfo shareInstance].userPassword;
    BOOL isLogined = [[NSFileManager defaultManager]
        fileExistsAtPath:[AppUtilities getTokenJSONFilePath]];
    if (userId && isLogined) {
        [self.requestSerializer
                      setValue:[NSString
                                   stringWithFormat:@"%@:%@", userId, password]
            forHTTPHeaderField:@"kkb-user"];
    }

    if (fromCache) {
        [self.requestSerializer
            setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    } else {
        [self.requestSerializer
            setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }

    if ([method isEqualToString:@"GET"]) {
        [self GET:url
            parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (successBlock != nil && responseObject != nil) {
                    successBlock(responseObject, operation);
                    //友盟监测网络响应结束时间
                    [MobClick endEvent:clickEvent primarykey:@"url"];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                [self checkResponseStatusCode401:operation];

                if (failureBlock != nil) {
                    failureBlock(error, operation);
                }
            }];

    } else if ([method isEqualToString:@"POST"]) {
        [self POST:url
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                successBlock(responseObject, operation);
                //友盟监测网络响应结束时间
                [MobClick endEvent:clickEvent primarykey:@"url"];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self checkResponseStatusCode401:operation];

                failureBlock(error, operation);
            }];

    } else if ([method isEqualToString:@"DELETE"]) {
        [self DELETE:url
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                successBlock(responseObject, operation);
                //友盟监测网络响应结束时间
                [MobClick endEvent:clickEvent primarykey:@"url"];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                [self checkResponseStatusCode401:operation];

                DDLogDebug(@"responseObject is %@", operation.responseObject);
                DDLogDebug(@"error is %@", error);

                failureBlock(error, operation);
            }];

    } else if ([method isEqualToString:@"PUT"]) {

        [self PUT:url
            parameters:param
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                successBlock(responseObject, operation);
                //友盟监测网络响应结束时间
                [MobClick endEvent:clickEvent primarykey:@"url"];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self checkResponseStatusCode401:operation];
                failureBlock(error, operation);
            }];

    } else if ([method isEqualToString:@"REGISTER"]) {
        [self POST:url
            parameters:nil
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if ([param objectForKey:@"imageInfo"]) {
                    NSDictionary *imageInfoDict =
                        [param objectForKey:@"imageInfo"];
                    NSData *imageData =
                        [imageInfoDict objectForKey:@"imageData"];
                    NSString *imageFileName =
                        [imageInfoDict objectForKey:@"fileName"];
                    NSString *imageFileNameWithPNG = [NSString stringWithFormat:@"%@.png",imageFileName];
                    [formData appendPartWithFileData:imageData
                                                name:@"file"
                                            fileName:imageFileNameWithPNG
                                            mimeType:@"image/jpeg"];
                }

                [formData appendPartWithFormData:
                              [[param objectForKey:@"username"]
                                  dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"username"];
                [formData appendPartWithFormData:
                              [[param objectForKey:@"email"]
                                  dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"email"];
                [formData appendPartWithFormData:
                              [[param objectForKey:@"password"]
                                  dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"password"];
                [formData appendPartWithFormData:
                              [[param objectForKey:@"from"]
                                  dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"from"];
                // CPA 注册接口 与 用户注册接口整合
                NSString *userId = @"";
                NSString *bundleIdentifier =
                    [[NSBundle mainBundle] bundleIdentifier];
                NSString *systemVersion =
                    [[UIDevice currentDevice] systemVersion];
                NSString *channel = @"AppStore";
                NSString *platform = @"iPhone";
                NSString *IDFV =
                    [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                NSString *IDFA = [[[ASIdentifierManager
                        sharedManager] advertisingIdentifier] UUIDString];
                NSString *model = [[UIDevice currentDevice] model];
                NSString *action = @"register";
                NSString *clientVersion =
                    [[[NSBundle mainBundle] infoDictionary]
                        objectForKey:(NSString *)kCFBundleVersionKey];
                NSTimeInterval timeStamp =
                    [[NSDate date] timeIntervalSince1970];
                NSNumber *timeStampNumber =
                    [NSNumber numberWithDouble:timeStamp];
                NSNumberFormatter *numberFormatter =
                    [[NSNumberFormatter alloc] init];
                NSString *timeAction =
                    [numberFormatter stringFromNumber:timeStampNumber];

                [formData appendPartWithFormData:
                              [userId dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"user_id"];
                [formData appendPartWithFormData:
                              [bundleIdentifier
                                  dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"package_name"];
                [formData
                    appendPartWithFormData:
                        [systemVersion dataUsingEncoding:NSUTF8StringEncoding]
                                      name:@"os_version"];
                [formData appendPartWithFormData:
                              [channel dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"channel"];
                [formData appendPartWithFormData:
                              [platform dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"platform"];
                [formData appendPartWithFormData:
                              [IDFV dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"ifv"];
                [formData appendPartWithFormData:
                              [IDFA dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"ifa"];
                [formData appendPartWithFormData:
                              [action dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"action"];
                [formData appendPartWithFormData:
                              [model dataUsingEncoding:NSUTF8StringEncoding]
                                            name:@"model"];
                [formData
                    appendPartWithFormData:
                        [clientVersion dataUsingEncoding:NSUTF8StringEncoding]
                                      name:@"client_version"];
                [formData
                    appendPartWithFormData:
                        [timeAction dataUsingEncoding:NSUTF8StringEncoding]
                                      name:@"time_action"];
            }
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                DDLogDebug(@"create request success");
                successBlock(responseObject, operation);
                //友盟监测网络响应结束时间
                [MobClick endEvent:clickEvent primarykey:@"url"];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DDLogDebug(@"create request failure");
                [self checkResponseStatusCode401:operation];
                failureBlock(error, operation);
            }];
    } else if ([method isEqualToString:@"MODIFY"]) {
        [self POST:url
            parameters:nil
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

                NSString *username = [param objectForKey:@"username"];
                NSString *imageFile = [[param objectForKey:@"imageInfo"] objectForKey:@"fileName"];
                
                NSString *imageFileName = [NSString stringWithFormat:@"%@.png",imageFile];

                NSData *imageData = [[param objectForKey:@"imageInfo"] objectForKey:@"imageData"];
                if (username) {
                    [formData
                        appendPartWithFormData:
                            [username dataUsingEncoding:NSUTF8StringEncoding]
                                          name:@"username"];
                }

                if (imageFile) {
                    [formData appendPartWithFileData:imageData
                                                name:@"file"
                                            fileName:imageFileName
                                            mimeType:@"image/png"];
                }
            }
            success:^(AFHTTPRequestOperation *operation, id responseObject) {

                DDLogDebug(@"create request success");
                successBlock(responseObject, operation);
                //友盟监测网络响应结束时间
                [MobClick endEvent:clickEvent primarykey:@"url"];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                DDLogDebug(@"create request failure");
                [self checkResponseStatusCode401:operation];
                failureBlock(error, operation);
            }];
    }
}

- (void)checkResponseStatusCode401:(AFHTTPRequestOperation *)operation {
    DDLogDebug(@"statusCode is %ld", (long)operation.response.statusCode);
    NSInteger statusCode = operation.response.statusCode;
    if (statusCode == 401) {
        self.is401Response = YES;
    } else {
        self.is401Response = NO;
    }
}

- (void)setGuestToken:(NSString *)_token {
    guestToken = _token;
}

//解析网络返还数据 返回字典或数组
//- (NSDictionary *)parseData:(NSData *)responseObject
//{
//    NSError *error;
//    NSDictionary *accountProfilesDictionary=[NSJSONSerialization
//    JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments
//                                      error:&error];
//    return accountProfilesDictionary;
//}

- (id)toArrayOrNSDictionary:(NSData *)jsonData {
    NSError *error = nil;
    id jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData
                                        options:NSJSONReadingAllowFragments
                                          error:&error];

    if (jsonObject != nil && error == nil) {
        return jsonObject;
    } else {
        // 解析错误
        return nil;
    }
}
- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String]; //转换成utf-8
    unsigned char result
        [16]; //开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    /*
     extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char
     *md)官方封装好的加密方法
     把cStr字符串转换成了32位的16进制数列（这个过程不可逆转）
     存储到了result这个空间中
     */
    return [NSString
        stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
}

#pragma mark - Property
- (void)setIs401Response:(BOOL)is401Response {
    if (_is401Response != is401Response) {
        _is401Response = is401Response;

        if (_is401Response) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:GB_NETWORK_RESPONSE_404ERR
                              object:nil];
        }
    }
}

#pragma mark - 取消指定的网络请求任务（如果指定的任务正在请求）
- (void)cancelCurrentRequesetInQueueWithRequestURL:(NSString *)urlStr {
    NSString *url = [NSString stringWithFormat:@"%@/%@", HOST_API, urlStr];

    for (AFHTTPRequestOperation *operation in self.operationQueue.operations) {
        if ([[operation.request.URL absoluteString] isEqualToString:url]) {
            [operation cancel];
            NSLog(@"取消请求:%@", url);
            break;
        }
    }
}
@end
