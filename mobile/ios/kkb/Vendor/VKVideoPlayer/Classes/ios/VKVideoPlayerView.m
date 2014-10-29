//
//  Created by Viki.
//  Copyright (c) 2014 Viki Inc. All rights reserved.
//

#import "VKVideoPlayerView.h"
#import "VKScrubber.h"
#import <QuartzCore/QuartzCore.h>
#import "DDLog.h"
#import "VKVideoPlayerConfig.h"
#import "VKFoundation.h"
#import "VKScrubber.h"
#import "VKVideoPlayerTrack.h"
#import "UIImage+VKFoundation.h"
#import "VKVideoPlayerSettingsManager.h"

// TODO: byzm 添加loading时用
#define LOADING_LABEL_HEIGHT 20
#define LOADING_MARGIN_BOTTOM 20
#define FAILEDMSG_LABEL_CENTER_MARGIN_TOP 60.0f

#define PADDING 8

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_WARN;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface VKVideoPlayerView () {
    CGPoint startLocation;
}
@property(nonatomic, strong) NSMutableArray *customControls;
@property(nonatomic, strong) NSMutableArray *portraitControls;
@property(nonatomic, strong) NSMutableArray *landscapeControls;

@end

@implementation VKVideoPlayerView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scrubber removeObserver:self forKeyPath:@"maximumValue"];
    [self.rewindButton removeObserver:self forKeyPath:@"hidden"];
    [self.nextButton removeObserver:self forKeyPath:@"hidden"];
}

