//
//  KKBCourseWeekItem.h
//  learn
//
//  Created by zxj on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKBCourseWeekItem : NSObject
@property(strong, nonatomic) NSString *courseId;
@property(strong, nonatomic) NSString *title;

- (id)initWith:(NSString *)courseId title:(NSString *)title;
@end
