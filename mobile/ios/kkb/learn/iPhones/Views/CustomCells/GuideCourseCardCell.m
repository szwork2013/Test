//
//  GuideCourseCardCell.m
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "GuideCourseCardCell.h"
#import "GuideCourseCardItemModel.h"

#import "GuideCourseVideoItemView.h"
#import "GuideCourseItemView.h"

#import "UILabel+KKB_VerticalAlign.h"

#import "GuideCourseItemModel.h"
#import "GuideCourseVideoItemModel.h"

static CGFloat const guideCourseCellHeight = 272;
static CGFloat const coverViewHeight = 165;
static CGFloat const itemHeight = 40;
static CGFloat const itemWidth = 304;
static CGFloat const itemBGViewToTop = 112;

@interface GuideCourseCardCell ()

@property(weak, nonatomic) IBOutlet UIControl *titleBackgroundView;
@property(weak, nonatomic) IBOutlet UIImageView *headImageView;
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIButton *weekLabel;
@property(strong, nonatomic) UIImageView *coverImageView;

@property(weak, nonatomic) IBOutlet UIView *itemsBGView;
@property(weak, nonatomic) IBOutlet GuideCourseVideoItemView *videoView;
@property(weak, nonatomic) IBOutlet GuideCourseItemView *discussView;
@property(weak, nonatomic) IBOutlet GuideCourseItemView *homewordView;
@property(weak, nonatomic) IBOutlet GuideCourseItemView *testView;

@end

@implementation GuideCourseCardCell

static UINib *cellNib;

+ (UINib *)cellNib {
    if (cellNib) {
        return cellNib;
    }

    cellNib = [UINib nibWithNibName:@"GuideCourseCardCell" bundle:nil];
    return cellNib;
}

+ (float)heightForCellWithModel:(GuideCourseCardItemModel *)model {
    return itemBGViewToTop +
           [GuideCourseCardCell heightForItemsViewWithModel:model];
}

+ (float)heightForItemsViewWithModel:(GuideCourseCardItemModel *)model {

    return itemHeight * [model.items count];
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
    self.clipsToBounds = YES;

    [self.headImageView.layer setCornerRadius:2.0f];
    [self.headImageView.layer setMasksToBounds:YES];

    self.videoView.backgroundColor = [UIColor clearColor];
    self.discussView.backgroundColor = [UIColor clearColor];
    self.homewordView.backgroundColor = [UIColor clearColor];
    self.testView.backgroundColor = [UIColor clearColor];
    self.itemsBGView.backgroundColor = [UIColor clearColor];

    [self.titleLabel kkb_alignTop];
    [self addTapFeedback];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Feedback

- (void)addTapFeedback {
    [_titleBackgroundView addTarget:self
                             action:@selector(viewDidTouchUpInside)
                   forControlEvents:UIControlEventTouchUpInside];
    [_titleBackgroundView addTarget:self
                             action:@selector(viewDidTouchUp)
                   forControlEvents:UIControlEventTouchUpOutside];
    [_titleBackgroundView addTarget:self
                             action:@selector(viewDidTouchUp)
                   forControlEvents:UIControlEventTouchCancel];
    [_titleBackgroundView addTarget:self
                             action:@selector(viewDidTouchDown)
                   forControlEvents:UIControlEventTouchDown];
}

- (void)viewDidTouchUp {
    [self performSelector:@selector(clearColor) withObject:nil afterDelay:0.1f];
}

- (void)viewDidTouchUpInside {
    [self clearColor];

    [self.delegate guideCourseCardDetailButtonDidSelect:_model];
}

- (void)clearColor {
    [_titleBackgroundView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidTouchDown {
    [_titleBackgroundView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
}

#pragma mark - configureCell
- (void)configureCell {
    if (!_model.isFinishedAllTask) {
        self.layer.cornerRadius = 2.0f;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.masksToBounds = YES;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.masksToBounds = YES;
    }

    self.titleLabel.text = self.model.courseTitle;

    [self.headImageView
        sd_setImageWithURL:[NSURL URLWithString:self.model.courseImageUrl]
          placeholderImage:nil];

    [self.weekLabel
        setTitle:[NSString stringWithFormat:@"第%d周",
                                            self.model.courseNumberOfWeek]
        forState:UIControlStateNormal];

    [self layoutItemsBGView];
}

#pragma mark - GuideCourseItemView Delegate Method
- (void)guideCourseItemDidSelect:(GuideCourseItemModel *)data {

    [self.delegate guideCourseCardPlainItemDidSelect:data];
}

#pragma mark - GuideCourseVideoItemView Delegate Methods
- (void)guideCourseVideoItemDidSelect {

    [self.delegate guideCourseCardVideoItemDidSelect:self.model];
}

#pragma mark - Property
- (void)setModel:(GuideCourseCardItemModel *)model {
    if (_model != model) {
        _model = model;
        [self configureCell];
    }
}

- (void)layoutItemsBGView {
    //先移除所有存在的
    [self.itemsBGView.subviews
        makeObjectsPerformSelector:@selector(removeFromSuperview)];

    //设置 itemsBGView height
    self.itemsBGView.height =
        [GuideCourseCardCell heightForItemsViewWithModel:self.model];

    for (int i = 0; i < [self.model.items count]; i++) {
        id<GuideCourseItemModelProtocol> model = self.model.items[i];
        if (model.guideType == GuideCourseType_Video) {

            GuideCourseVideoItemModel *amodel =
                (GuideCourseVideoItemModel *)model;
            GuideCourseVideoItemView *videoView =
                [[GuideCourseVideoItemView alloc]
                    initWithFrame:CGRectMake(0, i * itemHeight, itemWidth,
                                             itemHeight)];
            videoView.model = amodel;
            videoView.delegate = self;
            [self.itemsBGView addSubview:videoView];

        } else {
            GuideCourseItemModel *amodel = (GuideCourseItemModel *)model;
            GuideCourseItemView *itemView = [[GuideCourseItemView alloc]
                initWithFrame:CGRectMake(0, i * itemHeight, itemWidth,
                                         itemHeight)];
            itemView.model = amodel;
            itemView.delegate = self;

            // hide the last item's seperate line
            BOOL isLastItem = (i == ([self.model.items count] - 1));
            if (isLastItem) {

                [itemView.itemSeperateLine setHidden:YES];
            }

            [self.itemsBGView addSubview:itemView];
        }
    }
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, guideCourseCellHeight - coverViewHeight,
                                     G_SCREEN_WIDTH, coverViewHeight)];
        _coverImageView.image = [UIImage imageNamed:@"task_content_past_def"];
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}
@end
