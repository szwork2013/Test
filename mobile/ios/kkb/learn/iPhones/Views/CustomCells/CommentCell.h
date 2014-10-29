//
//  CommentCell.h
//  learn
//
//  Created by 翟鹏程 on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "KKBStarRatingView.h"
#import "KKBStarRatingView+CoursesSetRating.h"

@interface CommentCell : UITableViewCell

@property(weak, nonatomic) UIImageView *commentUserImageView;
@property(weak, nonatomic) UILabel *commentUserNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property(strong, nonatomic) RTLabel *commentContentNewLabel;
@property(weak, nonatomic) UILabel *commentTimeLabel;
@property(weak, nonatomic) UILabel *commentContentLabel;

@property(weak, nonatomic) UILabel *commentScoreLabel;
@property(weak, nonatomic) UIButton *commentUsefulButton;
@property(weak, nonatomic) UIButton *commentUselessButton;
@property(weak, nonatomic) UIButton *commentReplyButton;
@property(strong, nonatomic) KKBStarRatingView *starRatingView;

@end
