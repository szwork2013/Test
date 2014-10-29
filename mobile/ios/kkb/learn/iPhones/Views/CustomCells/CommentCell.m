//
//  CommentCell.m
//  learn
//
//  Created by 翟鹏程 on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    
    UIImage *bgImage = [UIImage imageNamed:@"v3_card_shadow"];
    UIImage *highlightedImg = [UIImage imageNamed:@"v3_card_shadow_pres"];
    _backgroundImageView.image = bgImage;
    _backgroundImageView.highlightedImage = highlightedImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (KKBStarRatingView *)starRatingView {
    if (!_starRatingView) {
        _starRatingView =
            [[KKBStarRatingView alloc] initWithOrigin:CGPointMake(56, 36)
                                            starCount:5
                                            starWidth:9
                                           starHeight:8
                                              spacing:4
                                          rateEnabled:NO];
        [self.contentView addSubview:_starRatingView];
    }
    return _starRatingView;
}

- (RTLabel *)commentContentNewLabel {
    if (!_commentContentNewLabel) {
        _commentContentNewLabel =
            [[RTLabel alloc] initWithFrame:CGRectMake(12, 60, 290, 14)];
        _commentContentNewLabel.backgroundColor = [UIColor clearColor];
        _commentContentNewLabel.font = [UIFont systemFontOfSize:14];
        _commentContentNewLabel.width = 290;
        [self.contentView addSubview:_commentContentNewLabel];
    }
    return _commentContentNewLabel;
}

@end
