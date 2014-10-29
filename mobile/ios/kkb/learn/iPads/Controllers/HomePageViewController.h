//
//  HomePageViewController.h
//  learn
//
//  Created by kaikeba on 13-4-9.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "UIGridView.h"
#import "DownloadDelegate.h"
#import "LeftSideBarInPadViewController.h"
#import "CycleScrollView.h"
#import "UpYun.h"

@protocol leftSideBarDelegate ;
@class AllCoursesCell;
@class User4Request;
@class AllCoursesItem;

@interface HomePageViewController : UIViewController<UIScrollViewDelegate, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate, ASIHTTPRequestDelegate, UIGridViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,DownloadDelegate,UpYunDelegate>
{

    
    //************空浮层View，在self.view里，里面的子视图为floatingLayerView**********
    UIImageView *floatingLayerBg_EmptyView;
    
    UIImageView *unitCellIcon;
    
    //**********登陆注册浮层，在self.view里**********************
    UIImageView *loginFloatingLayerBg_EmptyView; //登陆背景
    
    UIView *registerLoginView; //登录注册View
   
    UIWebView *loginWebView; //登录时的WebView
    
    
    //**********全部课程，在self.view里**********************

    UIButton *viewTheCourseButton; //查看课程

    UIGridView *gridView; //全部课程gridView
    
    UIWebView *settingsWebView;
    UIView *bgView;
}

@property (assign,nonatomic) id<leftSideBarDelegate> leftDelegate;
@property (assign,nonatomic) int index;
@property (nonatomic, retain) NSMutableArray *allCourseFromCacheArray;//从缓存中取到的数据
@property (nonatomic, retain) NSMutableArray *headerSliderArray; //首页推荐数据
@property (nonatomic, retain) NSMutableArray *allCoursesDataArray; //全部课程数据
@property (nonatomic, retain) NSMutableArray *myCoursesDataArray; //我的课程数据
@property (nonatomic, retain) NSMutableArray *allMyCoursesDataArray;// 我的全部课程数据 （与全部课程数据一致）
@property (nonatomic, retain) NSDictionary *currentAllCoursesItem; //当前全部课程的Item （改为NSDictionary）
@property (nonatomic,strong) NSMutableArray *allCoursesArray;
@property (nonatomic, retain) NSMutableArray *myBadgeDataArray; //我的badge图标

@property (nonatomic, retain) NSMutableArray *floatingLayerViewCurrentUnitList;
@property (nonatomic, strong) NSMutableArray *floatingLayerViewCurrentSecondLevelUnitList;
@property (nonatomic, retain) NSMutableArray *openedInSectionArr;

@property (nonatomic, retain) NSMutableArray *anncoumentsArray;//个人中心通告数据
@property (nonatomic, retain) NSMutableArray *messageArray;//个人中心作业数据
@property (nonatomic, retain) NSMutableArray *discussArray;//个人中心讨论数据

@property (nonatomic, retain) NSMutableArray *tempArray;//个人中心讨论数据

@property (nonatomic,strong)NSDictionary *userInfoDict;

@property (nonatomic, retain)IBOutlet UIView *settingView;
@property (retain,nonatomic)IBOutlet UIButton *logoutBtn;
@property (retain,nonatomic)IBOutlet UIButton *updateInfoBtn;




@property (nonatomic, retain)IBOutlet UIView *allCoursesView;
@property (nonatomic, retain)IBOutlet UIView *headerView;

@property (retain,nonatomic)IBOutlet UIPageControl* headerPageControl;
@property (retain,nonatomic) CycleScrollView * headerScrollView;
@property (retain,nonatomic)IBOutlet UILabel *courseTitleLabel; //课程title
@property (retain,nonatomic)IBOutlet UILabel *courseBriefLabel; //课程简介

@property (retain,nonatomic)IBOutlet UIView *BrirfVIew; //课程简介View
@property (retain,nonatomic)IBOutlet UIButton *guideBtn;
@property (retain,nonatomic)IBOutlet UIButton *allCourseBtn;
@property (retain,nonatomic)IBOutlet UIButton *publicBtn;
@property (retain, nonatomic) NSMutableArray *pickerArray;
@property (retain,nonatomic) UIPickerView *pickerView;
@property (retain, nonatomic) IBOutlet UIToolbar *doneToolbar;
@property (retain, nonatomic) IBOutlet UIImageView *headerImageView;


@property (retain, nonatomic) IBOutlet UILabel *titleLable;
@property (retain, nonatomic) IBOutlet UIView *backInAbout;

@property (nonatomic,retain) IBOutlet  UIView *myCoursesView;

@property(retain,nonatomic) IBOutlet UIButton *btnEntroll;

@property (nonatomic,retain) IBOutlet UIView *floatingLayerView; //浮层View
@property (nonatomic,retain) IBOutlet UIScrollView *myScrollView;
@property (nonatomic,retain) IBOutlet UIView *headView;
 @property (nonatomic,retain) IBOutlet UIWebView *floatingLayerViewWebView;
@property(retain,nonatomic) IBOutlet UIButton *btnInfo;
@property(retain,nonatomic) IBOutlet UIButton *btnbreif;
@property(retain,nonatomic) IBOutlet UIButton *btnArrange;
@property(retain,nonatomic) IBOutlet UIButton *btnPaly;

