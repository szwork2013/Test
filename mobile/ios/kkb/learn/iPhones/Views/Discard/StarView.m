//
//  StarView.m
//  learn
//
//  Created by 翟鹏程 on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "StarView.h"

@interface StarView()
{
    UIImageView *_bgImageView;//背景 显示白色的星星图片
    UIImageView *_starImageView;//显示黄色的星星
}
@end

@implementation StarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self uiConfig];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self uiConfig];
    }
    return self;
}

//根据评分来调整星星的显示
- (void)setStarView:(CGFloat)star{
    //调整_starImageView的宽度
    CGRect frame = _bgImageView.frame;
    //根据评分，宽度变为原来的(star/5)
    frame.size.width = frame.size.width *star/5;
    //改变后的frame赋值给星星视图
    _starImageView.frame = frame;
}

//视图布局
- (void)uiConfig{
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,65,23)];
    _bgImageView.image = [UIImage imageNamed:@"StarsBackground"];
    [self addSubview:_bgImageView];
    
    //初始的时候，与背景图一样大
    _starImageView = [[UIImageView alloc] initWithFrame:_bgImageView.frame];
    _starImageView.image = [UIImage imageNamed:@"StarsForeground"];

    //contentMode 是UIView的属性，设置内容视图的布局方式
    //UIViewContentModeLeft,图片会以左侧为准，宽度不会随着imageView的变化而变化
    _starImageView.contentMode = UIViewContentModeLeft;
    //裁掉超出imageViewframe的图片
    _starImageView.clipsToBounds = YES;
    [self addSubview:_starImageView];
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
