//
//  GuideCourseCardItem.h
//  learn
//  推荐的导学课
//  Created by xgj on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideCourseCardItemModel : NSObject

@property(nonatomic, strong) NSNumber *courseId;
@property(nonatomic, strong) NSNumber *lmsCourseId;
@property(nonatomic, strong) NSString *courseImageUrl;
@property(nonatomic, strong) NSString *courseTitle;

@property(nonatomic, assign) NSUInteger courseNumberOfWeek; //第几周

@property(strong, nonatomic) NSArray *items; // items

@property(nonatomic, assign) float courseLearnProgress;
@property(nonatomic, strong) NSString *courseLearnProgressText;

@property(nonatomic, assign) NSUInteger discussionScore;
@property(nonatomic, strong) NSString *discussionInfo;
@property(nonatomic, assign) BOOL discussionFinished;

@property(nonatomic, assign) NSUInteger homeworkScore;
@property(nonatomic, strong) NSString *homeworkInfo;
@property(nonatomic, assign) BOOL homeworkFinished;

@property(nonatomic, assign) NSUInteger quizScore;
@property(nonatomic, strong) NSString *quizInfo;
@property(nonatomic, assign) BOOL quizFinished;

@property(nonatomic, assign) BOOL isCoursePassed;
@property(nonatomic, assign) BOOL isSelected;

@property(nonatomic, assign) BOOL isFinishedAllTask;

@property(nonatomic, strong) NSIndexPath *indexPath;

@end
