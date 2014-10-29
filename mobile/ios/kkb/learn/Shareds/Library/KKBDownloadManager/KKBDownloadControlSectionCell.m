//
//  KKBDownlaodControlSectionCell.m
//  VideoDownload
//
//  Created by zengmiao on 9/9/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadControlSectionCell.h"

#define SELECTEDIMG_MARGIN_LEFT 4.0
#define SELECTEDIMG_WIDTH 32.0

#define SECTION_LABEL_NORMAL_MARGIN_LEFT 12.0
#define SECTION_LABEL_EDITING_MARGIN_LEFT 7.0

#define SECTION_LABEL_MARGIN_RIFGHT 8.0

#define ARROW_IMG_MARGIN_RIGHT 0.0
#define ARROW_IMG_WIDTH 44.0

@interface KKBDownloadControlSectionCell ()

@property(weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property(weak, nonatomic) IBOutlet UIImageView *seclectedImageView;
@property(weak, nonatomic) IBOutlet UIButton *selectedBtn;

@end

@implementation KKBDownloadControlSectionCell

+ (UINib *)cellNib {
    static UINib *cellNib;

    if (cellNib) {
        return cellNib;
    }

    cellNib =
        [UINib nibWithNibName:@"KKBDownloadControlSectionCell" bundle:nil];
    return cellNib;
}

- (void)awakeFromNib {
    // Initialization code
    self.separatorInset =
    UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Property
- (void)setIsEditting:(BOOL)isEditting {
    _isEditting = isEditting;

    [self layoutEdittingUI:isEditting];
}

- (void)setIsExpanding:(BOOL)isExpanding {
    _isExpanding = isExpanding;
    if (isExpanding) {

        self.arrowImageView.image = [UIImage imageNamed:@"v3_arrow_up"];
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"v3_arrow_down"];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self.selectedBtn
            setImage:[UIImage imageNamed:@"v3_download_selected_orange"]
            forState:UIControlStateNormal];
        [self.selectedBtn
            setImage:[UIImage imageNamed:@"v3_download_selected_orange"]
            forState:UIControlStateHighlighted];
        self.seclectedImageView.image =
            [UIImage imageNamed:@"v3_download_selected_orange"];

    } else {
        [self.selectedBtn
            setImage:[UIImage imageNamed:@"v3_download_noSelected"]
            forState:UIControlStateNormal];
        [self.selectedBtn
            setImage:[UIImage imageNamed:@"v3_download_noSelected"]
            forState:UIControlStateHighlighted];
        self.seclectedImageView.image =
            [UIImage imageNamed:@"v3_download_noSelected"];
    }
}
- (void)layoutEdittingUI:(BOOL)isEditting {

    if (isEditting) {
        self.selectedBtn.hidden = NO;
        self.selectedBtn.left = SELECTEDIMG_MARGIN_LEFT;
        self.selectedBtn.width = SELECTEDIMG_WIDTH;

        // TODO: byzm 先隐藏ImageView 用btn代替
        self.seclectedImageView.hidden = YES;
        self.seclectedImageView.left = SELECTEDIMG_MARGIN_LEFT;
        self.seclectedImageView.width = SELECTEDIMG_WIDTH;

        self.sectionTitleLabel.left =
            SECTION_LABEL_EDITING_MARGIN_LEFT + self.seclectedImageView.right;
        self.sectionTitleLabel.width =
            self.bounds.size.width - SELECTEDIMG_MARGIN_LEFT -
            SELECTEDIMG_WIDTH - SECTION_LABEL_EDITING_MARGIN_LEFT -
            SECTION_LABEL_MARGIN_RIFGHT - ARROW_IMG_MARGIN_RIGHT -
            ARROW_IMG_WIDTH;

        self.arrowImageView.width = ARROW_IMG_WIDTH;
        self.arrowImageView.right =
            self.bounds.size.width - ARROW_IMG_MARGIN_RIGHT;

    } else {
        self.selectedBtn.hidden = YES;

        self.seclectedImageView.hidden = YES;

        self.sectionTitleLabel.left = SECTION_LABEL_NORMAL_MARGIN_LEFT;
        self.sectionTitleLabel.width = self.bounds.size.width -
                                       SECTION_LABEL_NORMAL_MARGIN_LEFT -
                                       SECTION_LABEL_MARGIN_RIFGHT -
                                       ARROW_IMG_MARGIN_RIGHT - ARROW_IMG_WIDTH;

        self.arrowImageView.width = ARROW_IMG_WIDTH;
        self.arrowImageView.right =
            self.bounds.size.width - ARROW_IMG_MARGIN_RIGHT;
    }
}

- (void)setModel:(KKBDownloadClass *)model {
    if (_model != model) {
        _model = model;

        [self refreshUI];
    }
}

- (void)refreshUI {
    self.sectionTitleLabel.text = self.model.name;
}

- (IBAction)selectedBtnTapped:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sectionBtnTapped:)]) {
        [self.delegate sectionBtnTapped:self];
    }
}


#pragma mark - UIExpandingTableViewCell delegate
- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        
        if (_expansionStyle == UIExpansionStyleExpanded) {
            self.isExpanding = YES;
        } else {
            self.isExpanding = NO;
        }
    }
}
@end
