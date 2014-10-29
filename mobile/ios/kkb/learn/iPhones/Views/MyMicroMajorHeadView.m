//
//  MyMicroMajorHeadView.m
//  learn
//
//  Created by zxj on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MyMicroMajorHeadView.h"

@implementation MyMicroMajorHeadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.headImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(0, 0, frame.size.width,
                                     frame.size.height)];
        self.headImageView.image = [UIImage imageNamed:@"mic_pro_title_bg"];

        self.majorNameLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(12, 0, 220, frame.size.height)];
        self.majorNameLabel.textColor = [UIColor whiteColor];

        self.progressLabel = [[UILabel alloc]
            initWithFrame:CGRectMake(256, 0, 36, frame.size.height)];
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        self.progressLabel.font = [UIFont systemFontOfSize:12];
        self.progressLabel.textColor = [UIColor whiteColor];

        [self addSubview:self.headImageView];
        [self addSubview:self.majorNameLabel];
        [self addSubview:self.progressLabel];

        [self addTarget:self
                      action:@selector(viewDidSelect)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidSelect {
    [self.delegate headerViewDidSelectInSection:self.section];
}

- (void)initSubview {
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
