//
//  KKBCommentListView.h
//  learn
//
//  Created by pczhai on 14-9-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKBCommentListViewDelegate <NSObject>

- (void)commentListViewCoverViewClick;

@end

@interface KKBCommentListView
    : UIView <UITableViewDataSource, UITableViewDelegate,
              UIGestureRecognizerDelegate>

@property(nonatomic, assign) id<KKBCommentListViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
       CommentArray:(NSArray *)array
         CourseType:(NSString *)courseType;

- (void)showCommentView;
- (void)dismissCommentView;

@end
