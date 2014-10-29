//
//  KKBCourseItemCellModel.h
//  learn
//
//  Created by zengmiao on 8/16/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CourseItemModelType) {
    CourseItemOpenType = 0, //公开课
    CourseItemGuideType     //导学课
};

@interface KKBCourseItemCellModel : NSObject

@property(nonatomic, assign) CourseItemModelType itemType;

@property(nonatomic, copy) NSString *headImageURL;
@property(nonatomic, copy) NSString *cellTitle;
@property(nonatomic, copy) NSNumber *enrollments; //学习人数

@property(nonatomic, assign) CGFloat rating; // 0-5
@property(nonatomic, assign) BOOL isOnLine;  //是否开课

@end
