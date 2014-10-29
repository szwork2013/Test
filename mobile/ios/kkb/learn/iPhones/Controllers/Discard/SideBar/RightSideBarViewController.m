//
//  RightSideBarViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "RightSideBarViewController.h"
#import "GlobalDefine.h"
#import "LoginAndRegistViewController.h"
#import "GlobalOperator.h"
#import "HomePageOperator.h"
#import "ToolsObject.h"
#import "UIImageView+WebCache.h"
#import "UIImage+fixOrientation.h"
#import "SettingViewController.h"
#import "SidebarViewController.h"
#import "JSONKit.h"
#import "LeftSideBarViewController.h"
#import "AppDelegate.h"
#import "FileUtil.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "MobClick.h"
#import "DownloadManagerViewController.h"
//#import "CourseHomeViewController.h"


@interface RightSideBarViewController (){
    HomePageOperator *homePageOperator;
}

@end

@implementation RightSideBarViewController
@synthesize lbNick,loginBtn,avaterView;
@synthesize allCourseBtn,myCourseBtn,downloadManagerBtn;
@synthesize lbMyCourse,lbAllCourse;

@synthesize homeViewController;
@synthesize nav;
@synthesize levelTwoView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginView) name:@"updateLogInView" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]){
        LoginAndRegistViewController *controller = nil;
        if(IS_IPHONE_5){
            controller = [[LoginAndRegistViewController alloc]initWithNibName:@"LoginAndRegistViewController_iph5" bundle:nil];
        }else{
            controller = [[LoginAndRegistViewController alloc]initWithNibName:@"LoginAndRegistViewController" bundle:nil];
        }
        
        
        [self presentViewController:controller animated:NO completion:nil];
        controller.registView.hidden = NO;
        controller.btnBack.hidden = YES;
        controller.btnBack2.hidden = YES;
        controller.logoView.hidden = NO;
        controller.logoView2.hidden = NO;
        controller.btnToHomeView.hidden = NO;
    }
    
    
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject getTokenJSONFilePath]])
    {
        NSString *json = [NSString stringWithContentsOfFile:[ToolsObject getTokenJSONFilePath] encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *tokenDictionary = [json objectFromJSONString];
        
        NSString *token = [tokenDictionary objectForKey:@"access_token"];
        [GlobalOperator sharedInstance].userId = [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
        [KKBUserInfo shareInstance].userId = [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
        [GlobalOperator sharedInstance].isLogin = YES;

        [GlobalOperator sharedInstance].user4Request.user.avatar.token = token;
        [[KKBHttpClient shareInstance] setUserToken:token];
        
        //根据本地cache显示ui
        [self uncacheAccountProfiles];
        
        lbNick.text  = [GlobalOperator sharedInstance].user4Request.user.short_name;
        loginBtn.hidden = YES;
        myCourseBtn.hidden = NO;
        lbMyCourse.hidden = NO;
        
        [self.downloadManagerBtn setHidden:NO];
        [self.downloadManagerLabel setHidden:NO];
        
        [avaterView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject adaptImageURL:[GlobalOperator sharedInstance].user4Request.user.avatar.url]] placeholderImage:[UIImage imageNamed:@"avater_Default.png"]];
        if([ToolsObject isExistenceNetwork]){
            //[self getAccountProfiles:[GlobalOperator sharedInstance].userId token:token];
            [self getAccountProfiles];
           
        }
        
    }

    
    if(![GlobalOperator sharedInstance].isLogin){
        myCourseBtn.hidden = YES;
        lbMyCourse.hidden = YES;
        
        [self.downloadManagerBtn setHidden:YES];
        [self.downloadManagerLabel setHidden:YES];
    }
    
    
    [lbMyCourse setTextColor:[UIColor lightGrayColor]];
    [self.downloadManagerLabel setTextColor:[UIColor lightGrayColor]];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateLoginView];
    [super viewWillAppear:YES];
}
- (void)updateLoginView
{
    if([GlobalOperator sharedInstance].isLogin == YES){
        [avaterView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject adaptImageURL:[GlobalOperator sharedInstance].user4Request.user.avatar.url]] placeholderImage:avaterView.image];
        lbNick.text  = [GlobalOperator sharedInstance].user4Request.user.short_name;
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"])
    {
        if([GlobalOperator sharedInstance].user4Request.user.avatar.token != nil){
            //[self getAccountProfiles:[GlobalOperator sharedInstance].userId token:[GlobalOperator sharedInstance].user4Request.user.avatar.token];
            [self getAccountProfiles];
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateLogInView" object:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)showLoginView:(id)sender
{
    LoginAndRegistViewController *controller = nil;
    if(IS_IPHONE_5){
        controller = [[LoginAndRegistViewController alloc]initWithNibName:@"LoginAndRegistViewController_iph5" bundle:nil];
    }else{
        controller = [[LoginAndRegistViewController alloc]initWithNibName:@"LoginAndRegistViewController" bundle:nil];
    }
    
    controller.btnBack.hidden = NO;
    controller.btnBack2.hidden = NO;
    controller.logoView.hidden = YES;
    controller.logoView2.hidden = YES;
    controller.sideBarViewController = self;
    
    [self presentViewController:controller animated:NO completion:nil];
    controller.loginView.hidden = NO;
    controller.registView.hidden = YES;
    
    
}
- (void)showHomeView
{
    if ([[SidebarViewController share] respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        if([[SidebarViewController share] getSideBarShowing] == YES){
            [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionNone];
        }else{
            [[SidebarViewController share] showSideBarControllerWithDirection:SideBarShowDirectionRight];
        }
    }
}

-(void)removeMyCourse
{
    if (self.homeViewController.myCoursesDataArray != nil) {
        [self.homeViewController.myCoursesDataArray removeAllObjects];
    }
}
-(IBAction)showAllCourseView
{   self.homeViewController.allCourseContentView.hidden = NO;
    self.homeViewController.allCourseButton.hidden = NO;
    self.homeViewController.courseLabel.hidden = NO;
    [MobClick endLogPageView:@"my_course"];
    [MobClick beginLogPageView:@"all_courses"];
    
    [self.myCourseBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.allCourseBtn setBackgroundImage:[UIImage imageNamed:@"button_selected.png"] forState:UIControlStateNormal];
    [self.downloadManagerBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    [lbAllCourse setTextColor:[UIColor whiteColor]];
    [lbMyCourse setTextColor:[UIColor lightGrayColor]];
    [self.downloadManagerLabel setTextColor:[UIColor lightGrayColor]];
    
    [homeViewController popDownloadManagerView];
    [homeViewController showAllCourse];
    if ([ToolsObject getIsNotFromLoginView] == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLogInView" object:nil];
    }
    [self showHomeView];
    
}
-(IBAction)showmyCourseView
{
    self.homeViewController.allCourseContentView.hidden = YES;
    self.homeViewController.allCourseButton.hidden = YES;
    self.homeViewController.courseLabel.hidden = YES;
    [MobClick endLogPageView:@"all_courses"];
    [MobClick beginLogPageView:@"my_course"];

     [self.allCourseBtn setBackgroundImage:nil forState:UIControlStateNormal];
     [self.myCourseBtn setBackgroundImage:[UIImage imageNamed:@"button_selected.png"] forState:UIControlStateNormal];
    [self.downloadManagerBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
     [lbMyCourse setTextColor:[UIColor whiteColor]];
     [lbAllCourse setTextColor:[UIColor lightGrayColor]];
     [self.downloadManagerLabel setTextColor:[UIColor lightGrayColor]];
    
    [homeViewController popDownloadManagerView];
    [homeViewController showMyCourseView];
     [self showHomeView];
}

-(IBAction)showDownloadManager
{
    
    [self.myCourseBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.allCourseBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.downloadManagerBtn setBackgroundImage:[UIImage imageNamed:@"button_selected.png"] forState:UIControlStateNormal];
    
    [lbAllCourse setTextColor:[UIColor lightGrayColor]];
    [lbMyCourse setTextColor:[UIColor lightGrayColor]];
    [self.downloadManagerLabel setTextColor:[UIColor whiteColor]];
    
    [homeViewController showDownloadManagerView];
    [self showHomeView];
}

- (IBAction)showQRCode:(id)sender {
    [homeViewController showQRCodeViewController];
    [self showHomeView];
}

- (IBAction)showIFLY:(id)sender {
    [homeViewController showIFlyViewController];
    [self showHomeView];
}

-(IBAction)showSettingView
{
    SettingViewController *controller = nil;
    if(IS_IPHONE_5){
        controller = [[SettingViewController alloc]initWithNibName:@"SettingViewController_iph5" bundle:nil];
    }else{
        controller = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    }
    controller.sideBarViewController = self;
    
//    UINavigationController *navigationController = [[[UINavigationController alloc]initWithRootViewController:controller] autorelease];
//    navigationController.navigationBarHidden = YES;
    

    [self presentViewController:controller animated:YES completion:nil];
    
}



- (void)getAccountProfiles
{
    
    //[homePageOperator requestAccountProfiles:self token:token accoundId:accountId];
    
      NSString *jsonUrl = [NSString stringWithFormat:@"users/%@/profile", [KKBUserInfo shareInstance].userId];
    
    //[self getJSONFromUrl:delegate command:HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES jsonUrl:jsonUrl token:token];
    
    [[KKBHttpClient shareInstance]requestLMSUrlPath:jsonUrl method:@"GET" param:nil fromCache:NO success:^(id result){
        
        NSDictionary *accountProfilesDictionary =result;
        [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id = [accountProfilesDictionary objectForKey:@"login_id"];
        
        [GlobalOperator sharedInstance].user4Request.user.name = [accountProfilesDictionary objectForKey:@"name"];
        [GlobalOperator sharedInstance].user4Request.user.short_name = [accountProfilesDictionary objectForKey:@"short_name"];
        [GlobalOperator sharedInstance].user4Request.user.sortable_name = [GlobalOperator sharedInstance].user4Request.user.name;
        
        NSString *regex = @"upaiyun.com";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
        if ([predicate evaluateWithObject:[accountProfilesDictionary objectForKey:@"avatar_url"]])
        {
            [GlobalOperator sharedInstance].user4Request.user.avatar.url = [accountProfilesDictionary objectForKey:@"avatar_url"];
            
        }
        else
        {
            //本地默认的头像
            [GlobalOperator sharedInstance].user4Request.user.avatar.url = [[NSBundle mainBundle] pathForResource:@"icon_login_normal" ofType:@"png"];
        }
        [GlobalOperator sharedInstance].isLogin = YES;

        lbNick.text  = [GlobalOperator sharedInstance].user4Request.user.short_name;
        loginBtn.hidden = YES;
        
        myCourseBtn.hidden = NO;
        lbMyCourse.hidden = NO;
        
        [self.downloadManagerBtn setHidden:NO];
        [self.downloadManagerLabel setHidden:NO];
        
        [avaterView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject adaptImageURL:[GlobalOperator sharedInstance].user4Request.user.avatar.url]] placeholderImage:[UIImage imageNamed:@"avater_Default.png"]];
        //获取我的课程信息
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SETTING_VIEW object:nil];
   

    
    } failure:^(id result){}];

}
//- (void)requestSuccess:(NSString *)cmd
//{
//    if ([cmd compare:HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES] == NSOrderedSame)
//    {
//        [GlobalOperator sharedInstance].isLogin = YES;
//        
//        lbNick.text  = [GlobalOperator sharedInstance].user4Request.user.short_name;
//        loginBtn.hidden = YES;
//        myCourseBtn.hidden = NO;
//        lbMyCourse.hidden = NO;
//        [avaterView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject adaptImageURL:[GlobalOperator sharedInstance].user4Request.user.avatar.url]] placeholderImage:[UIImage imageNamed:@"avater_Default.png"]];
//        //获取我的课程信息
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SETTING_VIEW object:nil];
//    }
//
//}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)uncacheAccountProfiles
{
    NSString* cacheFileName= CACHE_HOMEPAGE_SELFINFO;
    //unarchiver
    NSString* courseCategoryPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_HOMEPAGE_SELFINFO ,nil];
    NSArray *accountProfilesArr = [NSKeyedUnarchiver unarchiveObjectWithFile:courseCategoryPath];
    if (accountProfilesArr!=nil&& accountProfilesArr.count>0) {
        [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id = [accountProfilesArr objectAtIndex:0];
        [GlobalOperator sharedInstance].user4Request.user.name = [accountProfilesArr objectAtIndex:1];
        [GlobalOperator sharedInstance].user4Request.user.short_name = [accountProfilesArr objectAtIndex:2];
        [GlobalOperator sharedInstance].user4Request.user.avatar.url = [accountProfilesArr objectAtIndex:3];

    }
    
    
}
- (IBAction)test:(UIButton *)sender {
   [homeViewController showTestViewCtr];
    [self showHomeView];
}
@end