- (void)initialize {

    //添加滑动手势 yqjiang
    UIPanGestureRecognizer *panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];

    self.customControls = [NSMutableArray array];
    self.portraitControls = [NSMutableArray array];
    self.landscapeControls = [NSMutableArray array];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    self.view.frame = self.frame;
    self.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.view];

    self.titleLabel.font = THEMEFONT(@"fontRegular", DEVICEVALUE(22.0f, 14.0f));
    self.titleLabel.textColor = THEMECOLOR(@"colorFont4");
    self.titleLabel.text = @"";

    self.captionButton.titleLabel.font = THEMEFONT(@"fontRegular", 13.0f);
    [self.captionButton setTitleColor:THEMECOLOR(@"colorFont4")
                             forState:UIControlStateNormal];

    self.videoQualityButton.titleLabel.font = THEMEFONT(@"fontRegular", 13.0f);
    [self.videoQualityButton setTitleColor:THEMECOLOR(@"colorFont4")
                                  forState:UIControlStateNormal];

    self.currentTimeLabel.font =
        THEMEFONT(@"fontRegular", DEVICEVALUE(16.0f, 10.0f));
    self.currentTimeLabel.textColor = THEMECOLOR(@"colorFont4");
    self.totalTimeLabel.font =
        THEMEFONT(@"fontRegular", DEVICEVALUE(16.0f, 10.0f));
    self.totalTimeLabel.textColor = THEMECOLOR(@"colorFont4");

    [self.scrubber addObserver:self
                    forKeyPath:@"maximumValue"
                       options:0
                       context:nil];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(durationDidLoad:)
                          name:kVKVideoPlayerDurationDidLoadNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(scrubberValueUpdated:)
                          name:kVKVideoPlayerScrubberValueUpdatedNotification
                        object:nil];

    [self.scrubber addTarget:self
                      action:@selector(updateTimeLabels)
            forControlEvents:UIControlEventValueChanged];

    UIView *overlay = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0,
                                 self.bottomControlOverlay.frame.size.width,
                                 self.bottomControlOverlay.frame.size.height)];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    overlay.backgroundColor = THEMECOLOR(@"colorBackground8");
    overlay.alpha = 0.6f;
    [self.bottomControlOverlay addSubview:overlay];
    [self.bottomControlOverlay sendSubviewToBack:overlay];

    overlay = [[UIView alloc] initWithFrame:self.topControlOverlay.frame];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    overlay.backgroundColor = THEMECOLOR(@"colorBackground8");
    overlay.alpha = 0.6f;
    [self.topControlOverlay addSubview:overlay];
    [self.topControlOverlay sendSubviewToBack:overlay];

    [self.captionButton setTitle:[VKSharedVideoPlayerSettingsManager
                                         .subtitleLanguageCode uppercaseString]
                        forState:UIControlStateNormal];

    [self.videoQualityButton
        setTitle:[VKSharedVideoPlayerSettingsManager
                     videoQualityShortDescription:
                         [VKSharedVideoPlayerSettingsManager streamKey]]
        forState:UIControlStateNormal];

    self.externalDeviceLabel.adjustsFontSizeToFitWidth = YES;

    [self.rewindButton addObserver:self
                        forKeyPath:@"hidden"
                           options:0
                           context:nil];
    [self.nextButton addObserver:self
                      forKeyPath:@"hidden"
                         options:0
                         context:nil];

    self.fullscreenButton.hidden = NO;

    for (UIButton *button in @[ self.topPortraitCloseButton ]) {
        [button setBackgroundImage:
                    [[UIImage imageWithColor:THEMECOLOR(@"colorBackground8")]
                        imageByApplyingAlpha:0.6f]
                          forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0f;
        button.clipsToBounds = YES;
    }

    [self.topPortraitCloseButton addTarget:self
                                    action:@selector(doneButtonTapped:)
                          forControlEvents:UIControlEventTouchUpInside];

    // TODO: byzm 刷新时间控件布局
    [self layoutForOrientation:
              [[UIApplication sharedApplication] statusBarOrientation]];
    //调整时间布局
    [self updateTimeLabels];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

#pragma mark - zmadd
- (void)layoutSubviews {
    [super layoutSubviews];

    // TODO: byzm failedView 布局
    self.reloadButton.center = self.failedView.center;

    // TODO: byzm
    UIInterfaceOrientation visibleInterfaceOrientation =
        self.delegate.visibleInterfaceOrientation;
    if (visibleInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.frame = self.portraitFrame;
        //横竖屏 player按钮布局
        [self.bigPlayButton
            setFrameOriginY:CGRectGetMinY(self.bottomControlOverlay.frame) / 2 -
                            CGRectGetHeight(self.bigPlayButton.frame) / 2];

        // TODO: byzpc
        [self.bigPlayBGView
            setFrameHeight:(self.controls.size.height -
                            self.bottomControlOverlay.size.height)];

        self.fauledMessageLabel.center = CGPointMake(
            self.reloadButton.centerX,
            self.reloadButton.centerY + FAILEDMSG_LABEL_CENTER_MARGIN_TOP);

    } else if (visibleInterfaceOrientation ==
                   UIInterfaceOrientationLandscapeLeft ||
               visibleInterfaceOrientation ==
                   UIInterfaceOrientationLandscapeRight) {
        self.frame = self.landscapeFrame;

        [self.bigPlayButton
            setFrameOriginY:(CGRectGetMinY(self.bottomControlOverlay.frame) -
                             CGRectGetMaxY(self.topControlOverlay.frame)) /
                                2 +
                            CGRectGetMaxY(self.topControlOverlay.frame) -
                            CGRectGetHeight(self.bigPlayButton.frame) / 2];

        // TODO: byzpc
        CGFloat screenWidth =
            [UIScreen kkb_screenBoundsFixedToPortraitOrientation].size.width;
        [self.bigPlayBGView
            setFrameHeight:(screenWidth -
                            self.bottomControlOverlay.size.height)];

        self.fauledMessageLabel.center = CGPointMake(
            self.reloadButton.centerX,
            self.reloadButton.centerY + FAILEDMSG_LABEL_CENTER_MARGIN_TOP + 30);
    }

    [self layoutLoginView];
}

#pragma - VKVideoPlayerViewDelegates
// TODO: byzm
- (IBAction)reloadBtnTapped:(UIButton *)sender {
    [self.delegate reloadPlayButtonTapped];
}

- (IBAction)playButtonTapped:(id)sender {

    UIButton *playButton;
    if ([sender isKindOfClass:[UIButton class]]) {
        playButton = (UIButton *)sender;
    }

    if (playButton.selected) {
        [self.delegate playButtonPressed];
        [self setPlayButtonsSelected:NO];
    } else {
        [self.delegate pauseButtonPressed];
        [self setPlayButtonsSelected:YES];
    }
}

- (IBAction)nextTrackButtonPressed:(id)sender {
    [self.delegate nextTrackButtonPressed];
}

- (IBAction)previousTrackButtonPressed:(id)sender {
    [self.delegate previousTrackButtonPressed];
}

- (IBAction)rewindButtonPressed:(id)sender {
    [self.delegate rewindButtonPressed];
}

- (IBAction)fullscreenButtonTapped:(id)sender {
    self.fullscreenButton.selected = !self.fullscreenButton.selected;
    [self.delegate fullScreenButtonTapped];
}

- (IBAction)captionButtonTapped:(id)sender {
    [self.delegate captionButtonTapped];
}

- (IBAction)videoQualityButtonTapped:(id)sender {
    [self.delegate videoQualityButtonTapped];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.delegate doneButtonTapped];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.scrubber) {
        if ([keyPath isEqualToString:@"maximumValue"]) {
            DDLogVerbose(@"scrubber Value change: %f", self.scrubber.value);
            RUN_ON_UI_THREAD(^{ [self updateTimeLabels]; });
        }
    }

    if ([object isKindOfClass:[UIButton class]]) {
        UIButton *button = object;
        if ([button isDescendantOfView:self.topControlOverlay]) {
            [self layoutTopControls];
        }
    }
}

