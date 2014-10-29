//
//  KKBVerticalLine.m
//  learn
//
//  Created by xgj on 14-7-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBVerticalLine.h"

@implementation KKBVerticalLine

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        frame.size.width = 2;
        frame.size.height = 40;

        UIView *leftLine =
            [[UIView alloc] initWithFrame:CGRectMake(1, 0, 1, 28)];
        [leftLine setBackgroundColor:UIColorFromRGB(0x1a1a1a)];

        UIView *rightLine =
            [[UIView alloc] initWithFrame:CGRectMake(2, 0, 1, 28)];
        [rightLine setBackgroundColor:UIColorFromRGB(0x4d4d4d)];

        [self addSubview:leftLine];
        [self addSubview:rightLine];
    }
    return self;
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
