//
//  KKBCourseSummaryItem.h
//  learn
//
//  Created by zxj on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBCourseWeekItem.h"
@interface KKBCourseSummaryItem : NSObject
@property(retain, nonatomic) NSString *courseId;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSMutableArray *courseWeekItemArray;

- (id)initWith:(NSString *)courseId title:(NSString *)title;
- (void)addWeekItem:(KKBCourseWeekItem *)courseWeekItem;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
