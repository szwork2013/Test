//
//  KKBDownloadTwolevelController.m
//  learn
//
//  Created by zengmiao on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBDownloadTwolevelController.h"
#import "KKBDownloadDeleteBtn.h"
#import "RATreeView.h"
#import "KKBDownloadManager.h"

#import "KKBDownloadControlSectionCell.h"
#import "KKBDownloadStatusCell.h"
#import "KKBFetchedResultsTwoLevelDataSource.h"
#import "KKBDownloadTreeViewModel.h"

@interface KKBDownloadTwolevelController () <
    RATreeViewDelegate, KKBTwoLevelFetchedResultDataSourceDelegate,
    KKBDownloadControlSectionCellDelegate>

@property(weak, nonatomic) IBOutlet UIView *topVIew;
@property(weak, nonatomic) IBOutlet UIView *bottomView;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *selectedBtn;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *downloadBtn;

@property(strong, nonatomic) RATreeView *treeView;

@property(strong, nonatomic) KKBFetchedResultsTwoLevelDataSource *dataSource;

@property(strong, nonatomic) NSMutableArray *selectedVideos; //添加video时的容器
@property(strong, nonatomic)
    NSMutableDictionary *cacheSectionAllowNums; // section下可以选取的数量
@end

@implementation KKBDownloadTwolevelController

