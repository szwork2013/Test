//
//  RightSideBarViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"



@interface RightSideBarViewController : UIViewController
@property (nonatomic,retain) IBOutlet UIButton * loginBtn;
@property (nonatomic,retain) IBOutlet UIButton * allCourseBtn;
@property (nonatomic,retain) IBOutlet UIButton * myCourseBtn;
@property (nonatomic,retain) IBOutlet UIButton * downloadManagerBtn;
@property (nonatomic,retain) IBOutlet UIImageView * avaterView;
@property (nonatomic,retain) IBOutlet UILabel * lbNick;
@property (nonatomic,retain) IBOutlet UILabel * lbMyCourse;
@property (nonatomic,retain) IBOutlet UILabel * lbAllCourse;
@property (nonatomic,retain) IBOutlet UILabel * downloadManagerLabel;

@property (nonatomic,retain) IBOutlet UIView * levelTwoView;
@property (nonatomic,retain) HomeViewController * homeViewController;
@property (retain,nonatomic)UINavigationController *nav;
-(IBAction)showLoginView:(id)sender;
- (void)getAccountProfiles;
-(IBAction)showSettingView;
-(void)removeMyCourse;
-(IBAction)showAllCourseView;
-(IBAction)showmyCourseView;
-(IBAction)showDownloadManager;
- (IBAction)showQRCode:(id)sender;
- (IBAction)showIFLY:(id)sender;
@end



