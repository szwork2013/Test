//
//  CourseUnitViewController.m
//  learn
//
//  Created by kaikeba on 13-4-17.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "CourseUnitViewController.h"
#import "JSONKit.h"
#import "GlobalOperator.h"
#import "CourseUnitStructs.h"
#import "Cell1.h"
#import "Cell2.h"
#import "AppUtilities.h"
#import "CourseUnitOperator.h"
#import "AnnouncementViewController.h"
#import "UsersInCourseViewController.h"
#import "UsersInCourseOperator.h"
#import "AppDelegate.h"
#import "DiscussionViewController.h"
#import "AssignmentViewController.h"
#import "FileUtil.h"
#import "UIImageView+WebCache.h"
#import "SidebarViewControllerInPadViewController.h"



#import "FilesDownManage.h"

#import "KKBHttpClient.h"
#import "KKBUserInfo.h"

@interface CourseUnitViewController ()<UIWebViewDelegate>
{
    
    
//    UIImageView *unitCellIcon;
    
    CourseUnitOperator *courseUnitOperator;
    
    UsersInCourseOperator *usersInCourseOperator;
    
    COURSE_SCENE_TYPE currentSceneType;
    
}

//@property (assign) BOOL isOpen;
//@property (nonatomic, retain) NSIndexPath *selectIndex;

@end


@implementation CourseUnitViewController

@synthesize courseId;
@synthesize courseName;
@synthesize currentUnitList;
@synthesize currentSecondLevelUnitList;
@synthesize unitTableView;
//@synthesize isOpen;
//@synthesize selectIndex;
@synthesize contentView;
@synthesize announcementViewController;
@synthesize usersInCourseViewController;
@synthesize discussionViewController;
@synthesize assignmentViewController;
@synthesize openedInSectionArr;
@synthesize lockSectionArr;
@synthesize leftViewTitle;
@synthesize imvAnnouncement,imvCourseBreif,imvDiscuss,imvQuiz,imvTask,imvTeacherBreif,imvUnit,imvUser;
@synthesize lbAnnouncement,lbCourseBreif,lbDiscuss,lbQuiz,lbTask,lbTeacherBreif,lbUnit,lbUser;
@synthesize html;
@synthesize moviePlayer;
@synthesize promoVideoStr;
@synthesize playView;
@synthesize imgStr;
@synthesize lbHasDownlaodNum;
@synthesize lbNODownlaodNum;
@synthesize curtainView;
@synthesize downArr;
@synthesize codeDic;
@synthesize downloadedList;
@synthesize downingList;
@synthesize ableDownload;
@synthesize isLocked;
@synthesize downButton;
@synthesize sidebarGestureR;
@synthesize currentSecondLevelVideoList;
#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.openedInSectionArr  = [[NSMutableArray alloc] init];
        self.lockSectionArr  = [[NSMutableArray alloc] init];
        self.currentSecondLevelUnitList = [[NSMutableArray alloc] init];
        
        self.currentSecondLevelVideoList = [[NSArray alloc] init];
        
        courseUnitOperator = (CourseUnitOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_COURSEUNIT];
        usersInCourseOperator = (UsersInCourseOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_USERSINCOURSE];
    }
    return self;
}
/*
- (id)init
{
    if (self = [super init])
    {
//        self.isOpen = NO;
//        self.currentUnitList = [[[NSMutableArray alloc] init] autorelease];
        self.openedInSectionArr  = [[[NSMutableArray alloc] init] autorelease];
         self.lockSectionArr  = [[[NSMutableArray alloc] init] autorelease];
        self.currentSecondLevelUnitList = [[[NSMutableArray alloc] init] autorelease];
        
        courseUnitOperator = (CourseUnitOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_COURSEUNIT];
        usersInCourseOperator = (UsersInCourseOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_USERSINCOURSE];
    }
    
    return self;
}
*/
//- (void)loadView
//{
//    [super loadView];
//    
////    [self makeLeftView];
//    [self createScenes];
//    currentSceneType = COURSE_SCENE_TYPE_UNIT;
//    
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.downloadedList = [NSMutableDictionary dictionary];
    self.downingList = [NSMutableDictionary dictionary];
    
    [self createScenes];
    currentSceneType = COURSE_SCENE_TYPE_UNIT;

    leftViewTitle.text = [NSString stringWithFormat:@"%@", self.courseName];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
//    [self uncacheModules];
    AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if(delegant.isFromDownLoad == YES){
        
        playView.hidden = NO;
        unitDetailsWebView.frame = CGRectMake(0, 550, 871, 304);
        
        unitTableView.hidden = YES;
        unitDetailsView.hidden = NO;
        
//        [self uncacheModules];
    }
 
    
    if([AppUtilities isExistenceNetwork]){
//        [courseUnitOperator requestModules:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseID:self.courseId];
        [self loadModules:NO];
        if(delegant.isFromDownLoad == NO){
            [AppUtilities showLoading:@"正在努力加载数据中......" andView:unitTableView];
        }
    }
    else {
        
        [self uncacheModules];
        
    }
    if(delegant.isFromActivityAnn == YES){
    [self announcementButtonOnClick];
    }else if (delegant.isFromActivityDis == YES)
    {
        [self discussButtonOnClick];
    }else if (delegant.isFromActivityMes == YES)
    {
        [self taskButtonOnClick];
    }
    html = @"";
    
    if(isLocked != YES){
        [self getDownlodeDic];
        if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
            unsigned long number = (unsigned long)[(NSArray *)[downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]] count];
            lbHasDownlaodNum.text = [NSString stringWithFormat:@"已下载视频：%ld个", number];
        }
        
        if([[self.downingList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
            self.downloadingNumberLabel.text = [NSString stringWithFormat:@"正下载视频：%ld个",(unsigned long)[(NSArray *)[downingList objectForKey:[NSString stringWithFormat:@"%@",courseId]] count]];
        }
    }

    

    [FilesDownManage sharedInstance].downloadDelegate = self;
}
- (void)createScenes
{
    //************课程简介和讲师简介*****************
    rightWebView = [[UIView alloc] init];

    rightWebView.frame = CGRectMake(153, 0, 871, 748);


    rightWebView.hidden = YES;
    [self.contentView addSubview:rightWebView];
    
    
    webView = [[UIWebView alloc] init];
    webView.frame = CGRectMake(0, 0, 871, 748);
    webView.delegate = self;
    [rightWebView addSubview:webView];
    
    
    //************单元***************
    unitView = [[UIView alloc] init];

    unitView.frame = CGRectMake(153, 0, 871, 748);

    [self.contentView addSubview:unitView];
    
    UIImageView *tableViewBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"courseunit_bg.png"]];
    
    unitTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 871, 748) style:UITableViewStylePlain];
    unitTableView.delegate = self;
    unitTableView.dataSource = self;
    unitTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    unitTableView.backgroundColor = [UIColor clearColor];
    unitTableView.backgroundView = tableViewBg;
    [unitView addSubview:unitTableView];
    
    unitDetailsView = [[UIView alloc] init];
    unitDetailsView.frame = CGRectMake(0, 0, 871, 748);
    unitDetailsView.hidden = YES;
    [unitView addSubview:unitDetailsView];
    
    UIImageView *unitDetailsWebViewHeaderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_nav_.png"]];
    unitDetailsWebViewHeaderImage.frame = CGRectMake(0, 0, 871, 60);
    [unitDetailsView addSubview:unitDetailsWebViewHeaderImage];

    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 101, 60)];
    backView.backgroundColor = [UIColor clearColor];
    [unitDetailsView addSubview:backView];
    
    
    UIButton *unitDetailsWebViewBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unitDetailsWebViewBackButton.frame = CGRectMake(0, 0, 101, 60);
//    [unitDetailsWebViewBackButton setBackgroundImage:[UIImage imageNamed:@"button_back_normal_.png"] forState:UIControlStateNormal];
    [unitDetailsWebViewBackButton addTarget:self action:@selector(unitDetailsWebViewBackButtonOnClick) forControlEvents:UIControlEventTouchUpInside];

    
    //unitDetailsWebViewHeaderImage.userInteractionEnabled = YES;
    
    UIImageView *unitDetailsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_back_normal_.png"]];
    unitDetailsImage.frame = CGRectMake(14, 20, 18, 20);
    unitDetailsImage.contentMode = UIViewContentModeScaleAspectFit;
    
    /*
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lastBtn.frame = CGRectMake(761, 7, 41, 41);
    [lastBtn setBackgroundImage:[UIImage imageNamed:@"button_previousone_normal.png"] forState:UIControlStateNormal];
    [lastBtn addTarget:self action:@selector(a) forControlEvents:UIControlEventTouchUpInside];
 
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(810, 7, 41, 41);
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"button_nextone_normal.png"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(a) forControlEvents:UIControlEventTouchUpInside];
    */

   
    [backView addSubview:unitDetailsImage];
    [backView addSubview:unitDetailsWebViewBackButton];
    /*
    [backView addSubview:lastBtn];
    [backView addSubview:nextBtn];
     */
   
    
    
    //播放view
    playView = [[UIView alloc] init];
    playView.frame = CGRectMake(0, 60, 871, 490);
    [unitDetailsView addSubview:playView];
    
    UIImageView *imageCoverView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 871, 490)];
    [imageCoverView setClipsToBounds:YES];
    [imageCoverView sd_setImageWithURL:[NSURL URLWithString:[AppUtilities adaptImageURL:self.imgStr]] placeholderImage:[UIImage imageNamed:@"cover_course_default.png"]];
    

    [playView addSubview:imageCoverView];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(400, 170, 100, 100);
    [playBtn setBackgroundImage:[UIImage imageNamed:@"button_play.png"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playMovieAtURL) forControlEvents:UIControlEventTouchUpInside];
    [playView addSubview:playBtn];

     
    
    unitDetailsWebView = [[UIWebView alloc] init];
    unitDetailsWebView.frame = CGRectMake(0, 550, 871, 218);
    unitDetailsWebView.delegate = self;
    [unitDetailsView addSubview:unitDetailsWebView];
    
    
    //************通知***************
    AnnouncementViewController *avc = [[AnnouncementViewController alloc] initWithNibName:@"AnnouncementViewController" bundle:nil];
    avc.courseId = self.courseId;
