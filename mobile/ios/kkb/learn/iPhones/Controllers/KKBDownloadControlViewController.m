//
//  KKBViewController.m
//  VideoDownload
//
//  Created by zengmiao on 8/27/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadControlViewController.h"
#import "KKBDownloadManager.h"
#import "KKBDownloadModelFactory.h"

#import "KKBDownloadDeleteBtn.h"

#import "KKBFetchedResultsDataSource.h"
#import "KKBDownloadControlCell.h"
#import "KKBDownloadControlSectionCell.h"
#import "PlayVideoViewController.h"
#import "KKBUserInfo.h"

static const float bottomViewHeight = 40.0;
static const float noTasksContentViewMarginTop = 80.0f;

@interface KKBDownloadControlViewController () <
    RATreeViewDelegate, KKBDownloadControlCellDelegate,
    KKBFetchedResultsDataDelegate, KKBDownloadControlSectionCellDelegate> {
    UIButton *btn;
}

@property(strong, nonatomic) NSArray *downloadTasks;

@property(strong, nonatomic)
    KKBFetchedResultsDataSource *fetchedResultsDataSource;

@property(nonatomic, assign) BOOL isEditingMode;
@property(nonatomic, assign) BOOL isFirstEnter;

@property(strong, nonatomic)
    NSMutableDictionary *selectedRowsDic; //复选时的容器

#pragma mark - 控制属性
@property(weak, nonatomic) IBOutlet UIView *bottomContentView;
@property(strong, nonatomic) IBOutlet UIView *downloadControlView;
@property(strong, nonatomic) IBOutlet UIView *deleteControlView;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *sureDeleteBtn;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *selectedDeleteBtn;
@property(weak, nonatomic) IBOutlet UIView *noTasksContentView;
@property(weak, nonatomic) IBOutlet UIButton *allPauseBtn;
@property(weak, nonatomic) IBOutlet UIButton *allResumeBtn;

@property(weak, nonatomic) IBOutlet UIButton *pauseAllButton;
@property(weak, nonatomic) IBOutlet UIButton *resumeAllButton;

@end

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@implementation KKBDownloadControlViewController

- (void)dealloc {
    DDLogInfo(@"count in Queue %d", [KKBDownloadManager countInQueue]);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"下载中心";
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];
    [self.tableView setShowsVerticalScrollIndicator:NO];

    self.isFirstEnter = YES;
    self.isEditingMode = NO;

    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView registerNib:[KKBDownloadControlCell cellNib]
         forCellReuseIdentifier:KKBDOWNLOADCONTROL_CELL_REUSEDID];
    [self.tableView registerNib:[KKBDownloadControlSectionCell cellNib]
         forCellReuseIdentifier:KKBDOWNLOADCONTROL_SECTION_CELL_REUSEDID];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.fetchedResultsDataSource = [[KKBFetchedResultsDataSource alloc]
           initWithClassID:nil
                  treeView:self.tableView
        expandableSections:self.expandableSections
                  delegate:self];

    self.fetchedResultsDataSource.sectionIdentifier =
        KKBDOWNLOADCONTROL_SECTION_CELL_REUSEDID;
    self.fetchedResultsDataSource.twoLevelIdentifier =
        KKBDOWNLOADCONTROL_CELL_REUSEDID;
    self.tableView.dataSource = self.fetchedResultsDataSource;

    if (self.fromStudyVC == YES) {
        [KKBUserInfo shareInstance].goToDownloadFromStudyVC = YES;
    } else {
        [KKBUserInfo shareInstance].goToDownloadFromStudyVC = NO;
    }

    [self init2ButtonsAtBottom];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.height =
        CGRectGetHeight(self.view.bounds) - bottomViewHeight;
    self.bottomContentView.top = self.tableView.bottom;
    self.noTasksContentView.top = noTasksContentViewMarginTop;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.fetchedResultsDataSource addDelegate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.classID && self.isFirstEnter) {
        self.isFirstEnter = NO;
        NSPredicate *predicate = [NSPredicate
            predicateWithFormat:@"whichClass.classID = %@", self.classID];
        NSArray *filters = [self.fetchedResultsDataSource.allDownloadVideos
            filteredArrayUsingPredicate:predicate];
        if ([filters count]) {
            KKBDownloadVideo *video = [filters firstObject];
            NSIndexPath *indexPath =
                [self.fetchedResultsDataSource indexPathOfItem:video];
            [self.tableView expandSection:indexPath.section animated:YES];
        }
    }

    // refresh task status
    [self dataSourcesDidChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableView.editing = NO;
    [self.fetchedResultsDataSource removeDelegate];
}

