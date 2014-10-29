//
//  LocalStorage.m
//  learn
//
//  Created by caojing on 6/23/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "LocalStorage.h"
#import "KKBUserInfo.h"
#import "KKBDatabaseManager.h"

#define LEARN_STATUS_PREFIX @"learn"
#define DOWNLOAD_PREFIX @"download"
#define TENCENT_PREFIX @"tencent"
#define ENROLL_COURSE_PREFIX @"enroll_course"
#define PLAY_BACK_POSITION @"playbackPosition"
#define GETUI_PUSH @"geTui"
#define MAJOR_CONTENTSIZE @"majorViewContentSize"

#define HasLaunchedOnce @"HasLaunchedOnce"

static const NSInteger SearchHistoryMaxRecords = 10;

static const int ddLogLevel = LOG_LEVEL_WARN;

@implementation LocalStorage

+ (LocalStorage *)shareInstance {
    static LocalStorage *singleton = nil;
    ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[LocalStorage alloc] init];
        singleton.userDefaults = [NSUserDefaults standardUserDefaults];

        [self createSearchRecordsTable];
    });
    return singleton;
}

- (void)addDownload:(NSDictionary *)downloadInfo {
}

- (void)removeAllLearnStatus {
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"SELF BEGINSWITH %@", LEARN_STATUS_PREFIX];
    NSArray *keys = [[self.userDefaults dictionaryRepresentation] allKeys];
    for (NSString *key in keys) {
        if ([predicate evaluateWithObject:key]) {
            [self.userDefaults removeObjectForKey:key];
        }
    }
}

- (void)saveLearnStatus:(BOOL)isAlreadyLearned course:(NSString *)courseId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return;
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", LEARN_STATUS_PREFIX, userId, courseId];
    [self.userDefaults setBool:isAlreadyLearned forKey:key];
}

- (void)saveLearnStatus:(BOOL)isAlreadyLearned ByClassId:(NSString *)classId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return;
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", LEARN_STATUS_PREFIX, userId, classId];
    [self.userDefaults setBool:isAlreadyLearned forKey:key];
}

- (BOOL)getLearnStatusByClassId:(NSString *)classId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return NO;
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", LEARN_STATUS_PREFIX, userId, classId];
    return [self.userDefaults boolForKey:key];
}

- (BOOL)getLearnStatusBy:(NSString *)courseId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return NO;
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", LEARN_STATUS_PREFIX, userId, courseId];
    return [self.userDefaults boolForKey:key];
}

- (void)saveCourseName:(NSString *)courseName course:(NSString *)courseId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        userId = @"0";
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", DOWNLOAD_PREFIX, userId, courseId];

    [self.userDefaults setObject:courseName forKey:key];
}

- (void)saveVideoName:(NSString *)videoName
               course:(NSString *)courseId
              videoId:(NSString *)videoId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@", DOWNLOAD_PREFIX,
                                               userId, courseId, videoId];
    [self.userDefaults setObject:videoName forKey:key];
}

- (NSString *)getCourseNameBy:(NSString *)courseId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        userId = @"0";
    }
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", DOWNLOAD_PREFIX, userId, courseId];

    return [self.userDefaults objectForKey:key];
}

- (NSString *)getVideoNameBy:(NSString *)courseId
                  andVideoId:(NSString *)videoId {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        return nil;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@", DOWNLOAD_PREFIX,
                                               userId, courseId, videoId];

    return [self.userDefaults stringForKey:key];
}

#pragma mark - Tencent
- (void)setTencentAccessToken:(NSString *)token {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"accessToken"];
    [self.userDefaults setObject:token forKey:key];
}

- (NSString *)getTencentAccessToken {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"accessToken"];

    return [self.userDefaults stringForKey:key];
}

- (void)setTencentAppId:(NSString *)appId {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"appId"];
    [self.userDefaults setObject:appId forKey:key];
}
- (NSString *)getTencentAppId {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"appId"];

    return [self.userDefaults stringForKey:key];
}

- (void)setTencentOpenId:(NSString *)openId {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"openId"];
    [self.userDefaults setObject:openId forKey:key];
}

- (NSString *)getTencentOpenId {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"openId"];

    return [self.userDefaults stringForKey:key];
}

- (void)setTencentExpirationDate:(NSString *)expirationDate {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"expirationDate"];
    [self.userDefaults setObject:expirationDate forKey:key];
}

- (NSString *)getTencentExpirationDate {
    NSString *key =
        [NSString stringWithFormat:@"%@_%@", TENCENT_PREFIX, @"expirationDate"];

    return [self.userDefaults stringForKey:key];
}

- (void)setLoginVia:(NSString *)th3Platform {
    [self.userDefaults setObject:th3Platform forKey:LoginVia];
}

- (NSString *)getLoginVia {
    return [self.userDefaults stringForKey:LoginVia];
}

#pragma mark - Search Records

- (NSArray *)getSearchRecords {
    FMDatabase *db =
        [FMDatabase databaseWithPath:[KKBDatabaseManager getDatabasePath]];

    if (![db open]) {
        DDLogInfo(@"Could not open db.");
        return nil;
    }

    NSString *queryStatement = [NSString
        stringWithFormat:@"select * from %@ ORDER BY %@ DESC limit %i",
                         TABLE_SEARCH_RECORD, @"SearchRecordId",
                         SearchHistoryMaxRecords];

    FMResultSet *result = [db executeQuery:queryStatement];

    NSMutableArray *records = [[NSMutableArray alloc] init];
    while ([result next]) {
        [records addObject:[result stringForColumn:COLUMN_RECORD]];
    }

    return (NSArray *)records;
}

