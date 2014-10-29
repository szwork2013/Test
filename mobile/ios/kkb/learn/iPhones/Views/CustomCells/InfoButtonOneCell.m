//
//  InfoButtonOneCell.m
//  learn
//
//  Created by zxj on 14-8-16.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "InfoButtonOneCell.h"

@implementation InfoButtonOneCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (RTLabel *)courseIntroLabel {
    if (!_courseIntroLabel) {
        _courseIntroLabel =
            [[RTLabel alloc] initWithFrame:CGRectMake(8, 44, 304, 14)];
        _courseIntroLabel.backgroundColor = [UIColor clearColor];
        _courseIntroLabel.font = [UIFont systemFontOfSize:14];
        _courseIntroLabel.width = 304;
        [self.contentView addSubview:_courseIntroLabel];
    }
    return _courseIntroLabel;
}

@end
