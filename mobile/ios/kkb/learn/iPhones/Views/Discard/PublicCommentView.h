//
//  PublicCommentView.h
//  learn
//
//  Created by 翟鹏程 on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

#define G_COMMENTVIEW_HEIGHT 300
@protocol PublicCommentViewDelegate <NSObject>

- (void)commentCoverViewClick;

/**
 *  请求到评论数量时的回调
 *
 *  @param commentCount commentCount description
 */
- (void)commentCount:(int)commentCount;

@end

@interface PublicCommentView
    : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, assign) id<PublicCommentViewDelegate> delegate;

@property(nonatomic, strong) UITableView *commentTableView;

@property(nonatomic, strong) NSDictionary *currentCourse;

@property(nonatomic, strong) NSMutableArray *currentCommentArray;

@property(nonatomic, strong) NSString *courseId;

- (void)initWithUI;

@end
