//
//  LeftSideBarInPadViewController.m
//  learn
//
//  Created by User on 14-3-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "LeftSideBarInPadViewController.h"
#import "HomePageViewController.h"
#import "SideBarSelectedInPadDelegate.h"
#import "SidebarViewControllerInPadViewController.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "UIImageView+WebCache.h"
#import "FileUtil.h"
@interface LeftSideBarInPadViewController ()

@end

@implementation LeftSideBarInPadViewController
@synthesize delegate;
@synthesize homeController;

@synthesize myCourseLabel, allCourseLabel, selfLabel, loginLabel,
    downloadManageLabel, imvDownloadManage;
@synthesize imvAllCourse, imvMyCourse, imvSelf, avatarImage;
@synthesize settingButton;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([delegate
            respondsToSelector:@selector(
                                   leftSideBarSelectWithControllerInPad:)]) {
        [delegate
            leftSideBarSelectWithControllerInPad:[self subConWithIndex:0]];
    }

    //从缓存加载我的信息
    [self uncacheAccountProfiles];
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {

        [avatarImage
            sd_setImageWithURL:
                [NSURL URLWithString:
                           [AppUtilities
                               adaptImageURL:[GlobalOperator sharedInstance]
                                                 .user4Request.user.avatar.url]]
              placeholderImage:[UIImage
                                   imageNamed:@"sidebar_icon_login_normal"]];
        loginLabel.text =
            [GlobalOperator sharedInstance].user4Request.user.short_name;
        [loginLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                 green:188.0 / 255.0
                                                  blue:188.0 / 255.0
                                                 alpha:1]];

    } else {
        loginLabel.text = @"登录/注册";
        [loginLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                 green:69.0 / 255.0
                                                  blue:69.0 / 255.0
                                                 alpha:1]];

        avatarImage.image = [UIImage imageNamed:@"sidebar_icon_login_normal"];
        [GlobalOperator sharedInstance].isLogin = NO;

        selfLabel.hidden = YES;
        myCourseLabel.hidden = YES;
        imvSelf.hidden = YES;
        imvMyCourse.hidden = YES;

        imvDownloadManage.hidden = YES;
        downloadManageLabel.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UINavigationController *)subConWithIndex:(int)index {
    HomePageViewController *con = [[HomePageViewController alloc]
        initWithNibName:@"HomePageViewController"
                 bundle:nil];
    con.index = index + 1;
    self.homeController = con;
    con.leftDelegate = self;
    //    [con setDelegate:self];

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:con];
    nav.navigationBar.hidden = YES;
    return nav;
}
- (void)showHomeView {
    if ([[SidebarViewControllerInPadViewController share]
            respondsToSelector:@selector(
                                   showSideBarControllerWithDirectionInPad:)]) {
        if ([[SidebarViewControllerInPadViewController
                    share] getSideBarInPadShowing] == YES) {
            [[SidebarViewControllerInPadViewController share]
                showSideBarControllerWithDirectionInPad:
                    SideBarShowInPadDirectionNone];
        } else {
            [[SidebarViewControllerInPadViewController share]
                showSideBarControllerWithDirectionInPad:
                    SideBarShowInPadDirectionLeft];
        }
    }
}
- (IBAction)showAllCourseView:(id)sender {
    [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
    [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                            green:69.0 / 255.0
                                             blue:69.0 / 255.0
                                            alpha:1]];
    [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                      green:69.0 / 255.0
                                                       blue:69.0 / 255.0
                                                      alpha:1]];

    [allCourseLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                 green:188.0 / 255.0
                                                  blue:188.0 / 255.0
                                                 alpha:1]];

    [imvAllCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_selected"]];
    [imvDownloadManage
        setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
    [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
    [imvMyCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

    [settingButton setBackgroundImage:[UIImage imageNamed:@"button_set_normal"]
                             forState:UIControlStateNormal];
    [self showHomeView];
    [self.homeController allCoursesButtonOnClick];
}
- (IBAction)showMyCourseView:(id)sender {
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {

        [myCourseLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                    green:188.0 / 255.0
                                                     blue:188.0 / 255.0
                                                    alpha:1]];
        [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
        [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                          green:69.0 / 255.0
                                                           blue:69.0 / 255.0
                                                          alpha:1]];

        [allCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                     green:69.0 / 255.0
                                                      blue:69.0 / 255.0
                                                     alpha:1]];

        [imvAllCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_normal"]];
        [imvDownloadManage
            setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
        [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
        [imvMyCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_selected"]];

        [settingButton
            setBackgroundImage:[UIImage imageNamed:@"button_set_normal"]
                      forState:UIControlStateNormal];

        [self showHomeView];
        [self.homeController myCoursesButtonOnClick];
    }
}
- (IBAction)showActivityView:(id)sender {
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {

        [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                    green:69.0 / 255.0
                                                     blue:69.0 / 255.0
                                                    alpha:1]];
        [selfLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                green:188.0 / 255.0
                                                 blue:188.0 / 255.0
                                                alpha:1]];
        [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                          green:69.0 / 255.0
                                                           blue:69.0 / 255.0
                                                          alpha:1]];

        [allCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                     green:69.0 / 255.0
                                                      blue:69.0 / 255.0
                                                     alpha:1]];

        [imvAllCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_normal"]];
        [imvDownloadManage
            setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
        [imvSelf
            setImage:[UIImage imageNamed:@"sidebar_icon_recently_selected"]];
        [imvMyCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

        [settingButton
            setBackgroundImage:[UIImage imageNamed:@"button_set_normal"]
                      forState:UIControlStateNormal];
        [self showHomeView];
        [self.homeController selfButtonOnClick];
    }
}
- (IBAction)showDownloadView:(id)sender {
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {

        [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                    green:69.0 / 255.0
                                                     blue:69.0 / 255.0
                                                    alpha:1]];
        [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
        [downloadManageLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                          green:188.0 / 255.0
                                                           blue:188.0 / 255.0
                                                          alpha:1]];

        [allCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                     green:69.0 / 255.0
                                                      blue:69.0 / 255.0
                                                     alpha:1]];

        [imvAllCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_normal"]];
        [imvDownloadManage
            setImage:[UIImage imageNamed:@"sidebar_icon_download_selected"]];
        [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
        [imvMyCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

        [settingButton
            setBackgroundImage:[UIImage imageNamed:@"button_set_normal"]
                      forState:UIControlStateNormal];

        [self showHomeView];
        [self.homeController downloadManageButtonOnClick];
    }
}
- (IBAction)showSettingView:(id)sender {
    [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
    [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                            green:69.0 / 255.0
                                             blue:69.0 / 255.0
                                            alpha:1]];
    [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                      green:69.0 / 255.0
                                                       blue:69.0 / 255.0
                                                      alpha:1]];

    [allCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                 green:69.0 / 255.0
                                                  blue:69.0 / 255.0
                                                 alpha:1]];

    [imvAllCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_normal"]];
    [imvDownloadManage
        setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
    [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
    [imvMyCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

    [settingButton
        setBackgroundImage:[UIImage imageNamed:@"button_set_selected"]
                  forState:UIControlStateNormal];

    [self showHomeView];
    [self.homeController settingsButtonOnClick];
}
- (IBAction)loginButtonOnClick:(id)sender {
    if (![[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {
        [self showHomeView];

        [self.homeController loginButtonOnClick];
    }
}
- (void)editSuccess {
    [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
    [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                            green:69.0 / 255.0
                                             blue:69.0 / 255.0
                                            alpha:1]];
    [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                      green:69.0 / 255.0
                                                       blue:69.0 / 255.0
                                                      alpha:1]];

    [allCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                 green:69.0 / 255.0
                                                  blue:69.0 / 255.0
                                                 alpha:1]];

    [imvAllCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_normal"]];
    [imvDownloadManage
        setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
    [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
    [imvMyCourse
        setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

    [settingButton
        setBackgroundImage:[UIImage imageNamed:@"button_set_selected"]
                  forState:UIControlStateNormal];
}
- (void)controllSidebar:(BOOL)isLogin {
    if (isLogin == YES) {

        selfLabel.hidden = NO;
        myCourseLabel.hidden = NO;
        imvSelf.hidden = NO;
        imvMyCourse.hidden = NO;

        imvDownloadManage.hidden = NO;
        downloadManageLabel.hidden = NO;

        [avatarImage
            sd_setImageWithURL:
                [NSURL URLWithString:
                           [AppUtilities
                               adaptImageURL:[GlobalOperator sharedInstance]
                                                 .user4Request.user.avatar.url]]
              placeholderImage:[UIImage imageNamed:@"avater_Default"]];
        loginLabel.text =
            [GlobalOperator sharedInstance].user4Request.user.short_name;
        [loginLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                 green:188.0 / 255.0
                                                  blue:188.0 / 255.0
                                                 alpha:1]];

        [myCourseLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                    green:69.0 / 255.0
                                                     blue:69.0 / 255.0
                                                    alpha:1]];
        [selfLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                green:69.0 / 255.0
                                                 blue:69.0 / 255.0
                                                alpha:1]];
        [downloadManageLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                          green:69.0 / 255.0
                                                           blue:69.0 / 255.0
                                                          alpha:1]];

        [allCourseLabel setTextColor:[UIColor colorWithRed:188.0 / 255.0
                                                     green:188.0 / 255.0
                                                      blue:188.0 / 255.0
                                                     alpha:1]];

        [imvAllCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_allcourses_selected"]];
        [imvDownloadManage
            setImage:[UIImage imageNamed:@"sidebar_icon_download_normal"]];
        [imvSelf setImage:[UIImage imageNamed:@"sidebar_icon_recently_normal"]];
        [imvMyCourse
            setImage:[UIImage imageNamed:@"sidebar_icon_mycourses_normal"]];

        [settingButton
            setBackgroundImage:[UIImage imageNamed:@"button_set_normal"]
                      forState:UIControlStateNormal];

    } else {

        loginLabel.text = @"登录/注册";
        [loginLabel setTextColor:[UIColor colorWithRed:69.0 / 255.0
                                                 green:69.0 / 255.0
                                                  blue:69.0 / 255.0
                                                 alpha:1]];
        avatarImage.image = [UIImage imageNamed:@"sidebar_icon_login_normal"];
        [GlobalOperator sharedInstance].isLogin = NO;

        selfLabel.hidden = YES;
        myCourseLabel.hidden = YES;
        imvSelf.hidden = YES;
        imvMyCourse.hidden = YES;

        imvDownloadManage.hidden = YES;
        downloadManageLabel.hidden = YES;
    }
}

- (void)uncacheAccountProfiles {
    NSString *cacheFileName = CACHE_HOMEPAGE_SELFINFO;
    // unarchiver
    NSString *courseCategoryPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_SELFINFO, nil];
    NSArray *accountProfilesArr =
        [NSKeyedUnarchiver unarchiveObjectWithFile:courseCategoryPath];

    @try {
        [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id =
            [accountProfilesArr objectAtIndex:0];
        [GlobalOperator sharedInstance].user4Request.user.name =
            [accountProfilesArr objectAtIndex:1];
        [GlobalOperator sharedInstance].user4Request.user.short_name =
            [accountProfilesArr objectAtIndex:2];
        [GlobalOperator sharedInstance].user4Request.user.avatar.url =
            [accountProfilesArr objectAtIndex:3];
    }
    @catch (NSException *exception) {
        NSLog(@"exception in method: uncacheAccountProfiles");
    }
    @finally {
    }
}

@end
