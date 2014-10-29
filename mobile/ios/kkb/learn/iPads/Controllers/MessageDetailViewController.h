//
//  MessageDetailViewController.h
//  learn
//
//  Created by User on 14-1-8.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiscussionTopicItem;
@interface MessageDetailViewController : UIViewController


@property (nonatomic, retain) DiscussionTopicItem *discussionTopic;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImage; //头像
@property (nonatomic, retain) IBOutlet UILabel *announcementTitle; //通告标题
@property (nonatomic, retain) IBOutlet UILabel *user_name;//姓名
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *timeTitle;
@property (nonatomic, retain) IBOutlet UIView *fileView;
@property (nonatomic, retain) IBOutlet UILabel *fileLabel;
@end
