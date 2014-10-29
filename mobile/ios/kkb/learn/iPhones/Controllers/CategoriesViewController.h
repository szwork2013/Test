//
//  CategoriesViewController.h
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBSearchView.h"
#import "FMDB.h"

@interface CategoriesViewController : UIViewController <KKBSearchDelegate> {
    FMDatabase *db;
    NSArray *searchRecords;
}

@property(nonatomic, retain) KKBSearchView *searchBarView;

@end
