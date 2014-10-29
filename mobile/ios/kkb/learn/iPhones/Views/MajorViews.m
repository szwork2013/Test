//
//  MajorViews.m
//  learn
//
//  Created by 翟鹏程 on 14-7-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MajorViews.h"
#import "UIImageView+WebCache.h"

static MajorViews *currentOpenedMajorViews = nil;
static const NSUInteger BackgroundViewTag = 100000;
static const CGFloat CellWidth = 304.0f;


@interface MajorViews () {
}

@end

@implementation MajorViews {
    CGRect totleRect;
}

@synthesize bgView;
@synthesize majorView;
@synthesize subMajorViews;
@synthesize subItemsCount;

- (void)dealloc {
    // TODO: byzm
    currentOpenedMajorViews = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (MajorViews *)createView {
    NSMutableArray *viewList = [[NSMutableArray alloc] init];
    MajorViews *currentView = [[MajorViews alloc] init];
    [viewList addObject:currentView];
    return currentView;
}

#pragma mark - View Feedback
- (void)addTapFeedbackFor:(UIControl *)view {
    [view addTarget:self
                  action:@selector(viewDidTouchUpInside:)
        forControlEvents:UIControlEventTouchUpInside];
    [view addTarget:self
                  action:@selector(viewDidTouchUp:)
        forControlEvents:UIControlEventTouchUpOutside];
    [view addTarget:self
                  action:@selector(viewDidTouchUp:)
        forControlEvents:UIControlEventTouchCancel];
    [view addTarget:self
                  action:@selector(viewDidTouchDown:)
        forControlEvents:UIControlEventTouchDown];
}

- (void)viewDidTouchUp:(UIControl *)view {

    [self performSelector:@selector(clearColor:)
               withObject:view
               afterDelay:0.1f];
}

- (void)viewDidTouchUpInside:(UIControl *)view {

    if (view.tag == BackgroundViewTag) {
        // background view
        [self majorViewChange];
    } else {
        // sub view
        [self miniMajorDidSelect:view];
    }

    [self clearColor:view];
}

- (void)clearColor:(id)sender {
    UIControl *view = (UIControl *)sender;
    [view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidTouchDown:(UIControl *)view {
    [view setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
}

#pragma mark - Init Methods
- (id)initWithFrame:(CGRect)rect
          parentView:(UIView *)view
    andSubItemsCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        totleRect = rect;
        self.selfY = rect.origin.y;
        [self initWithConfigFrame:rect view:view andSubItemsCount:count];
        self.opened = NO;

        subItemsCount = count;
    }
    return self;
}

- (void)initWithConfigFrame:(CGRect)rect
                       view:(UIView *)view
           andSubItemsCount:(NSUInteger)count {
    // 背景
    bgView = [[UIControl alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor whiteColor];

    bgView.layer.cornerRadius = 2.0f;
    bgView.layer.borderWidth = 0.5f;
    bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    bgView.layer.masksToBounds = YES;

    bgView.tag = BackgroundViewTag;

    [self addTapFeedbackFor:bgView];

    [view addSubview:bgView];
    // 专业
    majorView = [[UIView alloc]
        initWithFrame:CGRectMake(24, 16 + rect.origin.y, 104, 72 + 40)];
    [view addSubview:majorView];

    // 专业图片 先固定死
    _majorImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 104, 72)];
    [majorView addSubview:_majorImageView];

    // 专业标题
    _majorViewTitle =
        [[UILabel alloc] initWithFrame:CGRectMake(0, 72 + 12, 104, 16)];

    _majorViewTitle.textColor = [UIColor colorWithRed:92 / 256.0
                                                green:92 / 256.0
                                                 blue:102 / 256.0
                                                alpha:1];
    _majorViewTitle.font = [UIFont boldSystemFontOfSize:16];
    _majorViewTitle.text = @"";
    _majorViewTitle.textAlignment = NSTextAlignmentCenter;
    _majorViewTitle.tag = MajorViewCourseNameLabelTag;
    [majorView addSubview:_majorViewTitle];

    // 专业内容
    _majorIntro = [[UIView alloc]
        initWithFrame:CGRectMake(144, 16 + rect.origin.y, 160, 72)];
    [_majorIntro setHidden:YES];
    [_majorIntro setBackgroundColor:[UIColor redColor]];

    _majorIntroTitle = [[UILabel alloc]
        initWithFrame:CGRectMake(144, 16 + rect.origin.y, 160, 16)];
    _majorIntroTitle.font = [UIFont boldSystemFontOfSize:16];
    _majorIntroTitle.text = @"";
    [_majorIntroTitle setTextColor:[UIColor colorWithRed:92 / 256.0
                                                   green:92 / 256.0
                                                    blue:102 / 256.0
                                                   alpha:1]];
    [view addSubview:_majorIntroTitle];

    _majorIntroContent = [[UILabel alloc]
        initWithFrame:CGRectMake(144, 16 + rect.origin.y + 16 + 8, 160, 48)];
    [_majorIntroContent setFont:[UIFont systemFontOfSize:12]];
    [_majorIntroContent setNumberOfLines:3];
    [_majorIntroContent setTextColor:[UIColor colorWithRed:115 / 256.0
                                                     green:115 / 256.0
                                                      blue:128 / 256.0
                                                     alpha:1]];
    [_majorIntroContent setText:@"这里的课程介绍字数限制在30-"
                        @"35之内，大概有两行半的感觉，到这里基本够了" @"。"];
    [view addSubview:_majorIntroContent];

    _majorIntroTitle.alpha = 0;
    _majorIntroContent.alpha = 0;

    // 微专业
    subMajorViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        UIControl *subView = [[UIControl alloc]
            initWithFrame:CGRectMake(144, rect.origin.y + 16 + 24 * i, 160,
                                     24)];

        [self addTapFeedbackFor:subView];

        // add course name to sub view
        UILabel *nameLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 24)];
        nameLabel.text = @"Title";
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.tag = (MicroMajorCourseTitleLabelTag + i);
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        nameLabel.textColor = [UIColor colorWithRed:115 / 256.0
                                              green:115 / 256.0
                                               blue:128 / 256.0
                                              alpha:1];
        [nameLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];

        [subView addSubview:nameLabel];

        [view addSubview:subView];

        // 展开的View
        // 灰线
        UILabel *lineLabel = [[UILabel alloc] init];
        if (i == 0) {
            lineLabel.frame = CGRectMake(0, 0, 304, 0.5);
        } else {
            lineLabel.frame = CGRectMake(16, 0, 288, 0.5);
        }
        lineLabel.backgroundColor = [UIColor colorWithRed:219 / 256.0
                                                    green:219 / 256.0
                                                     blue:219 / 256.0
                                                    alpha:1];
        [subView addSubview:lineLabel];

        // 微专业标题
        UILabel *subMajorTitle =
            [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 244, 16)];
        subMajorTitle.font = [UIFont boldSystemFontOfSize:16];
        subMajorTitle.textColor = [UIColor colorWithRed:23 / 256.0
                                                  green:23 / 256.0
                                                   blue:26 / 256.0
                                                  alpha:1];
        subMajorTitle.text = @"移动云计算";
        [subView addSubview:subMajorTitle];
        // 微专业课程
        UILabel *subMajorCourse =
            [[UILabel alloc] initWithFrame:CGRectMake(16, 44, 244, 10)];
        subMajorCourse.font = [UIFont boldSystemFontOfSize:10];
        subMajorCourse.textColor = [UIColor colorWithRed:187 / 256.0
                                                   green:187 / 256.0
                                                    blue:191 / 256.0
                                                   alpha:1];
        subMajorCourse.text =
            @"《" @"PHP开发入门》、《HTTP基本原理》、《HTML5开发技" @"术》";
        [subView addSubview:subMajorCourse];

        // 图标
        UIImageView *subMajorImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(264, 12, 40, 40)];
        [subMajorImageView setImage:[UIImage imageNamed:@"major_arrow"]];
        [subView addSubview:subMajorImageView];

        lineLabel.alpha = 0;
        subMajorTitle.alpha = 0;
        subMajorCourse.alpha = 0;
        subMajorImageView.alpha = 0;

        [subMajorViews addObject:subView];
    }
}