#pragma mark - Property
- (void)setIsEditingMode:(BOOL)isEditingMode {
    _isEditingMode = isEditingMode;
    [self.tableView reloadDataAndResetExpansionStates:NO];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 35);
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];

    if (isEditingMode) {

        self.selectedDeleteBtn.counter = 0;

        self.selectedDeleteBtn.maxCount =
            [[self.fetchedResultsDataSource allDownloadVideos] count];
        self.sureDeleteBtn.selectedDeleteCount = 0;

        [btn setTitle:@"完成" forState:UIControlStateNormal];
        [btn setTitle:@"完成" forState:UIControlStateHighlighted];
        [btn addTarget:self
                      action:@selector(editDoneTapped)
            forControlEvents:UIControlEventTouchUpInside];

        [self.bottomContentView removeAllSubviews];
        [self.bottomContentView addSubview:self.deleteControlView];

    } else {
        [self.selectedRowsDic removeAllObjects];
        self.selectedDeleteBtn.counter = 0;
        self.sureDeleteBtn.selectedDeleteCount = 0;

        [btn setTitle:@"编辑" forState:UIControlStateNormal];
        [btn setTitle:@"编辑" forState:UIControlStateHighlighted];
        [btn addTarget:self
                      action:@selector(editBtnTapped)
            forControlEvents:UIControlEventTouchUpInside];

        [self.bottomContentView removeAllSubviews];
        [self.bottomContentView addSubview:self.downloadControlView];
    }

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (NSMutableDictionary *)selectedRowsDic {
    if (!_selectedRowsDic) {
        _selectedRowsDic = [[NSMutableDictionary alloc] init];
    }
    return _selectedRowsDic;
}

#pragma mark - edit Method

- (void)editBtnTapped {
    self.isEditingMode = YES;
}

- (void)editDoneTapped {
    self.isEditingMode = NO;
}

#pragma mark - Button Methods
- (void)init2ButtonsAtBottom {

    [self.pauseAllButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];

    [self.resumeAllButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];
}

#pragma mark - controlBtn mehtod
/**
 *  全部开始(继续下载，相对于暂停)
 *
 *  @param sender sender description
 */
- (IBAction)allStartDownloadBtnTapped:(UIButton *)sender {

    NSArray *videos = [self.fetchedResultsDataSource allDownloadVideos];
    if (![videos count]) {
        return;
    }

    NSMutableArray *arrays =
        [[NSMutableArray alloc] initWithCapacity:[videos count]];

    for (KKBDownloadVideo *videoItem in videos) {
        if ([videoItem allowResume]) {
            KKBDownloadVideoModel *model =
                [KKBDownloadModelFactory convertToBridgeVideoModel:videoItem];
            [arrays addObject:model];
        }
    }

    if ([arrays count]) {
        [KKBDownloadManager resumeDownloadWithItems:arrays];
    }
}

/**
 *  全部暂停
 *
 *  @param sender sender description
 */
- (IBAction)allPauseBtnTapped:(UIButton *)sender {

    NSArray *videos = [self.fetchedResultsDataSource allDownloadVideos];

    NSMutableArray *arrays =
        [[NSMutableArray alloc] initWithCapacity:[videos count]];

    for (KKBDownloadVideo *videoItem in videos) {
        if ([videoItem allowPause]) {
            KKBDownloadVideoModel *model =
                [KKBDownloadModelFactory convertToBridgeVideoModel:videoItem];
            [arrays addObject:model];
        }
    }

    if ([arrays count]) {
        [KKBDownloadManager pauseDownloadWithItems:arrays];
    }
}

/**
 *  全部选择
 *
 *  @param sender sender description
 */
