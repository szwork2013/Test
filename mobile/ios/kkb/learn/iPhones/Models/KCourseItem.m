//
//  CourseItem.m
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KCourseItem.h"

@implementation KCourseItem

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
             videoUrl:(NSString *)videoUrl {

    self = [super init];
    if (self) {
        self.imageUrl = imageUrl;
        self.name = name;
        self.duration = duration;
        self.learnTimeEachWeek = learnTime;
        self.vote = vote;
        self.learnerNumber = learnerNumber;
        self.type = type;
        self.other = otherInfo;
        self.courseId = courseId;
        self.courseIntro = courseIntro;
        self.courseLevel = courseLevel;
        self.keyWord = keyWord;
        self.coverImage = coverImage;
        self.videoUrl = videoUrl;
    }

    return self;
}

@end
