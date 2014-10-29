//
//  KKBActivityIndicator.m
//  learn
//
//  Created by xgj on 14-6-27.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#define TAG 1000
#define NAVIGATION_BAR_HEIGHT 44

#define RoundCornerViewLength 160
#define UIActivityIndicatorWidth 48

@implementation KKBActivityIndicatorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

        int width = RoundCornerViewLength;
        int height = RoundCornerViewLength;
        int x = (frame.size.width - width) / 2;
        //        int y = 176;
        int y = (frame.size.height - height) / 2 - NAVIGATION_BAR_HEIGHT;

        roundCornorView =
            [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        roundCornorView.backgroundColor =
            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
        [roundCornorView.layer setCornerRadius:5.0f];

        int width1 = UIActivityIndicatorWidth;
        int height1 = UIActivityIndicatorWidth;
        int x1 = (RoundCornerViewLength - width1) / 2;
        int y1 = width1;
        indicatorView = [[UIActivityIndicatorView alloc]
            initWithFrame:CGRectMake(x1, y1, width1, height1)];
        indicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyleWhiteLarge;
        [indicatorView startAnimating];

        [self setViewStyle:BlackStyle];

        [self addSubview:roundCornorView];
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
}

- (void)setViewStyle:(LoadingViewStyle)style {
    if (style == BlackStyle) {
        // black
        int width2 = RoundCornerViewLength;
        int height2 = 22;
        int x2 = 0;
        int y2 = 120;
        loadingTextLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(x2, y2, width2, height2)];
        [loadingTextLabel setText:@"加载中..."];
        loadingTextLabel.font = [UIFont boldSystemFontOfSize:14];
        [loadingTextLabel setTextColor:[UIColor whiteColor]];
        loadingTextLabel.textAlignment = NSTextAlignmentCenter;

        [roundCornorView addSubview:indicatorView];
        [roundCornorView addSubview:loadingTextLabel];
    } else {
        // grey

        roundCornorView.backgroundColor =
            [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.95f];
        indicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyleGray;
        loadingTextLabel.textColor = UIColorFromRGB(0x333333);

        CGRect frame = roundCornorView.frame;
        frame.origin.y = 146;
        roundCornorView.frame = frame;

        [self setBackgroundColor:
                  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
    }
}

- (void)markAsFailure {

    int width1 = UIActivityIndicatorWidth;
    int height1 = UIActivityIndicatorWidth;
    int x1 = (RoundCornerViewLength - width1) / 2;
    int y1 = width1;

    UIImageView *failure =
        [[UIImageView alloc] initWithFrame:CGRectMake(x1, y1, width1, height1)];
    failure.image = [UIImage imageNamed:@"pop_loading_failure"];
    failure.tag = TAG;
    [roundCornorView addSubview:failure];

    loadingTextLabel.text = @"加载失败，稍后再试";
    [indicatorView setHidden:YES];
}

- (void)markAsLoading {

    [[roundCornorView viewWithTag:TAG] removeFromSuperview];
    [indicatorView setHidden:NO];
    loadingTextLabel.text = @"加载中...";
}

- (void)showInView:(UIView *)superView {
    [superView addSubview:self];
}

- (void)hideView {
    [self removeFromSuperview];
}

+ (KKBActivityIndicatorView *)sharedInstance {
    static KKBActivityIndicatorView *singleton = nil;
    ;
    static dispatch_once_t onceToken;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect defaultFrame =
        CGRectMake(0, 0, screenBounds.size.width,
                   screenBounds.size.height - NAVIGATION_BAR_HEIGHT);
    dispatch_once(&onceToken, ^{
        singleton =
            [[KKBActivityIndicatorView alloc] initWithFrame:defaultFrame];
    });
    return singleton;
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
