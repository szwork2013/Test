//
//  DownloadCell.h
//  learn
//
//  Created by User on 14-3-8.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FileModel.h"
@interface DownloadCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *vidoTitle;
@property (strong, nonatomic) IBOutlet UIImageView *videoImv;
@property (strong, nonatomic) IBOutlet UILabel *videoSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoStateLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIProgressView *pView;
@property (weak, nonatomic) id actionTarget;

- (void)configureWithFileModel:(FileModel*)model;
- (IBAction)download:(id)sender;
- (IBAction)deletePressed:(id)sender;

@end