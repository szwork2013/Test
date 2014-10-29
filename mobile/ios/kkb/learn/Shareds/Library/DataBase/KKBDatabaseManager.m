//
//  KKBDatabaseManager.m
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBDatabaseManager.h"
#import "FMDatabase.h"
#import "FMDB.h"
#import "KKBUserInfo.h"
#import "LocalStorage.h"

#define FMDBQuickCheck(SomeBool)                                               \
    {                                                                          \
        if (!(SomeBool)) {                                                     \
            NSLog(@"Failure on line %d", __LINE__);                            \
            abort();                                                           \
        }                                                                      \
    }

#define SearchHistoryTableCurrentVersion 1

@implementation KKBDatabaseManager

+ (KKBDatabaseManager *)sharedInstance {
    static KKBDatabaseManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{ singleton = [[KKBDatabaseManager alloc] init]; });
    return singleton;
}

+ (BOOL)createSearchRecordsTable {
    FMDatabase *db =
        [FMDatabase databaseWithPath:[KKBDatabaseManager getDatabasePath]];
    BOOL updated = FALSE;
    if ([db open]) {

        BOOL isExisted = [self isSearchHistoryTableExisted:db];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        // 新用户,以前没安装过
        if (!isExisted) {
            updated = [self createSearchHistoryTable:db];
            [db close];

            [userDefaults setInteger:SearchHistoryTableCurrentVersion
                              forKey:SearchHistoryDatabaseUserVersion];

            return updated;
        }

        // 老用户，安装过
        for (int i = 0; i < SearchHistoryTableCurrentVersion; i++) {

            NSUInteger userDbVersion =
                [userDefaults integerForKey:SearchHistoryDatabaseUserVersion];

            if (userDbVersion < SearchHistoryTableCurrentVersion) {
                if (userDbVersion <= 0) {

                    [self upgradeTableStructureToVersion1:db];

                    [userDefaults setInteger:(userDbVersion + 1)
                                      forKey:SearchHistoryDatabaseUserVersion];
                }
            }
        }
    }

    [db close];

    return updated;
}

+ (void)upgradeTableStructureToVersion1:(FMDatabase *)db {

    // step 1: alter table
    NSString *alterTableStatement = [NSString
        stringWithFormat:@"ALTER TABLE %@ RENAME TO %@", TABLE_SEARCH_RECORD,
                         TEMP_TABLE_SEARCH_RECORD];

    // step 2: create new table
    NSString *createTableStatement = [NSString
        stringWithFormat:@"CREATE TABLE %@ (%@ TEXT UNIQUE, %@ "
                         @"INTEGER PRIMARY KEY AUTOINCREMENT)",
                         TABLE_SEARCH_RECORD, COLUMN_RECORD, COLUMN_RECORD_ID];

    //  step 3: data migration
    NSString *insertDataStatement =
        [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@",
                                   TABLE_SEARCH_RECORD, COLUMN_RECORD,
                                   COLUMN_RECORD, TEMP_TABLE_SEARCH_RECORD];

    // step 4: drop temp table
    NSString *dropTableStatment =
        [NSString stringWithFormat:@"DROP TABLE %@", TEMP_TABLE_SEARCH_RECORD];

    // final : executation
    [db executeUpdate:alterTableStatement];
    [db executeUpdate:createTableStatement];
    [db executeUpdate:insertDataStatement];
    [db executeUpdate:dropTableStatment];
}

+ (BOOL)isSearchHistoryTableExisted:(FMDatabase *)db {

    NSString *queryStatement = [NSString
        stringWithFormat:
            @"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';",
            TABLE_SEARCH_RECORD];

    FMResultSet *result = [db executeQuery:queryStatement];
    BOOL existed = ([result next]);

    return existed;
}
+ (BOOL)createSearchHistoryTable:(FMDatabase *)db {
    // create new table
    NSString *createTableStatement = [NSString
        stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ TEXT UNIQUE, %@ "
                         @"INTEGER PRIMARY KEY AUTOINCREMENT)",
                         TABLE_SEARCH_RECORD, COLUMN_RECORD, COLUMN_RECORD_ID];

    BOOL success = [db executeUpdate:createTableStatement];

    return success;
}

+ (NSString *)getDatabaseDirPath {
    NSFileManager *manager = [NSFileManager defaultManager];

    NSArray *allPathes = NSSearchPathForDirectoriesInDomains(
        NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [allPathes objectAtIndex:0];
    NSString *dbDir = [cachesDir stringByAppendingPathComponent:@"db"];

    [manager createDirectoryAtPath:dbDir
        withIntermediateDirectories:NO
                         attributes:nil
                              error:nil];

    return dbDir;
}

+ (NSString *)getDatabasePath {

    NSString *databaseName =
        [KKBUserInfo shareInstance].userId == nil
            ? GUEST_DATABASE_NAME
            : [NSString stringWithFormat:@"kkb_db_user%@.sqlite",
                                         [KKBUserInfo shareInstance].userId];

    NSString *dbPath =
        [[self getDatabaseDirPath] stringByAppendingPathComponent:databaseName];

    return dbPath;
}

@end
