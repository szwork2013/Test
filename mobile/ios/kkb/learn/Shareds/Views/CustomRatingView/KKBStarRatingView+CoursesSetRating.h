//
//  KKBStarRatingView+CoursesSetRating.h
//  learn
//
//  Created by zengmiao on 8/5/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBStarRatingView.h"

typedef NS_ENUM(NSInteger, courseType) {
    OPENCOURSE = 0, //公开课
    GUIDECOURSE      //导学课
};

@interface KKBStarRatingView (CoursesSetRating)

- (void)kkb_courseRating:(CGFloat)rating
                   type:(courseType)type;

@end