- (void)setDelegate:(id<VKVideoPlayerViewDelegate>)delegate {
    _delegate = delegate;
    self.scrubber.delegate = delegate;
}

- (void)durationDidLoad:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSNumber *duration = [info objectForKey:@"duration"];
    [self.delegate videoTrack].totalVideoDuration = duration;
    RUN_ON_UI_THREAD(^{
        self.scrubber.maximumValue = [duration floatValue];
        self.scrubber.hidden = NO;
    });
}

- (void)scrubberValueUpdated:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    RUN_ON_UI_THREAD(^{
        DDLogVerbose(@"scrubberValueUpdated: %@",
                     [info objectForKey:@"scrubberValue"]);
        [self.scrubber
            setValue:[[info objectForKey:@"scrubberValue"] floatValue]
            animated:YES];
        [self updateTimeLabels];
    });
}

- (void)updateTimeLabels {
    DDLogVerbose(@"Updating TimeLabels: %f", self.scrubber.value);

    [self.currentTimeLabel setFrameWidth:100.0f];
    [self.totalTimeLabel setFrameWidth:100.0f];

    self.currentTimeLabel.text =
        [VKSharedUtility timeStringFromSecondsValue:(int)self.scrubber.value];
    [self.currentTimeLabel sizeToFit];
    [self.currentTimeLabel
        setFrameHeight:CGRectGetHeight(self.bottomControlOverlay.frame)];

    self.totalTimeLabel.text = [VKSharedUtility
        timeStringFromSecondsValue:(int)self.scrubber.maximumValue];
    [self.totalTimeLabel sizeToFit];
    [self.totalTimeLabel
        setFrameHeight:CGRectGetHeight(self.bottomControlOverlay.frame)];

    [self layoutSlider];
}

