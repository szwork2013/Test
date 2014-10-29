//
//  MiniMajorCourse.h
//  learn
//
//  Created by xgj on 14-7-14.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiniMajorCourse : NSObject

@property(nonatomic, strong) NSString *imageUrl;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *detail;
@property(nonatomic, assign) BOOL isOnline;

@property(nonatomic, assign) BOOL isOpenType;
@property(assign, nonatomic) float rating;
@property(strong, nonatomic) NSNumber *enrollments_count;

- (id)initWith:(NSString *)imageUrl
     withTitle:(NSString *)title
     andDetail:(NSString *)detail
        onLine:(BOOL)isOnline;

@end