- (void)miniMajorDidSelect:(UIControl *)touchedView {

    if (self.opened) {
        [self.delegate miniMajorViewDidSelect:touchedView];
    } else {
        NSLog(@"closed");
        [self majorViewChange];
    }
}

- (void)majorViewChange {
    NSString *action = @"open";
    if (self.opened) {
        action = @"close";
    }
    NSString *clickMajorViewStatus = @"close";
    if (self.opened) {
        clickMajorViewStatus = @"open";
    }
    NSDictionary *majorDic = nil;
    if (currentOpenedMajorViews != nil) {
        majorDic = [[NSDictionary alloc]
            initWithObjectsAndKeys:self, @"major", currentOpenedMajorViews,
                                   @"openedMajor", clickMajorViewStatus,
                                   @"clickMajorViewStatus", action, @"action",
                                   nil];
    } else {
        majorDic = [[NSDictionary alloc]
            initWithObjectsAndKeys:self, @"major", clickMajorViewStatus,
                                   @"clickMajorViewStatus", action, @"action",
                                   nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMajor"
                                                        object:self
                                                      userInfo:majorDic];
}

- (void)changeMajor:(NSNotification *)noti {
    MajorViews *clickedMajorViews = [noti.userInfo objectForKey:@"major"];
    NSString *clickMajorViewStatus =
        [noti.userInfo objectForKey:@"clickMajorViewStatus"];
    NSString *action = [noti.userInfo objectForKey:@"action"];
    MajorViews *openedMajorViews = [noti.userInfo objectForKey:@"openedMajor"];

    int OFFSET_CLICK = 64 * clickedMajorViews.subItemsCount - 24;

    int OFFSET_OPENED = 0;
    if (openedMajorViews != nil) {
        OFFSET_OPENED = 64 * openedMajorViews.subItemsCount - 24;
    }
    if ([clickMajorViewStatus isEqualToString:@"open"]) {
        if (self == clickedMajorViews) {
            [self closeMajor:0];
        } else {
            int offsetY = 0;
            if (clickedMajorViews.row < self.row) {
                offsetY += -OFFSET_CLICK;
            }
            if (offsetY != 0) {
                [self moveMajor:offsetY];
            }
        }
    } else {
        if (self == clickedMajorViews) {
            if (self.opened) {
                [self closeMajor:0];
            } else {
                [self openMajor];
            }
        } else if (self.opened && [action isEqualToString:@"open"]) {
            int offsetY = 0;
            if (self.row > clickedMajorViews.row) {
                offsetY = OFFSET_CLICK;
            }
            [self closeMajor:offsetY];
        } else {
            int offsetY = 0;
            if (clickedMajorViews.row < self.row) {
                offsetY +=
                    OFFSET_CLICK * ([action isEqualToString:@"open"] ? 1 : -1);
            }
            if (openedMajorViews != nil && openedMajorViews.row < self.row) {
                offsetY +=
                    OFFSET_OPENED * ([action isEqualToString:@"open"] ? -1 : 1);
            }
            if (offsetY != 0) {
                [self moveMajor:offsetY];
            }
        }
    }

    [self.delegate miniMajorViewDidMove:self.majorView];
}

- (void)moveView:(UIView *)view offset:(int)offsetY {
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + offsetY,
                            view.frame.size.width, view.frame.size.height);
}

