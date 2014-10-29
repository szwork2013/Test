//
//  KKBDownloadStatusCell.m
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadStatusCell.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface KKBDownloadStatusCell ()
@property(weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property(weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property(weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end

@implementation KKBDownloadStatusCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;

    /*
    if (self.model.status == videoUnknown ||
        self.model.status == videoDownloadError) {
        if (isSelected) {
            self.selectedImageView.image =
                [UIImage imageNamed:@"v3_download_selected_orange"];
        } else {
            self.selectedImageView.image =
                [UIImage imageNamed:@"v3_download_noSelected"];
        }
        //        self.statusImageView.image = nil;
        [self refreshTitleAndBgUIWithSuccess:isSelected];
    }
     */
}

- (void)refreshTitleAndBgUIWithSuccess:(BOOL)success {
    if (success) {
        self.videoTitleLabel.textColor =
            [UIColor kkb_colorwithHexString:@"323233" alpha:1];
        self.backgroundColor =
            [UIColor kkb_colorwithHexString:@"f5f5f5" alpha:1];
    } else {
        self.backgroundColor =
            [UIColor kkb_colorwithHexString:@"ffffff" alpha:1];
        self.videoTitleLabel.textColor =
            [UIColor kkb_colorwithHexString:@"919699" alpha:1];
    }
}

+ (UINib *)cellNib {
    static UINib *cellNib;

    if (cellNib) {
        return cellNib;
    }

    cellNib = [UINib nibWithNibName:@"KKBDownloadStatusCell" bundle:nil];
    return cellNib;
}

- (void)setModel:(KKBDownloadVideoModel *)model {
    _model = model;
    [self refreshUI];
}

- (void)refreshUI {
    self.videoTitleLabel.text = self.model.videoTitle;
    DDLogDebug(@"videoID:%@--downloadPath:%@", self.model.videoID,
               self.model.downloadPath);

    if (self.model.status == videoUnknown ||
        self.model.status == videoDownloadError) {

        if (self.model.isSelected) {
            self.selectedImageView.image =
            [UIImage imageNamed:@"v3_download_selected_orange"];
        } else {
            self.selectedImageView.image =
            [UIImage imageNamed:@"v3_download_noSelected"];
        }
        
        if (self.model.status == videoDownloadError) {
            self.statusImageView.image = [UIImage imageNamed:@"v3_download_status_err"];
        } else {
            self.statusImageView.image = nil;
        }
        
        [self refreshTitleAndBgUIWithSuccess:self.model.isSelected];
        return;
    }

    
    //更新下载状态
    NSString *selectedImageStr = nil;
    NSString *statusImageStr = nil;
    switch (self.model.status) {
    case videoUnknown:

        break;
    case videoDownloading:
        [self refreshTitleAndBgUIWithSuccess:YES];
        selectedImageStr = @"v3_download_selected_gray";
        statusImageStr = @"v3_download_status_doing_green";
        break;

    case videoPause:
        [self refreshTitleAndBgUIWithSuccess:YES];
        selectedImageStr = @"v3_download_selected_gray";
        statusImageStr = @"v3_download_status_doing_green";
        break;

    case videoDownloadFinish:
        [self refreshTitleAndBgUIWithSuccess:YES];
        selectedImageStr = @"v3_download_selected_gray";
        statusImageStr = @"v3_download_status_success";
        break;
    case videoDownloadInQueue:
        [self refreshTitleAndBgUIWithSuccess:YES];
        selectedImageStr = @"v3_download_selected_gray";
        statusImageStr = @"v3_download_status_doing_green";

        break;
    case videoDownloadError:
        [self refreshTitleAndBgUIWithSuccess:NO];
        selectedImageStr = @"v3_download_noSelected";
        statusImageStr = @"v3_download_status_err";
        break;
    case videoDownloadCancel:
        [self refreshTitleAndBgUIWithSuccess:NO];
        selectedImageStr = @"v3_download_noSelected";
        statusImageStr = @"nil";
        break;
    default:

        break;
    }
    self.selectedImageView.image = [UIImage imageNamed:selectedImageStr];
    self.statusImageView.image = [UIImage imageNamed:statusImageStr];
}
@end