- (void)dealloc {
}

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
    // Do any additional setup after loading the view from its nib.

    self.view.layer.cornerRadius = bottomPopViewCornerRadius;
    self.view.layer.masksToBounds = YES;

    self.treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
    self.treeView.delegate = self;
    self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    [self.view insertSubview:self.treeView atIndex:0];

    [self.treeView registerNib:[KKBDownloadStatusCell cellNib]
        forCellReuseIdentifier:KKBDOWNLOADSTATUSCELL_CELL_REUSEDID];
    [self.treeView registerNib:[KKBDownloadControlSectionCell cellNib]
        forCellReuseIdentifier:KKBDOWNLOADCONTROL_SECTION_CELL_REUSEDID];

    self.dataSource = [[KKBFetchedResultsTwoLevelDataSource alloc]
        initWithClassID:self.classModel.classID
               treeView:self.treeView
                  items:self.videoItems];
    self.dataSource.sectionIdentifier =
        KKBDOWNLOADCONTROL_SECTION_CELL_REUSEDID;
    self.dataSource.twoLevelIdentifier = KKBDOWNLOADSTATUSCELL_CELL_REUSEDID;
    self.dataSource.delegate = self;

    self.treeView.dataSource = self.dataSource;

    //设置底部按钮状态
    self.selectedBtn.counter = 0;
    self.selectedBtn.maxCount = [self allowAddToDownloadNums];
    self.downloadBtn.selectedDownloadCount = 0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.treeView.top = self.topVIew.height;
    self.treeView.height =
        self.view.size.height - addPageBottomViewHeight - addPageTopViewHeight;
    self.bottomView.top = self.treeView.bottom;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.dataSource addDelegate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.dataSource removeDelegate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // expand the all section cell
    for (KKBDownloadTreeViewModel *model in self.videoItems) {
        [self.treeView expandRowForItem:model
                       withRowAnimation:RATreeViewRowAnimationNone];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshBottomUI {
    NSUInteger selectedCount = 0;
    for (NSArray *arr in self.selectedVideos) {
        selectedCount += [arr count];
    }
    self.selectedBtn.counter = selectedCount;
    self.downloadBtn.selectedDownloadCount = selectedCount;
}

- (NSUInteger)allowAddToDownloadNums {
    NSUInteger max = 0;

    for (KKBDownloadTreeViewModel *sectionModel in self.videoItems) {
        NSUInteger tmpCount = 0;
        for (KKBDownloadVideoModel *videoModel in sectionModel.childrens) {
            if ([self allowAddToDowndsWithModel:videoModel]) {
                tmpCount++;
                max++;
            }
        }
        [self.cacheSectionAllowNums setObject:@(tmpCount)
                                       forKey:sectionModel.sectionName];
    }
    return max;
}

#pragma mark - Property
- (NSMutableArray *)selectedVideos {
    if (!_selectedVideos) {
        _selectedVideos =
            [[NSMutableArray alloc] initWithCapacity:[_videoItems count]];

        //构造数据结构
        for (KKBDownloadTreeViewModel *model in _videoItems) {
            NSMutableArray *rowArray = [[NSMutableArray alloc]
                initWithCapacity:[model.childrens count]];
            [_selectedVideos addObject:rowArray];
        }
    }
    return _selectedVideos;
}

- (NSMutableDictionary *)cacheSectionAllowNums {
    if (!_cacheSectionAllowNums) {
        _cacheSectionAllowNums =
            [[NSMutableDictionary alloc] initWithCapacity:[_videoItems count]];
    }
    return _cacheSectionAllowNums;
}

#pragma mark - KKBTwoLevelFetchedResultDataSourceDelegate
- (void)configureSectionLevelCell:(KKBDownloadControlSectionCell *)cell
                             item:(KKBDownloadTreeViewModel *)aitem {
    cell.sectionTitleLabel.text = aitem.sectionName;
    cell.isEditting = YES;
    cell.delegate = self;

    // is selected?
    NSInteger index = [self.videoItems indexOfObject:aitem];
    NSMutableArray *selectedRows = self.selectedVideos[index];

    NSNumber *allowSelected = self.cacheSectionAllowNums[aitem.sectionName];
    if ([allowSelected integerValue] == [selectedRows count]) {
        cell.isSelected = YES;
    } else {
        cell.isSelected = NO;
    }
}

- (void)configureTwoLevelCell:(KKBDownloadStatusCell *)cell
                         item:(KKBDownloadVideoModel *)aitem {
    cell.model = aitem;
}

- (void)videoItemStatusChanged:(KKBDownloadVideoModel *)mode {
    if (mode.status == videoDownloadError) {
        //下载错误 update allow Selected Section of cahche
        self.selectedBtn.maxCount = [self allowAddToDownloadNums];
    }
}

#pragma mark - btnMethod
- (IBAction)downloadBtnTapped:(KKBDownloadDeleteBtn *)sender {
    /*
    NSArray *arrs = [KKBDownloadClass MR_findAll];
    for (KKBDownloadClass *classModel in arrs) {
        for (KKBDownloadVideo *video in classModel.videos) {
            NSLog(@"name:%@ className:%@",video.videoTitle,classModel.name);
            
        }
        NSLog(@"==================");
    }
     */
    
    if ([self.selectedVideos count]) {
        NSMutableArray *tasks = [[NSMutableArray alloc]
            initWithCapacity:[self.selectedVideos count]];

        for (NSArray *rows in self.selectedVideos) {
            for (KKBDownloadVideoModel *videItem in rows) {
                KKBDownloadTaskModel *taskModel =
                    [[KKBDownloadTaskModel alloc] init];
                taskModel.classModel = self.classModel;
                taskModel.videoModel = videItem;
                [tasks addObject:taskModel];
                self.successView.successMessage.text = @"已加入下载列表";
                self.successView .top =50;
                [self.view bringSubviewToFront:self.successView];
                [self popSuccessView];

            }
        }

        if ([tasks count]) {
            [KKBDownloadManager startDownloadWithItems:tasks];
        }
    }

    // clear selected Datas
    for (NSMutableArray *arr in self.selectedVideos) {
        [arr removeAllObjects];
    }
    [self refreshBottomUI];
}

- (IBAction)selectedBtnTapped:(KKBDownloadDeleteBtn *)sender {
    if ([sender allowSelected]) {
        //全选
        for (int i = 0; i < [self.videoItems count]; i++) {
            KKBDownloadTreeViewModel *sectionModel = self.videoItems[i];
            NSMutableArray *rowsArr = self.selectedVideos[i];
            for (KKBDownloadVideoModel *videoModel in sectionModel.childrens) {
                if ([self allowAddToDowndsWithModel:videoModel]) {
                    if (![rowsArr containsObject:videoModel]) {
                        [rowsArr addObject:videoModel];
                    }
                    videoModel.isSelected = YES;
                }
            }
        }

    } else {
        //全部取消
        for (NSMutableArray *arr in self.selectedVideos) {
            for (KKBDownloadVideoModel *model in arr) {
                model.isSelected = NO;
            }
            [arr removeAllObjects];
        }
    }

    [self.treeView reloadRows];
    [self refreshBottomUI];
}

- (IBAction)goToDownloadControlTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(downloadControlTapped:)]) {
        [self.delegate downloadControlTapped:self];
    }
}

