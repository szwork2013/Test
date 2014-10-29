//
//  AssignmentViewController.h
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssignmentOperator;
@interface AssignmentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    AssignmentOperator *op;
    
//    UIView *announcementBlankView; //没有数据时提示显示
}
@property (nonatomic, retain) NSMutableArray *arrAssignmentBefore; //以前的作业
@property (nonatomic, retain) NSMutableArray *arrAssignmentFuture; //未来的作业
@property (nonatomic, copy) NSString *courseId;
@property (nonatomic,retain) IBOutlet UITableView *assignmentTableView;
@end
