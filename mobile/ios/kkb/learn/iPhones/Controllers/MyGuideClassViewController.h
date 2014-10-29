//
//  MyGuideClassViewController.h
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"

@interface MyGuideClassViewController
    : KKBBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *myGuideClassArray;
    NSMutableArray *isProgressingArray;
    NSMutableArray *doneArray;
    NSMutableArray *willArray;
    BOOL isProgressing;
    BOOL done;
    BOOL will;
}

@property(strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentAction:(UISegmentedControl *)sender;

@end
