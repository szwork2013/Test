//
//  CoursesViewController.h
//  learn
//
//  Created by xgj on 14-7-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "KKBBaseViewController.h"
#import "KKBLoadingFailedView.h"

@interface CoursesViewController : KKBBaseViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>{
    NSArray *kkbAllCourses;// 从网络上请求下来的KKB所有课程
    NSArray *allCourses;// 从网络上请求下来的所有课程(某个Category下的所有课程)
    NSMutableArray *courses;// 加载至表中的课程
    int coursesTotalCount;
    
    KKBLoadingFailedView *loadingFailedView;
}

@property (nonatomic, assign) NSUInteger categoryId;
@property (nonatomic, strong) NSString *categoryName;

@property (nonatomic, retain) IBOutlet PullTableView *courseTableView;

- (IBAction) backButtonDidPress:(id)sender;

@end
