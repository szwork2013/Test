//
//  GuideCourseCardCell.h
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideCourseVideoItemView.h"
#import "GuideCourseItemView.h"

#define GUIDE_COURSE_CELL_REUSEDID @"GUIDE_COURSE_CELL_REUSEDID"

@class GuideCourseCardItemModel;

@protocol GuideCourseCardCellDelegate <NSObject>

@required

- (void)guideCourseCardDetailButtonDidSelect:(GuideCourseCardItemModel *)data;
- (void)guideCourseCardVideoItemDidSelect:(GuideCourseCardItemModel *)data;
- (void)guideCourseCardPlainItemDidSelect:(GuideCourseItemModel *)data;

@end

@interface GuideCourseCardCell
    : UITableViewCell <GuideCourseItemDelegate, GuideCourseVideoItemDelegate>

@property(strong, nonatomic) GuideCourseCardItemModel *model;
@property(nonatomic, weak) id<GuideCourseCardCellDelegate> delegate;

+ (float)heightForCellWithModel:(GuideCourseCardItemModel *)model;

+ (UINib *)cellNib;

@end
