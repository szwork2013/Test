//
//  KKBLoadingFailedView.h
//  learn
//
//  Created by xgj on 14-7-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBLoadingFailedView : UIView

+ (KKBLoadingFailedView *)sharedInstance;

- (void)updateFrame:(CGRect)frame;
- (void)setTapTarget:(id)target action:(SEL)selector;
- (void)show;
- (void)hide;

@end
