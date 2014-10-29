//
//  DynamicsViewController.h
//  learn
//
//  Created by xgj on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "KKBBaseViewController.h"

#import "CourseInFavorCell.h"
#import "GuideCourseCardCell.h"

@interface DynamicsViewController
    : KKBBaseViewController <UITableViewDataSource, UITableViewDelegate,
                             UIScrollViewDelegate,
                             EGORefreshTableHeaderDelegate,
                             GuideCourseCardCellDelegate, UIAlertViewDelegate> {

    UIView *topFloatView;
    NSMutableArray *dynamicCoursesArray;

    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL reloading;
}

@property(nonatomic, retain) IBOutlet UITableView *dynamicsTableView;

@end
