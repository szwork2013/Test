//
//  KKBCourseSummaryItem.m
//  learn
//
//  Created by zxj on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBCourseSummaryItem.h"

@implementation KKBCourseSummaryItem
- (id)initWith:(NSString *)courseId title:(NSString *)title {
    self.courseId = courseId;
    self.title = title;
    self.courseWeekItemArray = [[NSMutableArray alloc] init];
    return self;
}
- (void)addWeekItem:(KKBCourseWeekItem *)courseWeekItem {
    [self.courseWeekItemArray addObject:courseWeekItem];
}
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self.title = [dictionary objectForKey:@"name"];
    self.courseWeekItemArray = [dictionary objectForKey:@"courseTitle"];
    return self;
}
@end
