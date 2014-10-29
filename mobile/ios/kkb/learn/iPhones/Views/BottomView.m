//
//  BottomView.m
//  learn
//
//  Created by 翟鹏程 on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "BottomView.h"

@implementation BottomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initWithUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor orangeColor];
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
