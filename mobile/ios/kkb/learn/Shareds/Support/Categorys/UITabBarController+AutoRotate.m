//
//  UITabBarController+AutoRotate.m
//  learn
//
//  Created by xgj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "UITabBarController+AutoRotate.h"

@implementation UITabBarController (AutoRotate)

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
