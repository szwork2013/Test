//
//  KKBNoDownloadTaskView.m
//  learn
//
//  Created by xgj on 14-7-7.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBNoDownloadTaskView.h"

#define UIColorFromRGB(rgbValue)                                               \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0       \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0          \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                   \
                    alpha:1.0]
#define TAG 1000
#define NAVIGATION_BAR_HEIGHT 44

@implementation KKBNoDownloadTaskView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:UIColorFromRGB(0x404040)];

        int x = 80;
        int y = 106;
        int width = 160;
        int height = 200;
        UIImageView *noTaskImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [noTaskImageView setImage:[UIImage imageNamed:@"download_empty"]];

        [self addSubview:noTaskImageView];
    }
    return self;
}

- (void)updateFrame:(CGRect)frame {
    self.frame = frame;
}

+ (KKBNoDownloadTaskView *)sharedInstance {
    static KKBNoDownloadTaskView *singleton = nil;
    ;
    static dispatch_once_t onceToken;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect defaultFrame =
        CGRectMake(0, 0, screenBounds.size.width,
                   screenBounds.size.height - NAVIGATION_BAR_HEIGHT);
    dispatch_once(&onceToken, ^{
        singleton = [[KKBNoDownloadTaskView alloc] initWithFrame:defaultFrame];
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
