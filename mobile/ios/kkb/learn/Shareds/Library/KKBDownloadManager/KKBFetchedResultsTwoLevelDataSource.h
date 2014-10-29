//
//  KKBFetchedResultsTwoLevelDataSource.h
//  learn
//
//  Created by zengmiao on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RATreeView.h"
@class KKBDownloadVideoModel;

@protocol KKBTwoLevelFetchedResultDataSourceDelegate <NSObject>

@optional
- (void)configureSectionLevelCell:(UITableViewCell *)cell item:(id)aitem;
- (void)configureTwoLevelCell:(UITableViewCell *)cell item:(id)aitem;
- (void)videoItemStatusChanged:(KKBDownloadVideoModel *)mode;

@end

@interface KKBFetchedResultsTwoLevelDataSource:NSObject<RATreeViewDataSource>

#pragma mark - Property
@property(nonatomic, copy) NSString *sectionIdentifier;
@property(nonatomic, copy) NSString *twoLevelIdentifier;

@property(nonatomic, weak)
    id<KKBTwoLevelFetchedResultDataSourceDelegate> delegate;

- (instancetype)initWithClassID:(NSNumber *)classID
                       treeView:(RATreeView *)treeView
                          items:(NSArray *)items;

- (void)removeDelegate;
- (void)addDelegate;

@end
