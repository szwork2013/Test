//
//  LoginAndRegisterView.m
//  learn
//
//  Created by 翟鹏程 on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "LoginAndRegisterView.h"

@implementation LoginAndRegisterView
@synthesize loginButton, registerButton;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor =
            [UIColor colorWithRed:0 green:142 / 256.0 blue:236 / 256.0 alpha:1];
        //        self.alpha = 0.5;
        [self initWithUI];
    }
    return self;
}

- (void)initWithUI {
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setFrame:CGRectMake(0, 0, self.frame.size.width / 2,
                                     self.frame.size.height)];
    [loginButton setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];
    [loginButton
        setTitleColor:
            [UIColor colorWithRed:0 green:107 / 256.0 blue:178 / 256.0 alpha:1]
             forState:UIControlStateHighlighted];
    [loginButton addTarget:self
                    action:@selector(buttonClick:)
          forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.tag = 10000;
    [self addSubview:loginButton];

    registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton
        setFrame:CGRectMake(self.frame.size.width / 2, 0,
                            self.frame.size.width / 2, self.frame.size.height)];
    [registerButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
    [registerButton
        setTitleColor:
            [UIColor colorWithRed:0 green:107 / 256.0 blue:178 / 256.0 alpha:1]
             forState:UIControlStateHighlighted];
    [registerButton addTarget:self
                       action:@selector(buttonClick:)
             forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    registerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    registerButton.tag = 10001;
    [self addSubview:registerButton];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [line setBackgroundColor:[UIColor colorWithRed:0
                                             green:107 / 256.0
                                              blue:178 / 256.0
                                             alpha:1]];
    [self addSubview:line];

    UIView *centerLine =
        [[UIView alloc] initWithFrame:CGRectMake(160, 12, 1, 24)];
    [centerLine setBackgroundColor:[UIColor colorWithRed:0
                                                   green:107 / 256.0
                                                    blue:178 / 256.0
                                                   alpha:1]];
    [self addSubview:centerLine];
}

- (void)buttonClick:(UIButton *)button {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (button.tag == 10000) {
        UIButton *theOtherButton = (UIButton *)[self viewWithTag:10001];
        [theOtherButton setSelected:NO];

    } else {
        UIButton *theOtherButton = (UIButton *)[self viewWithTag:10000];
        [theOtherButton setSelected:NO];
    }
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action withObject:button];
    }
#pragma clang diagnostic pop
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
