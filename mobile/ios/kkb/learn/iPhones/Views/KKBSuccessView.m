//
//  KKBSuccessView.m
//  learn
//
//  Created by zxj on 14-9-24.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBSuccessView.h"
static const int viewWidth = 148;
static const int viewHeight = 148;
@implementation KKBSuccessView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake((G_SCREEN_WIDTH - viewWidth) / 2,
                                  (G_SCREEN_HEIGHT - viewHeight) / 2 -
                                      gNavigationAndStatusHeight,
                                  viewWidth, viewHeight)];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    // baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 148, 148)];
    roundCornorView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    roundCornorView.backgroundColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
    [roundCornorView.layer setCornerRadius:5.0f];
    backGroundView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"kkb-iphone-common-success"]];
    [backGroundView setFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.successMessage = [[UILabel alloc]
        initWithFrame:CGRectMake(0, viewHeight / 2 + 20, viewWidth, 12)];
    self.successMessage.textAlignment = NSTextAlignmentCenter;
    self.successMessage.textColor = [UIColor whiteColor];
    self.successMessage.font = [UIFont systemFontOfSize:12];
    [self addSubview:roundCornorView];
    [self addSubview:backGroundView];
    [self addSubview:self.successMessage];
}

@end
