//
//  GuideCourseItemModelProtocol.h
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GuideCourseItemModelProtocol <NSObject>

typedef enum {
    GuideCourseType_Discuss = 0, //讨论
    GuideCourseType_Test,        //测试
    GuideCourseType_homework,    //作业
    GuideCourseType_Video
} GuideCourseItemType;

@property(nonatomic, assign) GuideCourseItemType guideType;

@end
