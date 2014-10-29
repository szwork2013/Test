//
//  SidebarLevelTwoViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-28.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedDelegate.h"
#import "LeftSideBarViewController.h"
#import "RightLevelTwoViewController.h"
@interface SidebarLevelTwoViewController : UIViewController<SideBarSelectDelegate,UINavigationControllerDelegate>
{
    UIViewController  *_currentMainController;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}


@property (strong,nonatomic)IBOutlet UIView *contentView;
@property (strong,nonatomic)IBOutlet UIView *navBackView;
@property (strong,nonatomic)LeftSideBarViewController *leftSideBarViewController;
@property (strong,nonatomic)RightLevelTwoViewController *rightSideBarViewController;
+ (id)share;
@end
