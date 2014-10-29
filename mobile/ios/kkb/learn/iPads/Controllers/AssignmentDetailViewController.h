//
//  AssignmentDetailViewController.h
//  learn
//
//  Created by User on 14-1-3.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssignmentItem;

@interface AssignmentDetailViewController : UIViewController


@property (nonatomic, retain) IBOutlet UIWebView *assWebView;
@property (nonatomic, retain) NSMutableArray *assArr;
@property (nonatomic, retain) AssignmentItem *assignmentItem;
@property (nonatomic, retain) IBOutlet UILabel *titleLable;
@property (nonatomic, retain) IBOutlet UILabel *timeLable;
@property (nonatomic, retain) IBOutlet UILabel *pointsLabel;
@property NSInteger selectIndex;
@property (nonatomic, retain) IBOutlet UIButton *btnNext;
@property (nonatomic, retain) IBOutlet UIButton *btnLast;


@end
