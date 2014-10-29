//
//  KKBFetchedResultsTwoLevelDataSource.m
//  learn
//
//  Created by zengmiao on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBFetchedResultsTwoLevelDataSource.h"
#import "KKBDownloadVideoModel.h"
#import "KKBDownloadTreeViewModel.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface KKBFetchedResultsTwoLevelDataSource () <
    NSFetchedResultsControllerDelegate>

@property(strong, nonatomic)
    NSFetchedResultsController *fetchedResultsController;
@property(weak, nonatomic) RATreeView *treeView;
@property(nonatomic, copy) NSNumber *classID; //查询id

@property(strong, nonatomic) NSArray *items;

@end

@implementation KKBFetchedResultsTwoLevelDataSource

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithClassID:(NSNumber *)classID
                       treeView:(RATreeView *)treeView
                          items:(NSArray *)items {
    self = [super init];
    if (self) {
        self.treeView = treeView;
        self.classID = classID;
        self.items = items;

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

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //		abort();
    }

    if (note) {
        // reload tableView data
        [self.treeView reloadData];
    }

    // refresh videoItems status
    if ([self.fetchedResultsController.fetchedObjects count] > 0) {

        for (KKBDownloadVideo *item in self.fetchedResultsController
                 .fetchedObjects) {
            [self refreshVideoModel:item];
        }

    } else {
        //已经全部删除了此课程的下载或此课程还没下载
        for (KKBDownloadTreeViewModel *sectionModel in self.items) {
            for (KKBDownloadVideoModel *videoModel in sectionModel.childrens) {
                videoModel.status = videoUnknown;
                videoModel.downloadPath = nil;
                videoModel.isSelected = NO;
            }
        }
    }
}

- (void)removeDelegate {
    self.fetchedResultsController.delegate = nil;
}

- (void)addDelegate {
    self.fetchedResultsController.delegate = self;
    [self reloadFetchedResults:nil];
}

#pragma mark Fetched results controller
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
    [self.treeView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
    case NSFetchedResultsChangeInsert:
        //新添加了任务到下载
        // TODO: byzm 考虑是否要刷新cell？
        DDLogDebug(@"addNew download task");
        [self refreshVideoModel:anObject allowRefreshUI:YES];
        break;

    case NSFetchedResultsChangeDelete: {
        //从任务管理器中移除了某个任务
        // TODO: byzm 考虑是否要刷新cell？
        DDLogDebug(@"delete download task");
        id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item allowRefreshUI:YES];

    } break;

    case NSFetchedResultsChangeUpdate: {

        id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self refreshVideoModel:item allowRefreshUI:YES];
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
    [self.treeView endUpdates];
}

#pragma mark - RATreeViewDataSource
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.items count];
    }

    if ([item isKindOfClass:[KKBDownloadTreeViewModel class]]) {
        KKBDownloadTreeViewModel *sectionModel = item;
        return [sectionModel.childrens count];
    }
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {

    UITableViewCell *cell = nil;
    NSInteger level = [self.treeView levelForCellForItem:item];
    if (!level) {
        // section
        cell =
            [treeView dequeueReusableCellWithIdentifier:self.sectionIdentifier];

        if ([self.delegate
                respondsToSelector:@selector(configureSectionLevelCell:
                                                                  item:)]) {
            [self.delegate configureSectionLevelCell:cell item:item];
        }
    } else {
        // row
        cell = [treeView
            dequeueReusableCellWithIdentifier:self.twoLevelIdentifier];
        if ([self.delegate
                respondsToSelector:@selector(configureTwoLevelCell:item:)]) {
            [self.delegate configureTwoLevelCell:cell item:item];
        }
    }

    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    KKBDownloadTreeViewModel *sectionModel = item;
    if (sectionModel == nil) {
        return self.items[index];
    }

    KKBDownloadTreeViewModel *twoLevelModel = item;
    return twoLevelModel.childrens[index];
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
    return NO;
}

#pragma mark - refresh Model
- (void)refreshVideoModel:(KKBDownloadVideo *)model allowRefreshUI:(BOOL)allow {
    [self refreshVideoModel:model allowRefreshUI:allow allowCallDelegate:NO];
}

- (void)refreshVideoModel:(KKBDownloadVideo *)model {
    [self refreshVideoModel:model allowRefreshUI:NO allowCallDelegate:NO];
}

- (void)refreshVideoModel:(KKBDownloadVideo *)model
           allowRefreshUI:(BOOL)allow
        allowCallDelegate:(BOOL)allowCall {

    NSAssert(model != nil, @"refreshVideoModel = nil");
    for (int i = 0; i < [self.items count]; i++) {
        KKBDownloadTreeViewModel *sectionModel = self.items[i];
        for (KKBDownloadVideoModel *videoItem in sectionModel.childrens) {
            if ([model.videoID longValue] == [videoItem.videoID longValue]) {
                videoItem.status = [model customDownloadStatus];
                videoItem.videoTitle = model.videoTitle;
                videoItem.downloadPath = model.downloadPath;
                if (allow) {
                    [self.treeView
                        reloadRowsForItems:@[ videoItem ]
                          withRowAnimation:RATreeViewRowAnimationNone];
                }
                if (allowCall) {
                    if ([self.delegate
                            respondsToSelector:@selector(
                                                   videoItemStatusChanged:)]) {
                        [self.delegate videoItemStatusChanged:videoItem];
                    }
                }
                break;
            }
        }
    }
}

@end