- (void)layoutSliderForOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    //  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    //    [self.totalTimeLabel
    //    setFrameOriginX:CGRectGetMinX(self.fullscreenButton.frame) -
    //    self.totalTimeLabel.frame.size.width];
    //  } else {
    //    [self.totalTimeLabel
    //    setFrameOriginX:CGRectGetMinX(self.captionButton.frame) -
    //    self.totalTimeLabel.frame.size.width - PADDING];
    //  }

    CGFloat bottomControlsWidth = self.bottomControlOverlay.frame.size.width;
    CGFloat bottomControlsHeight = self.bottomControlOverlay.frame.size.height;

    CGFloat leftOffset = 0.0f;
    CGFloat rightOffset = bottomControlsWidth;

    // Play Button
    if (!self.playButton.hidden) {
        [self.playButton setFrameOriginX:leftOffset + 2];
        [self.playButton setFrameOriginY:(bottomControlsHeight -
                                          self.playButton.frame.size.height) /
                                         2];
        leftOffset = CGRectGetMaxX(self.playButton.frame);
    }

    // Current Time Label
    if (!self.currentTimeLabel.hidden) {
        [self.currentTimeLabel setFrameOriginX:MAX(leftOffset - 2, 0)];
        [self.currentTimeLabel
            setFrameOriginY:(bottomControlsHeight -
                             self.currentTimeLabel.frame.size.height)];
        leftOffset = CGRectGetMaxX(self.currentTimeLabel.frame);
    }

    // Full Screen Button
    if (!self.fullscreenButton.hidden) {
        [self.fullscreenButton
            setFrameOriginX:rightOffset - 4 -
                            self.fullscreenButton.frame.size.width];
        [self.fullscreenButton
            setFrameOriginY:(bottomControlsHeight -
                             self.fullscreenButton.frame.size.height) /
                            2];
        rightOffset = CGRectGetMinX(self.fullscreenButton.frame);
    }

    // Video Quality Button
    if (!self.videoQualityButton.hidden) {
        [self.videoQualityButton
            setFrameOriginX:rightOffset - 2 -
                            self.videoQualityButton.frame.size.width];
        [self.videoQualityButton
            setFrameOriginY:(bottomControlsHeight -
                             self.videoQualityButton.frame.size.height) /
                            2];
        rightOffset = CGRectGetMinX(self.videoQualityButton.frame);
    }

    // Captions Button
    if (!self.captionButton.hidden) {
        [self.captionButton
            setFrameOriginX:rightOffset - 4 -
                            self.captionButton.frame.size.width];
        [self.captionButton
            setFrameOriginY:(bottomControlsHeight -
                             self.captionButton.frame.size.height) /
                            2];
        rightOffset = CGRectGetMinX(self.captionButton.frame);
    }

    // Total Time Label
    if (!self.totalTimeLabel.hidden) {
        [self.totalTimeLabel
            setFrameOriginX:rightOffset - 2 -
                            self.totalTimeLabel.frame.size.width];
        [self.totalTimeLabel
            setFrameOriginY:(bottomControlsHeight -
                             self.captionButton.frame.size.height) /
                            2];
        rightOffset = CGRectGetMinX(self.totalTimeLabel.frame);
    }

    // Scrubber
    if (!self.scrubber.hidden) {
        [self.scrubber setFrameOriginX:leftOffset + 4];

        [self.scrubber setFrameWidth:self.totalTimeLabel.frame.origin.x -
                                     self.scrubber.frame.origin.x - 4];
        [self.scrubber setFrameOriginY:(bottomControlsHeight -
                                        self.scrubber.frame.size.height) /
                                       2];
    }
}

- (void)layoutSlider {
    [self layoutSliderForOrientation:self.delegate.visibleInterfaceOrientation];
}

- (void)layoutTopControls {

    CGFloat rightMargin = CGRectGetMaxX(self.topControlOverlay.frame);
    for (UIView *button in self.topControlOverlay.subviews) {
        if ([button isKindOfClass:[UIButton class]] &&
            button != self.doneButton && !button.hidden) {
            rightMargin = MIN(CGRectGetMinX(button.frame), rightMargin);
        }
    }

    [self.titleLabel
        setFrameWidth:rightMargin - CGRectGetMinX(self.titleLabel.frame) - 20];
}

