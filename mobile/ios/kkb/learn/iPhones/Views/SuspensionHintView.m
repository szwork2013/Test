//
//  SuspensionHintView.m
//  learn
//
//  Created by zxj on 14-6-5.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SuspensionHintView.h"

CGFloat const kLPPopupDefaultWaitDuration = 1.0f;

static NSString *const kLPPopupAnimationKey = @"kLPPopupAnimationKey";

@interface SuspensionHintView ()
- (id)initWithText:(NSString *)txt;
@property(copy, nonatomic) void (^animationCompletion)(void);
@end

@implementation SuspensionHintView

@synthesize popupColor;
@synthesize forwardAnimationDuration;
@synthesize backwardAnimationDuration;
@synthesize textInsets;
@synthesize maxWidth;

#pragma mark - Initialization
+ (SuspensionHintView *)popupWithText:(NSString *)txt {
    return [[SuspensionHintView alloc] initWithText:txt];
}

- (id)initWithText:(NSString *)txt {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.text = txt;
        [self sizeToFit];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        popupColor = [UIColor whiteColor];
        forwardAnimationDuration = 0.4f;
        backwardAnimationDuration = 0.4f;
        textInsets = UIEdgeInsetsMake(12.0f, 12.0f, 12.0f, 12.0f);
        maxWidth = 200.0f;

        self.backgroundColor = [UIColor clearColor];
        self.numberOfLines = 0;
        self.textAlignment = NSTextAlignmentCenter;

        self.textColor = [UIColor darkTextColor];
        self.font = [UIFont boldSystemFontOfSize:16.0f];
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

#pragma mark - Showing popup
- (void)showInView:(UIView *)parentView
     centerAtPoint:(CGPoint)pos
          duration:(CGFloat)waitDuration
        completion:(void (^)(void))block {
    self.center = pos;
    self.animationCompletion = block;

    CABasicAnimation *forwardAnimation =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    forwardAnimation.duration = self.forwardAnimationDuration;
    forwardAnimation.timingFunction =
        [CAMediaTimingFunction functionWithControlPoints:0.5f:1.7f:0.6f:0.85f];
    forwardAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    forwardAnimation.toValue = [NSNumber numberWithFloat:1.0f];

    CABasicAnimation *reverseAnimation =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    reverseAnimation.duration = self.backwardAnimationDuration;
    reverseAnimation.beginTime = forwardAnimation.duration + waitDuration;
    reverseAnimation.timingFunction =
        [CAMediaTimingFunction functionWithControlPoints:0.4f:0.15f:0.5f:-0.7f];
    reverseAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    reverseAnimation.toValue = [NSNumber numberWithFloat:0.0f];

    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations =
        [NSArray arrayWithObjects:forwardAnimation, reverseAnimation, nil];
    animationGroup.delegate = self;
    animationGroup.duration =
        forwardAnimation.duration + reverseAnimation.duration + waitDuration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;

    [parentView addSubview:self];
    [UIView animateWithDuration:animationGroup.duration
        delay:0.0
        options:0
        animations:^{
            [self.layer addAnimation:animationGroup
                              forKey:kLPPopupAnimationKey];
        }
        completion:^(BOOL finished) {}];
}

#pragma mark - Core animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self removeFromSuperview];

        if (self.animationCompletion)
            self.animationCompletion();
    }
}

#pragma mark - UILabel
- (void)sizeToFit {
    [super sizeToFit];

    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(
        self.frame.size.width + self.textInsets.left + self.textInsets.right,
        self.frame.size.height + self.textInsets.bottom + self.textInsets.top);

    self.frame = newFrame;
}

- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect1 = [self.text
        boundingRectWithSize:CGSizeMake(self.maxWidth - self.textInsets.left -
                                            self.textInsets.right,
                                        CGFLOAT_MAX)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:@{
                      NSFontAttributeName : [UIFont systemFontOfSize:16]
                  } context:nil];
    bounds.size = rect1.size;

    return bounds;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self sizeToFit];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIBezierPath *roundedRect =
        [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 5.0f, 5.0f)
                                   cornerRadius:5.0f];

    CGContextSetFillColorWithColor(context, self.popupColor.CGColor);
    CGContextFillPath(context);

    CGContextSetShadowWithColor(
        context, CGSizeMake(0.0f, 0.5f), 3.0f,
        [UIColor colorWithWhite:0.0f alpha:0.45f].CGColor);

    CGContextAddPath(context, roundedRect.CGPath);
    CGContextDrawPath(context, kCGPathFill);

    CGContextRestoreGState(context);
    [super drawRect:rect];
}

@end
