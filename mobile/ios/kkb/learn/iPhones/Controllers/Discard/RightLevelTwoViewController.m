//
//  RightLevelTwoViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-28.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "RightLevelTwoViewController.h"
#import "SidebarLevelTwoViewController.h"
#import "ToolsObject.h"
#import "MobClick.h"

@interface RightLevelTwoViewController ()

@end

@implementation RightLevelTwoViewController
@synthesize UnitBtn,courseBriefBtn,teacherBriefBtn,lbcourseBrief,lbteacherBrief,lbUnit;
@synthesize courseName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)showRight
{
    if ([[SidebarLevelTwoViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        if([[SidebarLevelTwoViewController share] getSideBarShowing] == YES){
            [[SidebarLevelTwoViewController share] showSideBarControllerWithDirection:SideBarShowDirectionNone];
        }else{
            [[SidebarLevelTwoViewController share] showSideBarControllerWithDirection:SideBarShowDirectionRight];
        }
    }
}
-(IBAction)back:(id)sender
{
    
   if (![self.presentedViewController isBeingDismissed])
    {
    [self dismissViewControllerAnimated:NO completion:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.courseName.text = self.HomeViewController.courseName;
    }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"iPhone用户正在进入【右侧二级侧滑菜单】页面"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"iPhone用户正在退出【右侧二级侧滑菜单】页面"];
}

-(IBAction)unitOnclick:(id)sender
{
    [self resetBtn];
    [lbUnit setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];

    [self.UnitBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal.png"] forState:UIControlStateNormal];
    [lbUnit setTextColor:[UIColor whiteColor]];
    [self showRight];
}
-(IBAction)CourseBriefOnclick:(id)sender
{
    [self resetBtn];
    [lbcourseBrief setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [self.courseBriefBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal.png"] forState:UIControlStateNormal];
    [lbcourseBrief setTextColor:[UIColor whiteColor]];
  
    [self showRight];
}
-(IBAction)teacherBriefOnclick:(id)sender
{
    [self resetBtn];
    [lbteacherBrief setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [self.teacherBriefBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal.png"] forState:UIControlStateNormal];
    [lbteacherBrief setTextColor:[UIColor whiteColor]];
   
    [self showRight];

}
-(void)resetBtn
{
    [self.UnitBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal_gray.png"] forState:UIControlStateNormal];
    [self.courseBriefBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal_gray.png"] forState:UIControlStateNormal];
    [self.teacherBriefBtn setBackgroundImage:[UIImage imageNamed:@"sidebar_button_normal_gray.png"] forState:UIControlStateNormal];
    [lbcourseBrief setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    [lbteacherBrief setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    [lbUnit setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    [lbcourseBrief setFont:[UIFont fontWithName:@"Helvetica" size:18]];
     [lbUnit setFont:[UIFont fontWithName:@"Helvetica" size:18]];
     [lbteacherBrief setFont:[UIFont fontWithName:@"Helvetica" size:18]];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
