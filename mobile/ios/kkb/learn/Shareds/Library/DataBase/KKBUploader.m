//
//  KKBUploader.m
//  learn
//
//  Created by 翟鹏程 on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBUploader.h"
#import "KKBDataBase.h"
#import "KKBHttpClient.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KKBUserInfo.h"

@implementation KKBUploader {
    dispatch_queue_t uploadDispatchQueue;
}

+ (KKBUploader *)sharedInstance {
    static KKBUploader *singleton = nil;
    ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ singleton = [[KKBUploader alloc] init]; });
    return singleton;
}

- (id)init {
    self = [super init];
    if (self) {
        const char *queueName = "kkbUpload";
        uploadDispatchQueue = dispatch_queue_create(queueName, NULL);
    }
    return self;
}

- (void)bufferCPAInfoWithUserID:(NSString *)userId action:(NSString *)action {
    if (userId == nil) {
        userId = @"";
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *channel = @"AppStore";
    NSString *platform = @"iPhone";
    NSString *IDFV =
        [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *IDFA = [
        [[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *mac = @"";
    NSString *imei = @"";
    NSString *clientVersion = [[[NSBundle mainBundle] infoDictionary]
        objectForKey:(NSString *)kCFBundleVersionKey];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampNumber = [NSNumber numberWithDouble:timeStamp];
    long timeActionNumber = [timeStampNumber longValue];
    //    NSString *theAction = action;
    NSString *model = [[UIDevice currentDevice] model];
    NSDictionary *dict;
    @try {
        dict = @{
                               @"user_id" : userId,
                               @"package_name" : bundleIdentifier,
                               @"os_version" : systemVersion,
                               @"channel" : channel,
                               @"platform" : platform,
                               @"ifv" : IDFV,
                               @"ifa" : IDFA,
                               @"mac" : mac,
                               @"imei" : imei,
                               @"time_action" : [NSNumber numberWithLong:timeActionNumber],
                               @"action" : action,
                               @"model" : model,
                               @"client_version" : clientVersion
                               };
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSMutableDictionary *paramDic = (NSMutableDictionary *)dict;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDic
                                                       options:0
                                                         error:&error];
    NSString *jsonString =
        [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [[KKBDataBase sharedInstance] addRecordWithJsonString:jsonString
                                                     type:@"CPA"];
}

- (void)bufferVideoProgressInfo {
}

- (void)bufferPushNotificationInfoWithUserID:(NSString *)userId
                                    clientID:(NSString *)clientId
                                   userEmail:(NSString *)userEmail {
    NSString *IDFV =
        [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *IDFA = [
        [[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSDictionary *dict = @{
        @"uid" : userId,
        @"ifv" : IDFV,
        @"ifa" : IDFA,
        @"cid" : clientId,
        @"email" : userEmail
    };
    NSMutableDictionary *paramDic = (NSMutableDictionary *)dict;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDic
                                                       options:0
                                                         error:&error];
    NSString *jsonString =
        [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[KKBDataBase sharedInstance] addRecordWithJsonString:jsonString
                                                     type:@"PUSH"];
}

- (void)startUpload {
    //
    dispatch_async(uploadDispatchQueue, ^{
        // 全部数据
        NSMutableArray *recordsArray =
            [[KKBDataBase sharedInstance] getAllRecords];
        while ([recordsArray count] != 0) {
            // 最后一条数据
            NSString *jsonString =
                [[recordsArray lastObject] objectForKey:@"content"];
            NSString *type = [[recordsArray lastObject] objectForKey:@"type"];
            // jsonString 转换成id 类型
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&error];
            int count = 5;
            while (count > 0) {
                // 最多请求5次网络 5次之后如果还没有成功 则 停止请求
                // 判断是否上传成功
                __block BOOL uploadStatus = NO;
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);

                NSString *urlForUpload;
                NSString *requestMethod;
                if ([type isEqualToString:@"CPA"]) {
                    urlForUpload = @"v1/cpa";
                    requestMethod = @"POST";
                } else if ([type isEqualToString:@"VIDEO"]) {
                    urlForUpload = @"v1/play_records";
                    requestMethod = @"PUT";
                } else if ([type isEqualToString:@"PUSH"]) {
                    urlForUpload = @"v1/push";
                    requestMethod = @"POST";
                }
                NSMutableDictionary *paramDic = (NSMutableDictionary *)result;

                [[KKBHttpClient shareInstance] requestAPIUrlPath:urlForUpload
                    method:requestMethod
                    param:paramDic
                    fromCache:NO
                    success:^(id result, AFHTTPRequestOperation *operation) {
                        if ((long)operation.response.statusCode == 201) {
                            uploadStatus = YES;
                        } else {
                            uploadStatus = NO;
                        }
                        dispatch_semaphore_signal(sema);
                    }
                    failure:^(id result, AFHTTPRequestOperation *operation) {
                        if (operation.responseObject) {
                            NSDictionary *responseDict =
                                (NSDictionary *)operation.responseObject;
                            if ([[responseDict objectForKey:@"message"]
                                    isEqualToString:@"创建信息已存在"]) {
                                uploadStatus = YES;
                            } else {
                                uploadStatus = NO;
                            }
                        } else {
                            uploadStatus = NO;
                        }
                        dispatch_semaphore_signal(sema);
                    }];
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

                if (uploadStatus) {
                    [[KKBDataBase sharedInstance]
                        removeRecordWithID:
                            [[[recordsArray lastObject]
                                objectForKey:@"id"] integerValue]];
                    [recordsArray removeLastObject];
                    break;
                } else {
                    count--;
                }

                if (count == 0) {
                    [recordsArray removeLastObject];
                }
            }
        }
    });
}

@end
