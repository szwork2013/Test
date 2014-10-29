//
//  DataManage.m
//  learn
//
//  Created by zxj on 14-6-7.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "DataManage.h"
#import "sqlite3.h"
#import "GlobalDefine.h"

static sqlite3* db;
@implementation DataManage
+(void)createSqliteDataFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:SQLITE_DATA_NAME];
    if(sqlite3_open([path UTF8String], &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSLog(@"打开数据库失败！");
    }
    
    if (sqlite3_exec(db, [SQLITE_CREATE_DATA_LAG UTF8String], nil, nil, nil)) {
        sqlite3_close(db);
        NSLog(@"创建表失败！");
    }
}
+(void)insertDataToSqlite:(NSString *)dataId value:(NSString *)dataValue
{
    NSString* inserStr = [NSString stringWithFormat:@"%@%@",dataId,dataValue];
    if (sqlite3_exec(db, [inserStr UTF8String], nil, nil, nil)) {
        sqlite3_close(db);
        NSLog(@"插入数据失败!");
    }
}
//+(void)deleteDataFromSqlite:(NSString *)dataId
//{
//    NSString
//}

+(void)searchDataFromSqlite:(NSString *)dataId
{
}
@end
