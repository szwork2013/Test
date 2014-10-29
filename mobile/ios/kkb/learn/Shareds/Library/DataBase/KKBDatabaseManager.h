//
//  KKBDatabaseManager.h
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GUEST_DATABASE_NAME @"kkb_guest_db.sqlite"
#define TABLE_SEARCH_RECORD @"tableSearchRecord"
#define TEMP_TABLE_SEARCH_RECORD @"tempTableSearchRecord20141014"
#define COLUMN_RECORD @"SearchRecord"
#define COLUMN_RECORD_ID @"SearchRecordId"

@interface KKBDatabaseManager : NSObject

+ (KKBDatabaseManager *)sharedInstance;
+ (NSString *)getDatabaseDirPath;
+ (NSString *)getDatabasePath;
+ (BOOL)createSearchRecordsTable;

@end