//    avc.view.frame = CGRectMake(0, 0, 768, 748);
//    avc.view.hidden = YES;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
    nvc.navigationBarHidden = YES;
    nvc.view.frame = CGRectMake(153, 0, avc.view.frame.size.width, avc.view.frame.size.height);
    nvc.view.hidden = YES;
    
    self.announcementViewController = nvc;
    [self.contentView addSubview:self.announcementViewController.view];
    
    //************人员***************
    UsersInCourseViewController *uvc = [[UsersInCourseViewController alloc] init];
    uvc.courseId = self.courseId;
    uvc.courseName = self.courseName;
    uvc.view.frame = CGRectMake(153, 0, uvc.view.frame.size.width, uvc.view.frame.size.height);
    uvc.view.hidden = YES;
    self.usersInCourseViewController = uvc;
    [self.contentView addSubview:self.usersInCourseViewController.view];
    
    
    //************讨论***************
    DiscussionViewController *dvc = [[DiscussionViewController alloc] initWithNibName:@"DiscussionViewController" bundle:nil];
    dvc.courseId = self.courseId;
    //    avc.view.frame = CGRectMake(0, 0, 768, 748);
//    dvc.view.hidden = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dvc];
    navigationController.navigationBarHidden = YES;
    navigationController.view.frame = CGRectMake(153, 0, dvc.view.frame.size.width, dvc.view.frame.size.height);
    navigationController.view.hidden = YES;
    
    self.discussionViewController = navigationController;
    [self.contentView addSubview:self.discussionViewController.view];
    
    //************作业***************
    AssignmentViewController *avcn = [[AssignmentViewController alloc] initWithNibName:@"AssignmentViewController" bundle:nil];
    avcn.courseId = self.courseId;
    //    avc.view.frame = CGRectMake(0, 0, 768, 748);
    //    dvc.view.hidden = YES;
    
    UINavigationController *navigationControllerForAss = [[UINavigationController alloc] initWithRootViewController:avcn];
    navigationControllerForAss.navigationBarHidden = YES;
    navigationControllerForAss.view.frame = CGRectMake(153, 0, avcn.view.frame.size.width, avcn.view.frame.size.height);
    navigationControllerForAss.view.hidden = YES;
    
    self.assignmentViewController = navigationControllerForAss;
    [self.contentView addSubview:self.assignmentViewController.view];

}

