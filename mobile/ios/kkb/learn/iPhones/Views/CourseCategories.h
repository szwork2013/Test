//
//  CourseCategories.h
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseUnitView.h"

@protocol CourseCategoryDelegate <NSObject>

- (void)courseViewDidSelect:(NSString *)categoryName
             withCategoryId:(NSUInteger)categoryId;

@end

@interface CourseCategories : UIView <CourseUnitDelegate>

@property(strong, nonatomic) UIView *courseView;

@property(nonatomic, weak) id<CourseCategoryDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
                 withData:(NSArray *)array
         withImageOriginY:(CGFloat)imageOriginY
    withLabelImageOriginY:(CGFloat)labelOriginY;

- (void)updateViewWithData:(NSArray *)array;

@end
