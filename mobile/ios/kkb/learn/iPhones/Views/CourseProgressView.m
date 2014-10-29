//
//  CourseProgressView.m
//  learn
//
//  Created by zxj on 14-7-30.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseProgressView.h"

@implementation CourseProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initRectView];
    }
    return self;
}

- (void)initRectView {
    rectViewArray = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        UIView *rect =
            [[UIView alloc] initWithFrame:CGRectMake((50 + 10) * i, 0, 50, 10)];
        [rect setBackgroundColor:[UIColor blueColor]];
        [self addSubview:rect];
        [rectViewArray addObject:rect];
    }
}

- (void)setProgress:(int)num {
    for (int j = 0; j < num; j++) {
        UIView *view = [rectViewArray objectAtIndex:j];
        [view setBackgroundColor:[UIColor grayColor]];
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
