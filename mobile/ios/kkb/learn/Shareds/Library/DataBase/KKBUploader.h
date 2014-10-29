//
//  KKBUploader.h
//  learn
//
//  Created by 翟鹏程 on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKBUploader : NSObject

+ (KKBUploader *)sharedInstance;

// bufferCPAInfo
// bufferPushNotificationInfo
// bufferVideoProgressInfo

- (void)bufferCPAInfoWithUserID:(NSString *)userId action:(NSString *)action;

- (void)bufferVideoProgressInfo;

- (void)bufferPushNotificationInfoWithUserID:(NSString *)userId
                                    clientID:(NSString *)clientId
                                   userEmail:(NSString *)userEmail;

- (void)startUpload;

@end
