//
//  DiscussionViewController.h
//  learn
//
//  Created by User on 13-12-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiscussionOperator;

@interface DiscussionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    DiscussionOperator *op;
    
    UIView *announcementBlankView; //没有数据时提示显示
}
@property (nonatomic, retain) NSMutableArray *discussionsArray;
@property (nonatomic, copy) NSString *courseId;


@property (nonatomic,retain) IBOutlet UITableView *discussionTableView;
@end