- (IBAction)allSelectedBtnTapped:(KKBDownloadDeleteBtn *)sender {
    if ([sender allowSelected]) {
        //允许全选
        NSArray *allSections = [self.fetchedResultsDataSource allSectionModels];
        for (KKBDownloadClass *item in allSections) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]
                initWithCapacity:[item.videos count]];
            for (KKBDownloadVideo *videoItem in item.videos) {
                [dic setObject:videoItem
                        forKey:[videoItem.videoID stringValue]];
            }
            NSString *key = [item.classID stringValue];
            self.selectedRowsDic[key] = dic;
        }

    } else {
        //取消全选
        [self.selectedRowsDic removeAllObjects];
    }

    [self refreshSelectedUI];
}

/**
 *  确认删除
 *
 *  @param sender sender description
 */
- (IBAction)sureDeleteBtnTapped:(KKBDownloadDeleteBtn *)sender {

    NSMutableArray *deleteAllTasks = [[NSMutableArray alloc] init];

    NSArray *allSectionKeys = [self.selectedRowsDic allKeys];
    for (int i = 0; i < [allSectionKeys count]; i++) {
        NSMutableDictionary *videoDic = self.selectedRowsDic[allSectionKeys[i]];

        NSArray *allRowKeys = [videoDic allKeys];
        for (int j = 0; j < [allRowKeys count]; j++) {
            KKBDownloadVideo *videoItem = videoDic[allRowKeys[j]];
            KKBDownloadVideoModel *videoModel =
                [KKBDownloadModelFactory convertToBridgeVideoModel:videoItem];
            [deleteAllTasks addObject:videoModel];

            // delete selected item
            [videoDic removeObjectForKey:allRowKeys[j]];
            if ([videoDic allKeys] == 0) {
                // delete Section item
                [self.selectedRowsDic removeObjectForKey:allSectionKeys[i]];
            }
        }
    }

    /*
    [self.selectedRowsDic
        enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSDictionary *videoDic = obj;
            [videoDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj,
                                                          BOOL *stop) {
                KKBDownloadVideoModel *videoModel =
                    [KKBDownloadModelFactory convertToBridgeVideoModel:obj];
                [deleteAllTasks addObject:videoModel];
            }];
        }];
    */

    [KKBDownloadManager deleteDownloadWithItems:deleteAllTasks];
}

- (void)refreshSelectedUI {
    [self.tableView reloadDataAndResetExpansionStates:NO];

    __block NSUInteger count = 0;
    [self.selectedRowsDic
        enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj,
                                            BOOL *stop) {
            count += [obj count];
        }];
    self.sureDeleteBtn.selectedDeleteCount = count;
    self.selectedDeleteBtn.counter = count;
}

