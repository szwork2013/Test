//
//  LocalStorage.h
//  learn
//
//  Created by caojing on 6/23/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "FMDB.h"
#import "FMDatabase.h"
#import "KKBDatabaseManager.h"

#define SearchHistoryDatabaseUserVersion @"SearchHistoryDatabaseUserVersion"
#define SearchHistoryDatabaseCurrentVersion                                    \
    @"SearchHistoryDatabaseCurrentVersion"

@interface LocalStorage : NSObject

@property(nonatomic) NSUserDefaults *userDefaults;

+ (LocalStorage *)shareInstance;
- (void)saveLearnStatus:(BOOL)isAlreadyLearned course:(NSString *)courseId;
- (BOOL)getLearnStatusBy:(NSString *)courseId;
- (void)removeAllLearnStatus;

- (void)saveCourseName:(NSString *)courseName course:(NSString *)courseId;
- (void)saveVideoName:(NSString *)videoName
               course:(NSString *)courseId
              videoId:(NSString *)videoId;
- (NSString *)getCourseNameBy:(NSString *)courseId;
- (NSString *)getVideoNameBy:(NSString *)courseId
                  andVideoId:(NSString *)videoId;

- (void)saveLearnStatus:(BOOL)isAlreadyLearned ByClassId:(NSString *)classId;
- (BOOL)getLearnStatusByClassId:(NSString *)classId;

// Download
// courseId, moduleId, itemId, CourseName, ItemName
- (void)addDownload:(NSDictionary *)downloadInfo;

// Tencent
- (void)setTencentAccessToken:(NSString *)token;
- (NSString *)getTencentAccessToken;

- (void)setTencentAppId:(NSString *)appId;
- (NSString *)getTencentAppId;

- (void)setTencentOpenId:(NSString *)openId;
- (NSString *)getTencentOpenId;

- (void)setTencentExpirationDate:(NSString *)date;
- (NSString *)getTencentExpirationDate;

- (void)setLoginVia:(NSString *)th3Platform;
- (NSString *)getLoginVia;

#pragma mark - Search Record
- (NSArray *)getSearchRecords;
- (void)clearSearchTableRecords;
- (void)insertSearchRecord:(NSString *)searchKeyword;
- (void)saveSearchRecordDatabaseUserVersion:(NSInteger)currentVersion;
- (NSInteger)getSearchRecordDatabaseUserVersion;

#pragma mark - 微专业
- (void)setEnrollCourseStatus:(NSString *)courseId userId:(NSString *)userId;
- (BOOL)getEnrollCourseStatus:(NSString *)courseId userId:(NSString *)userId;

#pragma mark - 获取用户播放视频
- (void)savePlaybackPosition:(float)playbackPosition
                    courseId:(NSString *)courseId
                     classId:(NSString *)classId
                    videoUrl:(NSString *)videoUrl;

- (float)getPlaybackPosition:(NSString *)courseId
                     classId:(NSString *)classId
                    videoUrl:(NSString *)videoUrl;

- (void)saveLaunchStatus;
- (BOOL)hasLaunchedOnce;

#pragma mark - 推送开关是否开启
- (BOOL)pushSwitchIsOpen;
- (void)setPushSwitchStatus:(BOOL)isOpen;


- (CGFloat)majorViewContentSizeHeight;

- (void)setMajorViewContentSizeHeight:(CGFloat)majorViewContentSizeHeight;

@end
