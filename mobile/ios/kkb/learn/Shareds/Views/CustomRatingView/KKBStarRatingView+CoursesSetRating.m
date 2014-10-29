//
//  KKBStarRatingView+CoursesSetRating.m
//  learn
//
//  Created by zengmiao on 8/5/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBStarRatingView+CoursesSetRating.h"

@implementation KKBStarRatingView (CoursesSetRating)

- (void)kkb_courseRating:(CGFloat)rating
                   type:(courseType)type {
    NSString *bgName = nil;
    NSString *fullName = nil;
    NSString *halfName = nil;

    if (type == OPENCOURSE) {
        bgName = @"star_gray_bg";
        fullName = @"star_blue_full";
        halfName = @"star_blue_half";
        
    } else {
        bgName = @"star_gray_bg";
        fullName = @"star_yellow_full";
        halfName = @"star_yellow_half";
    }
    self.fullImage = fullName;
    self.halfImage = halfName;
    self.emptyImage = bgName;
    self.rating = rating;
}

@end
