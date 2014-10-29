//
//  KKBDownlaodControlSectionCell.h
//  VideoDownload
//
//  Created by zengmiao on 9/9/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBDownloadClass.h"
#import "SLExpandableTableView.h"

#define KKBDOWNLOADCONTROL_SECTION_CELL_REUSEDID @"KKBDownloadControlSectionCell"

@protocol KKBDownloadControlSectionCellDelegate <NSObject>
@optional
- (void)sectionBtnTapped:(UITableViewCell *)cell;

@end

@interface KKBDownloadControlSectionCell : UITableViewCell<UIExpandingTableViewCell>

@property(weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;

@property (nonatomic, assign) BOOL isEditting;
@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) id<KKBDownloadControlSectionCellDelegate> delegate;

@property (strong ,nonatomic) KKBDownloadClass *model;

#pragma mark - UIExpandingTableViewCell delegate
@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, readonly) UIExpansionStyle expansionStyle;
- (void)setExpansionStyle:(UIExpansionStyle)style animated:(BOOL)animated;

+ (UINib *)cellNib;

@end
