//
//  PushUpScrollView.h
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"
@class PushUpScrollView;
@protocol PushUpScrollViewDelegate <NSObject>

/* After one of the delegate methods is invoked a loading animation is started, to end it use the respective status update property */
//- (void)pullDownScrollViewDidTriggerRefresh:(PushUpScrollView*)pushUpScrollView;
- (void)pullUpScrollViewDidTriggerLoadMore:(PushUpScrollView*)pushUpScrollView;

@end


@interface PushUpScrollView : UIScrollView<LoadMoreTableFooterDelegate, UIScrollViewDelegate>
{
    LoadMoreTableFooterView *loadMoreView;
    BOOL pullTableIsLoadingMore;
}
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;


@property (nonatomic,assign) id <PushUpScrollViewDelegate> pushUpDelegate;
@end
