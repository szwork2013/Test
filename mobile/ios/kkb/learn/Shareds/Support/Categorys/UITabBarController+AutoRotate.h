//
//  UITabBarController+AutoRotate.h
//  learn
//
//  Created by xgj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (AutoRotate)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
