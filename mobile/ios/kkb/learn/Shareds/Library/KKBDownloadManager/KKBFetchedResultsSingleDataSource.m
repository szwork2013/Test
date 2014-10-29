//
//  KKBFetchedResultsSingleDataSource.m
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBFetchedResultsSingleDataSource.h"
#import "KKBDownloadHeader.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface KKBFetchedResultsSingleDataSource () <
    NSFetchedResultsControllerDelegate>

@property(nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property(strong, nonatomic)
    NSFetchedResultsController *fetchedResultsController;

@property(weak, nonatomic) UITableView *tableView;
@property(nonatomic, copy) NSString *cellIdentifier;

@property(nonatomic, copy) NSNumber *classID; //查询id

@end

@implementation KKBFetchedResultsSingleDataSource

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithClassID:(NSNumber *)classID
                 items:(NSArray *)items
             tableView:(UITableView *)tableView
        cellIdentifier:(NSString *)aCellIdentifier
    configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {

    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.classID = classID;
        self.items = items;
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];

        [self customInit];
    }
    return self;
}

- (void)customInit {

    [self reloadFetchedResults:nil];

    // TODO: byzm
    // observe the storage telling us when it's finished asynchronously setting
    // up
    // the persistent store
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(reloadFetchedResults:)
               name:@"RefetchAllDatabaseData"
             object:[[UIApplication sharedApplication] delegate]];
}

- (void)reloadFetchedResults:(NSNotification *)note {

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {

        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        //		abort();
    }

    if (note) {
        [self.tableView reloadData];
    }

    // refresh videoItems status
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {

        for (KKBDownloadVideo *item in self.fetchedResultsController
                 .fetchedObjects) {
            [self refreshVideoModel:item];
        }
    } else {
        //已经全部删除了此课程的下载或此课程还没下载
        for (int i = 0; i < [self.items count]; i++) {
            KKBDownloadVideoModel *model = self.items[i];
            model.status = videoUnknown;
            model.downloadPath = nil;
            model.isSelected = NO;
        }
    }
}

#pragma mark - method

- (void)removeDelegate {
    self.fetchedResultsController.delegate = nil;
}

- (void)addDelegate {
    self.fetchedResultsController.delegate = self;
    [self reloadFetchedResults:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {

        NSPredicate *predicate = [NSPredicate
            predicateWithFormat:@"whichClass.classID=%@", self.classID];
        _fetchedResultsController =
            [KKBDownloadVideo MR_fetchAllSortedBy:@"videoID"
                                        ascending:YES
                                    withPredicate:predicate
                                          groupBy:nil
                                         delegate:self];
    }

    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

/**
 Delegate methods of NSFetchedResultsController to respond to additions,
 removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so
    // prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {

    //    UITableView *tableView = self.tableView;

    switch (type) {
    case NSFetchedResultsChangeInsert:
        //新添加了任务到下载
        // TODO: byzm 考虑是否要刷新cell？
        DDLogDebug(@"addNew download task");
        [self refreshVideoModel:anObject];

        /*
    if (self.configureCellBlock) {
        [self refreshVideoModel:anObject];
        KKBDownloadVideoModel *videoModel = self.items[newIndexPath.row];
        UITableViewCell *cell =
            [tableView cellForRowAtIndexPath:newIndexPath];
        self.configureCellBlock(cell, videoModel);
    }
         */

        break;

    case NSFetchedResultsChangeDelete: {
        //从任务管理器中移除了某个任务
        // TODO: byzm 考虑是否要刷新cell？
        DDLogDebug(@"delete download task");
        id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item];
        /*
    if (self.configureCellBlock) {
        id item =
            [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item];
        KKBDownloadVideoModel *videoModel = self.items[indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.configureCellBlock(cell, videoModel);
    }
         */
    } break;

    case NSFetchedResultsChangeUpdate: {

        id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item];
        /*
    if (self.configureCellBlock) {
        id item =
            [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item];
        KKBDownloadVideoModel *videoModel = self.items[indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.configureCellBlock(cell, videoModel);
    }
         */
    } break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {

    switch (type) {
    case NSFetchedResultsChangeInsert:
        DDLogDebug(@"err! addNewSection download task");

        break;

    case NSFetchedResultsChangeDelete:
        DDLogDebug(@"err! addNewSection download task");
        break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];

    // TODO: byzm 强制刷新所有数据
    [self.tableView reloadData];
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
    /*
  NSInteger numberOfRows = 0;

  if ([[self.fetchedResultsController sections] count] > 0) {
    id<NSFetchedResultsSectionInfo> sectionInfo =
        [self.fetchedResultsController sections][section];
    numberOfRows = [sectionInfo numberOfObjects];
  }

  return numberOfRows;
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                        forIndexPath:indexPath];

    if (self.configureCellBlock) {
        KKBDownloadVideoModel *videoModel = self.items[indexPath.row];
        self.configureCellBlock(cell, videoModel);
    }
    return cell;
}

- (void)refreshVideoModel:(KKBDownloadVideo *)model {
    NSAssert(model != nil, @"refreshVideoModel = nil");

    for (int i = 0; i < [self.items count]; i++) {
        KKBDownloadVideoModel *videoModel = self.items[i];
        if ([videoModel.videoID integerValue] == [model.videoID integerValue]) {
            videoModel.status = [model customDownloadStatus];
            videoModel.downloadPath = model.downloadPath;
            break;
        }
    }
}

@end
