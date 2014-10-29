//
//  MyMicroMajorFooterView.m
//  learn
//
//  Created by xgj on 8/15/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "MyMicroMajorFooterView.h"

@implementation MyMicroMajorFooterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor whiteColor];

        self.footerImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, (frame.size.height - 36) / 2, 36, 36)];
        self.footerImageView.image =
            [UIImage imageNamed:@"mic_pro_button_check_dis"];

        self.textlabel = [[UILabel alloc]
            initWithFrame:CGRectMake(50, 0, 100, frame.size.height)];
        self.textlabel.text = @"最终考核";
        self.textlabel.textColor = [UIColor grayColor];

        self.indicatorImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(240, (frame.size.height - 16) / 2, 48,
                                     16)];
        self.indicatorImageView.image =
            [UIImage imageNamed:@"mic_pro_button_wait_dis"];

        [self addSubview:self.footerImageView];
        [self addSubview:self.textlabel];
        [self addSubview:self.indicatorImageView];
    }
    return self;
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