- (IBAction)backButtonClick
{
    [self stopMovie];
    
    AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegant.isFromDownLoad = NO;
    
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//    [webView stopLoading];
//    
//    [unitDetailsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//    [unitDetailsWebView stopLoading];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)taskButtonOnClick
{
    [self pauseMovie];
    
     [unitDetailsWebView loadHTMLString:html baseURL:nil];

    [self switchScene:COURSE_SCENE_TYPE_TASK];
}
- (IBAction)quizButtonOnClick
{

    [unitDetailsWebView loadHTMLString:html baseURL:nil];
    [self switchScene:COURSE_SCENE_TYPE_QUIZ];
}
- (IBAction)discussButtonOnClick
{

    [self pauseMovie];
    
      [unitDetailsWebView loadHTMLString:html baseURL:nil];


    [self switchScene:COURSE_SCENE_TYPE_DISCUSS];
}

- (IBAction)courseIntroductionButtonOnClick
{

    [self pauseMovie];
    
      [unitDetailsWebView loadHTMLString:html baseURL:nil];

    [self switchScene:COURSE_SCENE_TYPE_COURSEINTRODUCTION];
}

- (IBAction)introductionOfLecturerButtonOnClick
{
    
    [self pauseMovie];

      [unitDetailsWebView loadHTMLString:html baseURL:nil];


    [self switchScene:COURSE_SCENE_TYPE_LECTURERINTRODUCTION];
}

- (void)webViewButtonOnClick
{

    [unitDetailsWebView loadHTMLString:html baseURL:nil];
   
    [self switchScene:COURSE_SCENE_TYPE_UNIT];
}

- (IBAction)unitButtonOnClick
{
    [self switchScene:COURSE_SCENE_TYPE_UNIT];
}

//切换视图到单元列表界面
- (void)unitDetailsWebViewBackButtonOnClick
{
    [self stopMovie];
    
     AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegant.isFromDownLoad = NO;
    
    [unitDetailsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [unitDetailsWebView stopLoading];
    
    unitDetailsView.hidden = YES;
    unitTableView.hidden = NO;
}

- (IBAction)announcementButtonOnClick
{
    
    [self switchScene:COURSE_SCENE_TYPE_ANNOUNCEMENT];
}

- (IBAction)downloadAllVideo:(id)sender {
    
    if([lbNODownlaodNum.text isEqualToString:@"0"]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该课程没有尚未下载的视频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else{
    [self getDownlodeDic];
    
    downButton.enabled = NO;
    
    for(int i = 0 ;i <self.currentUnitList.count; i++){
        //         NSLog(@"%@",((UnitItem *)[self.currentUnitList objectAtIndex:i]).name);
        //         NSLog(@"%@",((UnitItem *)[self.currentUnitList objectAtIndex:i]).unlock_at);
        NSDictionary *itemDict = [self.currentUnitList objectAtIndex:i];
        NSString * itemUnlockAt = [itemDict objectForKey:@"unlock_at"];
        
        if(![itemUnlockAt isKindOfClass:[NSNull class]]){
            
            
            if(![AppUtilities isLaterCurrentSystemDate:[itemUnlockAt substringToIndex:10]])
            {
                
                NSString *key = [itemDict objectForKey:@"item_id"];
//                NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:i]).item_id;
                
                if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
                    NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
                    
                    for(UnitDownladItem *downItem in arr) {
                        if(![downItem.hasDownloaded  isEqual: @"downloaded"] && ![downItem.hasDownloaded  isEqual: @"downloading"]){
                            
                            downItem.hasDownloaded = @"downloading";
                            [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
                                                                 TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
                            FilesDownManage *manage = [FilesDownManage sharedInstance];
                            [manage downFileUrl:downItem.videoUrl
                                       filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,downItem.itemID]
                                     filetarget:@"mp4"
                                      fileimage:[GlobalOperator sharedInstance].userId
                                      fileTitle:downItem.videoTitle
                                       courseID:[NSString stringWithFormat:@"%ld", (long)[self.courseId integerValue]]
                                        fileId:downItem.itemID
                                      showAlert:NO];
                        }
                    }

                    
                    
                }
                
            }
            
            
        }else {
            
//            NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:i]).item_id;
            NSString *key = [[self.currentUnitList objectAtIndex:i] objectForKey:@"item_id"];
            
            if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
                NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
                
                for(UnitDownladItem *downItem in arr) {
                    if(![downItem.hasDownloaded  isEqual: @"downloaded"] && ![downItem.hasDownloaded  isEqual: @"downloading"]){
                        
                        downItem.hasDownloaded = @"downloading";
                        [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
                                                             TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
                        FilesDownManage *manage = [FilesDownManage sharedInstance];
                        [manage downFileUrl:downItem.videoUrl
                                   filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,downItem.itemID]
                                 filetarget:@"mp4"
                                  fileimage:[GlobalOperator sharedInstance].userId
                                  fileTitle:downItem.videoTitle
                                   courseID:[NSString stringWithFormat:@"%ld", (long)[self.courseId integerValue]]
                                     fileId:downItem.itemID
                                  showAlert:NO];
                    }
                }

                
                
            }
            
        }
    }

//    [ToolsObject showLoading:@"已添加到下载队列，请到下载管理中查看" andView:self.view];
    
    
    
    /*
    [courseUnitOperator.courseUnit.modulesItemDic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray *arr, BOOL *stop) {
        for(UnitDownladItem *downItem in arr) {
            if(![downItem.hasDownloaded  isEqual: @"downloaded"] || ![downItem.hasDownloaded  isEqual: @"downloading"]){
                
                downItem.hasDownloaded = @"downloading";
                [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
                                                     TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
                FilesDownManage *manage = [FilesDownManage sharedFilesDownManage];
                [manage downFileUrl:downItem.videoUrl
                           filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,downItem.itemID]
                         filetarget:@"mp4"
                          fileimage:nil
                          fileTitle:downItem.videoTitle
                           courseID:[NSString stringWithFormat:@"%d", [self.courseId integerValue]]
                          showAlert:NO];
            }
        }
    }];
     */
    
    [unitTableView reloadData];
    
   
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"已下载，请到下载管理中查看" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    
    
}

- (IBAction)userButtonOnClick
{
    
    [self switchScene:COURSE_SCENE_TYPE_USER];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - 视图切换处理

- (void)showScene:(COURSE_SCENE_TYPE)sceneType
{
    NSNotificationCenter* ns = [NSNotificationCenter defaultCenter];
    [ns postNotificationName:@"hideKeyBoard" object:nil userInfo:nil];
    
    rightWebView.hidden = (sceneType == COURSE_SCENE_TYPE_LECTURERINTRODUCTION || sceneType ==COURSE_SCENE_TYPE_COURSEINTRODUCTION) ? NO : YES;
    //    rightWebView.hidden = (sceneType == COURSE_SCENE_TYPE_COURSEINTRODUCTION)? NO : YES;
    unitView.hidden = (sceneType == COURSE_SCENE_TYPE_UNIT) ? NO : YES;
    self.announcementViewController.view.hidden = (sceneType == COURSE_SCENE_TYPE_ANNOUNCEMENT) ? NO : YES;
    self.usersInCourseViewController.view.hidden = (sceneType == COURSE_SCENE_TYPE_USER) ? NO : YES;
    self.discussionViewController.view.hidden = (sceneType == COURSE_SCENE_TYPE_DISCUSS) ? NO : YES;
    self.assignmentViewController.view.hidden = (sceneType == COURSE_SCENE_TYPE_TASK) ? NO : YES;
}

- (void)switchButtonBgColor:(COURSE_SCENE_TYPE)sceneType
{
    lbCourseBreif.textColor = (sceneType == COURSE_SCENE_TYPE_COURSEINTRODUCTION) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvCourseBreif.image = (sceneType == COURSE_SCENE_TYPE_COURSEINTRODUCTION) ? [UIImage imageNamed:@"icon_courseintro_selected.png"] : [UIImage imageNamed:@"icon_courseintro_normal.png"];
    lbTeacherBreif.textColor = (sceneType == COURSE_SCENE_TYPE_LECTURERINTRODUCTION) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvTeacherBreif.image = (sceneType == COURSE_SCENE_TYPE_LECTURERINTRODUCTION) ? [UIImage imageNamed:@"icon_teacherintro_selected.png"] : [UIImage imageNamed:@"icon_teacherintro_normal.png"];
    lbUnit.textColor = (sceneType == COURSE_SCENE_TYPE_UNIT) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvUnit.image = (sceneType == COURSE_SCENE_TYPE_UNIT) ? [UIImage imageNamed:@"icon_unit_selected.png"] : [UIImage imageNamed:@"icon_unit_normal.png"];
    lbDiscuss.textColor = (sceneType == COURSE_SCENE_TYPE_DISCUSS) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvDiscuss.image = (sceneType == COURSE_SCENE_TYPE_DISCUSS) ? [UIImage imageNamed:@"icon_discuss_selected.png"] : [UIImage imageNamed:@"icon_discuss_normal.png"];
    lbAnnouncement.textColor = (sceneType == COURSE_SCENE_TYPE_ANNOUNCEMENT) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvAnnouncement.image = (sceneType == COURSE_SCENE_TYPE_ANNOUNCEMENT) ? [UIImage imageNamed:@"icon_annoucement_selected.png"] : [UIImage imageNamed:@"icon_annoucement_normal.png"];
    lbUser.textColor = (sceneType == COURSE_SCENE_TYPE_USER) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvUser.image = (sceneType == COURSE_SCENE_TYPE_USER) ? [UIImage imageNamed:@"icon_peoples_selected.png"] : [UIImage imageNamed:@"icon_peoples_normal.png"];
    lbTask.textColor = (sceneType == COURSE_SCENE_TYPE_TASK) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvTask.image = (sceneType == COURSE_SCENE_TYPE_TASK) ? [UIImage imageNamed:@"icon_assignment_selected.png"] : [UIImage imageNamed:@"icon_assignment_normal.png"];
    lbQuiz.textColor = (sceneType == COURSE_SCENE_TYPE_QUIZ) ? [UIColor whiteColor] : [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    imvQuiz.image = (sceneType == COURSE_SCENE_TYPE_QUIZ) ? [UIImage imageNamed:@"icon_quiz_selected.png"] : [UIImage imageNamed:@"icon_quiz_normal.png"];
   
    /*
    courseIntroductionButton.backgroundColor = (sceneType == COURSE_SCENE_TYPE_COURSEINTRODUCTION) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_selected.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_normal.png"]];
    introductionOfLecturerButton.backgroundColor = (sceneType == COURSE_SCENE_TYPE_LECTURERINTRODUCTION) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_selected.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_normal.png"]];
    unitButton.backgroundColor = (sceneType == COURSE_SCENE_TYPE_UNIT) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_selected.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_normal.png"]];
    announcementButton.backgroundColor = (sceneType == COURSE_SCENE_TYPE_ANNOUNCEMENT) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_selected.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_normal.png"]];
    userButton.backgroundColor = (sceneType == COURSE_SCENE_TYPE_USER) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_selected.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"button_sidemenu_normal.png"]];
     */
}

- (void)switchScene:(COURSE_SCENE_TYPE)sceneType
{
    switch (sceneType)
    {
        case COURSE_SCENE_TYPE_COURSEINTRODUCTION:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_COURSEINTRODUCTION)
            {
                currentSceneType = COURSE_SCENE_TYPE_COURSEINTRODUCTION;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_COURSEINTRODUCTION];
                [self showScene:COURSE_SCENE_TYPE_COURSEINTRODUCTION];
                
                
                if([AppUtilities isExistenceNetwork]){
                [AppUtilities showLoading:@"加载课程简介中..." andView:rightWebView];
                
                [courseUnitOperator requestCourseBriefIntroduction:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseID:self.courseId];
                    [self loadCourseBriefIntroduction:NO];
                }else
                {
                   [AppUtilities showHUD:@"无网络连接，请检查你的网络" andView:rightWebView];
                    
                }
            }
        }
            break;
            
        case COURSE_SCENE_TYPE_LECTURERINTRODUCTION:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_LECTURERINTRODUCTION)
            {
                currentSceneType = COURSE_SCENE_TYPE_LECTURERINTRODUCTION;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_LECTURERINTRODUCTION];
                [self showScene:COURSE_SCENE_TYPE_LECTURERINTRODUCTION];
                if([AppUtilities isExistenceNetwork]){
                [AppUtilities showLoading:@"加载讲师简介中..." andView:rightWebView];
                
                [courseUnitOperator requestIntroductionOfLecturer:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseID:self.courseId];
                    [self loadIntroductionFlecturer:NO];
                }else
                {
                    [AppUtilities showHUD:@"无网络连接，请检查你的网络" andView:rightWebView];
                }
            }
        }
            break;
            
        case COURSE_SCENE_TYPE_UNIT:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_UNIT)
            {
                currentSceneType = COURSE_SCENE_TYPE_UNIT;
                
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
                [webView stopLoading];
                
                [self switchButtonBgColor:COURSE_SCENE_TYPE_UNIT];
                [self showScene:COURSE_SCENE_TYPE_UNIT];
            }
            else
            {
                //视图切换到列表界面
                [self unitDetailsWebViewBackButtonOnClick];
            }
        }
            break;
            
        case COURSE_SCENE_TYPE_ANNOUNCEMENT:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_ANNOUNCEMENT)
            {
                currentSceneType = COURSE_SCENE_TYPE_ANNOUNCEMENT;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_ANNOUNCEMENT];
                [self showScene:COURSE_SCENE_TYPE_ANNOUNCEMENT];
                
            }
        }
            break;
            
        case COURSE_SCENE_TYPE_USER:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_USER)
            {
                currentSceneType = COURSE_SCENE_TYPE_USER;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_USER];
                [self showScene:COURSE_SCENE_TYPE_USER];
                
            }
        }
            break;
        case COURSE_SCENE_TYPE_TASK:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_TASK)
            {
                currentSceneType = COURSE_SCENE_TYPE_TASK;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_TASK];
                [self showScene:COURSE_SCENE_TYPE_TASK];
                
            }
        }
            break;
        case COURSE_SCENE_TYPE_QUIZ:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_QUIZ)
            {
                currentSceneType = COURSE_SCENE_TYPE_QUIZ;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_QUIZ];
                //                [self showScene:COURSE_SCENE_TYPE_USER];
                
            }
        }
            break;
        case COURSE_SCENE_TYPE_DISCUSS:
        {
            if (currentSceneType != COURSE_SCENE_TYPE_DISCUSS)
            {
                currentSceneType = COURSE_SCENE_TYPE_DISCUSS;
                [self switchButtonBgColor:COURSE_SCENE_TYPE_DISCUSS];
                [self showScene:COURSE_SCENE_TYPE_DISCUSS];
                
            }
        }
            break;
            
        default:
            break;
    }
    
    return;
}

#pragma mark DownloadDelegate Method
- (void)updateNumbersOfDownloading:(NSDictionary *)numbersByCourse
{
    [self getDownlodeDic];
    NSDictionary *dict = [numbersByCourse objectForKey:[NSString stringWithFormat:@"%@",courseId]];
    int downloadingTaskNumber = [((NSNumber *)[dict objectForKey:@"downloading"]) intValue];
    int finishedTaskNumber = [((NSNumber *)[dict objectForKey:@"finished"]) intValue];
    int remainingTaskNumber = [self getAllVideosCount] - (downloadingTaskNumber + finishedTaskNumber);
//    int remainingTaskNumber = [self getAbleDownloadCount] - (downloadingTaskNumber + finishedTaskNumber);
    ableDownload = remainingTaskNumber;
    self.downloadingNumberLabel.text = [NSString stringWithFormat:@"正下载视频：%d个", downloadingTaskNumber];
    self.lbHasDownlaodNum.text = [NSString stringWithFormat:@"已下载视频：%d个", finishedTaskNumber];
    self.lbNODownlaodNum.text = [NSString stringWithFormat:@"%d", remainingTaskNumber];
    
    [unitTableView reloadData];
}

