//
//  DataManage.h
//  learn
//
//  Created by zxj on 14-6-7.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManage : NSObject
+(void)createSqliteDataFile;
+(void)insertDataToSqlite:(NSString*)dataId value:(NSString*)dataValue;
+(void)deleteDataFromSqlite:(NSString*)dataId;
+(void)searchDataFromSqlite:(NSString*)dataId;
@end
