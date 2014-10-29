//
//  TeacherIntroCell.m
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "TeacherIntroCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TeacherIntroCell

- (void)awakeFromNib {
    UIImage *bgImage = [UIImage imageNamed:@"v3_card_shadow"];
    
    UIImage *highlightedImg = [UIImage imageNamed:@"v3_card_shadow_pres"];
    
    
    _backgroundImageView.image = bgImage;
    _backgroundImageView.highlightedImage = highlightedImg;
    [self turnAvatarToRoundCorner];
}

- (void)turnAvatarToRoundCorner{
    _teacherImageVIew.layer.cornerRadius = _teacherImageVIew.frame.size.width / 2;
    _teacherImageVIew.layer.borderColor = UIColorFromRGB(0xf5f5f5).CGColor;
    _teacherImageVIew.layer.borderWidth = 2.0f;
    _teacherImageVIew.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