@property(retain,nonatomic) IBOutlet UIButton *registerBtn;
@property(retain,nonatomic) IBOutlet UIView *jinbenView;

@property(retain,nonatomic) IBOutlet UILabel *lbLogout;

@property(retain,nonatomic) IBOutlet UILabel *lbTitle;
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

@property (nonatomic, retain) IBOutlet UIView *badgeView;
@property(retain,nonatomic) IBOutlet UIView *playView;
@property (nonatomic, retain) IBOutlet UILabel *allLable;
@property (nonatomic, retain) IBOutlet UITableView *floatingLayerViewCourseArrangementTableView; //课程安排TableView

@property (nonatomic, retain) IBOutlet UIView *activityView;
@property (nonatomic, retain) IBOutlet UITableView *activityTableView;

@property (nonatomic, retain) IBOutlet UIButton *btnAnn;
@property (nonatomic, retain) IBOutlet UIButton *btnMessage;
@property (nonatomic, retain) IBOutlet UIButton *btnDiscuss;

@property (retain,nonatomic) IBOutlet UIView *selfInfoView;

@property (retain,nonatomic) IBOutlet UIView *registerView; //注册View
@property (retain,nonatomic) IBOutlet UIView *loginWebViewBg;
@property (weak, nonatomic) IBOutlet UITextField *loginViewTFEmail;
@property (weak, nonatomic) IBOutlet UITextField *loginViewTFPwd;
@property (weak, nonatomic) IBOutlet UIButton *loginViewLoginButton;

@property (retain,nonatomic) IBOutlet UITextField *tfEmail;
@property (retain,nonatomic) IBOutlet UITextField *tfPwd;
@property (retain,nonatomic) IBOutlet UITextField *tfRealName;
@property (retain,nonatomic) IBOutlet UITextField *tfNickName;
@property (retain,nonatomic) IBOutlet UILabel *tfFalseDetail;
@property (retain,nonatomic) IBOutlet UIImageView *registerViewAvatar;

@property (retain,nonatomic) IBOutlet UIImageView *detailView1;
@property (retain,nonatomic) IBOutlet UIImageView *detailView2;
@property (retain,nonatomic) IBOutlet UIImageView *detailView3;
@property (retain,nonatomic) IBOutlet UIImageView *detailView4;
@property (retain,nonatomic) IBOutlet UIImageView *detailView5;


@property (retain,nonatomic) IBOutlet UITextField *tfEmailInSelfView;
@property (retain,nonatomic) IBOutlet UITextField *tfRealNameInSelfView;
@property (retain,nonatomic) IBOutlet UITextField *tfNickNameInSelfView;
@property (retain,nonatomic) IBOutlet UIImageView *registerViewAvatarInSelfView;
@property (retain,nonatomic) IBOutlet UILabel *tfFalseDetailInSelfView;

@property (retain,nonatomic) IBOutlet UIImageView *detailView1InSelfView;
@property (retain,nonatomic) IBOutlet UIImageView *detailView3InSelfView;
@property (retain,nonatomic) IBOutlet UIImageView *detailView4InSelfView;
@property (retain,nonatomic) IBOutlet UIImageView *detailView5InSelfView;
@property BOOL FromSelf;

@property (retain,nonatomic) NSString *courseCateogy;
@property (retain,nonatomic) NSString *courseType;

@property (retain,nonatomic) IBOutlet UIView *sectionView;
@property (retain,nonatomic) IBOutlet UILabel *showLabel;
@property (retain,nonatomic) IBOutlet UILabel *lbMyCourse;
@property (retain,nonatomic) IBOutlet UILabel *lbActivty;


//下载
@property (retain,nonatomic) IBOutlet UIView *downloadView;
@property (retain,nonatomic) IBOutlet UILabel *ableUseDiskLabel;
@property (retain,nonatomic) IBOutlet UILabel *UsedDiskLabel;
@property (retain,nonatomic) IBOutlet UILabel *startLabel;
@property (retain,nonatomic) IBOutlet UILabel *stopLabel;
@property (retain,nonatomic) IBOutlet UILabel *manageLabel;
@property (retain,nonatomic) IBOutlet UIButton *startBtn;
@property (retain,nonatomic) IBOutlet UIButton *stopBtn;
@property (retain,nonatomic) IBOutlet UIImageView *barView;

@property BOOL EnableEdit;

@property (retain,nonatomic) IBOutlet UICollectionView *downloadCollectionView; //下载管理tableView
@property(nonatomic,retain)NSMutableDictionary *downingList;
@property(nonatomic,retain)NSMutableArray *downingSectionList;

//@property (retain,nonatomic) IBOutlet UICollectionView *AllCourseCollectionView; //qubu

@property BOOL FromLogin;
//@property (retain,nonatomic) IBOutlet UIView *cloverView;
@property (retain,nonatomic) UIButton *menuBtn;

@property (retain,nonatomic) IBOutlet UICollectionView *myCourseCollectionView; //我的课程view


@property (nonatomic , strong) NSTimer *animationTimer;


- (IBAction)settingsButtonOnClick;
- (IBAction)downloadManageButtonOnClick;
- (IBAction)selfButtonOnClick;
- (IBAction)myCoursesButtonOnClick;
- (IBAction)allCoursesButtonOnClick;
-(IBAction)loginButtonOnClick;

- (IBAction)loginViewToLogin:(id)sender;
-(void)controllBtn:(BOOL)enabled;
@end
