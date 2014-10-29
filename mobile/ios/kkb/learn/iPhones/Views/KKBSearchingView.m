//
//  KKBSearchingView.m
//  learn
//
//  Created by guojun on 9/18/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBSearchingView.h"

@implementation KKBSearchingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self = [[[NSBundle mainBundle] loadNibNamed:@"KKBSearchingView"
                                              owner:self
                                            options:nil] lastObject];
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
