//
//  ViewController.h
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedDelegate.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"

@interface SidebarViewController : UIViewController<SideBarSelectDelegate,UINavigationControllerDelegate>
{
    UIViewController  *_currentMainController;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}

@property (strong,nonatomic)LeftSideBarViewController *leftSideBarViewController;
@property (strong,nonatomic)RightSideBarViewController *rightSideBarViewController;

@property (strong,nonatomic)IBOutlet UIView *contentView;
@property (strong,nonatomic)IBOutlet UIView *navBackView;

+ (id)share;

@end