- (void)setPlayButtonsSelected:(BOOL)selected {
    self.playButton.selected = selected;
    self.bigPlayButton.selected = selected;
}

- (void)setPlayButtonsEnabled:(BOOL)enabled {
    self.playButton.enabled = enabled;
    self.bigPlayButton.enabled = enabled;
}

- (void)setControlsEnabled:(BOOL)enabled {

    self.captionButton.enabled = enabled;
    self.videoQualityButton.enabled = enabled;
    self.topSettingsButton.enabled = enabled;

    [self setPlayButtonsEnabled:enabled];

    self.previousButton.enabled =
        enabled && self.delegate.videoTrack.hasPrevious;
    self.nextButton.enabled = enabled && self.delegate.videoTrack.hasNext;
    self.scrubber.enabled = enabled;
    self.rewindButton.enabled = enabled;
    self.fullscreenButton.enabled = enabled;

    self.isControlsEnabled = enabled;

    NSMutableArray *controlList = self.customControls.mutableCopy;
    [controlList addObjectsFromArray:self.portraitControls];
    [controlList addObjectsFromArray:self.landscapeControls];
    for (UIView *control in controlList) {
        if ([control isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)control;
            button.enabled = enabled;
        }
    }
}

- (IBAction)handleSingleTap:(id)sender {
    [self setControlsHidden:!self.isControlsHidden];
    if (!self.isControlsHidden) {
        self.controlHideCountdown = kPlayerControlsAutoHideTime;
    }
    [self.delegate playerViewSingleTapped];
}

- (IBAction)handleSwipeLeft:(id)sender {
    [self.delegate nextTrackBySwipe];
}
//-------新增的手势方法 yqjiang--------
- (void)handlePan:(UIPanGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint stopLocation = [sender locationInView:self];
        CGFloat distance = stopLocation.x - startLocation.x;
        CGFloat audioDistance = stopLocation.y - startLocation.y;
        NSString *panGestureEnd = @"panGestureEnd";
        NSDictionary *dic = [NSDictionary dictionary];
        if ([[UIScreen mainScreen] applicationFrame].size.width ==
            G_SCREEN_WIDTH) {

            if (distance * distance > audioDistance * audioDistance * 1.5) {
                NSNumber *panDistance = [NSNumber numberWithFloat:distance];
                dic = [NSDictionary dictionaryWithObject:panDistance
                                                  forKey:@"distance"];
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:panGestureEnd
                                  object:nil
                                userInfo:dic];
            } else if (distance * distance < audioDistance * audioDistance) {
                NSNumber *audioPanDistance =
                    [NSNumber numberWithFloat:audioDistance];
                dic = [NSDictionary dictionaryWithObject:audioPanDistance
                                                  forKey:@"audioDistance"];
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:panGestureEnd
                              object:nil
                            userInfo:dic];
        } else {
            if (distance * distance * 1.5 < audioDistance * audioDistance) {
                NSNumber *panDistance = [NSNumber numberWithFloat:distance];
                dic = [NSDictionary dictionaryWithObject:panDistance
                                                  forKey:@"distance"];
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:panGestureEnd
                                  object:nil
                                userInfo:dic];
            } else if (distance * distance > audioDistance * audioDistance) {
                NSNumber *audioPanDistance =
                    [NSNumber numberWithFloat:audioDistance];
                dic = [NSDictionary dictionaryWithObject:audioPanDistance
                                                  forKey:@"audioDistance"];
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:panGestureEnd
                              object:nil
                            userInfo:dic];
        }

    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"change");
        CGPoint point = [sender locationInView:self];
        CGFloat xDistance = point.x - startLocation.x;
        CGFloat yDistance = point.y - startLocation.y;
        if (xDistance * xDistance > yDistance * yDistance * 1.5) {
            NSValue *pointValue = [NSValue valueWithCGPoint:point];
            NSValue *startPoint = [NSValue valueWithCGPoint:startLocation];
            // NSDictionary *dic = [NSDictionary dictionaryWithObject:pointValue
            // forKey:@"movePoint"];
            NSDictionary *dic = [NSDictionary
                dictionaryWithObjectsAndKeys:pointValue, @"movePoint",
                                             startPoint, @"startPoint", nil];
            NSString *panGestureMove = @"panGestureMove";
            [[NSNotificationCenter defaultCenter]
                postNotificationName:panGestureMove
                              object:nil
                            userInfo:dic];
        }
    }
}

