//
//  KKBCardSytleView.m
//  learn
//
//  Created by zengmiao on 8/5/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBCardSytleView.h"

@interface KKBCardSytleView ()

@property(weak, nonatomic) UIImageView *cardImageView;

@end

@implementation KKBCardSytleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

- (void)customInit {
    self.cardEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    CGRect cardFrame = (CGRect) {
        .origin.x = self.cardEdgeInsets.left,
        .origin.y = self.cardEdgeInsets.top,
        .size.width = self.bounds.size.width - self.cardEdgeInsets.left -
                      self.cardEdgeInsets.right,
        .size.height = self.bounds.size.height - self.cardEdgeInsets.top -
                       self.cardEdgeInsets.bottom};

    UIImageView *cardImageView = [[UIImageView alloc] initWithFrame:cardFrame];
    UIImage *cardImg = [[UIImage imageNamed:@"card_shadow"]
        resizableImageWithCapInsets:UIEdgeInsetsMake(7, 10, 10, 9)];
    cardImageView.image = cardImg;
    [self addSubview:cardImageView];
    [self sendSubviewToBack:cardImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect cardFrame = (CGRect) {
        .origin.x = self.cardEdgeInsets.left,
        .origin.y = self.cardEdgeInsets.top,
        .size.width = self.bounds.size.width - self.cardEdgeInsets.left -
        self.cardEdgeInsets.right,
        .size.height = self.bounds.size.height - self.cardEdgeInsets.top -
        self.cardEdgeInsets.bottom};
    
    self.cardImageView.frame = cardFrame;
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
