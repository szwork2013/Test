//
//  AssignmentOperator.h
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//
#import "BaseOperator.h"
#import "AssignmentInCourseStructs.h"
@interface AssignmentOperator : BaseOperator

@property (nonatomic, retain) AssignmentInCourseStructs *assignmentStructs; //作业结构体



//获取作业
- (void)requestAssignments:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;
@end
