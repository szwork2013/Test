//
//  GuideCourseVideoItemView.m
//  learn
//
//  Created by xgj on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideCourseVideoItemView.h"
#import "KKBProgressBarView.h"
#import "GuideCourseVideoItemModel.h"
#import "GuideCourseVideoItemModel+DynamicMehtod.h"

static CGFloat ItemMarginLeft = 16.0f;
static CGFloat ItemMarginRight = 16.0f;

@interface GuideCourseVideoItemView ()

@property(strong, nonatomic) KKBProgressBarView *progressBarView;

@property(nonatomic, retain) UIImageView *itemImageView;
@property(nonatomic, retain) UILabel *itemTitleLabel;
@property(nonatomic, retain) UILabel *itemProgressLabel;
@property(nonatomic, retain) UIView *itemSeperateLine;

@end

@implementation GuideCourseVideoItemView

- (void)dealloc {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
        [self addTapAction];
    }
    return self;
}

- (void)addTapAction {
    [self addTarget:self
                  action:@selector(videoItemDidTouchUp)
        forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self
                  action:@selector(videoItemDidTouchUp)
        forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self
                  action:@selector(videoItemDidTouchUp)
        forControlEvents:UIControlEventTouchCancel];
    [self addTarget:self
                  action:@selector(videoItemDidTouchDown)
        forControlEvents:UIControlEventTouchDown];
}

- (void)videoItemDidTouchUp {
    [self performSelector:@selector(clearColor) withObject:nil afterDelay:0.2f];
    [self.delegate guideCourseVideoItemDidSelect];
}

- (void)clearColor {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)videoItemDidTouchDown {
    [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
}

- (void)customInit {
    self.itemImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(ItemMarginLeft,
                                 (self.frame.size.height - 24) / 2, 24, 24)];
    self.itemImageView.image =
        [UIImage imageNamed:@"dynamics_task_button_video_dis"];
    [self addSubview:self.itemImageView];

    self.itemTitleLabel = [[UILabel alloc] init];
    self.itemTitleLabel.frame = CGRectMake(
        ItemMarginLeft + 32, (self.frame.size.height - 21) / 2, 100, 21);
    self.itemTitleLabel.font = [UIFont fontWithName:nil size:14];
    self.itemTitleLabel.textColor = UIColorFromRGB(0x616466);
    [self addSubview:self.itemTitleLabel];

    self.itemProgressLabel = [[UILabel alloc] init];
    self.itemProgressLabel.frame =
        CGRectMake(self.frame.size.width - 44 - ItemMarginRight,
                   (self.frame.size.height - 10) / 2, 44, 10);
    self.itemProgressLabel.textColor = UIColorFromRGB(0x616466);
    self.itemProgressLabel.textAlignment = NSTextAlignmentRight;
    self.itemProgressLabel.font = [UIFont fontWithName:nil size:11];
    [self addSubview:self.itemProgressLabel];

    self.itemSeperateLine =
        [[UIView alloc] initWithFrame:CGRectMake(32, 39, 240, 0.5f)];
    self.itemSeperateLine.backgroundColor = UIColorFromRGB(0xf0f0f0);
    [self addSubview:self.itemSeperateLine];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Property
- (void)setModel:(GuideCourseVideoItemModel *)model {
    if (_model != model) {
        _model = model;

        // refresh UI
        [self refreshData];
    }
}

- (KKBProgressBarView *)progressBarView {
    if (!_progressBarView) {
        _progressBarView = [[KKBProgressBarView alloc]
            initWithFrame:CGRectMake(103 + ItemMarginLeft, 4, 145, 19)];
        [self addSubview:_progressBarView];
    }
    return _progressBarView;
}

- (void)refreshData {
    self.itemTitleLabel.text = self.model.title;
    self.progressBarView.progress = [self.model videoProgress];

    NSString *courseLearnProgressText =
        [NSString stringWithFormat:@"%@/%@", self.model.view_count,
                                   self.model.video_count];
    self.itemProgressLabel.text = courseLearnProgressText;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