#pragma mark - KKBDownloadControlSectionCellDelegate
- (void)sectionBtnTapped:(UITableViewCell *)cell {
    id item = [self.treeView itemForCell:cell];

    [self treeView:self.treeView didSelectRowForItem:item];
}

#pragma mark - RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    NSUInteger level = [self.treeView levelForCellForItem:item];
    if (level) {
        // row
        return gDownloadStatusCell + 1;
    }
    // section
    return gDownloadSectionCell + 1;
}

- (CGFloat)treeView:(RATreeView *)treeView
    estimatedHeightForRowForItem:(id)item {
    return gDownloadSectionCell;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {

    NSInteger level = [self.treeView levelForCellForItem:item];
    if (level) {
        // row
        KKBDownloadVideoModel *rowModel = item;
        if ([self allowAddToDowndsWithModel:rowModel]) {

            KKBDownloadTreeViewModel *sectionModel =
                [self.treeView parentForItem:item];

            NSUInteger index = [self.videoItems indexOfObject:sectionModel];
            NSMutableArray *rowArray = self.selectedVideos[index];

            if (rowModel.isSelected) {
                rowModel.isSelected = NO;
                [rowArray removeObject:rowModel];
            } else {
                rowModel.isSelected = YES;
                [rowArray addObject:rowModel];
            }

            // refresh ui
            [self.treeView reloadRowsForItems:@[ rowModel, sectionModel ]
                             withRowAnimation:RATreeViewRowAnimationNone];
            [self refreshBottomUI];
        }

    } else {
        // section
        KKBDownloadTreeViewModel *sectionModel = item;

        NSUInteger index = [self.videoItems indexOfObject:sectionModel];
        NSMutableArray *rowArray = self.selectedVideos[index];

        NSNumber *sectionAllowSelectedCount =
            self.cacheSectionAllowNums[sectionModel.sectionName];
        if ([sectionAllowSelectedCount integerValue] == [rowArray count]) {
            // cancel all row of childrens
            for (KKBDownloadVideoModel *rowModel in rowArray) {
                // cancel flag
                if ([self allowAddToDowndsWithModel:rowModel]) {
                    rowModel.isSelected = NO;
                }
            }
            [rowArray removeAllObjects];

        } else {

            for (KKBDownloadVideoModel *rowModel in sectionModel.childrens) {
                if ([self allowAddToDowndsWithModel:rowModel]) {
                    // selected flag
                    rowModel.isSelected = YES;
                    if (![rowArray containsObject:rowModel]) {
                        [rowArray addObject:rowModel];
                    }
                }
            }
        }

        // refresh ui
        [self.treeView reloadRows];
        [self refreshBottomUI];
    }
}

- (BOOL)treeView:(RATreeView *)treeView shouldCollapaseRowForItem:(id)item {
    return NO;
}

- (BOOL)allowAddToDowndsWithModel:(KKBDownloadVideoModel *)model {
    if (model.status == videoUnknown || model.status == videoDownloadError) {
        return YES;
    }
    return NO;
}
-(void)networkStatusDidChange{
    
}
@end
