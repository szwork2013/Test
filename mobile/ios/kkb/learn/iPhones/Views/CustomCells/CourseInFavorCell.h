//
//  CourseInFavorCell.h
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourseInFavorItemModel;

#define COURSE_INFAVOR_CELL_HEIGHT 143
#define COURSEINFAVO_CELL_REUSEDID @"CourseInFavorCellReusedID"

@interface CourseInFavorCell : UITableViewCell

@property(strong, nonatomic) CourseInFavorItemModel *model;

+ (UINib *)cellNib;

@end
