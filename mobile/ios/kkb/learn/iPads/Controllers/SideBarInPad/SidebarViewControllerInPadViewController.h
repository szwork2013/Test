//
//  SidebarViewControllerInPadViewController.h
//  learn
//
//  Created by User on 14-3-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedInPadDelegate.h"
#import "HomePageViewController.h"
@interface SidebarViewControllerInPadViewController : UIViewController<SideBarSelectedInPadDelegate,UINavigationControllerDelegate>


@property (strong,nonatomic)IBOutlet UIView *contentView;
@property (strong,nonatomic)IBOutlet UIView *navBackView;
@property (strong,nonatomic)HomePageViewController *homePage;

+ (id)share;

@end
