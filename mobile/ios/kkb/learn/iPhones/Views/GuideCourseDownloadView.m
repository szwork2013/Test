//
//  GuideCourseDownloadView.m
//  learn
//
//  Created by zxj on 14-8-6.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideCourseDownloadView.h"
#import "RATreeView.h"
#import "PublicDownloadViewCell.h"
#import "KKBUserInfo.h"
#import "PublicDownloadModel.h"
#import "GuideDownLoadModel.h"
#import "GuideDownLoadSubModel.h"
@implementation GuideCourseDownloadView {
    RATreeView *_downloadTableView;
    UIView *_coverView;
    NSMutableArray *_selectedArray;
    NSMutableDictionary *_selectedDict;
    UIButton *_downloadButton;
    NSArray *courseTreeArray;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor clearColor];
    // init
    _selectedArray = [[NSMutableArray alloc] init];

    /**统一查询course接口zeng**/
    [KKBCourseManager getCourseWithID:@([self.courseId intValue])
                          forceReload:NO
                    completionHandler:^(id model, NSError *error) {
                        _currentCourse = model;

                        courseTreeArray =
                            [_currentCourse objectForKey:@"course_outline"];

                        for (NSDictionary *dict in courseTreeArray) {
                            GuideDownLoadModel *model =
                                [[GuideDownLoadModel alloc] init];
                            [model initWithDictionary:dict];
                            [_selectedArray addObject:model];
                        }
                        [_downloadTableView reloadData];
                    }];

    // download and select button
    UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // need change the float y
    [selectAllButton
        setFrame:CGRectMake(0, self.frame.size.height - 20, 160, 40)];
    [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllButton setBackgroundColor:[UIColor blueColor]];
    [selectAllButton addTarget:self
                        action:@selector(downloadButtonClick:)
              forControlEvents:UIControlEventTouchUpInside];
    selectAllButton.tag = 11000;
    [self addSubview:selectAllButton];

    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton
        setFrame:CGRectMake(160, self.frame.size.height - 20, 160, 40)];
    [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    [_downloadButton addTarget:self
                        action:@selector(downloadButtonClick:)
              forControlEvents:UIControlEventTouchUpInside];
    [_downloadButton setBackgroundColor:[UIColor blueColor]];
    _downloadButton.tag = 11001;
    [self addSubview:_downloadButton];

    // download tableView
    _downloadTableView = [[RATreeView alloc]
        initWithFrame:CGRectMake(0, 100, 320, self.frame.size.height - 100 - 20)
                style:RATreeViewStylePlain];
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
    _downloadTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_downloadTableView setBackgroundColor:[UIColor blackColor]];
    [self addSubview:_downloadTableView];

    // coverView
    _coverView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, 320, G_SCREEN_HEIGHT - 44)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5;
    _coverView.userInteractionEnabled = YES;
    [self addSubview:_coverView];

    [self sendSubviewToBack:_coverView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(downloadCoverViewClick:)];
    [_coverView addGestureRecognizer:tapGesture];
    [tapGesture setNumberOfTapsRequired:1];
}

#pragma mark - Custom
- (void)downloadButtonClick:(UIButton *)button {
    if (button.tag == 11000) {
        NSLog(@"select all select");
    } else {
        NSLog(@"down load select");
    }
}

- (void)downloadCoverViewClick:(UITapGestureRecognizer *)tapG {
    [_delegate downloadCoverViewClick];
}

#pragma mark - treeViewDatasource
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [_selectedArray count];
    }

    GuideDownLoadModel *downLoadModel = (GuideDownLoadModel *)item;

    return [downLoadModel.itemArray count];
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    if (treeDepthLevel == 0) {

        static NSString *cellIdentifier = @"cellIdentifier";
        UITableViewCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        }

        GuideDownLoadModel *model = (GuideDownLoadModel *)item;

        cell.textLabel.text = model.name;
        return cell;
    }

    if (treeDepthLevel == 1) {
        static NSString *cellId = @"PublicDownloadViewCell";
        PublicDownloadViewCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell =
                [[[NSBundle mainBundle] loadNibNamed:@"PublicDownloadViewCell"
                                               owner:self
                                             options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor blackColor];
        cell.publicDownloadViewCellLabel.textColor =
            [UIColor colorWithRed:128.0 / 255
                            green:128.0 / 255
                             blue:128.0 / 255
                            alpha:1];
        cell.publicDownloadViewCellLabel.font =
            [UIFont fontWithName:@"Helvetica" size:13];

        cell.publicDownloadViewCellLabel.textColor = [UIColor whiteColor];

        GuideDownLoadSubModel *modelOne = (GuideDownLoadSubModel *)item;
        NSString *courseName = modelOne.title;
        cell.publicDownloadViewCellLabel.text = courseName;
        cell.publicDownloadCellImageView.image =
            [UIImage imageNamed:modelOne.itemImage];
        return cell;
    }
    return nil;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [_selectedArray objectAtIndex:index];
    }

    GuideDownLoadModel *model = (GuideDownLoadModel *)item;

    return [model.itemArray objectAtIndex:index];
}

@end
