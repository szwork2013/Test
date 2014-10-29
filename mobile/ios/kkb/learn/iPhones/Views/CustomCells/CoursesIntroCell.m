//
//  CoursesIntroCell.m
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CoursesIntroCell.h"

@implementation CoursesIntroCell

- (void)awakeFromNib {

    UIImage *bgImage = [UIImage imageNamed:@"v3_card_shadow"];

    UIImage *highlightedImg = [UIImage imageNamed:@"v3_card_shadow_pres"];

    _backgroundImageView.image = bgImage;
    _backgroundImageView.highlightedImage = highlightedImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
