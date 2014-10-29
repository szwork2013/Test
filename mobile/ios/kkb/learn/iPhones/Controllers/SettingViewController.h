//
//  SettingViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-18.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBActivityIndicatorView.h"
#import "KKBBaseViewController.h"

@interface SettingViewController
    : KKBBaseViewController <UINavigationControllerDelegate> {
    KKBActivityIndicatorView *_loadingView;
    NSMutableArray *dataSource;
}

@property(retain, nonatomic) IBOutlet UILabel *appVersion;
@property(nonatomic, retain) IBOutlet UITableView *settingsTableView;

@end
