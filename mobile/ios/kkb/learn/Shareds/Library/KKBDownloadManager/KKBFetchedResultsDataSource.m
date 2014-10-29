//
//  KKBFetchedResultsDataSource.m
//  VideoDownload
//
//  Created by zengmiao on 9/2/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBFetchedResultsDataSource.h"
#import "KKBDownloadModelFactory.h"
#import "KKBDownloadManager.h"

#import "KKBDownloadControlCell.h"
#import "KKBDownloadControlSectionCell.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface KKBFetchedResultsDataSource () <NSFetchedResultsControllerDelegate>

@property(nonatomic, copy) TableViewCellConfigureBlock configureCellBlock;
@property(strong, nonatomic)
    NSFetchedResultsController *fetchedResultsController;

@property(strong, nonatomic) SLExpandableTableView *tableView;
@property(nonatomic, strong) NSMutableIndexSet *expandableSections;

@property(nonatomic, copy) NSNumber *classID; //查询id

@property(strong, nonatomic) NSMutableArray *cacheSections; //

@property(nonatomic, assign) NSFetchedResultsChangeType fethedResultsChangeType;

@end

@implementation KKBFetchedResultsDataSource

#pragma mark Fetched results controller

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithClassID:(NSNumber *)classID
              treeView:(SLExpandableTableView *)tableView
    expandableSections:(NSMutableIndexSet *)expandableSections
              delegate:(id<KKBFetchedResultsDataDelegate>)delegate {
    self = [super init];
    if (self) {
        [self customInit];
        self.tableView = tableView;
        self.classID = classID;
        self.delegate = delegate;
        self.expandableSections = expandableSections;
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

        [self.tableView reloadDataAndResetExpansionStates:NO];
    }

    // cache section
    for (id<NSFetchedResultsSectionInfo> sectionInfo in
         [self.fetchedResultsController sections]) {
        KKBDownloadVideo *videoItemModel = [sectionInfo.objects firstObject];
        KKBDownloadClass *classItem = videoItemModel.whichClass;
        [self.cacheSections addObject:classItem];
    }
}

#pragma mark - Property
- (NSMutableArray *)cacheSections {
    if (!_cacheSections) {
        _cacheSections = [[NSMutableArray alloc]
            initWithCapacity:[[_fetchedResultsController sections] count]];
    }
    return _cacheSections;
}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {

        /*
         Set up the fetched results controller.
         */
        NSManagedObjectContext *context =
            [NSManagedObjectContext MR_defaultContext];

        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity =
            [NSEntityDescription entityForName:@"KKBDownloadVideo"
                        inManagedObjectContext:context];
        [fetchRequest setEntity:entity];

        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:50];

        NSSortDescriptor *sortClassIDDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"whichClass.classID"
                                        ascending:YES];
        NSSortDescriptor *positionDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSSortDescriptor *sortVideoIDDescriptor =
            [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];

        [fetchRequest setSortDescriptors:@[
                                            sortClassIDDescriptor,
                                            positionDescriptor,
                                            sortVideoIDDescriptor
                                         ]];

        _fetchedResultsController = [[NSFetchedResultsController alloc]
            initWithFetchRequest:fetchRequest
            managedObjectContext:context
              sectionNameKeyPath:@"whichClass.classID"
                       cacheName:nil];
        _fetchedResultsController.delegate = self;
    }

    return _fetchedResultsController;
}

- (NSArray *)allSectionModels {
    NSUInteger sections = [[self.fetchedResultsController sections] count];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:sections];
    for (int i = 0; i < sections; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        KKBDownloadVideo *videoItem =
            [self.fetchedResultsController objectAtIndexPath:indexPath];
        [array addObject:videoItem.whichClass];
    }
    return array;
}

- (id)itemOfIndex:(NSIndexPath *)indexPath {
    id itemModel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return itemModel;
}

- (NSIndexPath *)indexPathOfItem:(KKBDownloadVideo *)item {
    return [self.fetchedResultsController indexPathForObject:item];
}

- (NSArray *)allDownloadVideos {
    return self.fetchedResultsController.fetchedObjects;
}

- (NSArray *)modelsInSection:(NSUInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo =
        [self.fetchedResultsController sections][section];
    return sectionInfo.objects;
}

- (void)removeDelegate {
    self.fetchedResultsController.delegate = nil;
}

