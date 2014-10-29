//
//  CourseUnitViewController.h
//  learn
//
//  Created by kaikeba on 13-4-17.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KKBMoviePlayerController.h"
#import "DownloadDelegate.h"
@class AnnouncementViewController;
@class UsersInCourseViewController;

@interface CourseUnitViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, DownloadDelegate>
{
    UIView *sideBarView;
    
    UIButton *courseIntroductionButton; //课程简介按钮
    UIButton *introductionOfLecturerButton; //讲师简介按钮
    UIButton *unitButton; //单元按钮
    UIButton *announcementButton; //通知按钮
    UIButton *userButton; //人员按钮
    
    //************单元***************
    UIView *unitView; //单元界面
   
    UIView *unitDetailsView; //单元WebView界面
    UIWebView *unitDetailsWebView; //单元WebView
    
    //************课程简介和讲师简介*****************
    //用于加载显示所有的Html
    UIWebView *webView;
    UIView *rightWebView;//里面包含返回按钮和webView
    
    NSString *html;
    

}

@property (nonatomic, retain)  UITableView *unitTableView; //单元TableView
@property (nonatomic, retain) NSMutableArray *openedInSectionArr;
@property (nonatomic, retain) NSMutableArray *lockSectionArr;
@property (nonatomic, retain) NSMutableArray *currentUnitList;
@property (nonatomic, retain) NSMutableArray *currentSecondLevelUnitList;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UILabel *leftViewTitle;
@property (nonatomic, retain) IBOutlet UILabel *lbCourseBreif;
@property (nonatomic, retain) IBOutlet UILabel *lbTeacherBreif;
@property (nonatomic, retain) IBOutlet UILabel *lbUnit;
@property (nonatomic, retain) IBOutlet UILabel *lbAnnouncement;
@property (nonatomic, retain) IBOutlet UILabel *lbUser;
@property (nonatomic, retain) IBOutlet UILabel *lbDiscuss;
@property (nonatomic, retain) IBOutlet UILabel *lbTask;
@property (nonatomic, retain) IBOutlet UILabel *lbQuiz;

@property (nonatomic, retain) IBOutlet UIImageView *imvCourseBreif;
@property (nonatomic, retain) IBOutlet UIImageView *imvTeacherBreif;
@property (nonatomic, retain) IBOutlet UIImageView *imvUnit;
@property (nonatomic, retain) IBOutlet UIImageView *imvAnnouncement;
@property (nonatomic, retain) IBOutlet UIImageView *imvUser;
@property (nonatomic, retain) IBOutlet UIImageView *imvDiscuss;
@property (nonatomic, retain) IBOutlet UIImageView *imvTask;
@property (nonatomic, retain) IBOutlet UIImageView *imvQuiz;


@property (nonatomic, retain) IBOutlet UIButton *downButton;

@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, retain) NSString *html;
@property (nonatomic, retain) NSString *imgStr;

@property (nonatomic,retain) NSString *promoVideoStr;
@property(retain,nonatomic)  UIView *playView;

@property (nonatomic, retain) IBOutlet UILabel *downloadingNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *lbHasDownlaodNum;
@property (nonatomic, retain) IBOutlet UILabel *lbNODownlaodNum;
@property (nonatomic, retain) IBOutlet UIView *curtainView;

@property (nonatomic, retain) NSMutableArray *downArr;

@property (nonatomic, retain)NSDictionary *codeDic;

@property NSInteger ableDownload;

@property BOOL isLocked;

//保存MPMoviePlayerController
@property (nonatomic, strong) KKBMoviePlayerController *moviePlayer;

//************通知*****************
@property (nonatomic, retain) UINavigationController *announcementViewController;

//************讨论*****************
@property (nonatomic, retain) UINavigationController *discussionViewController;

//************作业*****************
@property (nonatomic, retain) UINavigationController *assignmentViewController;

//************人员*****************
@property (nonatomic, retain)  UsersInCourseViewController *usersInCourseViewController;

@property(nonatomic,retain)NSMutableDictionary *downingList;//正在下载的

@property(nonatomic,retain)NSMutableDictionary *downloadedList;//下载完成的

@property (nonatomic,strong)UIGestureRecognizer *sidebarGestureR;
@property (nonatomic,strong)NSArray *currentSecondLevelVideoList;


-(IBAction)announcementButtonOnClick;
- (IBAction)downloadAllVideo:(id)sender;

@end
