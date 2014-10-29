//
//  KKBDownloadControlCell.m
//  VideoDownload
//
//  Created by zengmiao on 9/2/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadControlCell.h"
#import "KKBDownloadHeader.h"

#define DOWNLOAD_CONTENTVIEW_WIDTH 302.0f
#define DOWNLOAD_CONTENTVIEW_NORMAL_MARGIN_LEFT 18.0f
#define DOWNLOAD_CONTENTVIEW_SELECT_MARGIN_LEFT 17.0
// TODO: <#byzm#> 这里需要调整size

#define DOWNLOAD_SELECTED_IMAGEVIEW_MARGIN_LEFT 17.0
#define DOWNLOAD_SELECTED_IMAGEVIEW_WIDTH 16.0

#define DOWNLOAD_BUTTON_WIDTH 44.0f

@interface KKBDownloadControlCell ()
@property(weak, nonatomic) IBOutlet UIView *downloadContentView;
@property(weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property(weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property(weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property(weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@end

@implementation KKBDownloadControlCell

+ (UINib *)cellNib {
    static UINib *cellNib;

    if (cellNib) {
        return cellNib;
    }

    cellNib = [UINib nibWithNibName:@"KKBDownloadControlCell" bundle:nil];
    return cellNib;
}

- (void)awakeFromNib {
    // Initialization code
    self.separatorInset =
        UIEdgeInsetsMake(0, DOWNLOAD_CONTENTVIEW_NORMAL_MARGIN_LEFT, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithModel:(id)model {
    self.model = model;
    KKBDownloadVideo *videoItem = model;

    self.contentTitleLabel.text = videoItem.videoTitle;

    [self refreshDownloadStatusWithModel:videoItem];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.selectedImageView.image =
            [UIImage imageNamed:@"v3_download_selected_orange"];

    } else {
        self.selectedImageView.image =
            [UIImage imageNamed:@"v3_download_noSelected"];
    }
}

- (void)setIsEditting:(BOOL)isEditting {
    _isEditting = isEditting;

    [self layoutEdittingUI:isEditting];
}

- (void)layoutEdittingUI:(BOOL)editting {
    if (editting) {
        self.selectedImageView.hidden = NO;
        self.selectedImageView.width = DOWNLOAD_SELECTED_IMAGEVIEW_WIDTH;
        self.selectedImageView.left = DOWNLOAD_SELECTED_IMAGEVIEW_MARGIN_LEFT;
        self.downloadContentView.left = self.selectedImageView.right +
                                        DOWNLOAD_CONTENTVIEW_SELECT_MARGIN_LEFT;

    } else {
        self.selectedImageView.hidden = YES;
        self.downloadContentView.left = DOWNLOAD_CONTENTVIEW_NORMAL_MARGIN_LEFT;
    }
}

- (void)refreshDownloadStatusWithModel:(KKBDownloadVideo *)model {
    [self.progressView setProgress:model.progressValue animated:NO];

    if ([model customDownloadStatus] == videoDownloadFinish) {
        self.sizeLabel.text = [NSString
            stringWithFormat:@"%@M", [self bytesConvert:model.totalBytesFile]];

    } else {
        self.sizeLabel.text = [NSString
            stringWithFormat:@"%@M/%@M",
                             [self bytesConvert:model.totalBytesReaded],
                             [self bytesConvert:model.totalBytesFile]];
    }

    self.downloadBtn.hidden = NO;

    // refreshBtn status
    NSString *btnTitleStr = nil;
    NSString *btnImageStatus = @"v3_download_status_error";
    UIColor *titleLabelColor =
        [UIColor kkb_colorwithHexString:@"919699" alpha:1];
    switch ([model customDownloadStatus]) {
    case videoDownloading:
        btnTitleStr = @"暂停";
        btnImageStatus = @"v3_download_status_stop";
        break;
    case videoPause:
        btnTitleStr = @"继续";
        btnImageStatus = @"v3_download_status_doing";
        break;

    case videoDownloadError:
        btnTitleStr = @"下载";
        btnImageStatus = @"v3_download_status_error";
        break;
    case videoDownloadInQueue:
        btnTitleStr = @"取消";
        btnImageStatus = @"v3_download_status_inqueue";
        break;
    case videoDownloadFinish:
        btnTitleStr = @"成功";
        btnImageStatus = @"v3_download_status_success";
        titleLabelColor = [UIColor kkb_colorwithHexString:@"323233" alpha:1];
        break;
    default:
        break;
    }
    [self.downloadBtn setImage:[UIImage imageNamed:btnImageStatus]
                      forState:UIControlStateNormal];
    self.contentTitleLabel.textColor = titleLabelColor;
    //        [self.downloadBtn setTitle:btnTitleStr
    //        forState:UIControlStateNormal];
}

- (IBAction)downBtnTapped:(UIButton *)sender {
    SEL sector = nil;
    switch ([self.model customDownloadStatus]) {
    case videoDownloading: {
        sector = @selector(pauseTapped:);
    } break;

    case videoPause: {
        sector = @selector(resumeTapped:);

    } break;

    case videoDownloadError: {
        sector = @selector(startTapped:);

    } break;

    default:
        break;
    }
    if (sector) {
        if ([self.delegate respondsToSelector:sector]) {
            [self.delegate performSelector:sector withObject:self];
        }
    }
}

#pragma mark - helper
- (NSString *)bytesConvert:(NSNumber *)bytes {
    float size = [bytes longLongValue] / 1024.0 / 1024.0;
    return [NSString stringWithFormat:@"%.1f", size];
}
@end