+ (BOOL)createSearchRecordsTable {
    return [KKBDatabaseManager createSearchRecordsTable];
}

- (void)insertSearchRecord:(NSString *)searchKeyword {

    FMDatabase *db =
        [FMDatabase databaseWithPath:[KKBDatabaseManager getDatabasePath]];
    BOOL openSuccess = [db open];
    if (openSuccess) {

        NSString *trimmedText =
            [searchKeyword stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
        NSString *insertStatement =
            [NSString stringWithFormat:@"insert into %@ (%@) values (?)",
                                       TABLE_SEARCH_RECORD, COLUMN_RECORD];
        BOOL insertSuccess =
            [db executeUpdate:insertStatement, trimmedText]; // ok

        if (!insertSuccess) {
            DDLogInfo(@"Insert Data Failed");
        }
    }

    [db close];
}

- (void)clearSearchTableRecords {
    FMDatabase *db =
        [FMDatabase databaseWithPath:[KKBDatabaseManager getDatabasePath]];

    if (![db open]) {
        DDLogInfo(@"Could not open db.");
        return;
    }

    NSString *clearStatement =
        [NSString stringWithFormat:@"delete from %@", TABLE_SEARCH_RECORD];
    [db executeUpdate:clearStatement];

    [db close];
}

- (void)saveSearchRecordDatabaseUserVersion:(NSInteger)currentVersion {
    [self.userDefaults setInteger:currentVersion
                           forKey:SearchHistoryDatabaseUserVersion];
}

- (NSInteger)getSearchRecordDatabaseUserVersion {
    return [self.userDefaults integerForKey:SearchHistoryDatabaseUserVersion];
}

- (void)setEnrollCourseStatus:(NSString *)courseId userId:(NSString *)userId {
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", ENROLL_COURSE_PREFIX, courseId, userId];
    [self.userDefaults setBool:YES forKey:key];
}
- (BOOL)getEnrollCourseStatus:(NSString *)courseId userId:(NSString *)userId {
    NSString *key = [NSString
        stringWithFormat:@"%@_%@_%@", ENROLL_COURSE_PREFIX, courseId, userId];
    return [self.userDefaults boolForKey:key];
}

// 播放时间
- (void)savePlaybackPosition:(float)playbackPosition
                    courseId:(NSString *)courseId
                     classId:(NSString *)classId
                    videoUrl:(NSString *)videoUrl {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        userId = @"0";
    }
    if (courseId == nil) {
        courseId = @"0";
    }
    if (classId == nil) {
        classId = @"0";
    }
    NSString *key =
        [NSString stringWithFormat:@"%@_%@_%@_%@_%@", PLAY_BACK_POSITION,
                                   userId, courseId, classId, videoUrl];
    DDLogInfo(@"💓saveKey:%@,duration:%f URL:%@💓", key, playbackPosition,
              videoUrl);

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:playbackPosition forKey:key];
    [prefs synchronize];
}

// 如果没有courseid userid classid 时 传nil值
- (float)getPlaybackPosition:(NSString *)courseId
                     classId:(NSString *)classId
                    videoUrl:(NSString *)videoUrl {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    if (userId == nil) {
        userId = @"0";
    }
    if (courseId == nil) {
        courseId = @"0";
    }
    if (classId == nil) {
        classId = @"0";
    }
    NSString *key =
        [NSString stringWithFormat:@"%@_%@_%@_%@_%@", PLAY_BACK_POSITION,
                                   userId, courseId, classId, videoUrl];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    float playbackPosition = [prefs floatForKey:key];

    DDLogInfo(@"💓getKey:%@,duration:%f URL:%@💓", key, playbackPosition,
              videoUrl);

    return playbackPosition;
}

- (void)saveLaunchStatus {
    [self.userDefaults setBool:YES forKey:HasLaunchedOnce];
}

- (BOOL)hasLaunchedOnce {
    return [self.userDefaults boolForKey:HasLaunchedOnce];
}

- (BOOL)pushSwitchIsOpen {
    // 跟用户绑定
    NSString *userId = [KKBUserInfo shareInstance].userId;
    // 如果用户名为空 默认为开
    if (userId == nil) {
        return YES;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%@", GETUI_PUSH, userId];
    // 如果用户名不为空，判断之前是否有过存储，没有的话默认为开
    NSString *keyValue = [self.userDefaults valueForKey:key];
    if (keyValue == nil) {
        [self setPushSwitchStatus:YES];
        return YES;
    }
    
    return [self.userDefaults boolForKey:key];
}

- (void)setPushSwitchStatus:(BOOL)isOpen {
    NSString *userId = [KKBUserInfo shareInstance].userId;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%@", GETUI_PUSH, userId];
    [userDefaults setBool:isOpen forKey:key];
    [userDefaults synchronize];
}

- (CGFloat)majorViewContentSizeHeight {
    NSString *key = [NSString stringWithFormat:@"%@", MAJOR_CONTENTSIZE];
    // 如果key值为空 contentsize返回值为0
    NSString *keyValue = [self.userDefaults valueForKey:key];
    if (keyValue == nil) {
        return 0;
    }
    return [self.userDefaults floatForKey:key];
}

- (void)setMajorViewContentSizeHeight:(CGFloat)majorViewContentSizeHeight {
    NSString *key = [NSString stringWithFormat:@"%@", MAJOR_CONTENTSIZE];
    [self.userDefaults setFloat:majorViewContentSizeHeight forKey:key];
    [self.userDefaults synchronize];
}


@end
