//
//  KKBDownloadStatusCell.h
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBDownloadVideoModel.h"

#define KKBDOWNLOADSTATUSCELL_CELL_REUSEDID @"KKBDownloadStatusCell"

@interface KKBDownloadStatusCell : UITableViewCell

@property (strong ,nonatomic) KKBDownloadVideoModel *model;
@property (nonatomic, assign) BOOL isSelected;

+ (UINib *)cellNib;

@end