- (void)addDelegate {
    self.fetchedResultsController.delegate = self;
    [self reloadFetchedResults:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate
/**
 Delegate methods of NSFetchedResultsController to respond to additions,
 removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (controller != self.fetchedResultsController) {
        return;
    }

    // The fetch controller is about to start sending change notifications, so
    // prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {

    self.fethedResultsChangeType = type;

    if (controller != self.fetchedResultsController) {
        return;
    }
    //    NSLog(@"indexPath:section:%d,row:%d**newIndexPath:section:%d,row:%d",
    //          indexPath.section, indexPath.row, newIndexPath.section,
    //          newIndexPath.row);

    UITableView *tableView = self.tableView;

    NSIndexPath *newConvertIndexPath =
        [NSIndexPath indexPathForRow:newIndexPath.row + 1
                           inSection:newIndexPath.section];
    NSIndexPath *convertIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row + 1
                           inSection:indexPath.section];

    switch (type) {
    case NSFetchedResultsChangeInsert:
        if ([self.tableView isSectionExpanded:convertIndexPath.section]) {
            [tableView insertRowsAtIndexPaths:@[ newConvertIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
        }

        break;

    case NSFetchedResultsChangeDelete: {
        if ([self.delegate
                respondsToSelector:@selector(dataSourcesChangedDeleteItem)]) {
            [self.delegate dataSourcesChangedDeleteItem];
        }

        //需要判断当前cell是否展开了 否则会造成崩溃
        if ([self.tableView isSectionExpanded:convertIndexPath.section]) {
            [tableView deleteRowsAtIndexPaths:@[ convertIndexPath ]
                             withRowAnimation:UITableViewRowAnimationFade];
        } else {
        }

    } break;

    case NSFetchedResultsChangeUpdate: {
        //需要判断当前cell是否展开了
        NSIndexPath *itemIndexPath =
            [self.fetchedResultsController indexPathForObject:anObject];

        NSIndexPath *convert =
            [NSIndexPath indexPathForRow:itemIndexPath.row + 1
                               inSection:itemIndexPath.section];

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:convert];

        if ([self.tableView.visibleCells containsObject:cell]) {
            [self.delegate
                configureTwoLevelCell:[tableView cellForRowAtIndexPath:convert]
                                 item:anObject];
        }

    } break;
    case NSFetchedResultsChangeMove:
        break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
             atIndex:(NSUInteger)sectionIndex
       forChangeType:(NSFetchedResultsChangeType)type {

    if (controller != self.fetchedResultsController) {
        return;
    }

    self.fethedResultsChangeType = type;

    switch (type) {
    case NSFetchedResultsChangeInsert:
        [self.tableView
              insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
            withRowAnimation:UITableViewRowAnimationFade];
        break;

    case NSFetchedResultsChangeDelete:
        [self.tableView
              deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
            withRowAnimation:UITableViewRowAnimationFade];
        break;
    case NSFetchedResultsChangeUpdate:
        [self.tableView
              reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
            withRowAnimation:UITableViewRowAnimationFade];
        break;

    case NSFetchedResultsChangeMove:
        break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell
    // the table view to process all updates.
    if (controller != self.fetchedResultsController) {
        return;
    }

    [self.tableView endUpdates];

    if ([self.delegate respondsToSelector:@selector(dataSourcesDidChanged)]) {
        [self.delegate dataSourcesDidChanged];
    }
}

#pragma mark - SLExpandableTableViewDatasource
- (BOOL)tableView:(SLExpandableTableView *)tableView
    canExpandSection:(NSInteger)section {
    return YES;
}

- (BOOL)tableView:(SLExpandableTableView *)tableView
    needsToDownloadDataForExpandableSection:(NSInteger)section {
    return ![self.expandableSections containsIndex:section];
}

- (UITableViewCell<UIExpandingTableViewCell> *)
                  tableView:(SLExpandableTableView *)tableView
    expandingCellForSection:(NSInteger)section {
    UITableViewCell<UIExpandingTableViewCell> *cell = [self.tableView
        dequeueReusableCellWithIdentifier:self.sectionIdentifier];

    if ([self.delegate
            respondsToSelector:@selector(configureSectionLevelCell:item:)]) {
        NSArray *sectionModels = [self allSectionModels];
        id sectionModel = sectionModels[section];
        [self.delegate configureSectionLevelCell:cell item:sectionModel];
    }
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    NSInteger count = [[self.fetchedResultsController sections] count];
    if ([self.delegate
            respondsToSelector:@selector(numberOfSectionInDataSource:)]) {
        [self.delegate numberOfSectionInDataSource:count];
    }

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;

    if ([[self.fetchedResultsController sections] count] > 0) {
        id<NSFetchedResultsSectionInfo> sectionInfo =
            [self.fetchedResultsController sections][section];
        numberOfRows = [sectionInfo numberOfObjects] + 1;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:self.twoLevelIdentifier];

    NSIndexPath *convertIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row - 1
                           inSection:indexPath.section];
    id itemModel =
        [self.fetchedResultsController objectAtIndexPath:convertIndexPath];
    [self.delegate configureTwoLevelCell:cell item:itemModel];

    return cell;
}

// editing
- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // section
        return NO;
    } else {
        // row
        if ([self.delegate respondsToSelector:@selector(canEditRowForItem:)]) {

            NSIndexPath *convertIndexPath =
                [NSIndexPath indexPathForRow:indexPath.row - 1
                                   inSection:indexPath.section];
            id itemModel = [self.fetchedResultsController
                objectAtIndexPath:convertIndexPath];

            return [self.delegate canEditRowForItem:itemModel];
        }
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSIndexPath *convertIndexPath =
            [NSIndexPath indexPathForRow:indexPath.row - 1
                               inSection:indexPath.section];

        KKBDownloadVideo *managedObject =
            [self.fetchedResultsController objectAtIndexPath:convertIndexPath];
        KKBDownloadVideoModel *videoModel =
            [KKBDownloadModelFactory convertToBridgeVideoModel:managedObject];
        [KKBDownloadManager deleteDownloadWithItems:@[ videoModel ]];
    }
}

@end
