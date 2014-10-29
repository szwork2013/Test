//
//  AnnouncementTopicEntryViewController.h
//  learn
//
//  Created by User on 13-7-18.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnouncementOperator;
@class DiscussionTopicItem;

@interface AnnouncementTopicEntryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    AnnouncementOperator *op;
    
    UITableView *topicEntryTableView; //单元TableView
  
    UIView *topicEntryBlankView; //没有数据时提示显示
}

@property (nonatomic, retain) NSMutableArray *currentTopicEntryList;
@property (nonatomic, retain) NSMutableArray *currentTopicEntryReplyList; 
@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, retain) DiscussionTopicItem *discussionTopicItem;

@end