- (void)moveMajor:(int)offsetY {
    [UIView animateWithDuration:0.24
                     animations:^{
                         [self moveView:bgView offset:offsetY];
                         [self moveView:majorView offset:offsetY];
                         for (int i = 0; i < subItemsCount; i++) {
                             UIView *subView = [subMajorViews objectAtIndex:i];
                             [self moveView:subView offset:offsetY];
                         }
                     }];
}

- (void)openMajor {
    self.opened = YES;
    currentOpenedMajorViews = self;
    [[bgView superview] bringSubviewToFront:majorView];
    [UIView animateWithDuration:0.24
        animations:^{
            [bgView setFrame:CGRectMake(8, totleRect.origin.y, 304,
                                        104 + subMajorViews.count * 64)];
            NSLog(@"self selfY %f", self.selfY + 195);
            UILabel *label = [[majorView subviews] objectAtIndex:1];
            label.alpha = 0;
            _majorIntroTitle.alpha = 1;
            _majorIntroContent.alpha = 1;

            [majorView
                setFrame:CGRectMake(24, 16 + totleRect.origin.y, 104, 72)];
            for (int i = 0; i < subMajorViews.count; i++) {
                UIView *view = [subMajorViews objectAtIndex:i];
                view.userInteractionEnabled = YES;
                view.frame =
                    CGRectMake(8, 104 + totleRect.origin.y + 64 * i, CellWidth, 64);

                UILabel *label = [[view subviews] objectAtIndex:0];
                label.alpha = 0;
                UILabel *lineLabel = [[view subviews] objectAtIndex:1];
                lineLabel.alpha = 1;
                UILabel *subTitleLabel = [[view subviews] objectAtIndex:2];
                subTitleLabel.alpha = 1;
                UILabel *subCourseLabel = [[view subviews] objectAtIndex:3];
                subCourseLabel.alpha = 1;
                UIImageView *subImageView = [[view subviews] objectAtIndex:4];
                subImageView.alpha = 1;
            }
        }
        completion:^(BOOL finished) {}];
}

- (void)closeMajor:(int)offsetY {
    self.opened = false;
    if (self == currentOpenedMajorViews) {
        currentOpenedMajorViews = nil;
    }
    [[bgView superview] bringSubviewToFront:majorView];
    [UIView animateWithDuration:0.24
        animations:^{
            [bgView
                setFrame:CGRectMake(8, totleRect.origin.y + offsetY, 304, 128)];
            NSLog(@"self selfY %f", self.selfY);
            UILabel *label = [[majorView subviews] objectAtIndex:1];
            label.alpha = 1;
            _majorIntroTitle.alpha = 0;
            _majorIntroContent.alpha = 0;

            [majorView
                setFrame:CGRectMake(24, 16 + totleRect.origin.y + offsetY, 104,
                                    72 + 40)];
            for (int i = 0; i < subMajorViews.count; i++) {
                UIView *view = [subMajorViews objectAtIndex:i];
                view.userInteractionEnabled = NO;
                view.frame = CGRectMake(
                    144, 16 + totleRect.origin.y + 24 * i + offsetY, 152, 24);
                UILabel *label = [[view subviews] objectAtIndex:0];
                label.alpha = 1;

                UILabel *lineLabel = [[view subviews] objectAtIndex:1];
                lineLabel.alpha = 0;
                UILabel *subTitleLabel = [[view subviews] objectAtIndex:2];
                subTitleLabel.alpha = 0;
                UILabel *subCourseLabel = [[view subviews] objectAtIndex:3];
                subCourseLabel.alpha = 0;
                UIImageView *subImageView = [[view subviews] objectAtIndex:4];
                subImageView.alpha = 0;
            }
        }
        completion:^(BOOL finished) {}];
}

- (void)majorHeight {
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
