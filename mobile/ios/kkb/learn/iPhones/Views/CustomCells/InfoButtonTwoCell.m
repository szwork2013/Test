//
//  InfoButtonTwoCell.m
//  learn
//
//  Created by zxj on 14-8-16.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "InfoButtonTwoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation InfoButtonTwoCell

- (void)awakeFromNib {

    [self turnTeacherAvatarRoundCorner];
}

- (void)turnTeacherAvatarRoundCorner {
    _teacherHeadImageView.layer.cornerRadius = _teacherHeadImageView.width / 2;
    _teacherHeadImageView.layer.borderColor = [UIColor grayColor].CGColor;
    _teacherHeadImageView.layer.borderWidth = 1.0f;
    _teacherHeadImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (RTLabel *)teacherDetailLabel {
    if (!_teacherDetailLabel) {
        _teacherDetailLabel =
            [[RTLabel alloc] initWithFrame:CGRectMake(8, 74, 304, 14)];
        _teacherDetailLabel.backgroundColor = [UIColor clearColor];
        _teacherDetailLabel.font = [UIFont systemFontOfSize:14];
        _teacherDetailLabel.width = 304;
        [self.contentView addSubview:_teacherDetailLabel];
    }
    return _teacherDetailLabel;
}

@end