- (IBAction)handleSwipeRight:(id)sender {
    [self.delegate previousTrackBySwipe];
}

- (void)setControlHideCountdown:(NSInteger)controlHideCountdown {
    if (controlHideCountdown == 0) {
        [self setControlsHidden:YES];
    } else {
        [self setControlsHidden:NO];
    }
    _controlHideCountdown = controlHideCountdown;
}

- (void)hideControlsIfNecessary {
    if (self.isControlsHidden)
        return;
    if (self.controlHideCountdown == -1) {
        [self setControlsHidden:NO];
    } else if (self.controlHideCountdown == 0) {
        [self setControlsHidden:YES];
    } else {
        self.controlHideCountdown--;
    }
}

- (void)setLoading:(BOOL)isLoading {
    // TODO: byzm 在这里需要实现预加载效果
    /*
    if (isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
     */
    if (isLoading) {
        [self.activityIndicator startAnimating];
        [self allowShowLoadingView:YES];

    } else {
        [self.activityIndicator stopAnimating];
        [self allowShowLoadingView:NO];
    }
}

// TODO: byzm 在这里需要实现预加载效果
- (void)allowShowLoadingView:(BOOL)show {

    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *olderloginView = (UIView *)[self viewWithTag:10086];
        if (!olderloginView) {
            UIView *logingView = [[UIView alloc] initWithFrame:self.bounds];
            logingView.tag = 10086;
            logingView.clipsToBounds = YES;
            logingView.backgroundColor = [UIColor clearColor];

            UIImageView *imageView =
                [[UIImageView alloc] initWithFrame:logingView.bounds];
            imageView.tag = 10087;
            imageView.image = [UIImage imageNamed:@"bg_video"];
            [logingView addSubview:imageView];

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
            titleLabel.tag = 10088;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"视频加载中，请稍后...";
            [logingView addSubview:titleLabel];

            // activityIndicator
            UIActivityIndicatorView *indicator =
                [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleWhiteLarge];
            indicator.tag = 10089;
            indicator.hidesWhenStopped = YES;
            indicator.center = logingView.center;
            [logingView addSubview:indicator];
            [indicator startAnimating];

            [self addSubview:logingView];
        }

        [self layoutLoginView];

        UIActivityIndicatorView *indicator =
            (UIActivityIndicatorView *)[olderloginView viewWithTag:10089];
        if (show) {
            olderloginView.hidden = NO;
            [indicator startAnimating];
        } else {
            olderloginView.hidden = YES;
            [indicator stopAnimating];
        }
    });
}

/**
 *  zm add
 */
- (void)layoutLoginView {
    UIView *olderloginView = (UIView *)[self viewWithTag:10086];
    if (olderloginView) {
        olderloginView.frame = self.bounds;
        UIView *imageView = (UIView *)[olderloginView viewWithTag:10087];
        UIView *labelView = (UIView *)[olderloginView viewWithTag:10088];
        UIView *indicator = (UIView *)[olderloginView viewWithTag:10089];

        CGRect titleFrame =
            (CGRect) {.origin.x = 0,
                      .origin.y = olderloginView.frame.size.height -
                                  LOADING_LABEL_HEIGHT - LOADING_MARGIN_BOTTOM,
                      .size.width = olderloginView.frame.size.width,
                      .size.height = LOADING_LABEL_HEIGHT};

        imageView.frame = olderloginView.bounds;
        labelView.frame = titleFrame;
        indicator.center = olderloginView.center;
    }
}