-(IBAction)downloadVideosInMudels:(id)sender {
    
    [self getDownlodeDic];
    
    UIButton *btn = (UIButton *)sender;
    // add
    NSString *key = [[self.currentUnitList objectAtIndex:btn.tag - 200] objectForKey:@"item"];
    for (NSDictionary *moduleDic in self.currentSecondLevelVideoList) {
        if ([[moduleDic objectForKey:@"moduleID"] intValue] == [key intValue]) {
            NSMutableArray *videoList = [moduleDic objectForKey:@"videoList"];
            for (NSDictionary *videoDic in videoList) {
                NSArray *downloadingArray = [self.downingList objectForKey:[NSString stringWithFormat:@"%@",self.courseId]];
                NSArray *downloadedArray = [self.downloadedList objectForKey:[NSString stringWithFormat:@"%@",self.courseId]];
                for (FileModel *downLoading in downloadingArray) {
                    if ([downLoading.fileTitle isEqualToString:[videoDic objectForKey:@"itemTitle"]]) {
                    }
                }
                for (FileModel *downloaded in downloadedArray) {
                    if ([downloaded.fileTitle  isEqualToString:[videoDic objectForKey:@"itemTitle"]]) {
                    }
                }
                // 需要设置下载状态
                [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad" TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
                FilesDownManage *manage = [FilesDownManage sharedInstance];
                [manage downFileUrl:[videoDic objectForKey:@"videoURL"]
                           filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,[videoDic objectForKey:@"itemID"]]
                         filetarget:@"mp4"
                          fileimage:[GlobalOperator sharedInstance].userId
                          fileTitle:[videoDic objectForKey:@"itemTitle"]
                           courseID:[NSString stringWithFormat:@"%ld",(long)[self.courseId integerValue]]
                             fileId:[videoDic objectForKey:@"itemID"]
                          showAlert:YES];
            }
        }
    }
    // change
//    NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:btn.tag-200]).item_id;
//    if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
//        NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
//        for(UnitDownladItem *downItem in arr)
//        {
//            if(![downItem.hasDownloaded  isEqual: @"downloaded"] && ![downItem.hasDownloaded  isEqual: @"downloading"]){
//            downItem.hasDownloaded = @"downloading";
//            [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
//                                                 TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
//            FilesDownManage *manage = [FilesDownManage sharedFilesDownManage];
//            [manage downFileUrl:downItem.videoUrl
//                       filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,downItem.itemID]
//                     filetarget:@"mp4"
//                      fileimage:[GlobalOperator sharedInstance].userId
//                      fileTitle:downItem.videoTitle
//                       courseID:[NSString stringWithFormat:@"%ld", (long)[self.courseId integerValue]]
//                         fileId:downItem.itemID
//                      showAlert:NO];
//            }
//        }
//    }
    // end
    [self setUndownloadItemsCount];
    [unitTableView reloadData];
    
}
-(IBAction)downloadVideoInItem:(id)sender
{

    UITableViewCell* cell = nil;
    if (IS_IOS_7) {
        cell = (UITableViewCell *)[[sender superview] superview];
    } else {
        cell = (UITableViewCell *)[sender superview];
    }
    NSIndexPath *indexPath = [unitTableView indexPathForCell:cell];
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    UIButton *btn = (UIButton *)sender;
    btn.hidden = YES;
    UILabel *label = (UILabel *)[cell viewWithTag:64];
    label.text = @"正在下载";
    label.textColor = [UIColor grayColor];
    
    // add
    NSString *key = [[self.currentUnitList objectAtIndex:section] objectForKey:@"id"];
    // end 3
    // change 3
//    NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:section]).item_id;
    // change3
    NSLog(@"key == %@",key);
    
    
    NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:section];

    NSLog(@"%@",self.currentSecondLevelVideoList);
//    NSLog(@"%@",[courseUnitOperator.courseUnit.modulesItemDic allKeys]);
    NSString *detailItemId = [[((NSDictionary *)[array objectAtIndex:row]) objectForKey:@"id"] stringValue];
    // add  4
    for (NSDictionary *moduleDic in self.currentSecondLevelVideoList) {
        if ([[moduleDic objectForKey:@"moduleID"] intValue] == [key intValue]) {
            NSMutableArray *videoList = [moduleDic objectForKey:@"videoList"];
            for (NSDictionary *videoDic in videoList) {
                if ([[videoDic objectForKey:@"itemID"] intValue] == [detailItemId intValue]) {
                    // 需要设置下载状态
                    [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad" TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
                    FilesDownManage *manage = [FilesDownManage sharedInstance];
                    [manage downFileUrl:[videoDic objectForKey:@"videoURL"]
                            filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,[videoDic objectForKey:@"itemID"]]
                            filetarget:@"mp4"
                            fileimage:[GlobalOperator sharedInstance].userId
                            fileTitle:[videoDic objectForKey:@"itemTitle"]
                            courseID:[NSString stringWithFormat:@"%ld",(long)[self.courseId integerValue]]
                            fileId:[videoDic objectForKey:@"itemID"]
                            showAlert:YES];
                }

            }
        }
    }
    // end  4
    // change   4
//    if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
//        NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
//        for(UnitDownladItem *downItem in arr) {
//            if([downItem.itemID isEqualToString:detailItemId]){
//
//                 downItem.hasDownloaded = @"downloading";
//                [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
//                                                     TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
//                
//                FilesDownManage *manage = [FilesDownManage sharedFilesDownManage];
//                
//                [manage downFileUrl:downItem.videoUrl
//                           filename:[NSString stringWithFormat:@"%@_%@_%@.mp4",self.courseId,key,downItem.itemID]
//                         filetarget:@"mp4"
//                          fileimage:[GlobalOperator sharedInstance].userId
//                          fileTitle:downItem.videoTitle
//                           courseID:[NSString stringWithFormat:@"%ld", (long)[self.courseId integerValue]]
//                             fileId:downItem.itemID
//                          showAlert:YES];
//            }
//        }
//    }
    // end  4
    [self setUndownloadItemsCount];
    [self.unitTableView reloadData];
}

#pragma mark - Table view data source

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * mySectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 871, 60)];
    mySectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"unit_Ititlebar_nav"]];
    UIButton * myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 871, 40);
    myButton.tag = 100 + section;
    [myButton addTarget:self action:@selector(tapHeader:) forControlEvents:UIControlEventTouchUpInside];
    [mySectionView addSubview:myButton];
    
    // add  2
    NSString *name = [[self.currentUnitList objectAtIndex:section] objectForKey:@"name"];
    // change   2
//    NSString *name = ((UnitItem *)[self.currentUnitList objectAtIndex:section]).name;
    // end  2
    
    UILabel * myLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 450, 30)];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    myLabel.text = name;
    [myButton addSubview:myLabel];
    
//      NSDate* date = [NSDate date];
//    NSLog(@"%@",((UnitItem *)[self.currentUnitList objectAtIndex:section]).unlock_at);
  
   
    
    UIButton * downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.frame = CGRectMake(683, 15, 175, 35);
    downloadBtn.tag = 200 + section;
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"button_downloadAll_normal.png"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadVideosInMudels:) forControlEvents:UIControlEventTouchUpInside];
    [mySectionView addSubview:downloadBtn];
    downloadBtn.hidden = YES;
    
    UILabel * downlabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, 175, 35)];
    downlabel.backgroundColor = [UIColor clearColor];
    downlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    downlabel.text = @"下载该单元全部视频";
    downlabel.textColor = [UIColor whiteColor];
    [downloadBtn addSubview:downlabel];
//    NSLog(@"module===%@",((UnitItem *)[self.currentUnitList objectAtIndex:section])._id);
//    NSLog(@"able===%@",((UnitItem *)[self.currentUnitList objectAtIndex:section]).ableDownload);
    
    // change   3
//    if( [((UnitItem *)[self.currentUnitList objectAtIndex:section]).ableDownload intValue] == 0){
//         downloadBtn.hidden = YES;
//    }
    // add  3
    for (NSDictionary *modulesDic in self.currentSecondLevelVideoList) {
        if ([[[self.currentUnitList objectAtIndex:section] objectForKey:@"id"] intValue] == [[modulesDic objectForKey:@"moduleID"] intValue]) {
            downloadBtn.hidden = NO;
        }
    }
    // end  3
    
    // add  4
    if ((NSNull *)[[self.currentUnitList objectAtIndex:section]objectForKey:@"unlock_at"] != [NSNull null]) {
        if ([AppUtilities isLaterCurrentSystemDate:[(NSString *)[[self.currentUnitList objectAtIndex:section] objectForKey:@"unlock_at"] substringToIndex:10]]) {
            downloadBtn.hidden = YES;
            UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(683, 15, 30, 30)];
            imgView.image = [UIImage imageNamed:@"icon_lock"];
            [myButton addSubview:imgView];
            
            UILabel * Label = [[UILabel alloc] initWithFrame:CGRectMake(713, 15, 250, 30)];
            Label.backgroundColor = [UIColor clearColor];
            Label.font = [UIFont fontWithName:@"Helvetica" size:16];
            Label.text = [NSString stringWithFormat:@"开启时间：%@",[AppUtilities convertTimeStyleToD:[[self.currentUnitList objectAtIndex:section] objectForKey:@"unlock_at"]]];
            Label.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
            [myButton addSubview:Label];
            [lockSectionArr replaceObjectAtIndex:section withObject:@"0"];
        }
    }
    // change 4
//    if((NSNull *)((UnitItem *)[self.currentUnitList objectAtIndex:section]).unlock_at != [NSNull null]){
//    
//        if([ToolsObject isLaterCurrentSystemDate:[((UnitItem *)[self.currentUnitList objectAtIndex:section]).unlock_at substringToIndex:10]])
//        {
//            downloadBtn.hidden = YES;
//            UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(683, 15, 30, 30)];
//            imgView.image = [UIImage imageNamed:@"icon_lock"];
//            [myButton addSubview:imgView];
//            UILabel * Label = [[UILabel alloc] initWithFrame:CGRectMake(713, 15, 250, 30)];
//            Label.backgroundColor = [UIColor clearColor];
//            Label.font = [UIFont fontWithName:@"Helvetica" size:16];
//            Label.text = [NSString stringWithFormat:@"开启时间：%@",[ToolsObject convertTimeStyleToD:((UnitItem *)[self.currentUnitList objectAtIndex:section]).unlock_at]];
//            Label.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
//            [myButton addSubview:Label];
//            [lockSectionArr replaceObjectAtIndex:section withObject:@"0"];
//        }
//    }
    // end  4
    return mySectionView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.currentUnitList count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

-(void)tapHeader:(UIButton *)sender
{
    if ([[openedInSectionArr objectAtIndex:sender.tag - 100] intValue] == 0) {
        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"1"];
    }
    else{
        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"0"];
    }
    [unitTableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[openedInSectionArr objectAtIndex:section] intValue] == 1 &&
        [self.currentSecondLevelUnitList count] > section) {
        return [(NSArray *)[self.currentSecondLevelUnitList objectAtIndex:section] count];
    }
    
    return 0;
    
