//
//  KKBDataBase.h
//  learn
//
//  Created by 翟鹏程 on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface KKBDataBase : NSObject {
    FMDatabaseQueue *queue;
}

+ (KKBDataBase *)sharedInstance;

- (void)addRecordWithJsonString:(NSString *)jsonString type:(NSString *)type;

- (NSMutableArray *)getAllRecords;
- (void)removeRecordWithID:(int)recordId;

@end
