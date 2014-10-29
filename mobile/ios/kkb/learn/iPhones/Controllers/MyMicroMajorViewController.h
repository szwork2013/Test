//
//  MyMicroMajorViewController.h
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMicroMajorHeadView.h"
#import "KKBBaseViewController.h"

@interface MyMicroMajorViewController
    : KKBBaseViewController <UITableViewDataSource, UITableViewDelegate,
                             HeadViewDelegate> {
    NSMutableArray *myMicroMajorArray;
    MyMicroMajorHeadView *headView;
}
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) UITableViewCell *lastCell;

@end
