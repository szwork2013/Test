//
//  DifficultCard.m
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "DifficultCard.h"

@implementation DifficultCard

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initCardView:(NSString *)level {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, 14, 14)];
    label.font = [UIFont systemFontOfSize:14];
    int j;
    if ([level isEqualToString:@"low"]) {
        j = 0;
        label.text = @"易";
    } else if ([level isEqualToString:@"medium"]) {
        j = 1;
        label.text = @"中";
    } else {
        j = 2;
        label.text = @"难";
    }
    [self addSubview:label];
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(0 + 16 * i, 3, 8, 8)];
        if (j >= i) {
            [imageView setImage:[UIImage imageNamed:@"difficulty_icon.png"]];
        } else {
            [imageView setImage:[UIImage imageNamed:@"difficulty_icon_bg.png"]];
        }
        [self addSubview:imageView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
