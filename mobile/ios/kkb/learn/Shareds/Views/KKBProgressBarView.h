//
//  KKBProgressBarView.h
//  KKBProgressBarView
//
//  Created by zengmiao on 8/4/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBProgressBarView : UIView

@property(nonatomic,assign) float progress;
// 0.0 .. 1.0, default is 0.0. values outside are pinned.


- (instancetype)initWithFrame:(CGRect)frame;

@end
