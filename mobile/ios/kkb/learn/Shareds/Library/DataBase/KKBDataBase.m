//
//  KKBDataBase.m
//  learn
//
//  Created by 翟鹏程 on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBDataBase.h"

#define DB_FILE @"uploadDBCache.sqlite"
#define TYPE @"CPA"
#define BATCH_SIZE 100

@implementation KKBDataBase {
    //声明一个操作sqlite3数据库的成员变量
    FMDatabase *_dataBase;
}

static KKBDataBase *manager = nil;
+ (KKBDataBase *)sharedInstance {
    if (manager == nil) {
        manager = [[KKBDataBase alloc] init];
    }
    return manager;
}
//重写init方法，完成必要的初始化操作
- (id)init {
    self = [super init];
    if (self) {
        //指定数据库的路径
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
            NSCachesDirectory, NSUserDomainMask, YES);
        NSString *docsDir = dirPaths[0];
        NSString *databasePath = [[NSString alloc]
            initWithString:[docsDir stringByAppendingPathComponent:DB_FILE]];
        _dataBase = [[FMDatabase alloc] initWithPath:databasePath];

        //创建一个FMDataBase（操作sqlite3）的对象,并将数据库的路径传递给对象
        //        NSString *dbPath = [NSHomeDirectory()
        //        stringByAppendingFormat:@"/Documents/%@",DB_FILE];
        //        _dataBase = [[FMDatabase alloc] initWithPath:dbPath];

        // open有两层含义:如果指定路径下没有.db则创建一个.db数据库文件，并打开，如果已经存在.db则直接打开,返回值反映操作是否成功
        BOOL isSuccessed = [_dataBase open];
        if (isSuccessed) {
            //创建一个表(用sql语句：对数据库进行操作的语句，是一种语言)
            // blob 指代二进制的对象 image 要转化成NSData存入数据库
            NSString *createSql = @"create table if not exists cache (id "
                @"integer primary key autoincrement, type "
                @"text,content text)";
            //需要执行创建表的语句,创建表、增、删、改
            //写的sql语句，执行的话全用executeUpdate方法,返回值为执行的结果
            BOOL isCreateSuccessed = [_dataBase executeUpdate:createSql];
            if (!isCreateSuccessed) {
                //执行语句失败
                // lastErrorMessage 会获取到执行sql语句失败的信息
                NSLog(@"create error:%@", _dataBase.lastErrorMessage);
            }
        }
    }
    return self;
}

- (void)addRecordWithJsonString:(NSString *)jsonString type:(NSString *)type {
    // executeUpdate:后面跟的参数类型必须是NSObject或它的子类，
    // FMDataBase对象会将传过来的参数，转化成与数据库字段相匹配的类型，再进行后续处理
    NSString *insertSql = [NSString
        stringWithFormat:@"insert into cache (type,content) values ('%@','%@')",
                         type, jsonString];
    BOOL isSuccessed = [_dataBase executeUpdate:insertSql];
    if (isSuccessed == NO) {
        //插入语句执行失败
        NSLog(@"insert error:%@", _dataBase.lastErrorMessage);
    }
}

- (NSMutableArray *)getAllRecords {
    NSMutableArray *array = [NSMutableArray array];
    NSString *selectSql = @"select * from cache";
    FMResultSet *set = [_dataBase executeQuery:selectSql];
    while ([set next]) {
        //每次取出一整条数据
        //根据字段名称，取出字段的值
        NSString *jsonString = [set stringForColumn:@"content"];
        NSString *theType = [set stringForColumn:@"type"];
        NSString *recordId = (NSString *)[set stringForColumn:@"id"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:jsonString forKey:@"content"];
        [dict setObject:theType forKey:@"type"];
        [dict setObject:recordId forKey:@"id"];

        [array addObject:dict];
    }
    return array;
}

- (void)removeRecordWithID:(int)recordId {
    NSString *delectSql = [NSString
        stringWithFormat:@"delete from cache where id = '%d'", recordId];
    [_dataBase executeUpdate:delectSql];
}

@end
