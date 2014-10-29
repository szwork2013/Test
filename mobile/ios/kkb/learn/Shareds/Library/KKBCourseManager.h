//
//  KKBCourseManager.h
//  learn
//
//  Created by zengmiao on 8/26/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionHandler)(id model, NSError *error);

@interface KKBCourseManager : NSObject

/**
 *  刷新course的数据
 *
 *  @param forceReload 本地/网络
 *  @param block       block description
 */
+ (void)updateAllCoursesForceReload:(BOOL)forceReload
                  completionHandler:(void (^)(BOOL success))block;

/**
 *  根据courseID查询指定的course
 *
 *  @param courseID    courseID description
 *  @param forceReload 是否需要强制刷新
 *  @param handler     handler description
 */
+ (void)getCourseWithID:(NSNumber *)courseID
            forceReload:(BOOL)forceReload
      completionHandler:(completionHandler)handler;

/**
 *  根据courseIDs查询指定的course集合 集合中的id必须为 NSNumber类型
 *
 *  @param courseIDs   courseIDs description
 *  @param forceReload forceReload description
 *  @param handler     集合
 */
+ (void)getCoursesWithIDs:(NSArray *)courseIDs
              forceReload:(BOOL)forceReload
        completionHandler:(completionHandler)handler;

+ (void)getAllCoursesForceReload:(BOOL)forceReload
               completionHandler:(completionHandler)handler;

@end
