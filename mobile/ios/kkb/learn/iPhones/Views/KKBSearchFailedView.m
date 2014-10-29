//
//  KKBSearchFailedView.m
//  learn
//
//  Created by guojun on 9/17/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBSearchFailedView.h"

@implementation KKBSearchFailedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self = [[[NSBundle mainBundle] loadNibNamed:@"KKBSearchFailedView"
                                              owner:self
                                            options:nil] lastObject];
    }
    return self;
}

- (void)addTapAction:(SEL)selector target:(id)target {

    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGesture];
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
