//
//  KKBNetDisconnectView.m
//  learn
//
//  Created by xgj on 8/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBNetworkDisconnectView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@implementation KKBNetworkDisconnectView {
    UILabel *label;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:
                  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];

        int width = 456 / 2;
        int height = 200 / 2;
        int x = (frame.size.width - width) / 2;
        int y = 142 + 44;
        UIView *rectView =
            [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [rectView.layer setCornerRadius:4.0f];
        [rectView setBackgroundColor:
                      [UIColor colorWithRed:1 green:1 blue:1 alpha:0.95f]];

        int width2 = width;
        int height2 = height;
        int x2 = 0;
        int y2 = 0;
        label =
            [[UILabel alloc] initWithFrame:CGRectMake(x2, y2, width2, height2)];
        label.text = @"已" @"断" @"开"
                                   @"网络连接，请检查\n您的网络连接状态";
        label.numberOfLines = 2;
        label.font = [UIFont fontWithName:nil size:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColorFromRGB(0x333333);

        [rectView addSubview:label];

        [self addSubview:rectView];
    }

    return self;
}

- (id)init {
    KKBNetworkDisconnectView *view = [[KKBNetworkDisconnectView alloc]
        initWithFrame:[self networkDisconnectViewFrame]];
    return view;
}

- (void) showInView:(UIView *)superView LabelText:(NSString *)labelText {
    AppDelegate *appdelegate = APPDELEGATE;
    [appdelegate.window addSubview:self];
    label.text = labelText;
    [self performSelector:@selector(hideView) withObject:nil afterDelay:1.0];
}

- (void)showInView:(UIView *)superView {

    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.window addSubview:self];

    [self performSelector:@selector(hideView) withObject:nil afterDelay:2.0f];
}

- (void)hideView {

    [self removeFromSuperview];
}

- (CGRect)networkDisconnectViewFrame {
    int x = 0;
    int y = NavigationBarHeight + StatusBarHeight + 2;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - TabBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
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
