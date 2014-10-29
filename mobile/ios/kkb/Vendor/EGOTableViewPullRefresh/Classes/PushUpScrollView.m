//
//  PushUpScrollView.m
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "PushUpScrollView.h"

@implementation PushUpScrollView

@synthesize pullTableIsLoadingMore;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self config];
}

- (void)config {
    /* Message interceptor to intercept scrollView delegate messages */

    /* Status Properties */

    pullTableIsLoadingMore = NO;

    /* Refresh View */
    //    refreshView = [[EGORefreshTableHeaderView alloc]
    //    initWithFrame:CGRectMake(0, -self.bounds.size.height,
    //    self.bounds.size.width, self.bounds.size.height)];
    //    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    //    UIViewAutoresizingFlexibleBottomMargin;
    //    refreshView.delegate = self;
    //    [self addSubview:refreshView];

    /* Load more view init */
    loadMoreView = [[LoadMoreTableFooterView alloc]
        initWithFrame:CGRectMake(0, self.bounds.size.height,
                                 self.bounds.size.width,
                                 self.bounds.size.height)];
    loadMoreView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    loadMoreView.originY = 0;
    [self addSubview:loadMoreView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight =
        (self.bounds.size.height -
         MIN(self.bounds.size.height, self.contentSize.height));

    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y =
        self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {

    [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}
- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore {
    if (!pullTableIsLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        pullTableIsLoadingMore = YES;
    } else if (pullTableIsLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsLoadingMore = NO;
    }
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view {
    pullTableIsLoadingMore = YES;
    [self.pushUpDelegate pullUpScrollViewDidTriggerLoadMore:self];
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
