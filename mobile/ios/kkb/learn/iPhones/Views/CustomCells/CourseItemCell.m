//
//  CourseItemCell.m
//  learn
//
//  Created by zengmiao on 8/7/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "CourseItemCell.h"
#import "UILabel+KKB_VerticalAlign.h"
#import "KKBStarRatingView+CoursesSetRating.h"

@interface CourseItemCell ()
@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(weak, nonatomic) IBOutlet UIImageView *headImageView;
@property(weak, nonatomic) IBOutlet UILabel *titleCellLabel;
@property(weak, nonatomic) IBOutlet UILabel *numbersLabel;

@property(weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property(weak, nonatomic) IBOutlet UIImageView *willBeginImageView;
@property(weak, nonatomic) IBOutlet UIImageView *portraitImageView; //小人物头像

@property(strong, nonatomic) KKBStarRatingView *starRatingView; //评分控件
@end

@implementation CourseItemCell

static UINib *cellNib;

+ (UINib *)cellNib {
    if (cellNib) {
        return cellNib;
    }

    cellNib = [UINib nibWithNibName:@"CourseItemCell" bundle:nil];
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
    //设置背景图片
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];

    UIImage *bgImage = [UIImage imageNamed:@"v3_card_shadow"];
    UIImage *highlightedImg = [UIImage imageNamed:@"v3_card_shadow_pres"];
    

    _backgroundImageView.image = bgImage;
    _backgroundImageView.highlightedImage = highlightedImg;
    [_titleCellLabel kkb_alignTop];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

#pragma mark - Property
- (void)setModel:(KKBCourseItemCellModel *)model {
    if (_model != model) {
        _model = model;
        [self refreshUI];
    }
}

- (void)refreshUI {
    self.titleCellLabel.text = self.model.cellTitle;

    NSURL *imageURL = [NSURL URLWithString:self.model.headImageURL];
    [self.headImageView
        sd_setImageWithURL:imageURL
          placeholderImage:[UIImage imageNamed:@"allcourse_cover_default"]];

    // type ImageView
    NSString *typeImageStr = nil;
    NSString *portraitImageStr = nil;

    if (self.model.itemType == CourseItemOpenType) {
        typeImageStr = @"PublicClass_icon_dis";
        portraitImageStr = @"kkb-iphone-opencoursecard-videocount";
        self.portraitImageView.frame = CGRectMake(260, 72, 9, 8);
        [self.starRatingView kkb_courseRating:self.model.rating
                                         type:OPENCOURSE];

    } else {
        typeImageStr = @"teachers_icon_dis";
        portraitImageStr = @"guide_people_portrait";
        [self.starRatingView kkb_courseRating:self.model.rating
                                         type:GUIDECOURSE];
    }

    self.typeImageView.image = [UIImage imageNamed:typeImageStr];
    self.portraitImageView.image = [UIImage imageNamed:portraitImageStr];

    //设置人数
    self.numbersLabel.text = [self watchedNumsConvert];

    if (self.model.isOnLine) {
        self.willBeginImageView.hidden = YES;
        self.portraitImageView.hidden = NO;
        self.numbersLabel.hidden = NO;

    } else {
        self.willBeginImageView.hidden = NO;
        self.portraitImageView.hidden = YES;
        self.numbersLabel.hidden = YES;
    }
}

- (KKBStarRatingView *)starRatingView {
    if (!_starRatingView) {
        _starRatingView =
            [[KKBStarRatingView alloc] initWithOrigin:CGPointMake(238, 88)
                                            starCount:5
                                            starWidth:9
                                           starHeight:8
                                              spacing:4
                                          rateEnabled:NO];
        [self.contentView addSubview:_starRatingView];
    }
    return _starRatingView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (NSString *)watchedNumsConvert {
    if ([self.model.enrollments integerValue] >= 10000) {
        float nums = [self.model.enrollments floatValue];
        nums /= 10000.0;
        NSString *str = [NSString stringWithFormat:@"%.1f万", nums];
        return str;
    } else {
        return [NSString
            stringWithFormat:@"%@", [self.model.enrollments stringValue]];
    }
}

@end
