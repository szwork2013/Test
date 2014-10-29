//
//  AnnouncementDetailViewController.h
//  learn
//
//  Created by User on 13-7-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiscussionTopicItem;
@class AnnouncementOperator;


@interface AnnouncementDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
     AnnouncementOperator *op;
//     UIImageView *headerView;
//    UIImageView *bottomView; //底部View
//    
//    UIImageView *avatarImage; //头像
//    UILabel *announcementTitle; //通告标题
//    UILabel *user_name;//姓名
//    UILabel *posted_at;
//    UILabel *discussion_subentry_count;
//    
//    UIWebView *messageWebView; //内容
//    
//    UIButton *fileButton; //文件按钮
//    UIButton *topicEntryButton; //讨论按钮
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
//@property (nonatomic, retain) NSMutableArray *arr;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *viewFooter;
@property (nonatomic, retain) IBOutlet UITextView *inputView;

@property (nonatomic, retain) IBOutlet UIImageView *imvBg;
@property (nonatomic, retain) IBOutlet UIView *fileView;
@property (nonatomic, retain) IBOutlet UILabel *fileLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLeftLabel;
@property NSInteger selectIndex;
@property NSInteger btnTag;
@property (nonatomic, retain) NSMutableArray *assArr;

@property (nonatomic, retain) NSString *textHeaderstr;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;

@property (nonatomic, retain) IBOutlet UIButton *btnNext;
@property (nonatomic, retain) IBOutlet UIButton *btnLast;
@end
