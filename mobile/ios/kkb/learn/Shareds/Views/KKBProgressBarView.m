//
//  KKBProgressBarView.m
//  KKBProgressBarView
//
//  Created by zengmiao on 8/4/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBProgressBarView.h"
#import "UIView+KKBAddUtils.h"

static const CGFloat bannar_marginTop = 0;
static const CGFloat bannar_Height = 10;
static const CGFloat bannar_width = 6;

static const CGFloat imageView_marginBannar = 2;
static const CGFloat imageView_marinBottom = 0;

@interface KKBProgressBarView ()
@property (weak ,nonatomic) UIImageView *foregroundImageView;
@property (weak ,nonatomic) UIImageView *backgroundImageView;

@property (weak ,nonatomic) UIImageView *bannarImageView;

@end


@implementation KKBProgressBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _progress = 0;
    self.clipsToBounds = YES;
    
    UIImageView *bannarImageView = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(0, bannar_marginTop, bannar_width, bannar_Height)];
//    bannarImageView.backgroundColor = [UIColor redColor];
    bannarImageView.image = [UIImage imageNamed:@"task_content_flag"];
    _bannarImageView = bannarImageView;
    [self addSubview:bannarImageView];
    
    
    CGFloat backgroundFrameHeight = self.bounds.size.height - bannar_marginTop - bannar_Height - imageView_marginBannar - imageView_marinBottom;
    
    CGRect backgroundFrame = (CGRect){
        .origin.x = 0,
        .origin.y = imageView_marginBannar + bannarImageView.bottom,
        .size.width =  self.bounds.size.width - bannar_width,
        .size.height = backgroundFrameHeight
    };
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundFrame];
//    backgroundImageView.backgroundColor = [UIColor grayColor];
    backgroundImageView.image = [UIImage imageNamed:@"task_progress-bar_underside"];
    _backgroundImageView = backgroundImageView;
    [self addSubview:backgroundImageView];

    
    CGRect foregroundFrame = (CGRect){
        .origin.x = - self.bounds.size.width + bannar_width,
        .origin.y = imageView_marginBannar + bannarImageView.bottom,
        .size.width =  self.bounds.size.width - bannar_width,
        .size.height = backgroundFrameHeight
    };
    UIImageView *foregroundImageView = [[UIImageView alloc] initWithFrame:foregroundFrame];
//    foregroundImageView.backgroundColor = [UIColor greenColor];
    foregroundImageView.image = [UIImage imageNamed:@"task_progress-bar_upside"];
    _foregroundImageView = foregroundImageView;
    [self addSubview:foregroundImageView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

#pragma mark - Property
- (void)setProgress:(float)progress {
    if (_progress != progress) {
        _progress = progress;
        
        //refreshFrame
        [self refreshProgress];
    }
}

- (void)refreshProgress {
    CGRect bannarFrame = self.bannarImageView.frame;
    CGRect imageViewFrme = self.foregroundImageView.frame;
    
    float imageViewOriginX = imageViewFrme.size.width * self.progress;
    
    float imageViewWidth = imageViewFrme.size.width;
    bannarFrame.origin.x = imageViewOriginX;
    imageViewFrme.origin.x =  imageViewOriginX - imageViewWidth;
    
    self.bannarImageView.frame = bannarFrame;
    self.foregroundImageView.frame = imageViewFrme;
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
