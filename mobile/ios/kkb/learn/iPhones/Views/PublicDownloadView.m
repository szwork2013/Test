//
//  PublicDownloadView.m
//  learn
//
//  Created by 翟鹏程 on 14-7-30.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "PublicDownloadView.h"
#import "PublicDownloadViewCell.h"
#import "PublicDownloadModel.h"

@implementation PublicDownloadView {
    UITableView *_downloadTableView;
    UIView *_coverView;
    NSMutableArray *_selectedArray;
    NSMutableDictionary *_selectedDict;

    UIButton *_downloadButton;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)initWithUI {
    self.backgroundColor = [UIColor clearColor];
    // init
    _selectedArray = [[NSMutableArray alloc] init];

    for (NSDictionary *dict in _currentCourseVideoList) {
        PublicDownloadModel *model = [[PublicDownloadModel alloc] init];
        model.itemImage = @"download_default";
        model.itemTitle = [dict objectForKey:@"item_title"];
        model.isSelected = NO;
        [_selectedArray addObject:model];
    }

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
    _downloadTableView = [[UITableView alloc]
        initWithFrame:CGRectMake(0, 100, 320, self.frame.size.height - 100 - 20)
                style:UITableViewStylePlain];
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
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

#pragma mark - TableViewD

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return [_currentCourseVideoList count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"PublicDownloadViewCell";
    PublicDownloadViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PublicDownloadViewCell"
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
    PublicDownloadModel *model = [_selectedArray objectAtIndex:indexPath.row];
    cell.publicDownloadViewCellLabel.text = model.itemTitle;
    cell.publicDownloadCellImageView.image =
        [UIImage imageNamed:model.itemImage];

    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select !!!!");
    PublicDownloadViewCell *cell =
        (PublicDownloadViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    PublicDownloadModel *model = [_selectedArray objectAtIndex:indexPath.row];
    if (model.isSelected == NO) {
        model.isSelected = YES;
        cell.publicDownloadCellImageView.image =
            [UIImage imageNamed:@"download_selected"];
        model.itemImage = @"download_selected";
    } else {
        model.isSelected = NO;
        cell.publicDownloadCellImageView.image =
            [UIImage imageNamed:@"download_default"];
        model.itemImage = @"download_default";
    }
    int selectCount = 0;
    for (PublicDownloadModel *aModel in _selectedArray) {
        if (aModel.isSelected == YES) {
            selectCount++;
        }
    }
    if (selectCount == 0) {
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    } else {
        [_downloadButton
            setTitle:[NSString stringWithFormat:@"下载(%d)", selectCount]
            forState:UIControlStateNormal];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
