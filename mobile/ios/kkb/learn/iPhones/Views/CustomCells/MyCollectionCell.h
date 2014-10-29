//
//  MyCollectionCell.h
//  learn
//
//  Created by zxj on 14-7-28.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQStarRatingView.h"
@interface MyCollectionCell : UITableViewCell <StarRatingViewDelegate>

@property(weak, nonatomic) TQStarRatingView *starView;
@property(weak, nonatomic) UIImageView *courseImageView;
@property(weak, nonatomic) UIImageView *courseTypeImageView;
@property(weak, nonatomic) UIImageView *courseTypeImageView2;
@property(weak, nonatomic) UILabel *courseNameLabel;
@property(weak, nonatomic) UILabel *courseLearnerNumberLabel;

@end