- (IBAction)lookMoreBtnTapped:(UIButton *)sender {
    self.tabBarController.selectedIndex = 1;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 全部开始 全部暂停 按钮状态
- (void)allPasueBtnShouldEnable:(BOOL)enabled {
    self.allPauseBtn.enabled = enabled;
    UIColor *color = [UIColor kkb_colorwithHexString:@"646466" alpha:1];
    if (enabled) {
        color = [UIColor kkb_colorwithHexString:@"008eec" alpha:1];
    }

    [self.allPauseBtn setTitleColor:color forState:UIControlStateNormal];
    [self.allPauseBtn setTitleColor:color forState:UIControlStateHighlighted];
}

- (void)allStartBtnShouldEnable:(BOOL)enabled {
    self.allResumeBtn.enabled = enabled;
    UIColor *color = [UIColor kkb_colorwithHexString:@"646466" alpha:1];
    if (enabled) {
        color = [UIColor kkb_colorwithHexString:@"008eec" alpha:1];
    }

    [self.allResumeBtn setTitleColor:color forState:UIControlStateNormal];
    [self.allResumeBtn setTitleColor:color forState:UIControlStateHighlighted];
}

#pragma mark - KKBDownloadControlCellDelegate
- (void)pauseTapped:(KKBDownloadControlCell *)cell {
    KKBDownloadVideoModel *videoModel =
        [KKBDownloadModelFactory convertToBridgeVideoModel:cell.model];
    [KKBDownloadManager pauseDownloadWithItems:@[ videoModel ]];
}

- (void)resumeTapped:(KKBDownloadControlCell *)cell {
    KKBDownloadVideoModel *videoModel =
        [KKBDownloadModelFactory convertToBridgeVideoModel:cell.model];
    [KKBDownloadManager resumeDownloadWithItems:@[ videoModel ]];
}

- (void)startTapped:(KKBDownloadControlCell *)cell {
    KKBDownloadVideo *video = cell.model;

    KKBDownloadVideoModel *videoModel =
        [KKBDownloadModelFactory convertToBridgeVideoModel:video];
    [KKBDownloadManager resumeDownloadWithItems:@[ videoModel ]];
}

- (void)playVideoOnFullScreen:(KKBDownloadVideo *)videoItem {

    PlayVideoViewController *playVideoVC =
        [[PlayVideoViewController alloc] init];
    playVideoVC.videoURLs =
        [[NSMutableArray alloc] initWithObjects:videoItem.downloadPath, nil];
    playVideoVC.itemIDs = @[videoItem.videoID];
    playVideoVC.classId = [videoItem.whichClass.classID stringValue];
    [self presentViewController:playVideoVC animated:YES completion:nil];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSIndexPath *convertIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row - 1
                           inSection:indexPath.section];
    KKBDownloadVideo *item =
        [self.fetchedResultsDataSource itemOfIndex:convertIndexPath];

    if (self.isEditingMode) {
        if ([item isKindOfClass:[KKBDownloadVideo class]]) {

            [self addDownloadTaskToContainersWithItem:item];

        } else {
            //点了section
        }
    } else {
        //正常模式
        if ([item isKindOfClass:[KKBDownloadVideo class]]) {
            //选择了第二级
            KKBDownloadVideo *videoItem = item;
            if ([videoItem customDownloadStatus] == videoDownloadFinish) {

                [self playVideoOnFullScreen:videoItem];
            }
        }
    }
}

- (void)addDownloadTaskToContainersWithItem:(KKBDownloadVideo *)item {
    NSString *key = [item.videoID stringValue];
    NSString *sectionKey = [item.whichClass.classID stringValue];
    NSMutableDictionary *sectionDic = self.selectedRowsDic[sectionKey];
    if (sectionDic) {
        // section已经保存
        if (sectionDic[key]) {
            //取消选择
            [sectionDic removeObjectForKey:key];
        } else {
            //加入选择
            [sectionDic setObject:item forKey:key];
        }
    } else {
        //新建
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:item forKey:key];
        if (sectionKey) {
            [self.selectedRowsDic setObject:dic forKey:sectionKey];
        }
    }
    // refresh ui
    [self refreshSelectedUI];
}

#pragma mark - KKBFetchedResultsDataDelegate
- (BOOL)canEditRowForItem:(id)item {
    return !self.isEditingMode;
}

- (void)configureSectionLevelCell:(UITableViewCell *)cell item:(id)aitem {
    KKBDownloadControlSectionCell *sectionCel =
        (KKBDownloadControlSectionCell *)cell;
    KKBDownloadClass *classItem = aitem;
    NSString *key = [classItem.classID stringValue];
    NSUInteger allCount = [classItem.videos count];
    NSDictionary *addDic = self.selectedRowsDic[key];
    NSUInteger addedCount = [addDic count];
    if (allCount == addedCount) {
        sectionCel.isSelected = YES;
    } else {
        sectionCel.isSelected = NO;
    }

    sectionCel.delegate = self;
    sectionCel.model = classItem;
    sectionCel.isEditting = self.isEditingMode;
}

- (void)configureTwoLevelCell:(UITableViewCell *)cell item:(id)aitem {
    KKBDownloadControlCell *downloadCell = (KKBDownloadControlCell *)cell;
    KKBDownloadVideo *videoItem = aitem;
    NSString *key = [videoItem.videoID stringValue];
    NSString *sectionKey = [videoItem.whichClass.classID stringValue];
    NSDictionary *sectionDic = self.selectedRowsDic[sectionKey];
    if (sectionDic[key]) {
        downloadCell.isSelected = YES;
    } else {
        downloadCell.isSelected = NO;
    }
    downloadCell.delegate = self;
    [downloadCell setupWithModel:videoItem];
    downloadCell.isEditting = self.isEditingMode;
}

