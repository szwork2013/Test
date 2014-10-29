//
//  CourseInFavorCell.m
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "CourseInFavorCell.h"
#import "UILabel+KKB_VerticalAlign.h"

#import "CourseInFavorItemModel.h"

@interface CourseInFavorCell ()

@property(weak, nonatomic) UIImageView *headmageView;
@property(weak, nonatomic) UIImageView *typeImageView;
@property(weak, nonatomic) UILabel *titleLabel;
@property(weak, nonatomic) UILabel *contentLabel;
@property(weak, nonatomic) UILabel *timeLabel;

@end

@implementation CourseInFavorCell

static UINib *cellNib;

+ (UINib *)cellNib {
    if (cellNib) {
        return cellNib;
    }

    cellNib = [UINib nibWithNibName:@"CourseInFavorCell" bundle:nil];
    return cellNib;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.titleLabel kkb_alignTop];
    [self.contentLabel kkb_alignTop];

    self.layer.cornerRadius = 2.0f;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.masksToBounds = YES;

    [self.headmageView.layer setCornerRadius:2.0f];
    [self.headmageView.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Property
- (void)setModel:(CourseInFavorItemModel *)model {
    if (_model != model) {
        _model = model;
    }
    [self refreshCellData];
}

- (void)refreshCellData {
    if (self.model.isOpenCourse) {
        self.typeImageView.image =
            [UIImage imageNamed:@"public-class_button_link"];

    } else {
        self.typeImageView.image = [UIImage imageNamed:@"teachers_button_link"];
    }

    [self.headmageView
        sd_setImageWithURL:[NSURL URLWithString:self.model.courseImageUrl]
          placeholderImage:nil];
    self.titleLabel.text = self.model.courseTitle;
    self.contentLabel.text = self.model.updateInfo;
    self.timeLabel.text = self.model.updateTime;
}

@end
