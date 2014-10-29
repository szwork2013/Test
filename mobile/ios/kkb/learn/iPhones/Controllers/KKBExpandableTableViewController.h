//
//  KKBExpandableTableViewController.h
//  learn
//
//  Created by zengmiao on 9/15/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@interface KKBExpandableTableViewController
    : UIViewController <SLExpandableTableViewDelegate>

@property(strong, nonatomic) SLExpandableTableView *tableView;
@property(nonatomic, strong) NSMutableIndexSet *expandableSections; 

 @end
