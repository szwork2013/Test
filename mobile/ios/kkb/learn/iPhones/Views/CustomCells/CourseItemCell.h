//
//  CourseItemCell.h
//  learn
//
//  Created by zengmiao on 8/7/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBStarRatingView.h"
#import "KKBCourseItemCellModel.h"

#define COURSEITEMCELL_HEIGHT 105
#define COURSEITEMCELL_RESUEDID @"CourseItemCellReusedID"

@interface CourseItemCell : UITableViewCell

@property(nonatomic, assign) KKBCourseItemCellModel *model;

+ (UINib *)cellNib;

@end
