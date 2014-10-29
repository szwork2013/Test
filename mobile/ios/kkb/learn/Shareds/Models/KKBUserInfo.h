//
//  KKBUserInfo.h
//  learn

//  用户名 邮箱 密码 头像 是否登录

//  Created by zxj on 6/20/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKBUserInfo : NSObject

@property(copy, nonatomic) NSString *courseId;
@property(copy, nonatomic) NSString *userId;

+ (KKBUserInfo *)shareInstance;

- (NSString *)transTimeformat:(NSString *)dateString;

@property(nonatomic, copy) NSString *userEmail;
@property(nonatomic, copy) NSString *userPassword;
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *avatar_url;
@property(nonatomic, assign) BOOL isLogin;

@property (nonatomic,copy) NSString *geTuiClientId;

@property (nonatomic,assign) BOOL goToDownloadFromStudyVC;

@end