//    if (self.isOpen)
//    {
//        if (self.selectIndex.section == section)
//        {
//            return [[self.currentSecondLevelUnitList objectAtIndex:section] count] + 1;
//        }
//    }
//    
//    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//   static NSString *CellIdentifier = @"Cell2";
//   NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UIImage *img = [UIImage imageNamed:@"unit_item_bg.png"];
        UIImageView *imgv = [[UIImageView alloc] initWithImage:img];
        imgv.frame = CGRectMake(0, 0, 871, 60);
        [cell.contentView addSubview:imgv];
        [cell sendSubviewToBack:imgv];
        
        UIImageView * arrView = [[UIImageView alloc] init];
        arrView.frame = CGRectMake(835, 22, 15, 15);
        arrView.image = nil;
        arrView.tag = 62;
        [cell addSubview:arrView];

        UIImageView *unitCellIcon = [[UIImageView alloc] init];
        unitCellIcon.frame = CGRectMake(45, 14, 30, 30);
        unitCellIcon.tag = 60;
        unitCellIcon.image = nil;
        [cell addSubview:unitCellIcon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 600, 60)];
        title.tag = 61;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
        
        title.font = [UIFont fontWithName:@"Helvetica" size:16];
        [cell addSubview:title];
        
        UIButton * downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.frame = CGRectMake(743, 15, 85, 32);
        downloadBtn.tag = 63;
        [downloadBtn setBackgroundImage:[UIImage imageNamed:@"button_download.png"] forState:UIControlStateNormal];
        [downloadBtn addTarget:self action:@selector(downloadVideoInItem:) forControlEvents:UIControlEventTouchUpInside];
        downloadBtn.hidden = YES;
        [cell addSubview:downloadBtn];
        
        UILabel * downlabel = [[UILabel alloc] initWithFrame:CGRectMake(755, 14, 60, 32)];
        downlabel.backgroundColor = [UIColor clearColor];
        downlabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        downlabel.tag = 64;
        [cell addSubview:downlabel];
    }
     UIImageView *arrView = (UIImageView*)[cell viewWithTag:62];
     UIImageView *unitCellIcon = (UIImageView*)[cell viewWithTag:60];
     UILabel *nameLabel = (UILabel *)[cell viewWithTag:61];
     UIButton *downBtn = (UIButton *)[cell viewWithTag:63];
     UILabel *downlabel = (UILabel *)[cell viewWithTag:64];
    
      if([[lockSectionArr objectAtIndex:indexPath.section] isEqualToString:@"1"]){
          arrView.image = [UIImage imageNamed:@"arrow_unit"];
          NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
          NSString *detailItemId = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"id"];
//          NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:indexPath.section]).item_id;
          
          // add    5
          NSString *key = [[self.currentUnitList objectAtIndex:indexPath.section] objectForKey:@"id"];
          if (self.currentSecondLevelVideoList.count > 0) {
              for (int i = 0; i < self.currentSecondLevelVideoList.count; i++) {
                  if ([key intValue] == [[[self.currentSecondLevelVideoList objectAtIndex:i] objectForKey:@"moduleID"] intValue]) {
                      NSArray *videoListArray = [[self.currentSecondLevelVideoList objectAtIndex:i] objectForKey:@"videoList"];
                      for (NSDictionary *videoDict in videoListArray) {
                          if ([[videoDict objectForKey:@"itemID"] intValue] == [detailItemId intValue]) {
                              
                              downBtn.hidden = NO;
                              downlabel.text = @"下载视频";
                              downlabel.textColor = [UIColor colorWithRed:39.0/255 green:165.0/255 blue:237.0/255 alpha:1];
                              
                              
                              NSArray *downloadingArray = [self.downingList objectForKey:[NSString stringWithFormat:@"%@",self.courseId]];
                              NSArray *downloadedArray = [self.downloadedList objectForKey:[NSString stringWithFormat:@"%@",self.courseId]];
                              
//                              for (FileModel *downLoading in downloadingArray) {
//                                  if ([downLoading.fileTitle isEqualToString:[videoDict objectForKey:@"itemTitle"]]) {
//                                      downBtn.hidden = YES;
//                                      downlabel.text = @"正在下载";
//                                      downlabel.textColor = [UIColor grayColor];
//                                  }
//                              }
                              for (FileModel *downloaded in downloadedArray) {
                                  if ([downloaded.fileTitle  isEqualToString:[videoDict objectForKey:@"itemTitle"]]) {
                                      downBtn.hidden = YES;
                                      downlabel.text = @"已下载";
                                      downlabel.textColor = [UIColor grayColor];
                                  }
                              }
                              
                          }
                      }
                  }
              }
          }
          // change 5
