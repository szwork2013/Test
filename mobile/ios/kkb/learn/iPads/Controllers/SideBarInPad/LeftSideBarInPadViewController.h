//
//  LeftSideBarInPadViewController.h
//  learn
//
//  Created by User on 14-3-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageViewController.h"

@class HomePageViewController;

@protocol leftSideBarDelegate <NSObject>

@optional
- (void)controllSidebar:(BOOL)isLogin;
- (void)editSuccess;


@end


@protocol SideBarSelectedInPadDelegate ;

@interface LeftSideBarInPadViewController : UIViewController<leftSideBarDelegate>

@property (assign,nonatomic)id<SideBarSelectedInPadDelegate>delegate;
@property (retain,nonatomic)HomePageViewController * homeController;



@property (retain, nonatomic) IBOutlet UIImageView *avatarImage; //头像
@property (retain, nonatomic) IBOutlet UILabel *myCourseLabel;
@property (retain, nonatomic) IBOutlet UILabel *allCourseLabel;
@property (retain, nonatomic) IBOutlet UIImageView  *imvAllCourse;
@property (retain, nonatomic) IBOutlet UIImageView  *imvMyCourse;
@property (retain, nonatomic) IBOutlet UIImageView  *imvSelf;
@property (retain, nonatomic) IBOutlet UILabel *loginLabel; //登录前为“登录/注册”，登录后变为“名字”



@property (retain, nonatomic) IBOutlet UILabel *downloadManageLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imvDownloadManage;


@property (retain, nonatomic) IBOutlet UIButton *settingButton;

@property (retain, nonatomic) IBOutlet UILabel *selfLabel;




@end
