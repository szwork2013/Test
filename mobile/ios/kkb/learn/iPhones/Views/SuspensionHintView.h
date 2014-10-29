//
//  SuspensionHintView.h
//  learn
//
//  Created by zxj on 14-6-5.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kLPPopupDefaultWaitDuration;

@interface SuspensionHintView : UILabel
@property(strong, nonatomic) UIColor *popupColor UI_APPEARANCE_SELECTOR;

@property(assign, nonatomic) CGFloat forwardAnimationDuration;
@property(assign, nonatomic) CGFloat backwardAnimationDuration;

@property(assign, nonatomic) UIEdgeInsets textInsets;
@property(assign, nonatomic) CGFloat maxWidth;

#pragma mark - Initialization
+ (SuspensionHintView *)popupWithText:(NSString *)txt;

#pragma mark - Showing popup
- (void)showInView:(UIView *)parentView
     centerAtPoint:(CGPoint)pos
          duration:(CGFloat)waitDuration
        completion:(void (^)(void))block;
@end
