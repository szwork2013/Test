//
//  KKBLoadingFailedView.m
//  learn
//
//  Created by xgj on 14-7-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBLoadingFailedView.h"

#define NAVIGATION_BAR_HEIGHT 44

@implementation KKBLoadingFailedView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.frame = frame;

        [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

        int ivWidth = 56;
        int ivHeight = 56;
        int ivX = (frame.size.width - ivWidth) / 2;
        int ivY = 164;

        UIImageView *kaikebaImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(ivX, ivY, ivWidth, ivHeight)];
        [kaikebaImageView
            setImage:[UIImage imageNamed:@"page_loading_failure"]];

        int width = 200;
        int height = 34;
        int x = (frame.size.width - width) / 2;
        int y = kaikebaImageView.frame.origin.y + ivHeight + 20;
        UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        label.text = @"页面加载失败\n请点击页面刷新";
        label.textColor = UIColorFromRGB(0xbbbbbf);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        label.font = [UIFont boldSystemFontOfSize:14];

        [self addSubview:kaikebaImageView];
        [self addSubview:label];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
}

- (void)setTapTarget:(id)target action:(SEL)selector {
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tapGesture];
}

- (void)show {
    [self setHidden:NO];
}
- (void)hide {
    [self setHidden:YES];
}

+ (KKBLoadingFailedView *)sharedInstance {
    static KKBLoadingFailedView *singleton = nil;
    ;
    static dispatch_once_t onceToken;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect defaultFrame =
        CGRectMake(0, 0, screenBounds.size.width,
                   screenBounds.size.height - NAVIGATION_BAR_HEIGHT);
    dispatch_once(&onceToken, ^{
        singleton = [[KKBLoadingFailedView alloc] initWithFrame:defaultFrame];
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