//          if([courseUnitOperator.courseUnit.modulesItemDic allKeys].count > 0){
//            for( int i = 0; i <[courseUnitOperator.courseUnit.modulesItemDic allKeys].count;i++){
//                if([key intValue] == [[[courseUnitOperator.courseUnit.modulesItemDic allKeys] objectAtIndex:i] intValue]){
//                    NSMutableArray *arr = [[courseUnitOperator.courseUnit.modulesItemDic allValues] objectAtIndex:i];
//                    for(UnitDownladItem *downItem in arr) {
//                        if([downItem.itemID intValue] == [detailItemId intValue]){
//                            if([downItem.hasDownloaded isEqualToString:@"downloading"]){
//                                downBtn.hidden = YES;
//                                downlabel.text = @"正在下载";
//                                downlabel.textColor = [UIColor grayColor];
//                            } else if ([downItem.hasDownloaded isEqualToString:@"downloaded"]){
//                                downBtn.hidden = YES;
//                                downlabel.text = @"已下载";
//                                downlabel.textColor = [UIColor grayColor];
//                            } else {
//                                downBtn.hidden = NO;
//                                downlabel.text = @"下载视频";
//                                downlabel.textColor = [UIColor colorWithRed:39.0/255 green:165.0/255 blue:237.0/255 alpha:1];
//                            }
//                        }
//                    }
//                }
//            }
//        
//        }
          //end     5
          
          NSString *type = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"type"];
          //             NSLog(@"%@",type);
          if ([type isEqual:@"Page"])//页面
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_page_active_dark.png"];
          }
          else if ([type isEqual:@"Discussion"])//讨论
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_dis_active_dark.png"];
          }
          else if ([type isEqual:@"Assignment"])//作业
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_assignment_active_dark.png"];
          }
          else if ([type isEqual:@"Quiz"])//测验
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_quiz_active_dark.png"];
          }
          else if ([type isEqual:@"File"])//文件
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_download_active_dark.png"];
          } else if ([type isEqual:@"ExternalTool"])//wailian
          {
              unitCellIcon.image = [UIImage imageNamed:@"unit_icon_video_active_dark"];
          }
          
          
          nameLabel.text = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"title"];
          nameLabel.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
        }else{
            arrView.image = nil;
            NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
            NSString *type = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"type"];
            //        NSLog(@"%@",type);
            if ([type isEqual:@"Page"])//页面
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_page_active_grey.png"];
            }
            else if ([type isEqual:@"Discussion"])//讨论
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_dis_active_grey.png"];
            }
            else if ([type isEqual:@"Assignment"])//作业
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_assignment_active_grey.png"];
            }
            else if ([type isEqual:@"Quiz"])//测验
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_quiz_active_grey.png"];
            }
            else if ([type isEqual:@"File"])//文件
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_download_active_dark.png"];
            }
            else if ([type isEqual:@"ExternalTool"])//文件
            {
                unitCellIcon.image = [UIImage imageNamed:@"unit_icon_video_active_gray"];
            }
            nameLabel.text = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"title"];
            nameLabel.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
        }
        return cell;
    /*
    if (self.isOpen && self.selectIndex.section == indexPath.section && indexPath.row != 0)
    {
//        static NSString *CellIdentifier = @"Cell2";
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
        Cell2 *cell = (Cell2 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = (Cell2 *)[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            UIImage *img = [UIImage imageNamed:@"item_bg01.png"];
            UIImageView *imgv = [[UIImageView alloc] initWithImage:img];
            imgv.frame = CGRectMake(0, 0, 768, 60);
            [cell addSubview:imgv];
            [imgv release];
            [cell sendSubviewToBack:imgv];
            
            unitCellIcon = [[UIImageView alloc] init];
            unitCellIcon.frame = CGRectMake(20, 14, 32, 32);
            [cell addSubview:unitCellIcon];
            [unitCellIcon release];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 600, 60)];
            title.tag = 61;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
            title.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
            [cell.contentView addSubview:title];
            [title release];
            
            
            NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:self.selectIndex.section];
            NSLog(@"array ==== %@",array);
            NSString *type = [((NSDictionary *)[array objectAtIndex:indexPath.row-1]) objectForKey:@"type"];
            
            if ([type isEqual:@"Page"])//页面
            {
                unitCellIcon.image = [UIImage imageNamed:@"icon_coursepage_32x32.png"];
            }
            else if ([type isEqual:@"Discussion"])//讨论
            {
                unitCellIcon.image = [UIImage imageNamed:@"icon_discuss_32x32.png"];
            }
            else if ([type isEqual:@"Assignment"])//作业
            {
                unitCellIcon.image = [UIImage imageNamed:@"icon_assignment_32x32.png"];
            }
            else if ([type isEqual:@"Quiz"])//测验
            {
                unitCellIcon.image = [UIImage imageNamed:@"icon_quiz_32x32.png"];
            }
            else if ([type isEqual:@"File"])//文件
            {
                unitCellIcon.image = [UIImage imageNamed:@"icon_download_32x32.png"];
            }
            
            
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:61];
            nameLabel.text = [((NSDictionary *)[array objectAtIndex:indexPath.row-1]) objectForKey:@"title"];


        }
        
               //        else if ([type isEqual:@"SubHeader"])//副标题
        //        {
        //            unitCellIcon.image = [UIImage imageNamed:@"icon_coursepage_32x32.png"];
        //        }
        //        else if ([type isEqual:@"ExternalUrl"])//外部链接
        //        {
        //            unitCellIcon.image = [UIImage imageNamed:@"icon_link_32x32.png"];
        //        }
        //        else if ([type isEqual:@"ExternalTool"])//外部工具
        //        {
        //            unitCellIcon.image = [UIImage imageNamed:@"icon_link_32x32.png"];
        //        }
//        else
//        {
//            unitCellIcon.image = [UIImage imageNamed:@"icon_point_32x32.png"];
//        }
        
        
       
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell1";
        Cell1 *cell = (Cell1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
            
            UIImage *img = [UIImage imageNamed:@"unit_bg01.png"];
            UIImageView *imgv = [[UIImageView alloc] initWithImage:img];
            imgv.frame = CGRectMake(0, 0, 768, 40);
            [cell addSubview:imgv];
            [imgv release];
            
            [cell sendSubviewToBack:imgv];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 600, 40)];
            title.tag = 60;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor colorWithRed:167.0/255 green:0 blue:0 alpha:1];
            //            title.lineBreakMode = NSLineBreakByWordWrapping;
            //            title.numberOfLines = 0;
            title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
            [cell.contentView addSubview:title];
            [title release];
        }
        
        NSString *name = ((UnitItem *)[self.currentUnitList objectAtIndex:indexPath.section]).name;
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:60];
        nameLabel.text = name;
        
        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath] ? YES : NO)];
        
        
        return cell;
    }
     */
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([AppUtilities isExistenceNetwork]){
        
        if([[lockSectionArr objectAtIndex:indexPath.section] isEqualToString:@"1"]){
            NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
            // add  6
            if (self.currentSecondLevelVideoList.count > 0) {
                NSString *detailItemId = [[array objectAtIndex:indexPath.row] objectForKey:@"id"];
                NSString *key = [[self.currentUnitList objectAtIndex:indexPath.section] objectForKey:@"id"];
                if (self.currentSecondLevelVideoList.count > 0) {
                    if ([[[array objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"ExternalTool"]) {
                        for (NSDictionary *videoDic in self.currentSecondLevelVideoList) {
                            if ([key intValue] == [[videoDic objectForKey:@"moduleID"] intValue]) {
                                NSArray *videoListArray = [videoDic objectForKey:@"videoList"];
                                for (NSDictionary *videoModuleDic in videoListArray) {
                                    if ([[videoModuleDic objectForKey:@"itemID"] intValue] == [detailItemId intValue]) {
                                        playView.hidden = NO;
                                        unitDetailsWebView.frame = CGRectMake(0, 550, 871, 218);
                                        unitTableView.hidden = YES;
                                        unitDetailsView.hidden = NO;
                                        self.promoVideoStr = [videoModuleDic objectForKey:@"videoURL"];
                                    }
                                }
                            }
                        }
                    } else {
                        if ([[array objectAtIndex:indexPath.row] objectForKey:@"url"]) {
                            playView.hidden = YES;
                            unitDetailsWebView.frame = CGRectMake(0, 60, 871, 708);
                            //截取字符串
                            NSString *regex = @"/";
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
                            
                            NSMutableString *url = [[NSMutableString alloc] init];
                            
                            [url setString: [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]];
                            while ([predicate evaluateWithObject:url])
                            {
                                NSRange range = [url rangeOfString:regex];
                                [url setString:[url substringFromIndex:range.location + 1]];
                            }
                            if([self isPureInt:url] == YES){
                                [AppUtilities showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                            }else{
                                [courseUnitOperator requestPage:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId pageURL:url];
                                [AppUtilities showLoading:@"加载数据中..." andView:unitTableView];
                            }
                        } else {
                            [AppUtilities showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                        }
                    }
                }
            } else {
                if ([[array objectAtIndex:indexPath.row] objectForKey:@"url"]) {
                    //截取字符串
                    NSString *regex = @"/";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
                    
                    NSMutableString *url = [[NSMutableString alloc] init];
                    
                    [url setString: [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]];
                    
                    while ([predicate evaluateWithObject:url])
                    {
                        NSRange range = [url rangeOfString:regex];
                        [url setString:[url substringFromIndex:range.location + 1]];
                    }
                    if([self isPureInt:url] == YES){
                        [AppUtilities showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                    }else{
                        [courseUnitOperator requestPage:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId pageURL:url];
                        [AppUtilities showLoading:@"加载数据中..." andView:unitTableView];
                    }
                }else
                {
                    [AppUtilities showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                }

            }
            // end  6
/*
            if([courseUnitOperator.courseUnit.modulesItemDic allKeys].count > 0){//supclass课程
                NSString *detailItemId = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"id"];
                NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:indexPath.section]).item_id;
                if([courseUnitOperator.courseUnit.modulesItemDic allKeys].count > 0){
                    if([[((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"type"] isEqualToString:@"ExternalTool"]){
                        for( int i = 0; i <[courseUnitOperator.courseUnit.modulesItemDic allKeys].count;i++){
                            if([key intValue] == [[[courseUnitOperator.courseUnit.modulesItemDic allKeys] objectAtIndex:i] intValue]){
                                NSMutableArray *arr = [[courseUnitOperator.courseUnit.modulesItemDic allValues] objectAtIndex:i];
                                for(UnitDownladItem *downItem in arr)
                                {
                                    if([downItem.itemID intValue] == [detailItemId intValue]){
                                        playView.hidden = NO;
                                        unitDetailsWebView.frame = CGRectMake(0, 550, 871, 218);
                                        unitTableView.hidden = YES;
                                        unitDetailsView.hidden = NO;
                                        self.promoVideoStr =  downItem.videoUrl;
                                    }
                                }
                            }
                        }
                    }else{
                        if ([((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"])
                        {
                            
                            playView.hidden = YES;
                            unitDetailsWebView.frame = CGRectMake(0, 60, 871, 708);
                            //截取字符串
                            NSString *regex = @"/";
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
                            
                            NSMutableString *url = [[NSMutableString alloc] init];
                            
                            [url setString: [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]];
                            
                            while ([predicate evaluateWithObject:url])
                            {
                                NSRange range = [url rangeOfString:regex];
                                [url setString:[url substringFromIndex:range.location + 1]];
                            }
                            if([self isPureInt:url] == YES){
                                [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                            }else{
                                [courseUnitOperator requestPage:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId pageURL:url];
                                [ToolsObject showLoading:@"加载数据中..." andView:unitTableView];
                            }
                        }
                        else
                        {
                            [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                        }
                    }
                }
            }else{//非superclass课程
                if ([((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"])
                {
                    
                    //截取字符串
                    NSString *regex = @"/";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
                    
                    NSMutableString *url = [[NSMutableString alloc] init];
                    
                    [url setString: [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]];
                    
                    while ([predicate evaluateWithObject:url])
                    {
                        NSRange range = [url rangeOfString:regex];
                        [url setString:[url substringFromIndex:range.location + 1]];
                    }
                    if([self isPureInt:url] == YES){
                        [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                    }else{
                         [courseUnitOperator requestPage:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId pageURL:url];
                        [ToolsObject showLoading:@"加载数据中..." andView:unitTableView];
                    }
                }
                else
                {
                    [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
                }
            }
*/
            
        }else{
            [AppUtilities showHUD:@"课程尚未开始，敬请期待" andView:unitTableView];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [AppUtilities showHUD:@"无网络连接，请检查你的网络" andView:unitTableView];
    }
}

- (void)loadModules:(BOOL)fromCache{
    NSString *jsonUrlModules = [NSString stringWithFormat:@"courses/%@/modules?per_page=%d", self.courseId, 999999];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlModules method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        self.currentUnitList = result;
        for (int i = 0; i < self.currentUnitList.count; i++) {
            [self.openedInSectionArr addObject:@"1"];
            [self.lockSectionArr addObject:@"1"];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @synchronized(self.currentSecondLevelUnitList) {
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                NSMutableArray * tempSecondLevelUnitList = [[NSMutableArray alloc] init];
                for (int i = 0; i < [self.currentUnitList count]; i++) {
                    NSDictionary *item = [self.currentUnitList objectAtIndex:i];
                    NSString *itemId = [item objectForKey:@"id"];
                    NSString *jsonUrlModulesItems = [NSString stringWithFormat:@"courses/%@/modules/%@/items?per_page=%d",
                                                     self.courseId, itemId, 999999];
                    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlModulesItems method:@"GET" param:nil fromCache:fromCache success:^(id result) {
                        NSLog(@"result is %@",result);
                        [tempSecondLevelUnitList addObject:(NSArray *)result];
                        dispatch_semaphore_signal(sema);
                    } failure:^(id result) {
                        dispatch_semaphore_signal(sema);
                    }];
                    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                }
                self.currentSecondLevelUnitList = tempSecondLevelUnitList;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(isLocked != YES){
//                    [courseUnitOperator requestCourseVideo:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId];
                    [self loadCourseVideo:NO];
                }else
                {
                    [AppUtilities closeLoading:unitTableView];
                    [unitTableView reloadData];
                }
            });
        });
        
        
        
    } failure:^(id result) {
        
    }];

}

- (void)loadCourseVideo:(BOOL)fromCache{
    NSString *jsonUrlForVideo = [NSString stringWithFormat:@"api.php?num=666&courseid=%@", self.courseId];
    [[KKBHttpClient shareInstance] requestSuperClassUrlPath:jsonUrlForVideo method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        self.currentSecondLevelVideoList = (NSArray *)result; // moduelsItemDic
        
        if(self.currentSecondLevelVideoList.count > 0)
        {
            curtainView.hidden = YES;
        }else{
            curtainView.hidden = NO;
        }
        AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        if(delegant.isFromDownLoad == NO){
            [AppUtilities closeLoading:unitTableView];
        }
//        [self getAbleDownloadCount];
        [self getVideosCountAvailabelDownload];

        lbNODownlaodNum.text = [NSString stringWithFormat:@"%d",ableDownload];
//        if ([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
//            [lbNODownlaodNum setText:[NSString stringWithFormat:@"%lu",(long)ableDownload - [(NSArray *)[downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]] count]]];
//        } else {
//            lbNODownlaodNum.text = [NSString stringWithFormat:@"%d",[self getAllVideosCount]];
//        }
        
        [unitTableView reloadData];
        
    } failure:^(id result) {
        if (fromCache == YES) {
        }
    }];

}

