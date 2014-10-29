//
//  CourseUnitView.m
//  learn
//
//  Created by 翟鹏程 on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseUnitView.h"

@implementation CourseUnitView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addTapFeedback {

    [self addTarget:self
                  action:@selector(itemDidTouchUpInside)
        forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self
                  action:@selector(itemDidTouchUp)
        forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self
                  action:@selector(itemDidTouchUp)
        forControlEvents:UIControlEventTouchCancel];
    [self addTarget:self
                  action:@selector(itemDidTouchDown)
        forControlEvents:UIControlEventTouchDown];
}
- (void)itemDidTouchUp {

    [self clearColor];
}

- (void)itemDidTouchUpInside {

    [self clearColor];
    [self.delegate courseCategoryViewDidSelect:_courseUnitTitleLabel.text
                                withCategoryId:_courseCategoryId];
}

- (void)clearColor {
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)itemDidTouchDown {
    [self setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
}

- (id)initWithFrame:(CGRect)frame
    withImageViewOriginY:(CGFloat)imageOriginY
        withLabelOriginY:(CGFloat)labelOriginY {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithUIWithImageY:imageOriginY withLabelY:labelOriginY];
        [self addTapFeedback];
    }
    return self;
}

- (void)initWithUIWithImageY:(CGFloat)imageOriginY
                  withLabelY:(CGFloat)labelOriginY {

    CGFloat imageViewX = self.frame.size.width / 2 - 24;
    CGFloat imageViewY = self.frame.size.height / 2 - 44;

    _courseUnitImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(imageViewX, imageOriginY, 48, 48)];
    [self addSubview:_courseUnitImageView];

    _courseUnitTitleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, labelOriginY, self.frame.size.width, 20)];
    [_courseUnitTitleLabel setTextColor:[UIColor blackColor]];
    [_courseUnitTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_courseUnitTitleLabel setFont:[UIFont systemFontOfSize:12]];

    [self addSubview:_courseUnitTitleLabel];
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
