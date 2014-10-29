//
//  RatingView.h
//  StarRatingView
//
//  Created by
//  Copyright (c) 2014年 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBStarRatingView : UIView

- (id)initWithOrigin:(CGPoint)origin
           starCount:(int)count
           starWidth:(CGFloat)starWidth
          starHeight:(CGFloat)starHeight
             spacing:(CGFloat)spacing
         rateEnabled:(BOOL)rateEnabled;

// star configuration
@property(nonatomic, assign) BOOL rateEnabled;
@property(nonatomic, assign) CGFloat rating;

// star image
@property(nonatomic, strong) NSString *fullImage;
@property(nonatomic, strong) NSString *halfImage;
@property(nonatomic, strong) NSString *emptyImage;

@end
