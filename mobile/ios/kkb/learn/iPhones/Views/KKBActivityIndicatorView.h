//
//  KKBActivityIndicator.h
//  learn
//
//  Created by xgj on 14-6-27.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum { BlackStyle, GrayStyle } LoadingViewStyle;

@interface KKBActivityIndicatorView : UIView {
    UIView *roundCornorView;
    UIActivityIndicatorView *indicatorView;
    UILabel *loadingTextLabel;
}

/***********

 [ 重要说明：这个单例有问题，多个View
 Controller共享一个KKBActivityIndicatorView是不可能的，每个view
 Controller应该有它自己的KKBActivityIndicatorView ]
 建议废弃该单例函数

 **********/
+ (KKBActivityIndicatorView *)sharedInstance;

- (void)updateFrame:(CGRect)frame;
- (void)setViewStyle:(LoadingViewStyle)style;
- (void)markAsFailure;
- (void)markAsLoading;
- (void)showInView:(UIView *)superView;
- (void)hideView;

@end
