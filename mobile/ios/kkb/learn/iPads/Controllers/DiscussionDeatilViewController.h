//
//  DiscussionDeatilViewController.h
//  learn
//
//  Created by User on 14-1-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//


#import <UIKit/UIKit.h>

@class DiscussionTopicItem;
@class DiscussionOperator;


@interface DiscussionDeatilViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    DiscussionOperator *op;
  
}

@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, retain) DiscussionTopicItem *discussionTopicItem;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage; //头像
@property (nonatomic, retain) IBOutlet UILabel *announcementTitle; //通告标题
@property (nonatomic, retain) IBOutlet UILabel *user_name;//姓名
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UILabel *timeTitle;
@property (nonatomic, retain) IBOutlet UITableView *discussionTableView;
@property (nonatomic, retain) NSMutableArray *currentTopicEntryList;
@property (nonatomic, retain) NSMutableArray *currentTopicEntryReplyList;
@property (nonatomic, retain) NSMutableArray *currentTopicEntryOpenList;

@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *viewFooter;
@property (nonatomic, retain) IBOutlet UITextView *inputView;

@property (nonatomic, retain) IBOutlet UIImageView *imvBg;

@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLeftLabel;
@property NSInteger selectIndex;
@property NSInteger btnTag;
@property (nonatomic, retain) NSMutableArray *assArr;

@property (nonatomic, retain) NSString *textHeaderstr;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;
@property (nonatomic, retain) IBOutlet UIView *fileView;
@property (nonatomic, retain) IBOutlet UILabel *fileLabel;
@property (nonatomic, retain) IBOutlet UIButton *btnNext;
@property (nonatomic, retain) IBOutlet UIButton *btnLast;
@end
