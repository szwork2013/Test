//
//  CourseItem.h
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCourseItem : NSObject

@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) int duration;
@property(nonatomic, assign) int learnTimeEachWeek;
@property(nonatomic, strong) NSString *vote;
@property(nonatomic, assign) int learnerNumber;
@property(nonatomic, assign) int type;
@property(nonatomic, strong) NSString *courseId;
@property(nonatomic, strong) NSString *other;
@property(nonatomic, copy) NSString *courseIntro;
@property(nonatomic, copy) NSString *courseLevel;
@property(nonatomic, copy) NSString *keyWord;
@property(nonatomic, copy) NSString *coverImage;
@property(nonatomic, copy) NSString *videoUrl;

@property(nonatomic, assign) float rating; //评星

- (id)init:(NSString *)imageUrl
                 name:(NSString *)name
             duration:(int)duration
    learnTimeEachWeek:(int)learnTime
                 vote:(NSString *)vote
        learnerNumber:(int)learnerNumber
                 type:(int)type
             courseId:(NSString *)courseId
                other:(NSString *)otherInfo
          courseIntro:(NSString *)courseIntro
          courseLevel:(NSString *)courseLevel
              keyWord:(NSString *)keyWord
           coverImage:(NSString *)coverImage
             videoUrl:(NSString *)videoUrl;

@end
