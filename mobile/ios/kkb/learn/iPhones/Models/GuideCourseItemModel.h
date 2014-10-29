//
//  CourseItemModel.h
//  learn
//  讨论 作业 测验

//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideCourseItemModelProtocol.h"

@interface GuideCourseItemModel : NSObject <GuideCourseItemModelProtocol>

@property(nonatomic, assign) GuideCourseItemType guideType;
@property(nonatomic, copy) NSString *point;  //分数
@property(nonatomic, copy) NSString *statue; //"n" "y" 完成/未完成
@property(nonatomic, copy) NSString *due_at; //截止日期

// 仅用于测验
@property(nonatomic, assign) NSInteger remainingSubmitCount;

@end
