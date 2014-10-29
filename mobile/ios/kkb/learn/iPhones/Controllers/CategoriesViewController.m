//
//  CategoriesViewController.m
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CategoriesViewController.h"
#import "KKBSearchView.h"
#import "FMDatabase.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

#pragma mark - Custom Methods

#pragma mark - Life Cycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    [db close];
    db = nil;
}

@end
