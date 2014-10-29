//
//  GuideCourseItemView.m
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideCourseItemView.h"
#import <QuartzCore/QuartzCore.h>

#import "GuideCourseItemModel.h"
#import "GuideCourseItemModel+DynamicMehtod.h"

static CGFloat ItemMarginLeft = 16.0f;

static CGFloat const timeLabelSpaceFromLeft = 10;
static CGFloat const timeLabelWidth = 75;

@interface GuideCourseItemView ()

@property(nonatomic, strong) UIImageView *itemImageView;
@property(nonatomic, strong) UILabel *itemTitleLabel;
@property(nonatomic, strong) UIButton *itemScoreButton;
@property(nonatomic, strong) UILabel *itemDeadlineLabel;
@property(nonatomic, strong) UIImageView *itemLearnStatusImageView;

@end

@implementation GuideCourseItemView {
    NSString *scoreImageStr;
    NSString *statusImageStr;
    UIColor *timeColor;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customUI];
        [self addTapAction];
    }
    return self;
}

- (void)addTapAction {

    [self addTarget:self
                  action:@selector(itemDidTouchUp)
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

    [self performSelector:@selector(clearColor) withObject:nil afterDelay:0.2f];
    [self.delegate guideCourseItemDidSelect:self.model];
}

- (void)clearColor {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)itemDidTouchDown {
    [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
}

- (void)customUI {
    self.itemImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(ItemMarginLeft, (self.frame.size.height - 24) / 2, 24, 24)];
    self.itemImageView.image = [UIImage imageNamed:@"task_icon"];
    [self addSubview:self.itemImageView];

    self.itemTitleLabel = [[UILabel alloc] init];
    self.itemTitleLabel.frame =
        CGRectMake(32 + ItemMarginLeft, (self.frame.size.height - 21) / 2, 100, 21);
    self.itemTitleLabel.font = [UIFont fontWithName:nil size:14];
    self.itemTitleLabel.textColor = UIColorFromRGB(0x616466);
    [self addSubview:self.itemTitleLabel];

    self.itemScoreButton = [[UIButton alloc] init];
    self.itemScoreButton.frame =
        CGRectMake(103 + ItemMarginLeft, (self.frame.size.height - 14) / 2, 32, 14);
    self.itemScoreButton.titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.itemScoreButton.titleLabel.font = [UIFont fontWithName:nil size:10];
    self.itemScoreButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.itemScoreButton];

    self.itemDeadlineLabel = [[UILabel alloc] init];
    self.itemDeadlineLabel.frame =
        CGRectMake(self.itemScoreButton.right + timeLabelSpaceFromLeft,
                   (self.frame.size.height - 21) / 2, timeLabelWidth, 21);
    self.itemDeadlineLabel.font = [UIFont fontWithName:nil size:12];
    self.itemDeadlineLabel.textAlignment = NSTextAlignmentLeft;
    self.itemDeadlineLabel.textColor = [UIColor grayColor];
    self.itemDeadlineLabel.lineBreakMode = NSLineBreakByClipping;
    [self addSubview:self.itemDeadlineLabel];

    self.itemLearnStatusImageView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"Validate_true"]];
    self.itemLearnStatusImageView.frame = CGRectMake(
        self.frame.size.width - 36 - ItemMarginLeft, (self.frame.size.height - 16) / 2, 36, 16);
    [self addSubview:self.itemLearnStatusImageView];

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
- (void)setModel:(GuideCourseItemModel *)model {
    if (_model != model) {
        _model = model;
        [self refreshData];
    }
}

- (void)refreshData {
    // item类型图标
    if (self.model.guideType == GuideCourseType_Discuss) {
        self.itemImageView.image =
            [UIImage imageNamed:@"dynamics_task_button_discussion_dis"];
    } else if (self.model.guideType == GuideCourseType_Test) {
        self.itemImageView.image =
            [UIImage imageNamed:@"dynamics_task_button_test_dis"];
    } else {
        self.itemImageView.image =
            [UIImage imageNamed:@"dynamics_task_button_homework_dis"];
    }
    // item 标题
    self.itemTitleLabel.text = [self.model title];
    // item 分数
    NSString *scoreStr = [NSString stringWithFormat:@"%@分", self.model.point];
    [self.itemScoreButton setTitle:scoreStr forState:UIControlStateNormal];
    [self judgeDataWithModel:self.model];
}

