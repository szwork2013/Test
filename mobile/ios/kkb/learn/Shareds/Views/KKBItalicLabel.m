//
//  KKBItalicLabel.m
//  learn
//
//  Created by zengmiao on 8/4/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBItalicLabel.h"

@implementation KKBItalicLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _internalFontSize = 14.0;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _internalFontSize = 14.0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:@"Heiti SC Medium" matrix:matrix];
    self.font = [UIFont fontWithDescriptor:desc size:self.internalFontSize];

}


@end