- (void)loadPage:(BOOL)fromCache{
    
}

- (void)loadCourseBriefIntroduction:(BOOL)fromCache{
    NSString *jsonUrlForCourseBriefIntroduction = [NSString stringWithFormat:@"courses/%@/pages/course-introduction-4tablet", self.courseId];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForCourseBriefIntroduction method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        NSDictionary *resultDic = (NSDictionary *)result;
        [webView loadHTMLString:[resultDic objectForKey:@"body"] baseURL:nil];
        
        [AppUtilities closeLoading:rightWebView];

    } failure:^(id result) {
        
    }];
}

- (void)loadIntroductionFlecturer:(BOOL)fromCache{
    NSString *jsonUrlForIntroductionOfFlecturer = [NSString stringWithFormat:@"courses/%@/pages/course-instructor-4tablet",self.courseId];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForIntroductionOfFlecturer method:@"GET" param:nil fromCache:fromCache success:^(id result) {
        NSDictionary *resultDic = (NSDictionary *)result;
        [webView loadHTMLString:[resultDic objectForKey:@"body"] baseURL:nil];
        [AppUtilities closeLoading:rightWebView];
    } failure:^(id result) {
        
    }];
}

- (void) setUndownloadItemsCount{
    if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
//        NSArray *downloadedItems = (NSArray *)[downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]];
//        NSArray *downloadingRequestItems = (NSArray *)[downingList objectForKey:[NSString stringWithFormat:@"%@",courseId]];
//        int downloadedItemsCount = downloadedItems.count;
//        int downloadingItemsCount = downloadingRequestItems.count;
//        NSUInteger remainingItemsCount = ([self getAbleDownloadCount] - downloadedItemsCount - downloadingItemsCount);
        [lbNODownlaodNum setText:[NSString stringWithFormat:@"%d", [self getVideosCountAvailabelDownload]]];
    }else{
        [lbNODownlaodNum setText:[NSString stringWithFormat:@"%ld", (long)ableDownload]];
    }
}

#pragma mark BaseOperatorDelegate

- (void)requestSuccess:(NSString *)cmd
{
    if ([cmd compare:HTTP_CMD_COURSE_MODULES] == NSOrderedSame)
    {
//        [[[SidebarViewControllerInPadViewController share]contentView] addGestureRecognizer:sidebarGestureR];
        for (int k = 0; k<courseUnitOperator.courseUnit.modulesArray.count; k++){
            [self.openedInSectionArr addObject:@"1"];
            [self.lockSectionArr addObject:@"1"];
        }
        
        self.currentUnitList = courseUnitOperator.courseUnit.modulesArray;
        
        for (int i = 0; i < [self.currentUnitList count]; i++) {
            UnitItem *item = [self.currentUnitList objectAtIndex:i];
            
            NSString *url = [NSString stringWithFormat:@"%@", [courseUnitOperator getModuleItemsUrl:courseId moduleID:[NSString stringWithFormat:@"%d", item.item_id.intValue]]];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            [request addRequestHeader:@"Accept" value:@"application/json"];
            [request addRequestHeader:@"Content-Type" value:@"application/json"];
            [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", [GlobalOperator sharedInstance].user4Request.user.avatar.token]];
            
            __unsafe_unretained ASIHTTPRequest *weakRequest = request;
            [request setCompletionBlock: ^{
                 NSArray *array = [weakRequest.responseString objectFromJSONString];
                 [self.currentSecondLevelUnitList addObject:array];
             }];
            
            [request setFailedBlock:^{
                 [weakRequest cancel];
             }];
            
            [request startAsynchronous];
        }
    
        [self cacheModules];
        
        if(isLocked != YES){
            [courseUnitOperator requestCourseVideo:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId];
        } else {
            [AppUtilities closeLoading:unitTableView];
            [unitTableView reloadData];
        }

    } else if ([cmd compare:HTTP_CMD_COURSEUNIT_VIDEO] == NSOrderedSame)

    {
          if([courseUnitOperator.courseUnit.modulesItemDic allKeys].count > 0)
          {
              curtainView.hidden = YES;
          }else{
              curtainView.hidden = NO;
          }
        AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];

        if(delegant.isFromDownLoad == NO){
        [AppUtilities closeLoading:unitTableView];
        }
        /*
        __block NSInteger downCount = 0;
        [courseUnitOperator.courseUnit.modulesItemDic.allValues enumerateObjectsUsingBlock:^(NSMutableArray *arr, NSUInteger idx, BOOL *stop) {
            downCount += [arr count];
        }];
        if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
            [lbNODownlaodNum setText:[NSString stringWithFormat:@"%d", downCount - [[downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]] count]]];
        }else{
        [lbNODownlaodNum setText:[NSString stringWithFormat:@"%d", downCount]];
        }
        */
//        [self getAbleDownloadCount];
        [self getVideosCountAvailabelDownload];
        
        [lbNODownlaodNum setText:[NSString stringWithFormat:@"%ld",(long)ableDownload]];
        
//        if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
//             [lbNODownlaodNum setText:[NSString stringWithFormat:@"%lu", (long)ableDownload - [(NSArray *)[downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]] count]]];
//        }else{
//            [lbNODownlaodNum setText:[NSString stringWithFormat:@"%ld", (long)ableDownload]];
//        }
        
        [unitTableView reloadData];

        
    }
    else if ([cmd compare:HTTP_CMD_COURSEUNIT_PAGE] == NSOrderedSame)
    {
        NSString *body = [NSString stringWithFormat:@"%@", courseUnitOperator.page];
//       NSLog(@"%@",body);
        
          NSRange range=[body rangeOfString:@"<div id=\"embed_media_0\""];
        if(range.length != 0){
            
           
            [self getVideoCode];
            
          NSString* str = [body substringFromIndex:range.location];
//       NSLog(@"str ==%@",str);
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//             NSLog(@" ==%@",[[ToolsObject cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]);
            self.html = [body substringToIndex:range.location];
            self.promoVideoStr =[NSString stringWithFormat:@"%@.mp4",[codeDic objectForKey:[[AppUtilities cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]]];
            NSLog(@"self.pro = %@",promoVideoStr);
            
        playView.hidden = NO;
        unitDetailsWebView.frame = CGRectMake(0, 550                                                                                                                                                                                                                                                     , 871, 708);

        }else
        {
            self.html = body;
            playView.hidden = YES;
            unitDetailsWebView.frame = CGRectMake(0, 60, 871, 708);

        }
//        if([body isEqualToString:@"(null)"])
//        {
//            [ToolsObject closeLoading:unitTableView];
//            [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:unitTableView];
//        }else{
        
        //<div id=\"embed_media
//        if ([[NSPredicate predicateWithFormat:@"SELF CONTAINS %@", @"<div id=\"embed_media_0\">"] evaluateWithObject:body])
 //     {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              self.html = [NSString stringWithFormat:@"<html><head><meta c                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               harset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"/><script type=\"text/javascript\" src=\"http://media.kaikeba.com/lib/js/jquery_v1.4.2.min.js\"></script></head><body>%@<script src=\"http://learn.kaikeba.com/javascripts/homepage_js/kaikeba_mobile_api.js\" type=\"text/javascript\"></script></body></html>", body];
//        self.html = [NSString stringWithFormat:@"<html><head><meta c                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               harset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\"/><script type=\"text/javascript\" src=\"http://media.kaikeba.com/lib/js/jquery_v1.4.2.min.js\"></script></head><body>%@<script src=\"http://learn.kaikeba.com/javascripts/homepage_js/kaikeba_mobile_api.js\" type=\"text/javascript\"></script></body></html>", body];

//            NSLog(@"%@",html);
        [unitDetailsWebView loadHTMLString:self.html baseURL:nil];
        
        
//        }
//        else
//        {
//            NSString *html = [NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /></head><body>%@</body></html>", body];
//            
//            [unitDetailsWebView loadHTMLString:html baseURL:nil];
//        }
        
        unitTableView.hidden = YES;
        unitDetailsView.hidden = NO;
        
        [AppUtilities closeLoading:unitTableView];
//        }
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] == NSOrderedSame)
    {
//        [webView loadHTMLString:courseUnitOperator.courseBriefIntroduction baseURL:nil];
//        
//        [ToolsObject closeLoading:rightWebView];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] == NSOrderedSame)
    {
//        [webView loadHTMLString:courseUnitOperator.introductionOfLecturer baseURL:nil];
//        
//        [ToolsObject closeLoading:rightWebView];
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg
{
    if ([cmd compare:HTTP_CMD_COURSE_MODULES] == NSOrderedSame)
    {
        [AppUtilities closeLoading:unitTableView];
        [self uncacheModules];
        
        AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
        if(delegant.isFromDownLoad == YES){
            
            playView.hidden = NO;
            unitDetailsWebView.frame = CGRectMake(0, 464, 871, 304);
            
            unitTableView.hidden = YES;
            unitDetailsView.hidden = NO;
        }
        

    }
    else if ([cmd compare:HTTP_CMD_COURSEUNIT_PAGE] == NSOrderedSame)
    {
        [AppUtilities closeLoading:unitTableView];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] == NSOrderedSame || [cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] == NSOrderedSame)
    {
        [AppUtilities closeLoading:rightWebView];
    }
    
    [AppUtilities showHUD:errMsg andView:self.view];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

//获取本地的对照表
-(void)getVideoCode
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"obsoletecode" ofType:@"txt"];
    
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    self.codeDic = [str objectFromJSONString];
    
//    NSLog(@"coed === %@",codeDic);
   

}
//判断是否位数字，暂时
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}



