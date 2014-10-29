//
//  KKBEmptyContentView.m
//  learn
//
//  Created by guojun on 9/4/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBEmptyContentView.h"
static const CGFloat ImageViewMarginTop = 118.0f;
static const CGFloat ImageViewMarginLeft = 80.0f;
static const CGFloat ImageViewWidth = 160.0f;
static const CGFloat ImageViewHeight = 120.0f;

static const CGFloat TextLabelMarginTop = 8.0f;
static const CGFloat TextLabelHeight = 21.0f;
static const CGFloat TextLabelFontSize = 16.0f;

@implementation KKBEmptyContentView


- (id)initWithFrame:(CGRect)frame imagePath:(NSString *) imagePath text:(NSString *)labelText
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
        
        UIImageView *emptyContentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ImageViewMarginLeft, ImageViewMarginTop, ImageViewWidth, ImageViewHeight)];
        
        emptyContentImageView.image = [UIImage imageNamed:imagePath];

        CGFloat x = 0;
        CGFloat y = ImageViewMarginTop + ImageViewHeight + TextLabelMarginTop;
        CGFloat width = G_SCREEN_WIDTH;
        CGFloat height = TextLabelHeight;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [textLabel setFont:[UIFont systemFontOfSize:TextLabelFontSize]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setTextColor:UIColorFromRGB(0x7d7d80)];
        [textLabel setText:labelText];
        
        [self addSubview:emptyContentImageView];
        [self addSubview:textLabel];
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
