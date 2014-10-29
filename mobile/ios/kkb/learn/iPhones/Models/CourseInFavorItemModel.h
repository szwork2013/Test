//
//  CourseInFavorItem.h
//  learn
//  用户收藏 包括导学课和公开课
//  Created by xgj on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseInFavorItemModel : NSObject

@property(nonatomic, strong) NSNumber *courseId;

@property(nonatomic, strong) NSString *courseTitle;
@property(nonatomic, strong) NSString *courseImageUrl;
@property(nonatomic, assign) BOOL isOpenCourse;
@property(nonatomic, copy) NSNumber *time;

@property(nonatomic, strong) NSString *updateTime; //页面使用的时间
@property(nonatomic, strong)
    NSString *updateInfo; // cell中detail字段 引导话+name组合
@property(nonatomic, assign) BOOL isSelected;

@end
