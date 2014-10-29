//
//  MyCollectionViewController.h
//  learn
//
//  Created by zxj on 14-7-28.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"

@interface MyCollectionViewController
    : KKBBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    BOOL isPublicClass;
    BOOL isGuideClass;
    NSMutableArray *allCourseArray;
    NSMutableArray *publicArray;
    NSMutableArray *guideArray;
}

@property(weak, nonatomic) IBOutlet UISegmentedControl *segmentCtr;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)segmentAction:(UISegmentedControl *)sender;

@end
