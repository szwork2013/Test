//
//  MeViewController.h
//  learn
//
//  Created by zxj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property(strong, nonatomic) IBOutlet UILabel *profileNameLabel;

@end
