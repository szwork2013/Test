//
//  KKBDownloadSingleHierarchyController.m
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadSingleHierarchyController.h"
#import "KKBDownloadControlViewController.h"

#import "KKBDownloadDeleteBtn.h"
#import "KKBDownloadStatusCell.h"
#import "KKBFetchedResultsSingleDataSource.h"
#import "KKBDownloadManager.h"
#import "KKBDownloadTaskModel.h"

// static const float topViewHeight = 40.0;
// static const float bottomViewHeight = 56.0;

@interface KKBDownloadSingleHierarchyController () <UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UIView *topView;
@property(weak, nonatomic) IBOutlet UIView *bottomView;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *downloadBtn;
@property(weak, nonatomic) IBOutlet KKBDownloadDeleteBtn *selectedBtn;

@property(strong, nonatomic) KKBFetchedResultsSingleDataSource *dataSource;

@property(strong, nonatomic) UITableView *tableView;

@property(strong, nonatomic) NSMutableArray *selectedVideoItems;

@end

@implementation KKBDownloadSingleHierarchyController

#pragma mark - Life Cycle Methods
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

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView registerNib:[KKBDownloadStatusCell cellNib]
         forCellReuseIdentifier:KKBDOWNLOADSTATUSCELL_CELL_REUSEDID];

    //    __weak typeof(self) weakSelf = self;

    TableViewCellConfigureBlock block =
        ^(KKBDownloadStatusCell *cell,
          KKBDownloadVideoModel *item) { cell.model = item; };

    self.dataSource = [[KKBFetchedResultsSingleDataSource alloc]
           initWithClassID:self.classModel.classID
                     items:self.videoItems
                 tableView:self.tableView
            cellIdentifier:KKBDOWNLOADSTATUSCELL_CELL_REUSEDID
        configureCellBlock:block];
    self.tableView.dataSource = self.dataSource;
    //    [self.tableView reloadData]

    //设置底部按钮状态
    self.selectedBtn.counter = 0;
    NSUInteger maxAllowCount = 0;
    for (KKBDownloadVideoModel *videoModel in self.videoItems) {
        if (videoModel.status == videoUnknown ||
            videoModel.status == videoDownloadError) {
            maxAllowCount++;
        }
    }
    self.selectedBtn.maxCount = maxAllowCount;
    self.downloadBtn.selectedDownloadCount = 0;

    [self prepare4Buttons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.dataSource addDelegate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dataSource removeDelegate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.top = self.topView.height;
    self.tableView.height =
        self.view.size.height - addPageTopViewHeight - addPageBottomViewHeight;
    self.bottomView.top = self.tableView.bottom;
}

#pragma mark - Custom Methods
- (void)prepare4Buttons {
    [_downloadBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                            forState:UIControlStateHighlighted];

    [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                            forState:UIControlStateHighlighted];
}
#pragma mark - Property
- (NSMutableArray *)selectedVideoItems {
    if (_selectedVideoItems == nil) {
        _selectedVideoItems = [[NSMutableArray alloc] init];
    }
    return _selectedVideoItems;
}

- (void)refreshBottomUI {
    self.selectedBtn.counter = [self.selectedVideoItems count];
    self.downloadBtn.selectedDownloadCount = [self.selectedVideoItems count];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KKBDownloadVideoModel *videoModel = self.videoItems[indexPath.row];

    if (videoModel.status == videoUnknown ||
        videoModel.status == videoDownloadError) {

        if ([self.selectedVideoItems containsObject:videoModel]) {
            //取消选择
            videoModel.isSelected = NO;
            [self.selectedVideoItems removeObject:videoModel];
        } else {
            //选择
            videoModel.isSelected = YES;
            [self.selectedVideoItems addObject:videoModel];
                   }

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

        [self refreshBottomUI];
    }
}

#pragma mark - btn Mehtod
- (IBAction)downloadBtnTapped:(KKBDownloadDeleteBtn *)sender {
    if ([self.selectedVideoItems count]) {
        NSMutableArray *tasks = [[NSMutableArray alloc]
            initWithCapacity:[self.selectedVideoItems count]];

        for (KKBDownloadVideoModel *videoModel in self.selectedVideoItems) {
            KKBDownloadTaskModel *taskModel =
                [[KKBDownloadTaskModel alloc] init];
            taskModel.classModel = self.classModel;
            taskModel.videoModel = videoModel;
            [tasks addObject:taskModel];
        }

        [KKBDownloadManager startDownloadWithItems:tasks];
        self.successView.successMessage.text = @"已加入下载列表";
        self.successView.top = 50;
        [self.view bringSubviewToFront:self.successView];
        [self popSuccessView];

    }
    [self.selectedVideoItems removeAllObjects];
    [self refreshBottomUI];
}

- (IBAction)selectedBtnTapped:(KKBDownloadDeleteBtn *)sender {
    if ([sender allowSelected]) {
        //全选
        for (KKBDownloadVideoModel *videoModel in self.videoItems) {
            if (videoModel.status == videoUnknown ||
                videoModel.status == videoDownloadError) {
                if (![self.selectedVideoItems containsObject:videoModel]) {
                    videoModel.isSelected = YES;
                    [self.selectedVideoItems addObject:videoModel];
                }
            }
        }

    } else {
        //取消全选
        for (KKBDownloadVideoModel *videoItem in self.videoItems) {
            videoItem.isSelected = NO;
        }
        [self.selectedVideoItems removeAllObjects];
    }

    [self refreshBottomUI];
    [self.tableView reloadData];
}

- (IBAction)goDownloadControlTapped:(UITapGestureRecognizer *)sender {

    if ([self.delegate respondsToSelector:@selector(downloadControlTapped:)]) {
        [self.delegate downloadControlTapped:self];
    }
}

- (void)networkStatusDidChange{
    
}
@end
