//
//  CourseDetailTreeOneCell.h
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@interface CourseDetailTreeOneCell : UITableViewCell<UIExpandingTableViewCell>
@property(strong, nonatomic) IBOutlet UILabel *coursName;
@property(strong, nonatomic) UIView *line;
@property(strong, nonatomic) IBOutlet UIImageView *statusImageView;
@property(assign, nonatomic) BOOL isFold;

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;
- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated;


@end
