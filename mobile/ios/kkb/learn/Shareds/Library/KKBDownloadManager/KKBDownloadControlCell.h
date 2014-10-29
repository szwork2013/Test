//
//  KKBDownloadControlCell.h
//  VideoDownload
//
//  Created by zengmiao on 9/2/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KKBDOWNLOADCONTROL_CELL_REUSEDID @"KKBDownloadControlCell"

@class KKBDownloadControlCell;

@protocol KKBDownloadControlCellDelegate <NSObject>

- (void)pauseTapped:(KKBDownloadControlCell *)cell;
- (void)resumeTapped:(KKBDownloadControlCell *)cell;
- (void)startTapped:(KKBDownloadControlCell *)cell; //下载失败重新下载

@end

@interface KKBDownloadControlCell : UITableViewCell

@property(strong, nonatomic) id model;
@property (nonatomic, weak) id<KKBDownloadControlCellDelegate> delegate;
@property (nonatomic, assign) BOOL isEditting;
@property (nonatomic, assign) BOOL isSelected;


+ (UINib *)cellNib;

- (void)setupWithModel:(id)model;

@end
