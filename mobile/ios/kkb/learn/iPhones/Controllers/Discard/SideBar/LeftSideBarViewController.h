//
//  LeftSideBarViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightSideBarViewController.h"
#import "RightLevelTwoViewController.h"
@protocol SideBarSelectDelegate ;

@interface LeftSideBarViewController : UIViewController

@property (assign,nonatomic)id<SideBarSelectDelegate>delegate;
@property (retain,nonatomic)RightSideBarViewController * right;
@property (retain,nonatomic)RightLevelTwoViewController * rightTwo;

@end