- (void)setControlsHidden:(BOOL)hidden {
    DDLogVerbose(@"Controls: %@", hidden ? @"hidden" : @"visible");

    if (self.isControlsHidden != hidden) {
        self.isControlsHidden = hidden;
        self.controls.hidden = hidden;

        if (UIInterfaceOrientationIsLandscape(
                self.delegate.visibleInterfaceOrientation)) {
            for (UIView *control in self.landscapeControls) {
                control.hidden = hidden;
            }
        }
        if (UIInterfaceOrientationIsPortrait(
                self.delegate.visibleInterfaceOrientation)) {
            for (UIView *control in self.portraitControls) {
                control.hidden = hidden;
            }
        }
        for (UIView *control in self.customControls) {
            control.hidden = hidden;
        }
    }

    [self layoutTopControls];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[VKScrubber class]] ||
        [touch.view isKindOfClass:[UIButton class]]) {
        // prevent recognizing touches on the slider
        return NO;
    }
    return YES;
}

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        self.topControlOverlay.hidden = YES;
        self.topPortraitControlOverlay.hidden = NO;

        [self.buttonPlaceHolderView setFrameOriginY:PADDING / 2];
        self.buttonPlaceHolderView.hidden = YES;

        self.captionButton.hidden = YES;
        self.videoQualityButton.hidden = YES;

        [self.bigPlayButton
            setFrameOriginY:CGRectGetMinY(self.bottomControlOverlay.frame) / 2 -
                            CGRectGetHeight(self.bigPlayButton.frame) / 2];

        for (UIView *control in self.portraitControls) {
            control.hidden = self.isControlsHidden;
        }
        for (UIView *control in self.landscapeControls) {
            control.hidden = YES;
        }

    } else {
        [self.topControlOverlay setFrameOriginY:0.0f];
        self.topControlOverlay.hidden = NO;
        self.topPortraitControlOverlay.hidden = YES;

        [self.buttonPlaceHolderView
            setFrameOriginY:PADDING / 2 +
                            CGRectGetMaxY(self.topControlOverlay.frame)];
        self.buttonPlaceHolderView.hidden = NO;

        self.captionButton.hidden = NO;
        self.videoQualityButton.hidden = NO;

        [self.bigPlayButton
            setFrameOriginY:(CGRectGetMinY(self.bottomControlOverlay.frame) -
                             CGRectGetMaxY(self.topControlOverlay.frame)) /
                                2 +
                            CGRectGetMaxY(self.topControlOverlay.frame) -
                            CGRectGetHeight(self.bigPlayButton.frame) / 2];

        for (UIView *control in self.portraitControls) {
            control.hidden = YES;
        }
        for (UIView *control in self.landscapeControls) {
            control.hidden = self.isControlsHidden;
        }
    }

    [self layoutTopControls];
    [self layoutSliderForOrientation:interfaceOrientation];
}

- (void)addSubviewForControl:(UIView *)view {
    [self addSubviewForControl:view toView:self];
}
- (void)addSubviewForControl:(UIView *)view toView:(UIView *)parentView {
    [self addSubviewForControl:view
                        toView:parentView
                forOrientation:UIInterfaceOrientationMaskAll];
}
- (void)addSubviewForControl:(UIView *)view
                      toView:(UIView *)parentView
              forOrientation:(UIInterfaceOrientationMask)orientation {
    view.hidden = self.isControlsHidden;
    if (orientation == UIInterfaceOrientationMaskAll) {
        [self.customControls addObject:view];
    } else if (orientation == UIInterfaceOrientationMaskPortrait) {
        [self.portraitControls addObject:view];
    } else if (orientation == UIInterfaceOrientationMaskLandscape) {
        [self.landscapeControls addObject:view];
    }
    [parentView addSubview:view];
}
- (void)removeControlView:(UIView *)view {
    [view removeFromSuperview];
    [self.customControls removeObject:view];
    [self.landscapeControls removeObject:view];
    [self.portraitControls removeObject:view];
}

@end
