//
//  KKBDownloadModule.h
//  learn
//
//  Created by xgj on 14-7-2.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBDownloadRecord.h"

@interface KKBDownloadCourse : NSObject

@property(assign, nonatomic) BOOL isSelected;
@property(retain, nonatomic) NSString *courseId;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic)
    NSMutableArray *downloadRecords; // it contains KKBDownloadRecord instance

- (id)initWith:(NSString *)courseId title:(NSString *)title;
- (void)addRecord:(KKBDownloadRecord *)aRecord;

@end
