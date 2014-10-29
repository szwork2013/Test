//
//  CycleScrollView.h
//  learn
//
//  Created by MagicLGD on 14-4-8.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol CycleScrollViewDelegate <NSObject>
//
//- (void)scrollViewDidEnd;
//
//
//@end

@interface CycleScrollView : UIView

//@property (nonatomic , readonly) UIScrollView *scrollView;
@property(nonatomic, assign) NSInteger currentPageIndex;
@property(nonatomic, assign) NSInteger totalPageCount;
@property(nonatomic, strong) NSMutableArray *contentViews;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSTimer *animationTimer;
@property(nonatomic, assign) NSTimeInterval animationDuration;

//@property (assign,nonatomic)id<CycleScrollViewDelegate>CycleDelegate;
/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame
    animationDuration:(NSTimeInterval)animationDuration;

/**
 数据源：获取总的page个数
 **/
@property(nonatomic, copy) NSInteger (^totalPagesCount)(void);
/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property(nonatomic, copy) UIView * (^fetchContentViewAtIndex)
    (NSInteger pageIndex);
/**
 当点击的时候，执行的block
 **/
@property(nonatomic, copy) void (^TapActionBlock)(NSInteger pageIndex);

/**
 当滑动的时候，执行的block
 **/
@property(nonatomic, copy) void (^ScrollBlock)(NSInteger pageIndex);

- (void)pauseTimer:(BOOL)isPaused;

@end
