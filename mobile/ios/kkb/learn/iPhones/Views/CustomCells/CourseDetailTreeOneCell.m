//
//  CourseDetailTreeOneCell.m
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseDetailTreeOneCell.h"

@implementation CourseDetailTreeOneCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)accessibilityLabel
{
    return self.textLabel.text;
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        //[self _updateDetailTextLabel];
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        //[self _updateDetailTextLabel];
        if (expansionStyle == UIExpansionStyleExpanded) {
            [self.statusImageView setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-up"]];
        }else if (expansionStyle == UIExpansionStyleCollapsed){
            [self.statusImageView setImage:[UIImage imageNamed:@"kkb-iphone-common-arrow-down"]];
        }
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //[self _updateDetailTextLabel];
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)_updateDetailTextLabel
{
    if (self.isLoading) {
        self.detailTextLabel.text = @"Loading data";
    } else {
        switch (self.expansionStyle) {
            case UIExpansionStyleExpanded:
                self.detailTextLabel.text = @"Click to collapse";
                break;
            case UIExpansionStyleCollapsed:
                self.detailTextLabel.text = @"Click to expand";
                break;
        }
    }
}


@end