- (void)judgeDataWithModel:(GuideCourseItemModel *)itemModel {
    scoreImageStr = nil;
    statusImageStr = nil;
    timeColor = nil;
    /*
     首先判断截止日期
     然后判断是否已完成
     */
    if (![self.model.due_at isKindOfClass:[NSNull class]]) {
        // 系统截止日期
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dueAtDate = [formatter dateFromString:self.model.due_at];
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        NSInteger timeInterval = [timeZone secondsFromGMTForDate:dueAtDate];

        NSDate *deadLineDate =
            [dueAtDate dateByAddingTimeInterval:timeInterval];
        // 当前时间
        NSDate *currentDate = [NSDate date];
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSInteger localTimeInterval =
            [localTimeZone secondsFromGMTForDate:currentDate];
        NSDate *localCurrentDate =
            [currentDate dateByAddingTimeInterval:localTimeInterval];

        NSInteger deadLineInterval = [deadLineDate timeIntervalSince1970];

        NSInteger localCurrentInterval =
            [localCurrentDate timeIntervalSince1970];
        // timePast = 截止日期 - 当前日期
        NSInteger timePast = deadLineInterval - localCurrentInterval;
        // 是否已经到截止日期
        if (timePast > 0) {
            if (timePast > 60 * 60 * 24) {
                // 大于一天 橙色
                NSDateFormatter *aboveADayFormatter =
                    [[NSDateFormatter alloc] init];
                [aboveADayFormatter setDateFormat:@"M月d日"];
                NSString *timeString =
                    [aboveADayFormatter stringFromDate:deadLineDate];
                self.itemDeadlineLabel.text =
                    [NSString stringWithFormat:@"%@截止", timeString];
                [self orangeBackgroundFinished];
            } else {
                // 小于一天 红色
                NSInteger lastHour = timePast / 60 / 60;
                self.itemDeadlineLabel.text =
                    [NSString stringWithFormat:@"还有%d个小时", lastHour];
                [self redBackgroundFinished];
            }

        } else {
            // 已截止 红色
            self.itemDeadlineLabel.text = @"已截止";
            [self redBackgroundFinished];
        }
    } else {
        // 此处需要跟白鸽讨论一下
        // due_at值为NULL
        self.itemDeadlineLabel.text = @"已截止";
        [self redBackgroundFinished];
    }
    // 设置分数背景
    [self.itemScoreButton setBackgroundImage:[UIImage imageNamed:scoreImageStr]
                                    forState:UIControlStateNormal];
    // 设置截止日期颜色
    self.itemDeadlineLabel.textColor = timeColor;
    // 设置状态颜色
    self.itemLearnStatusImageView.image = [UIImage imageNamed:statusImageStr];
}
// 红色的判断是否完成
- (void)redBackgroundFinished {
    if ([self.model.statue isEqualToString:@"y"]) {
        // 已完成
        scoreImageStr = @"task_button_fraction3";
        statusImageStr = @"task_button_finish";
        timeColor = UIColorRGB(140, 202, 7);
    } else {
        // 未完成
        scoreImageStr = @"task_button_fraction2";
        statusImageStr = @"task_button_unfinished2";
        timeColor = UIColorRGB(248, 88, 86);
    }
}
// 橙色的判断是否完成
- (void)orangeBackgroundFinished {
    if ([self.model.statue isEqualToString:@"y"]) {
        scoreImageStr = @"task_button_fraction3";
        statusImageStr = @"task_button_finish";
        timeColor = UIColorRGB(140, 202, 7);
    } else {
        scoreImageStr = @"task_button_fraction1";
        statusImageStr = @"task_button_unfinished1";
        timeColor = UIColorRGB(255, 127, 0);
    }
}

@end
