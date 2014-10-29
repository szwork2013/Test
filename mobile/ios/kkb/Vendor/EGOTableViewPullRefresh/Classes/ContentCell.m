//
//  ContentCell.m
//  learn
//
//  Created by zxj on 6/25/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "ContentCell.h"
#import "UIView+ViewFrameGeometry.h"
@implementation ContentCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label = [[UILabel alloc] initWithFrame:self.contentView.bounds];

        self.label.opaque = NO;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        // self.label.backgroundColor = [UIColor redColor];

        self.label.font = [[self class] defaultFont];
        self.label.textColor =
            [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        [self.contentView addSubview:self.label];
        self.lineImageView = [[UIImageView alloc]
            initWithImage:[UIImage imageNamed:@"category-filter_line"]];
        [self.lineImageView
            setFrame:CGRectMake(self.contentView.right + 16, 0, 1, 22)];
        [self addSubview:self.lineImageView];
        self.backgroundColor = [UIColor greenColor];
        self.contentView.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

+ (UIFont *)defaultFont {
    return [UIFont boldSystemFontOfSize:13];
}

+ (CGSize)sizeForContentString:(NSString *)s {
    // CGSize textSize = [s sizeWithFont:[self defaultFont]
    // constrainedToSize:CGSizeMake(300, 1000)
    // lineBreakMode:NSLineBreakByCharWrapping];

    NSDictionary *dic = @{NSFontAttributeName : [[self class] defaultFont]};

    CGSize textSize = [s sizeWithAttributes:dic];

    return textSize;
}

- (NSString *)text {
    return self.label.text;
}
- (void)setText:(NSString *)text {
    self.label.text = text;
    CGRect newLabelFrame = self.label.frame;
    CGRect newContentFrame = self.contentView.frame;
    CGSize textSize = [[self class] sizeForContentString:text];
    newLabelFrame.size = textSize;
    newContentFrame.size = textSize;
    self.label.frame = newLabelFrame;
    self.contentView.frame = newContentFrame;
    //    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
    //
    //    transform = CGAffineTransformScale(transform, 0.8, 0.8);
    //
    //    [self.contentView setTransform:transform];
    //    self.label.top = (self.height-self.label.height)/2;
    //    self.label.left = (self.width-self.label.width)/2;
    self.contentView.top = (self.height - self.label.height) / 2;
    self.contentView.left = (self.width - self.label.width) / 2;
    [self.lineImageView
        setFrame:CGRectMake(self.contentView.right + 16, 0, 1, 22)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
