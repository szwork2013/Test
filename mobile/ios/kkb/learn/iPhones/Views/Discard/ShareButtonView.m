//
//  ShareButtonView.m
//  learn
//
//  Created by zxj on 7/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "ShareButtonView.h"

@implementation ShareButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonImageArray = [NSArray arrayWithObjects:@"sina.png",@"tencent.png",@"wechat.png",@"friends.png",@"qq.png",@"qzone.png",@"renren.png",@"douban.png",nil];
        
        [self initButton];
        [self setBackgroundColor:[UIColor grayColor]];
    }
    return self;
}
-(void)initButton{
    self.buttonArray = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i < self.buttonImageArray.count; i++) {
        int x = 0;
        int row = 0;
        x = i%4;
        if (x==0 && i>1) {
            row ++;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(22.5+(50+25)*x, 42 +row*(50+34), 50, 50)];
        [button setImage:[UIImage imageNamed:[self.buttonImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [self.buttonArray addObject:button];
        [self addSubview:button];
        
    }
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
