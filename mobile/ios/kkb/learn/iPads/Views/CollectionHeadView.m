//
//  CollectionHeadView.m
//  learn
//
//  Created by User on 14-3-10.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CollectionHeadView.h"

@implementation CollectionHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 500, 40)];
        _label.text = @"";
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:18];
        _label.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0];
//        _label.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.6];
        _label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_label];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
         _button.frame = CGRectMake(900, 15, 80, 25);
        _button.hidden = YES;
          [_button setBackgroundImage:[UIImage imageNamed:@"button_deleteall_normal"] forState:UIControlStateNormal];
        
        [self addSubview:_button];
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
