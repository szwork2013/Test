//
//  CourseInfoViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-22.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "SideBarSelectedDelegate.h"
#import "DownloadDelegate.h"
#import "KKBActivityIndicatorView.h"
#import "UMSocial.h"
#import "UMSocialConfig.h"
#import "PlayerFrameView.h"

@class AllCoursesItem;
@class CourseDetailView;
@interface CourseInfoViewController : UIViewController</*UITableViewDataSource,UITableViewDelegate,*/UIScrollViewDelegate,ASIHTTPRequestDelegate/*,CourseArrangeViewDelegate*/,UIAlertViewDelegate, DownloadDelegate,UMSocialUIDelegate,PlayerFrameViewDelegate>
{
    KKBActivityIndicatorView *_loadingView;
}
@property (nonatomic, retain)  IBOutlet UIScrollView * myScrollView;
@property (retain, nonatomic) IBOutlet CourseDetailView *courseDetailView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIImageView *shadowView;

@property (nonatomic, retain) NSMutableArray *myCoursesDataArray;

//@property (retain,nonatomic) IBOutlet UITableView *unitTableView;
@property (nonatomic, retain) NSArray *currentUnitList;
@property (nonatomic, retain) NSMutableArray *currentSecondLevelUnitList;
@property (nonatomic, retain) NSArray *currentSecondLevelVideoList;
@property (nonatomic, retain) NSIndexPath *selectIndex;

@property(retain,nonatomic) IBOutlet UIButton *btnInfo;
@property(retain,nonatomic) IBOutlet UIButton *btnbreif;
@property(retain,nonatomic) IBOutlet UIButton *btnArrange;
@property(retain,nonatomic) IBOutlet UIButton *btnPaly;
@property(retain,nonatomic) IBOutlet UILabel *lbCourseName;
@property(retain,nonatomic) IBOutlet UILabel *lbType;
@property(retain,nonatomic) IBOutlet UILabel *lbSchool;
@property(retain,nonatomic) IBOutlet UILabel *lbTeacher;
@property(retain,nonatomic) IBOutlet UILabel *lbStartTime;
@property(retain,nonatomic) IBOutlet UILabel *lbDayTime;
@property(retain,nonatomic) IBOutlet UILabel *lbNumber;
@property(retain,nonatomic) IBOutlet UILabel *lbKeyWords;
@property(retain,nonatomic) IBOutlet UILabel *lbBrief;
@property(retain,nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) NSDictionary *currentAllCoursesItem; //当前全部课程的Item
@property (nonatomic, retain) NSMutableArray *myBadgeDataArray; //我的badge图标

//@property (retain, nonatomic) IBOutlet PlayerFrameView *playerFrameView;
@property (retain, nonatomic) IBOutlet PlayerFrameView *playerFrameViewBasic;
@property (nonatomic,retain) NSString *selectVideoURL;

@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *courseImage;
@property (nonatomic, retain) IBOutlet UIWebView *wbBrief;
@property (nonatomic, retain) IBOutlet UIView *badgeView;
@property (nonatomic, retain) IBOutlet UIView *bgView;

@property(retain,nonatomic) IBOutlet UIButton *btnEntroll;
@property (assign) BOOL isOpen;
@property (retain, nonatomic) IBOutlet UIButton *goOnButton;
@property (retain, nonatomic) IBOutlet UIView *enrollButtonView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

-(IBAction)enrollCourseOnclick;
@end