- (void)numberOfSectionInDataSource:(NSUInteger)count {
    if (count) {
        self.tableView.hidden = NO;
        self.bottomContentView.hidden = NO;
        self.noTasksContentView.hidden = YES;
        [btn setHidden:NO];
    } else {
        self.tableView.hidden = YES;
        self.bottomContentView.hidden = YES;
        self.noTasksContentView.hidden = NO;
        [btn setHidden:YES];
    }
}

- (void)dataSourcesChangedDeleteItem {
    if (self.isEditingMode) {

        if ([[self.fetchedResultsDataSource allDownloadVideos] count]) {
            // refresh selectedDeleteBtn.maxCount count is correct
            self.selectedDeleteBtn.counter = 0;
            self.selectedDeleteBtn.maxCount =
                [[self.fetchedResultsDataSource allDownloadVideos] count];
            self.sureDeleteBtn.selectedDeleteCount = 0;
        } else {
            // exit editing model
            self.isEditingMode = NO;
        }
    }
}

- (void)dataSourcesDidChanged {
    NSArray *allVideos = [self.fetchedResultsDataSource allDownloadVideos];
    if ([allVideos count]) {
        NSPredicate *predicate = [NSPredicate
            predicateWithFormat:@"status != %d", videoDownloadFinish];
        NSArray *allUnFinishVideos =
            [allVideos filteredArrayUsingPredicate:predicate];

        if ([allUnFinishVideos count]) {
            NSPredicate *predicateDownload = [NSPredicate
                predicateWithFormat:@"status = %d OR status = %d",
                                    videoDownloading, videoDownloadInQueue];
            NSArray *allDownloadings = [allUnFinishVideos
                filteredArrayUsingPredicate:predicateDownload];
            if ([allDownloadings count]) {
                //当前有正在下载的任务 允许暂停
                [self allPasueBtnShouldEnable:YES];

                if ([allDownloadings count] == [allUnFinishVideos count]) {
                    //当前没有可以开始的任务
                    [self allStartBtnShouldEnable:NO];
                } else {
                    //当前有可以开始的任务
                    [self allStartBtnShouldEnable:YES];
                }

            } else {
                //当前没正在下载的任务 允许全部开始
                [self allPasueBtnShouldEnable:NO];
                [self allStartBtnShouldEnable:YES];
            }

        } else {
            //当前视频已全部下载成功
            [self allPasueBtnShouldEnable:NO];
            [self allStartBtnShouldEnable:NO];
        }
    }
}

#pragma mark - KKBDownloadControlSectionCellDelegate
- (void)sectionBtnTapped:(KKBDownloadControlSectionCell *)cell {
    KKBDownloadClass *classItem = cell.model;
    NSString *key = [classItem.classID stringValue];

    NSMutableDictionary *existSectionDic = self.selectedRowsDic[key];
    if (existSectionDic) {
        //已经存在 1.先检查subItem是否全部添加了
        if ([existSectionDic count] == [classItem.videos count]) {
            //全部取消
            [self.selectedRowsDic removeObjectForKey:key];
        } else {
            //添加剩下未添加的
            for (KKBDownloadVideo *videoModel in classItem.videos) {
                NSString *itemKey = [videoModel.videoID stringValue];
                [existSectionDic setObject:videoModel forKey:itemKey];
            }
        }

    } else {
        //不存在全部添加
        NSMutableDictionary *sectionDic = [[NSMutableDictionary alloc]
            initWithCapacity:[classItem.videos count]];
        // selected sub model
        for (KKBDownloadVideo *videoModel in classItem.videos) {
            NSString *itemKey = [videoModel.videoID stringValue];
            [sectionDic setObject:videoModel forKey:itemKey];
        }
        [self.selectedRowsDic setObject:sectionDic forKey:key];
    }
    // refresh ui
    [self refreshSelectedUI];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

@end
