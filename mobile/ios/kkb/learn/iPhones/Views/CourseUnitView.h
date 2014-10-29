//
//  CourseUnitView.h
//  learn
//
//  Created by 翟鹏程 on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CourseUnitDelegate <NSObject>

@required
- (void)courseCategoryViewDidSelect:(NSString *)categoryName
                     withCategoryId:(NSUInteger)categoryId;

@end

@interface CourseUnitView : UIControl

@property(nonatomic, strong) UIImageView *courseUnitImageView;
@property(nonatomic, strong) UILabel *courseUnitTitleLabel;
@property(nonatomic, assign) NSUInteger courseCategoryId;

@property(nonatomic, weak) id<CourseUnitDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withImageViewOriginY:(CGFloat)imageOriginY withLabelOriginY:(CGFloat)labelOriginY;

@end
