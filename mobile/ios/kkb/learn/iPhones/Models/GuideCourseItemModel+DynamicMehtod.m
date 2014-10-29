//
//  GuideCourseItemModel+DynamicMehtod.m
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "GuideCourseItemModel+DynamicMehtod.h"

@implementation GuideCourseItemModel (DynamicMehtod)

- (NSString *)title {
    if (self.guideType == GuideCourseType_Discuss) {
        return @"讨论";
    } else if (self.guideType == GuideCourseType_Test) {
        return @"测试";
    } else if (self.guideType == GuideCourseType_homework) {
        return @"作业";
    }
    return @"未知";
}

@end