//视频播放
- (IBAction)playMovieAtURL
{
/*
    
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     NSString *plistPath = [document stringByAppendingPathComponent:@"finishPlist.plist"];
//    NSLog(@"%@",document);
//    NSLog(@"%@",plistPath);
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSLog(@"%@",data);
//     NSLog(@"%@",[data objectForKey:@"test"] );
//    NSLog(@"%@",[[data objectForKey:@"test"] objectForKey:@"filepath"]);
//    NSURL *url = [NSURL URLWithString:[[data objectForKey:@"test"] objectForKey:@"filepath"]];
      NSURL *url =  [[NSURL alloc] initFileURLWithPath:[[data objectForKey:@"test.mp4"] objectForKey:@"filepath"]];
       NSLog(@"%@",url);
*/
       NSURL *url;
   
       AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
       if(delegant.isFromDownLoad == YES){
           NSString *path = delegant.annStr;
//            NSString* path = [[NSBundle mainBundle] pathForResource:delegant.annStr ofType:@"mp4"];
           NSLog(@"%@",path);
           url =  [[NSURL alloc] initFileURLWithPath:path];
    }else
    {
         url =  [NSURL URLWithString:promoVideoStr];
    }
   
    
   
    self.moviePlayer = [[KKBMoviePlayerController alloc] initWithContentURL:url];

//    self.moviePlayer = theMoviePlayer;
    
//    self.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    
    [self.moviePlayer.view setFrame:CGRectMake(0, 0, 871, 490)];
    self.moviePlayer.initialPlaybackTime = -1;
    self.moviePlayer.endPlaybackTime = -1;
    
    [playView addSubview:self.moviePlayer.view];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer play];
    
    // 注册一个播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
   
}

- (void)myMovieFinishedCallback:(NSNotification *)notify
{
    //视频播放对象
    self.moviePlayer = [notify object];
    
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];
    self.moviePlayer.fullscreen = NO;
    [self.moviePlayer.view removeFromSuperview];
    // 释放视频对象
//    [theMoviePlayer release];
//    self.moviePlayer = nil;
    
}
-(void)stopMovie
{
    if (self.moviePlayer)
    {
        [self.moviePlayer stop];
        //销毁播放通知
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:self.moviePlayer];
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer.view removeFromSuperview];
        
        self.moviePlayer = nil;
    }
    
}
-(void)pauseMovie
{
    if (self.moviePlayer)
    {
        [self.moviePlayer pause];
        self.moviePlayer.fullscreen = NO;
       
    }

}


//缓存单元数据
-(void)cacheModules
{
    NSString * cacheFileName = [NSString stringWithFormat:@"CACHE_MODULES_%@",courseId];

    //archiver
    NSString* modulesPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_COURSEUNIT_MODULES ,nil];
    NSArray * array = [NSArray arrayWithObjects:self.currentUnitList,self.currentSecondLevelUnitList, nil];
    
    [NSKeyedArchiver archiveRootObject:array toFile:modulesPath];
    
}
//读取单元数据
-(void)uncacheModules
{
    NSString * cacheFileName = [NSString stringWithFormat:@"CACHE_MODULES_%@",courseId];
    //unarchiver
    NSString* modulesPath =[FileUtil getDocumentFilePathWithFile:cacheFileName dir:ARCHIVER_DIR,CACHE_COURSEUNIT_MODULES ,nil];
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithFile:modulesPath];
    
    self.currentUnitList = [array objectAtIndex:0];
    self.currentSecondLevelUnitList = [array objectAtIndex:1];
    
    for (int k = 0; k<self.currentUnitList.count; k++){
        [self.openedInSectionArr addObject:@"1"];
        [self.lockSectionArr addObject:@"1"];
    }
    if(self.currentUnitList.count != 0 ){
        [unitTableView reloadData];
    } else {
        [AppUtilities showHUD:@"无网络连接，请检查你的网络" andView:unitTableView];
    }
}

-(void)getDownlodeDic
{
    [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad" TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
 
    FilesDownManage *filedownmanage = [FilesDownManage sharedInstance];
    @synchronized(filedownmanage.filelist){
        for (FileModel *aFile in filedownmanage.filelist) {
            BOOL isCurrentUser = ([[GlobalOperator sharedInstance].userId intValue] == [aFile.usrname intValue]);
            if (aFile != nil && aFile.courseId != nil  && isCurrentUser) {
                BOOL contained = [[self.downloadedList allKeys] containsObject:aFile.courseId];
                if(!contained && (aFile.status == Finished)) {
                    NSMutableArray *arr = [NSMutableArray arrayWithObject:aFile];
                    [self.downloadedList setObject:arr forKey:aFile.courseId];
                } else {
                    NSMutableArray *arr = [downloadedList objectForKey:aFile.courseId];
                    [arr addObject:aFile];
                }
            }
        }
    }
    
    @synchronized(filedownmanage.downinglist){
        for (ASIHTTPRequest *theRequest in filedownmanage.downinglist) {
            if (theRequest!=nil) {
                FileModel *fileInfo = [theRequest.userInfo objectForKey:@"File"];
                if (fileInfo.courseId != nil  && [[NSString stringWithFormat:@"%@",[GlobalOperator sharedInstance].userId] isEqualToString:[NSString stringWithFormat:@"%@",fileInfo.usrname]]) {
                    if([[self.downingList allKeys] containsObject:fileInfo.courseId]) {
                        NSMutableArray *arr = [downingList objectForKey:fileInfo.courseId];
                        BOOL duplicate = NO;
                        for (ASIHTTPRequest *req in arr) {
                            if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                                if ([[req.url absoluteString] isEqualToString:[theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            } else {
                                if ([[(FileModel*)req fileURL] isEqualToString:[theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            }
                        }
                        if (!duplicate ) {
                            [arr addObject:theRequest];
                        }
                    } else {
                        NSMutableArray *arr = [NSMutableArray arrayWithObject:theRequest];
                        [self.downingList setObject:arr forKey:fileInfo.courseId];
                    }
                }
            }
        }
    }
}

-(int)getAbleDownloadCount
{
    ableDownload = 0;
    
    for(int i = 0 ;i <self.currentUnitList.count; i++){
//        if ((NSNull *)[[self.currentUnitList objectAtIndex:i] objectForKey:@"unlock_at"] != [NSNull null]) {
        if((NSNull *)((UnitItem *)[self.currentUnitList objectAtIndex:i]).unlock_at != [NSNull null]){
//            if (![ToolsObject isLaterCurrentSystemDate:[[[[self.currentUnitList objectAtIndex:i] objectForKey:@"unlock_at"] stringValue] substringToIndex:10]]) {
            if(![AppUtilities isLaterCurrentSystemDate:[((UnitItem *)[self.currentUnitList objectAtIndex:i]).unlock_at substringToIndex:10]])
            {
//                NSString *key = [[self.currentUnitList objectAtIndex:i] objectForKey:@"id"];
                NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:i]).item_id;
            
                for (NSDictionary *moduleDic in self.currentSecondLevelVideoList) {
                    if ([[moduleDic objectForKey:@"moduleID"] isEqualToString:key]) {
                        NSMutableArray *videoListArray = [moduleDic objectForKey:@"videoList"];
                        ableDownload += [videoListArray count];
                        
                        if ([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]) {
                            
                        }
                        
                    }
                }
                
                if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
                    NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
                    ableDownload += [arr count];
                    
                    if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]){
                        for(FileModel *m in [self.downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]]){
                            for(UnitDownladItem *item in arr){
                                if([m.fileTitle isEqualToString:item.videoTitle]){
                                    item.hasDownloaded= @"downloaded";
                                }
                            }
                        }
                    }
                    
                    if([[self.downingList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]){
                        for(ASIHTTPRequest *theRequest in [self.downingList objectForKey:[NSString stringWithFormat:@"%@",courseId]]){
                            FileModel *fileInfo = [theRequest.userInfo objectForKey:@"File"];
                            for(UnitDownladItem *item in arr){
                                if([fileInfo.fileTitle isEqualToString:item.videoTitle]){
                                    item.hasDownloaded= @"downloading";
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
        }else {
            
            NSString *key = ((UnitItem *)[self.currentUnitList objectAtIndex:i]).item_id;
//            NSString *key  = [[self.currentUnitList objectAtIndex:i] objectForKey:@"id"];
            
            if ([[courseUnitOperator.courseUnit.modulesItemDic allKeys] containsObject:key]) {
                NSMutableArray *arr = [courseUnitOperator.courseUnit.modulesItemDic objectForKey:key];
                ableDownload += [arr count];
                if([[self.downloadedList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]){
                    for(FileModel *m in [self.downloadedList objectForKey:[NSString stringWithFormat:@"%@",courseId]]){
                        for(UnitDownladItem *item in arr){
                            if([m.fileTitle isEqualToString:item.videoTitle]){
                                item.hasDownloaded= @"downloaded";
                            }
                        }
                    }
                }
                
                if([[self.downingList allKeys] containsObject:[NSString stringWithFormat:@"%@",courseId]]){
                    for(ASIHTTPRequest *theRequest in [self.downingList objectForKey:[NSString stringWithFormat:@"%@",courseId]]){
                        FileModel *fileInfo = [theRequest.userInfo objectForKey:@"File"];
                        for(UnitDownladItem *item in arr){
                            if([fileInfo.fileTitle isEqualToString:item.videoTitle]){
                                item.hasDownloaded= @"downloading";
                            }
                        }
                    }
                }
                
                
            }
            
        }
    }
    
    return ableDownload;
}

- (int) getVideosCountAvailabelDownload{

    FilesDownManage *manager = [FilesDownManage sharedInstance];
    int undownloadItemsCount = [self getAllVideosCount] - [manager getNumberOfTask:courseId];
    
    ableDownload = undownloadItemsCount;
    return undownloadItemsCount;
}

- (int) getAllVideosCount{
    int videosCounter = 0;
    ableDownload = 0;
    for (NSArray *aModules in self.currentSecondLevelUnitList) {
        for (NSDictionary *aItem in aModules) {
            NSString *type = [aItem objectForKey:@"type"];
            BOOL isVideo = [type isEqualToString:@"ExternalTool"];
            if (isVideo) {
                videosCounter++;
            }
        }
    }
    return videosCounter;
}

@end
