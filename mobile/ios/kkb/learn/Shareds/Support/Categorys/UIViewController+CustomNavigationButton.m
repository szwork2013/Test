//
//  UIViewController+CustomNavigationButton.m
//  learn
//
//  Created by zengmiao on 8/7/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "UIViewController+CustomNavigationButton.h"

#define BAR_BUTTON_WIDTH 30
#define BAR_BUTTOM_HEIGHT 35
@implementation UIViewController (CustomNavigationButton)

/**
 *  自定义导航栏返回按钮
 *
 *  @param name            图片名称
 *  @param highLightedName highLightedName description
 */
- (void)kkb_customLeftNarvigationBarWithImageName:(NSString *)name
                                  highlightedName:(NSString *)highLightedName {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *normalImgName = name;
    NSString *highlightedImgName = highLightedName;
    if (!normalImgName) {
        normalImgName = @"v3_button_back_normal";
    }
    if (!highlightedImgName) {
        highlightedImgName = @"v3_button_back_selected";
    }
    [btn setImage:[UIImage imageNamed:normalImgName]
         forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImgName]
         forState:UIControlStateHighlighted];

    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [btn addTarget:self
                  action:@selector(backBtnTapped)
        forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, BAR_BUTTON_WIDTH, BAR_BUTTON_WIDTH);

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

/**
 *  自定义导航栏返回按钮
 *
 *  @param title title 默认 "返回"
 */
- (void)kkb_customLeftNarvigationBarWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *normalTitle = title;
    NSString *highlightedTitle = title;
    if (!normalTitle) {
        normalTitle = @"返回";
    }
    if (!highlightedTitle) {
        highlightedTitle = @"返回";
    }
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    [btn setTitle:highlightedTitle forState:UIControlStateHighlighted];

    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [btn addTarget:self
                  action:@selector(backBtnTapped)
        forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, BAR_BUTTON_WIDTH, BAR_BUTTOM_HEIGHT);

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barItem;
}

/**
 *  自定义导航栏右侧按钮
 *
 *  @param title title 默认 "完成"
 */
- (void)kkb_customRightNarvigationBarWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *normalTitle = title;
    NSString *highlightedTitle = title;
    if (!normalTitle) {
        normalTitle = @"完成";
    }
    if (!highlightedTitle) {
        highlightedTitle = @"完成";
    }
    [btn setTitle:normalTitle forState:UIControlStateNormal];
    [btn setTitle:highlightedTitle forState:UIControlStateHighlighted];

    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [btn addTarget:self
                  action:@selector(rightBtnTapped)
        forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, BAR_BUTTON_WIDTH, BAR_BUTTOM_HEIGHT);

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

/**
 *  自定义导航栏右侧按钮
 *
 *  @param name            图片名称 默认 ZXNavAdd.png
 *  @param highLightedName highLightedName description
 */
- (void)kkb_customRightNarvigationBarWithImageName:(NSString *)name
                                   highlightedName:(NSString *)highLightedName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    if (!name) {
        name = @"";
    }
    if (!highLightedName) {
        highLightedName = @"";
    }
    [btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highLightedName]
         forState:UIControlStateHighlighted];

    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [btn addTarget:self
                  action:@selector(rightBtnTapped)
        forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, BAR_BUTTON_WIDTH, BAR_BUTTOM_HEIGHT);

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barItem;
}

- (void)backBtnTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnTapped {
}

@end
