//
//  CourseCategories.m
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "CourseCategories.h"
#import "UIView+ViewFrameGeometry.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

#import "KKBFindCourseCategoryModel.h"

@implementation CourseCategories

- (id)initWithFrame:(CGRect)frame
                 withData:(NSArray *)array
         withImageOriginY:(CGFloat)imageOriginY
    withLabelImageOriginY:(CGFloat)labelOriginY {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.courseView = [[UIView alloc]
            initWithFrame:CGRectMake(0, 0, 320, self.height - 30)];
        [self addSubview:self.courseView];

        [self initCourseView:array
            withImageOriginY:imageOriginY
            withLabelOriginY:labelOriginY];
    }
    return self;
}
- (void)initCourseView:(NSArray *)array
      withImageOriginY:(CGFloat)imageOriginY
      withLabelOriginY:(CGFloat)labelOriginY {
    // 行
    int row = 0;
    // 列 0 1 2
    int column = 0;
    // 每个高度
    float height = (self.height) / 3;
    // 每个宽度
    float width = 106;
    // 间隔
    float space = 0.5;
    for (int i = 0; i < array.count; i++) {
        column = i % 3;
        row = i / 3;

        CGRect rect;
        if (column == 0) {
            width = 106;
            rect = CGRectMake(0, row * (height + space), width, height);
        } else if (column == 1) {
            width = 107;
            rect =
                CGRectMake(width - 0.5, row * (height + space), width, height);
        } else if (column == 2) {
            width = 106;
            rect = CGRectMake(width * 2 + 2, row * (height + space), width,
                              height);
        }

        CourseUnitView *courseUnitView =
            [[CourseUnitView alloc] initWithFrame:rect
                             withImageViewOriginY:imageOriginY
                                 withLabelOriginY:labelOriginY];

        [courseUnitView
            setBackgroundColor:
                [UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
        
        KKBFindCourseCategoryModel *model = array[i];
        courseUnitView.courseCategoryId = [model.courseID integerValue];
        
        courseUnitView.userInteractionEnabled = YES;
        courseUnitView.delegate = self;

        [courseUnitView.courseUnitImageView
            sd_setImageWithURL:model.courseAvatorURL
              placeholderImage:[UIImage imageNamed:@"findcourses_default"]];

        [courseUnitView.courseUnitTitleLabel setText:model.name];

        [self.courseView addSubview:courseUnitView];
    }
}

- (void)updateViewWithData:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        NSUInteger tag = 3000 + i;
        UIView *courseUnitView = (UIView *)[self.courseView viewWithTag:tag];

        KKBFindCourseCategoryModel *model = array[i];

        tag = 1000 + i;
        UIButton *courseButton = (UIButton *)[courseUnitView viewWithTag:tag];
        [courseButton sd_setImageWithURL:model.courseAvatorURL
                                forState:UIControlStateNormal];

        tag = 2000 + i;
        UILabel *courseTitleLabel = (UILabel *)[courseUnitView viewWithTag:tag];
        courseTitleLabel.text = model.name;
        [courseTitleLabel setNeedsDisplay];
    }
}

- (void)courseUnitViewTap:(UITapGestureRecognizer *)tapGes {
    [tapGes view];
    UIView *view = [tapGes view];
    UILabel *label = [[view subviews] objectAtIndex:1];

    [self.delegate courseViewDidSelect:label.text withCategoryId:view.tag];
}

#pragma mark - CourseUnitView Delegate Methods
- (void)courseCategoryViewDidSelect:(NSString *)categoryName
                     withCategoryId:(NSUInteger)categoryId {

    [self.delegate courseViewDidSelect:categoryName withCategoryId:categoryId];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
