//
//  DownloadManagerViewController.h
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RATreeView.h"
#import "PlayerFrameView.h"
#import "KKBVerticalLine.h"
#import "DownloadDelegate.h"
@interface DownloadManagerViewController : UIViewController<RATreeViewDataSource, RATreeViewDelegate,DownloadDelegate>{
    NSArray *_allCourseIdsAndNames;// 包含所有课程的ID和名称，每个课程的Id和名称存储在一个NSDictionary中
    BOOL isEditActivated;
    BOOL isAllItemsSelected;
    BOOL shouldExpanded;
    int selectedItemsCount;
    PlayerFrameView *playerFrameView;
    
    UIButton *pauseAllButton;
    UIButton *resumeAllButton;
    UIButton *selectAllItemsButton;
    UIButton *removeItemsButton;
    int loadTime;
    KKBVerticalLine *line;
}

@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnEditOrDone;
@property (retain, nonatomic) IBOutlet UIButton *btnLeftBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnRightBottom;
@property (retain, nonatomic) RATreeView *tableView;
@property (strong, nonatomic) id expanded;
@property (strong, nonatomic) NSMutableArray *downloadCourses;

@end
