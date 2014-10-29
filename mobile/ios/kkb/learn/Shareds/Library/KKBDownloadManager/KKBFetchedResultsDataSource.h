//
//  KKBFetchedResultsDataSource.h
//  VideoDownload
//
//  Created by zengmiao on 9/2/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RATreeView.h>
#import "SLExpandableTableView.h"
@class KKBDownloadVideo;

@protocol KKBFetchedResultsDataDelegate <NSObject>

@required
- (BOOL)canEditRowForItem:(id)item;
- (void)configureSectionLevelCell:(UITableViewCell *)cell item:(id)aitem;
- (void)configureTwoLevelCell:(UITableViewCell *)cell item:(id)aitem;
- (void)numberOfSectionInDataSource:(NSUInteger)count;

@optional

- (void)dataSourcesChangedDeleteItem;
- (void)dataSourcesDidChanged;

@end

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface KKBFetchedResultsDataSource
    : NSObject <SLExpandableTableViewDatasource>

@property(nonatomic, assign) id<KKBFetchedResultsDataDelegate> delegate;
@property(nonatomic, copy) NSString *sectionIdentifier;
@property(nonatomic, copy) NSString *twoLevelIdentifier;

- (id)initWithClassID:(NSNumber *)classID
              treeView:(SLExpandableTableView *)tableView
    expandableSections:(NSMutableIndexSet *)expandableSections
              delegate:(id<KKBFetchedResultsDataDelegate>)delegate;

- (NSArray *)allSectionModels;
- (NSArray *)allDownloadVideos;
- (NSArray *)modelsInSection:(NSUInteger)section;

- (id)itemOfIndex:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathOfItem:(KKBDownloadVideo *)item;

- (void)removeDelegate;
- (void)addDelegate;

@end
