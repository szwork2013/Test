//
//  HomePageViewController.m
//  learn
//
//  Created by kaikeba on 13-4-9.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "HomePageViewController.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UMFeedback.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "HomePageOperator.h"
#import "UIImage+fixOrientation.h"

#import "CourseUnitStructs.h"
#import "AllCoursesCell.h"
#import "DownloadCell.h"
#import "MyCourseCell.h"
#import "CourseUnitViewController.h"
#import "Cell1.h"
#import "Cell2.h"
#import "MobClick.h"
#import "FileUtil.h"

#import "MBProgressHUD.h"

#import "FilesDownManage.h"

#import "KKBMoviePlayerController.h"
#import "CollectionHeadView.h"
#import "CollectionFootView.h"

#import "SidebarViewControllerInPadViewController.h"
#import "NSTimer+Addition.h"
#import <objc/runtime.h>

#import "AllCourseCell.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "LocalStorage.h"
#import "KKBDataBase.h"
#import "KKBUploader.h"

NSString *const KCellID = @"CollectionCell";
NSString *const MyCoyrseCellID = @"CollectionMyCoyrseCell";

// NSString *const AllCourseCellID = @"CollectionAllCoyrseCell";
#define API_CMS_V4 @"http://www.kaikeba.com/api/v4/"

static const char kRepresentedObject;

@interface HomePageViewController () <
    UIActionSheetDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    UIActionSheet *uploadImageActionSheet; //上传头像ActionSheet

    UIImagePickerController *cameraImagePicker;

    int tickIndex;

    HomePageOperator *homePageOperator;
    UIGestureRecognizer *sidebarGestureR;
}

@property(retain, nonatomic) UIPopoverController *popoverController;

//保存MPMoviePlayerController
@property(nonatomic, strong) KKBMoviePlayerController *moviePlayer;

//@property (nonatomic, copy) NSString *blueButtonUrl;

@end

@implementation HomePageViewController

//@synthesize cloverView;
@synthesize leftDelegate;
@synthesize index;
@synthesize EnableEdit;
@synthesize popoverController;
@synthesize moviePlayer;
@synthesize headerSliderArray;
@synthesize allCoursesDataArray;
@synthesize myCoursesDataArray;
@synthesize currentAllCoursesItem;
@synthesize allCourseFromCacheArray;
@synthesize floatingLayerViewCurrentUnitList;
@synthesize floatingLayerViewCurrentSecondLevelUnitList;
@synthesize anncoumentsArray, messageArray, discussArray, tempArray;
@synthesize downingList;
@synthesize settingView, updateInfoBtn, logoutBtn;
@synthesize allCoursesView;
@synthesize headerView;
@synthesize headerPageControl, headerScrollView;
@synthesize courseBriefLabel, courseTitleLabel;
@synthesize BrirfVIew;
@synthesize publicBtn, guideBtn, allCourseBtn;
@synthesize pickerArray;
@synthesize pickerView;
@synthesize doneToolbar;
@synthesize headerImageView;
@synthesize titleLable;
@synthesize backInAbout;

@synthesize floatingLayerView;
@synthesize myCoursesView;
@synthesize myScrollView;
@synthesize headView;
@synthesize floatingLayerViewWebView;
@synthesize btnArrange, btnbreif, btnInfo, btnPaly;
@synthesize jinbenView;
@synthesize lbLogout;

@synthesize lbDayTime, lbNumber, lbSchool, lbStartTime, lbTeacher, lbType,
    lbBrief, lbKeyWords, lbCourseName, lbTitle;
@synthesize badgeView, imgView;
@synthesize myBadgeDataArray;
@synthesize allLable;
@synthesize playView;

@synthesize openedInSectionArr;
@synthesize floatingLayerViewCourseArrangementTableView;
@synthesize activityTableView, activityView;

@synthesize btnAnn, btnDiscuss, btnMessage;

@synthesize tfEmail, tfNickName, tfPwd, tfRealName, tfFalseDetail;
@synthesize registerViewAvatar;
@synthesize detailView1, detailView2, detailView3, detailView4, detailView5;
@synthesize registerView, loginWebViewBg;
@synthesize selfInfoView;

@synthesize tfEmailInSelfView, tfNickNameInSelfView, tfRealNameInSelfView,
    registerViewAvatarInSelfView, tfFalseDetailInSelfView;
@synthesize detailView1InSelfView, detailView3InSelfView, detailView4InSelfView,
    detailView5InSelfView;
@synthesize FromSelf;
@synthesize courseCateogy, courseType;
@synthesize sectionView;
@synthesize showLabel;
@synthesize lbMyCourse;
@synthesize lbActivty;
@synthesize downloadView, ableUseDiskLabel, UsedDiskLabel, startBtn, startLabel,
    stopBtn, stopLabel, barView, manageLabel;
@synthesize downingSectionList;
@synthesize downloadCollectionView;
@synthesize FromLogin;
@synthesize menuBtn;
@synthesize myCourseCollectionView;
@synthesize registerBtn;
@synthesize btnEntroll;
//@synthesize AllCourseCollectionView;
//@synthesize cloverBtn;
@synthesize allCoursesArray;
@synthesize allMyCoursesDataArray;
@synthesize userInfoDict;
#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        self.pickerArray =
            [[NSMutableArray alloc] initWithObjects:@"全部类别", nil];
        self.openedInSectionArr = [[NSMutableArray alloc] init];

        self.discussArray = [[NSMutableArray alloc] init];
        self.anncoumentsArray = [[NSMutableArray alloc] init];
        self.messageArray = [[NSMutableArray alloc] init];

        self.floatingLayerViewCurrentUnitList = [[NSMutableArray alloc] init];
        self.floatingLayerViewCurrentSecondLevelUnitList =
            [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)makeActivityView {
    activityView = [[UIView alloc] init];
    if (IS_IOS_7) {
        activityView.frame = CGRectMake(256, 20, 768, 748);
    } else {
        activityView.frame = CGRectMake(256, 0, 768, 748);
    }
    activityView.hidden = YES;
    [self.view addSubview:activityView];

    activityView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"mycourse_bg"]];

    UIImageView *headerImage =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bar"]];
    headerImage.frame = CGRectMake(0, 0, 768, 44);
    headerImage.userInteractionEnabled = YES;
    [activityView addSubview:headerImage];

    activityTableView =
        [[UITableView alloc] initWithFrame:CGRectMake(10, 44, 748, 748)
                                     style:UITableViewStylePlain];
    activityTableView.delegate = self;
    activityTableView.dataSource = self;
    [activityTableView setBackgroundColor:[UIColor clearColor]];
    activityTableView.showsHorizontalScrollIndicator = NO;
    activityTableView.showsVerticalScrollIndicator = NO;
    [activityTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [activityView addSubview:activityTableView];

    [activityView bringSubviewToFront:activityTableView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginViewTFPwd.secureTextEntry = YES;
    if ([AppUtilities isExistenceNetwork] == NO) {
        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:@"提示"
                      message:@"当前网络处于非wifi状态下"
                     delegate:self
            cancelButtonTitle:@"取消"
            otherButtonTitles:nil];
        [alertView show];
    }

    FromLogin = NO;

    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor blackColor];

    headerImageView.layer.masksToBounds = NO;
    headerImageView.layer.cornerRadius = 8; // if you like rounded corners
    headerImageView.layer.shadowOffset = CGSizeMake(0, 1);
    headerImageView.layer.shadowRadius = 3;
    headerImageView.layer.shadowOpacity = 0.1;

    gridView = [[UIGridView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];

    gridView.backgroundColor = [UIColor clearColor];
    //    gridView.backgroundColor = [UIColor lightGrayColor];
    gridView.uiGridViewDelegate = self;
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.showsVerticalScrollIndicator = NO;
    //    gridView.rowHeight = 325;
    [gridView setTableHeaderView:headerView];
    //    [gridView release];

    [allCoursesView addSubview:gridView];

    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, 1024, 20);
    footView.backgroundColor = [UIColor clearColor];
    [gridView setTableFooterView:footView];

    //    UIView *footView1 = [[[UIView alloc]init]autorelease];
    //    footView1.frame = CGRectMake(0, 0, 768, 20);
    //    footView1.backgroundColor = [UIColor clearColor];

    courseTitleLabel.numberOfLines = 0;
    courseTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    courseBriefLabel.numberOfLines = 0;
    courseBriefLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    activityTableView.delegate = self;
    activityTableView.dataSource = self;
    [activityTableView setBackgroundColor:[UIColor clearColor]];
    activityTableView.showsHorizontalScrollIndicator = NO;
    activityTableView.showsVerticalScrollIndicator = NO;
    [activityTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    //    UIView *footView2 = [[[UIView alloc]init]autorelease];
    //    footView2.frame = CGRectMake(0, 0, 768, 20);
    //    footView2.backgroundColor = [UIColor clearColor];
    [activityTableView setTableFooterView:footView];

    [floatingLayerViewCourseArrangementTableView setDelegate:self];

    //先创建轮播图，防止timer创建2次
    self.headerScrollView =
        [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 325)
                             animationDuration:5];

    //从缓存加载轮播图
    //    [self uncacheHeaderSliders];
    //从缓存加载全部课程
    //    [self uncacheAllCourse];
    //从缓存加载课程分类
    //    [self uncacheCourseCategory];
    //从缓存加载badge图标
    //    [self uncacheBadges];

    if ([AppUtilities isExistenceNetwork]) {
        //加载首页推荐数据
        //        [homePageOperator requestHeaderSliders:self
        //        token:PUBLIC_TOKEN];
        //加载全部课程数据
        //        [homePageOperator requestAllCourses:self token:PUBLIC_TOKEN];
        //        [homePageOperator requestAllCoursesCategory:self
        //        token:PUBLIC_TOKEN];
        //        [homePageOperator requestBadge:self token:PUBLIC_TOKEN];
    }

    //判断token.json文件是否存在，存在的话则不用登录
    if ([[NSFileManager defaultManager]
            fileExistsAtPath:[AppUtilities getTokenJSONFilePathForPad]]) {
        //        //无网情况下使用缓存
        //        if (![ToolsObject isExistenceNetwork])
        //        {
        //从缓存加载我的课程
        //            [self uncacheMyCourse];
        //            //从缓存加载我的信息
        //            [self uncacheAccountProfiles];
        lbLogout.text = @"注销";

        //        }

        [GlobalOperator sharedInstance].isLogin = YES;

        NSString *json = [NSString
            stringWithContentsOfFile:[AppUtilities getTokenJSONFilePathForPad]
                            encoding:NSUTF8StringEncoding
                               error:nil];
        NSDictionary *tokenDictionary = [json objectFromJSONString];

        NSString *token = [tokenDictionary objectForKey:@"token"];
        [GlobalOperator sharedInstance].userId =
            [tokenDictionary objectForKey:@"id"];

        [GlobalOperator sharedInstance].user4Request.user.avatar.token = token;
        [[KKBHttpClient shareInstance] setUserToken:token];

        [self getAccountProfiles:[GlobalOperator sharedInstance].userId
                           token:token];

        [self loadMyCourses:YES];

    } else {

        updateInfoBtn.enabled = NO;
        updateInfoBtn.titleLabel.textColor = [UIColor lightGrayColor];
    }

    // add
    [self loadData:YES];

    [self loadData:NO];
    // end

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardwillshow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardDidHide:)
               name:UIKeyboardDidHideNotification
             object:nil];

    [self makeFloatingLayerView];

    self.courseCateogy = @"全部类别";
    self.courseType = @"all";

    //无网情况下使用缓存
    if (![AppUtilities isExistenceNetwork]) {
        lbActivty.text = @"无网络连接，请检查您的网络";
    }

    self.downingList = [NSMutableDictionary dictionary];
    // KCellID为宏定义 @"CollectionCell"

    UINib *nibForMyCourse = [UINib nibWithNibName:@"MyCoursesCell" bundle:nil];
    [self.myCourseCollectionView registerNib:nibForMyCourse
                  forCellWithReuseIdentifier:MyCoyrseCellID];

    [self.myCourseCollectionView registerClass:[MyCourseCell class]
                    forCellWithReuseIdentifier:MyCoyrseCellID];

    [self.myCourseCollectionView
                     registerClass:[CollectionFootView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
               withReuseIdentifier:@"foot"];

    UINib *nib = [UINib nibWithNibName:@"DownloadCell" bundle:nil];
    [self.downloadCollectionView registerNib:nib
                  forCellWithReuseIdentifier:KCellID];
    [self.downloadCollectionView registerClass:[DownloadCell class]
                    forCellWithReuseIdentifier:KCellID];

    [self.downloadCollectionView
                     registerClass:[CollectionHeadView class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"head"];

    EnableEdit = NO;

    menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    menuBtn.frame = CGRectMake(0, 0, 60, 60);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"button_menu_normal"]
                       forState:UIControlStateNormal];
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"button_menu_selected"]
                       forState:UIControlStateHighlighted];
    [menuBtn addTarget:self
                  action:@selector(showLeftSideBar:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuBtn];

    [self.view bringSubviewToFront:menuBtn];
}
- (IBAction)showLeftSideBar:(id)sender {
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == floatingLayerViewCourseArrangementTableView) {
        if (myScrollView.contentOffset.y < 248 ||
            myScrollView.contentOffset.y <= 0) {
            [scrollView setUserInteractionEnabled:NO];
        }
    } else if (scrollView == myScrollView) {
        if (myScrollView.contentOffset.y >= 253) {
            [floatingLayerViewCourseArrangementTableView
                setUserInteractionEnabled:YES];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == myScrollView) {
        if (myScrollView.contentOffset.y > 253) {
            //        hView.backgroundColor = [UIColor blueColor];
            //        [floatingLayerView addSubview:hView];
            [headView
                setFrame:CGRectMake(0, scrollView.contentOffset.y, 450, 70)];
            if (floatingLayerViewWebView.hidden == NO) {
                myScrollView.contentSize =
                    CGSizeMake(myScrollView.frame.size.width, 1095);

                [floatingLayerViewWebView
                    setFrame:CGRectMake(0, scrollView.contentOffset.y + 60, 450,
                                        618)];
            }
            if (floatingLayerViewCourseArrangementTableView.hidden == NO) {
                myScrollView.contentSize =
                    CGSizeMake(myScrollView.frame.size.width, 1095);
                //            floatingLayerViewCourseArrangementTableView.contentSize
                //            =
                //            [floatingLayerViewCourseArrangementTableView
                //            setFrame:CGRectMake(0,
                //            scrollView.contentOffset.y+60, 450, 618)];
                //            if(
                //            floatingLayerViewCourseArrangementTableView.contentOffset.y
                //            > 0){
                //
                //                // [self scrollViewDidScroll:myScrollView];
                //            }
            }
        }
        if (myScrollView.contentOffset.y <= 253 &&
            myScrollView.contentOffset.y > 0) {
            [headView setFrame:CGRectMake(0, 253, 450, 70)];
            //            [floatingLayerViewCourseArrangementTableView
            //            setFrame:CGRectMake(0, 343, 450, 618)];
        }
        //    NSLog(@"=%f",myScrollView.contentOffset.y);
        if (myScrollView.contentOffset.y >= 253) {
            [floatingLayerViewCourseArrangementTableView
                setUserInteractionEnabled:YES];
        }
    } else {
        if (scrollView == floatingLayerViewCourseArrangementTableView) {
            if (myScrollView.contentOffset.y < 248 ||
                myScrollView.contentOffset.y <= 0) {
                [scrollView setUserInteractionEnabled:NO];
            }
        }
    }
}

- (void)retBtnInAllCourse {
    [allCourseBtn setTitleColor:[UIColor colorWithRed:121.0 / 255
                                                green:124.0 / 255
                                                 blue:128.0 / 255
                                                alpha:1.0]
                       forState:UIControlStateNormal];
    [allCourseBtn
        setBackgroundImage:[UIImage imageNamed:@"allcourses_tab_left_selected"]
                  forState:UIControlStateNormal];
    [guideBtn setTitleColor:[UIColor colorWithRed:121.0 / 255
                                            green:124.0 / 255
                                             blue:128.0 / 255
                                            alpha:1.0]
                   forState:UIControlStateNormal];
    [guideBtn
        setBackgroundImage:[UIImage
                               imageNamed:@"allcourses_tab_middle_selected"]
                  forState:UIControlStateNormal];
    [publicBtn setTitleColor:[UIColor colorWithRed:121.0 / 255
                                             green:124.0 / 255
                                              blue:128.0 / 255
                                             alpha:1.0]
                    forState:UIControlStateNormal];
    [publicBtn
        setBackgroundImage:[UIImage imageNamed:@"allcourses_tab_right_selected"]
                  forState:UIControlStateNormal];
}
- (IBAction)clickPublicBtn:(id)sender {
    [self retBtnInAllCourse];
    [publicBtn setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    [publicBtn
        setBackgroundImage:[UIImage imageNamed:@"allcourses_tab_right_normal"]
                  forState:UIControlStateNormal];
    self.courseType = @"public";

    [self.allCoursesDataArray removeAllObjects];
    //    self.allCoursesDataArray = [[[NSMutableArray alloc]init]autorelease];
    if ([AppUtilities isExistenceNetwork]) {
        for (int i = 0; i < self.allCoursesArray.count; i++) {
            NSDictionary *item = [self.allCoursesArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    } else {
        for (int i = 0; i < self.allCourseFromCacheArray.count; i++) {
            NSDictionary *item = [self.allCourseFromCacheArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    }

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];

    for (NSDictionary *item in self.allCoursesDataArray) {
        if ([[item objectForKey:@"courseCategory"]
                isEqualToString:courseCateogy]) {

            if (![[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                [tempArr addObject:item];
            }
        } else if ([@"全部类别" isEqualToString:courseCateogy]) {
            if (![[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                [tempArr addObject:item];
            }
        }
    }
    [self.allCoursesDataArray removeAllObjects];
    self.allCoursesDataArray = tempArr;
    if (self.allCoursesDataArray.count == 0) {
        showLabel.text = [NSString
            stringWithFormat:
                @"在%@"
                @"下暂时没有公开课，课程很快就会充实起"
                @"来了。先去看看其他类型的课程吧。",
                self.courseCateogy];

    } else {
        showLabel.text = @"";
    }
    [gridView reloadData];
}
- (IBAction)clickGuideBtn:(id)sender {
    [self retBtnInAllCourse];
    [guideBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [guideBtn
        setBackgroundImage:[UIImage imageNamed:@"allcourses_tab_middle_normal"]
                  forState:UIControlStateNormal];
    self.courseType = @"guide";

    [self.allCoursesDataArray removeAllObjects];
    //    self.allCoursesDataArray = [[[NSMutableArray alloc]init]autorelease];
    if ([AppUtilities isExistenceNetwork]) {
        for (int i = 0; i < self.allCoursesArray.count; i++) {
            NSDictionary *item = [self.allCoursesArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    } else {
        for (int i = 0; i < self.allCourseFromCacheArray.count; i++) {
            NSDictionary *item = [self.allCourseFromCacheArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    }

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSDictionary *item in self.allCoursesDataArray) {
        if ([[item objectForKey:@"courseCategory"]
                isEqualToString:courseCateogy]) {
            if ([[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                [tempArr addObject:item];
            }
        } else if ([@"全部类别" isEqualToString:courseCateogy]) {
            if ([[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                [tempArr addObject:item];
            }
        }
    }
    [self.allCoursesDataArray removeAllObjects];
    self.allCoursesDataArray = tempArr;
    if (self.allCoursesDataArray.count == 0) {
        showLabel.text = [NSString
            stringWithFormat:
                @"在%@"
                @"下暂时没有导学课，课程很快就会充实起"
                @"来了。先去看看其他类型的课程吧。",
                self.courseCateogy];

    } else {
        showLabel.text = @"";
    }
    [gridView reloadData];
}
- (IBAction)clickAllBtn:(id)sender {
    [self retBtnInAllCourse];
    [allCourseBtn setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [allCourseBtn
        setBackgroundImage:[UIImage imageNamed:@"allcourses_tab_left_normal"]
                  forState:UIControlStateNormal];
    self.courseType = @"all";

    [self.allCoursesDataArray removeAllObjects];
    if ([AppUtilities isExistenceNetwork]) {
        for (int i = 0; i < self.allCoursesArray.count; i++) {
            NSDictionary *item = [self.allCoursesArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    } else {
        for (int i = 0; i < self.allCourseFromCacheArray.count; i++) {
            NSDictionary *item = [self.allCourseFromCacheArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    }

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    if (![@"全部类别" isEqualToString:courseCateogy]) {
        for (NSDictionary *item in self.allCoursesDataArray) {
            if ([[item objectForKey:@"courseCategory"]
                    isEqualToString:courseCateogy]) {
                [tempArr addObject:item];
            }
        }
        [self.allCoursesDataArray removeAllObjects];
        self.allCoursesDataArray = tempArr;
    }
    showLabel.text = @"";
    [gridView reloadData];
}

- (IBAction)clickAllCourseBtn:(id)sender {
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 1024, 768);
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self
                  action:@selector(canclePress:)
        forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];

    pickerView =
        [[UIPickerView alloc] initWithFrame:CGRectMake(0, 552, 1024, 216)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.backgroundColor = [UIColor whiteColor];
    [pickerView selectRow:0 inComponent:0 animated:YES];
    [bgView addSubview:pickerView];

    doneToolbar.frame = CGRectMake(0, 508, 1024, 44);
    //    doneToolbar.backgroundColor = [UIColor clearColor];
    [bgView addSubview:doneToolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.headerScrollView pauseTimer:NO];

    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.headerScrollView pauseTimer:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)keyboardwillshow:(NSNotification *)noti {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:0.25];
    loginWebViewBg.frame = CGRectMake(240, 30, 550, 405);
    //    registerLoginView.frame = CGRectMake(175, -6, 675, 520);
    registerView.frame =
        CGRectMake(240, -70, 550, registerView.frame.size.height);
    selfInfoView.frame = CGRectMake(240, -70, 550, 472);

    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)noti {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:0.25];

    loginWebViewBg.frame = CGRectMake(240, 140, 550, 405);
    //    registerLoginView.frame = CGRectMake(175, 114, 675, 520);
    registerView.frame =
        CGRectMake(240, 140, 550, registerView.frame.size.height);
    selfInfoView.frame = CGRectMake(240, 100, 550, 472);

    [UIView commitAnimations];
}

#pragma mark - LeftView界面

//全部课程按钮响应
- (IBAction)allCoursesButtonOnClick {
    if (self.allCoursesDataArray.count == 0 &&
        [AppUtilities isExistenceNetwork]) {
        //加载全部课程数据
        //        [homePageOperator requestAllCourses:self token:PUBLIC_TOKEN];

        //          [homePageOperator requestAllCoursesCategory:self
        //          token:PUBLIC_TOKEN];

        [self loadAllCourses:NO];
        [self loadAllCoursesCategory:NO];

        //        [homePageOperator requestBadge:self token:PUBLIC_TOKEN];
    }
    if (self.myBadgeDataArray.count == 0 && [AppUtilities isExistenceNetwork]) {

        //        [homePageOperator requestBadge:self token:PUBLIC_TOKEN];
        [self loadBadge:NO];
    }

    allCoursesView.hidden = NO;
    myCoursesView.hidden = YES;
    activityView.hidden = YES;
    downloadView.hidden = YES;

    loginFloatingLayerBg_EmptyView.hidden = YES;

    [self.headerScrollView pauseTimer:NO];
}
- (IBAction)myCoursesButtonOnClick {
    myCoursesView.hidden = NO;
    allCoursesView.hidden = YES;
    activityView.hidden = YES;
    downloadView.hidden = YES;

    loginFloatingLayerBg_EmptyView.hidden = YES;

    [self.headerScrollView pauseTimer:YES];

    if (myCoursesDataArray.count == 0) {
        [self checkMyCourses];
    }
}

- (IBAction)selfButtonOnClick {
    allCoursesView.hidden = YES;
    myCoursesView.hidden = YES;
    activityView.hidden = NO;
    downloadView.hidden = YES;

    loginFloatingLayerBg_EmptyView.hidden = YES;

    if (self.anncoumentsArray.count == 0 && self.discussArray.count == 0 &&
        self.messageArray.count == 0 && [AppUtilities isExistenceNetwork]) {

        //加载全部课程数据
        //        [homePageOperator requestAllCourses:self token:PUBLIC_TOKEN];
        [self loadAllCourses:NO];

        //        [homePageOperator requestMyCourses:self token:[GlobalOperator
        //        sharedInstance].user4Request.user.avatar.token];
        [self loadMyCourses:NO];
        //        [homePageOperator requestActivityStream:self
        //        token:[GlobalOperator
        //        sharedInstance].user4Request.user.avatar.token];
        [self loadActivityStream:NO];
    }
    [self.headerScrollView pauseTimer:YES];
}
- (IBAction)downloadManageButtonOnClick {
    [self.headerScrollView pauseTimer:YES];

    allCoursesView.hidden = YES;
    myCoursesView.hidden = YES;
    activityView.hidden = YES;
    downloadView.hidden = NO;

    loginFloatingLayerBg_EmptyView.hidden = YES;

    [self checkUsedDisk];

    [self.downingList removeAllObjects];

    [FilesDownManage
        sharedFilesDownManageWithBasepath:@"DownLoad"
                            TargetPathArr:[NSArray
                                              arrayWithObject:@"DownLoad/mp4"]];
    [FilesDownManage sharedInstance].downloadDelegate = self;
    FilesDownManage *filedownmanage = [FilesDownManage sharedInstance];

    //    [filedownmanage startLoad];

    for (FileModel *model in filedownmanage.filelist) {
        if (model.status == Downloading) {
            [startLabel setTextColor:[UIColor colorWithRed:61.0 / 255
                                                     green:69.0 / 255
                                                      blue:76.0 / 255
                                                     alpha:1.0]];
            [stopLabel setTextColor:[UIColor colorWithRed:61.0 / 255
                                                    green:69.0 / 255
                                                     blue:76.0 / 255
                                                    alpha:1.0]];
            startBtn.enabled = YES;
            stopBtn.enabled = YES;
            break;
        }
    }
    for (FileModel *model in filedownmanage.filelist) {
        if ([[NSString
                stringWithFormat:@"%@", [GlobalOperator sharedInstance].userId]
                isEqualToString:[NSString
                                    stringWithFormat:@"%@", model.usrname]]) {
            if (model.courseId == nil) {
                continue;
            }
            if ([[self.downingList allKeys] containsObject:model.courseId]) {
                NSMutableArray *arr = [downingList objectForKey:model.courseId];
                BOOL duplicate = NO;
                for (FileModel *m in arr) {
                    if ([m isKindOfClass:[FileModel class]]) {
                        if ([[m fileName] isEqualToString:[model fileName]]) {
                            duplicate = YES;
                            break;
                        }
                    } else {
                        if ([[[(ASIHTTPRequest *)m url] absoluteString]
                                isEqualToString:[model fileURL]]) {
                            duplicate = YES;
                            break;
                        }
                    }
                }
                if (!duplicate) {
                    [arr addObject:model];
                }
            } else {

                BOOL contained = NO;
                NSMutableArray *items =
                    [self.downingList objectForKey:model.courseId];
                for (FileModel *aFile in items) {
                    if ([aFile.fileName isEqualToString:model.fileName]) {
                        contained = YES;
                        break;
                    }
                }

                if (!contained) {
                    NSMutableArray *arr =
                        [NSMutableArray arrayWithObject:model];
                    [self.downingList setObject:arr forKey:model.courseId];
                }
                //                NSMutableArray *arr = [NSMutableArray
                //                arrayWithObject:model];
                //                [self.downingList setObject:arr
                //                forKey:model.courseId];
            }
        }
    }

    @synchronized(filedownmanage.downinglist) {
        for (ASIHTTPRequest *theRequest in filedownmanage.downinglist) {
            if (theRequest != nil) {
                FileModel *fileInfo =
                    [theRequest.userInfo objectForKey:@"File"];

                if (fileInfo.courseId != nil &&
                    [[NSString
                        stringWithFormat:@"%@",
                                         [GlobalOperator sharedInstance].userId]
                        isEqualToString:
                            [NSString
                                stringWithFormat:@"%@", fileInfo.usrname]]) {
                    if ([[self.downingList allKeys]
                            containsObject:fileInfo.courseId]) {
                        NSMutableArray *arr =
                            [downingList objectForKey:fileInfo.courseId];
                        BOOL duplicate = NO;
                        for (ASIHTTPRequest *req in arr) {
                            if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                                if ([[req.url absoluteString]
                                        isEqualToString:
                                            [theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            } else {
                                if ([[(FileModel *)req fileURL]
                                        isEqualToString:
                                            [theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            }
                        }
                        if (!duplicate) {
                            [arr addObject:theRequest];
                        }
                    } else {
                        NSMutableArray *arr =
                            [NSMutableArray arrayWithObject:theRequest];
                        [self.downingList setObject:arr
                                             forKey:fileInfo.courseId];
                    }
                }
            }
        }
    }

    @synchronized(filedownmanage.filelist) { // here

        filedownmanage.filelist = [NSMutableArray
            arrayWithArray:[filedownmanage sortbyTime:filedownmanage.filelist]];

        for (FileModel *fileInfo in filedownmanage.filelist) {
            BOOL isCurrentUser = [[NSString
                stringWithFormat:@"%@", [GlobalOperator sharedInstance].userId]
                isEqualToString:[NSString
                                    stringWithFormat:@"%@", fileInfo.usrname]];
            if (fileInfo != nil && fileInfo.courseId != nil && isCurrentUser) {
                if ([[self.downingList allKeys]
                        containsObject:fileInfo.courseId]) {
                    NSMutableArray *arr =
                        [downingList objectForKey:fileInfo.courseId];

                    BOOL duplicate = NO;
                    for (FileModel *aFile in arr) {
                        duplicate =
                            [aFile.fileName isEqualToString:fileInfo.fileName];
                        if (duplicate) {
                            break;
                        }
                    }

                    if (!duplicate) {
                        [arr addObject:fileInfo];
                    }

                } else {
                    NSMutableArray *arr =
                        [NSMutableArray arrayWithObject:fileInfo];
                    [self.downingList setObject:arr forKey:fileInfo.courseId];
                }

                //                NSMutableArray *arr = [downingList
                //                objectForKey:fileInfo.courseId];
                //                arr = [NSMutableArray arrayWithArray:[self
                //                sortItems:arr]];
            }
        }
    }

    [self sortDownloadItems];

    if (EnableEdit == YES) {
        manageLabel.text = @"管理";
        EnableEdit = NO;

        startLabel.hidden = NO;
        stopLabel.hidden = NO;
        startBtn.enabled = YES;
        stopBtn.enabled = YES;

        ableUseDiskLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                     green:161.0 / 255
                                                      blue:219.0 / 255
                                                     alpha:1.0];
        UsedDiskLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                  green:161.0 / 255
                                                   blue:219.0 / 255
                                                  alpha:1.0];

        barView.image = [UIImage imageNamed:@"recently_tab_bg"];
    }

    [self.downloadCollectionView reloadData];
}

- (void)sortDownloadItems {
    for (NSString *courseId in [self.downingList allKeys]) {
        NSMutableArray *arr = [downingList objectForKey:courseId];
        arr = [NSMutableArray arrayWithArray:[self sortItems:arr]];

        [downingList setObject:arr forKey:courseId];
    }
}

- (void)login {
    /*
     //判断token.json文件是否存在，存在的话则不用登录
     if ([[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject
     getTokenJSONFilePath]])
     {
     NSString *json = [NSString stringWithContentsOfFile:[ToolsObject
     getTokenJSONFilePath] encoding:NSUTF8StringEncoding error:nil];
     NSDictionary *tokenDictionary = [json objectFromJSONString];

     NSString *token = [tokenDictionary objectForKey:@"access_token"];
     [GlobalOperator sharedInstance].userId = [[tokenDictionary
     objectForKey:@"user"] objectForKey:@"id"];

     [GlobalOperator sharedInstance].user4Request.user.avatar.token = token;

     [self getAccountProfiles:[GlobalOperator sharedInstance].userId
     token:token];

     [self checkMyCourses];
     }
     else
     {
     registerLoginView.hidden = YES;
     loginWebViewBg.hidden = NO;

     [loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL
     URLWithString:[homePageOperator loginUrl]]]];
     }
     */
    registerLoginView.hidden = YES;

    //    loginWebViewBg = [[UIView alloc] init];
    loginWebViewBg.frame = CGRectMake(240, 140, 550, 405);
    loginWebViewBg.userInteractionEnabled = YES;
    loginWebViewBg.hidden = NO;
    //    loginWebViewBg.backgroundColor = [UIColor colorWithRed:230.0/255.0
    //    green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    [loginFloatingLayerBg_EmptyView addSubview:loginWebViewBg];
    //    [loginWebViewBg release];

    //    UIView *ivHeader = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 550,
    //    65)]autorelease];
    //    ivHeader.backgroundColor = [UIColor colorWithRed:36.0/255.0
    //    green:36.0/255.0 blue:36.0/255.0 alpha:1.0];
    //    [loginWebViewBg addSubview:ivHeader];
    //
    //    UIImageView *imvLogo = [[[UIImageView alloc]initWithImage:[UIImage
    //    imageNamed:@"bar_logo_bg"]]autorelease];
    //    imvLogo.frame = CGRectMake(210, 5, 115, 60);
    //    [ivHeader addSubview:imvLogo];

    //    loginWebViewBg = [[UIImageView alloc] initWithImage:[UIImage
    //    imageNamed:@"dialog_bg_normal"]];
    //    loginWebViewBg.frame = CGRectMake(220, 140, 550, 405);
    //    loginWebViewBg.userInteractionEnabled = YES;
    //    loginWebViewBg.hidden = NO;
    //    [loginFloatingLayerBg_EmptyView addSubview:loginWebViewBg];
    //    [loginWebViewBg release];

//    if (loginWebView != nil) {
//        [loginWebView
//            loadRequest:[NSURLRequest
//                            requestWithURL:[NSURL
//                                               URLWithString:@"about:blank"]]];
//        [loginWebView stopLoading];
//    } else {
//        //登录的WebView
//        loginWebView = [[UIWebView alloc] init];
//        loginWebView.frame =
//            CGRectMake(0, 65, 550, 340); //(350, 260, 280, 280);
//        loginWebView.userInteractionEnabled = YES;
//        loginWebView.delegate = self;
//        loginWebView.scalesPageToFit = YES;
//        loginWebView.scrollView.showsHorizontalScrollIndicator = NO;
//        loginWebView.scrollView.showsVerticalScrollIndicator = NO;
//        //    loginWebView.frame = CGRectMake(37, 67, 600, 435);
//        loginWebView.backgroundColor = [UIColor clearColor];
//        [loginWebViewBg addSubview:loginWebView];
//    }
//
//    [loginWebView
//        loadRequest:[NSURLRequest
//                        requestWithURL:
//                            [NSURL URLWithString:[homePageOperator loginUrl]]]];
}

//设置按钮响应
- (IBAction)settingsButtonOnClick {
    allCoursesView.hidden = YES;
    myCoursesView.hidden = YES;
    activityView.hidden = YES;
    downloadView.hidden = YES;

    loginFloatingLayerBg_EmptyView.hidden = YES;
}

#pragma mark - loginFloatingLayer 登录浮层界面

//创建浮层界面 登陆按钮响应
- (IBAction)loginButtonOnClick {
    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];

    delegant.isClickEntrollment = NO;

    [self makeLoginFloatingLayerView];
}

- (IBAction)loginViewToLogin:(id)sender {
    NSLog(@"loginButtonClick!!");

    [self.loginViewTFPwd resignFirstResponder];
    [self.loginViewTFEmail resignFirstResponder];
    NSString *jsonUrlForLogin = @"v1/user/login";
    NSDictionary *dict = @{
        @"email" : self.loginViewTFEmail.text,
        @"password" : self.loginViewTFPwd.text
    };

    NSMutableDictionary *param = (NSMutableDictionary *)dict;
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonUrlForLogin
        method:@"POST"
        param:param
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result is %@", result);
            NSDictionary *dict = result;
            NSData *data = [NSJSONSerialization
                dataWithJSONObject:dict
                           options:NSJSONWritingPrettyPrinted
                             error:nil];
            // 登陆成功
            [AppUtilities writeFile:@"token.json"
                            subDir:KAIKEBA_CONFIG_DIR
                          contents:data];

            [GlobalOperator sharedInstance].userId = [dict objectForKey:@"id"];
            [KKBUserInfo shareInstance].userId = [dict objectForKey:@"id"];
            [GlobalOperator sharedInstance].user4Request.user.avatar.token =
                [dict objectForKey:@"token"];

            [[KKBHttpClient shareInstance]
                setUserToken:[dict objectForKey:@"token"]];

            [self getAccountProfiles:[GlobalOperator sharedInstance].userId
                               token:[GlobalOperator sharedInstance]
                                         .user4Request.user.avatar.token];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"error");
        }];
}

- (void)makeLoginFloatingLayerView {
    if ([AppUtilities isExistenceNetwork]) {

        FromLogin = YES;
        registerView.hidden = YES;
        selfInfoView.hidden = YES;

        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (delegant.isClickEntrollment == YES) {
            loginFloatingLayerBg_EmptyView.image = nil;
        } else {
            loginFloatingLayerBg_EmptyView.image =
                [UIImage imageNamed:@"alpha_black_bg"];
        }

        loginFloatingLayerBg_EmptyView.hidden = NO;

        registerLoginView = [[UIView alloc] init];
        registerLoginView.frame = CGRectMake(240, 140, 550, 405);
        registerLoginView.userInteractionEnabled = YES;
        registerLoginView.backgroundColor = [UIColor colorWithRed:230.0 / 255.0
                                                            green:230.0 / 255.0
                                                             blue:230.0 / 255.0
                                                            alpha:1.0];
        [loginFloatingLayerBg_EmptyView addSubview:registerLoginView];

        UIView *ivHeader =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, 550, 65)];
        ivHeader.backgroundColor = [UIColor colorWithRed:36.0 / 255.0
                                                   green:36.0 / 255.0
                                                    blue:36.0 / 255.0
                                                   alpha:1.0];
        [registerLoginView addSubview:ivHeader];

        UIImageView *imvLogo = [[UIImageView alloc]
            initWithImage:[UIImage imageNamed:@"bar_logo_bg"]];
        imvLogo.contentMode = UIViewContentModeScaleAspectFit;
        imvLogo.frame = CGRectMake(210, 5, 115, 60);
        [ivHeader addSubview:imvLogo];

        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.frame = CGRectMake(299, 193, 180, 60);
        //    [registerButton setBackgroundImage:[UIImage
        //    imageNamed:@"button_register_normal_l"]
        //    forState:UIControlStateNormal];
        registerButton.backgroundColor = [UIColor whiteColor];
        [registerButton setTitle:@"注册" forState:UIControlStateNormal];

        [registerButton setTitleColor:[UIColor colorWithRed:72.0 / 255
                                                      green:80.0 / 255
                                                       blue:88.0 / 255
                                                      alpha:1.0]
                             forState:UIControlStateNormal];
        [registerButton.titleLabel setFont:[UIFont systemFontOfSize:18]];

        [registerButton addTarget:self
                           action:@selector(registerButtonOnClick)
                 forControlEvents:UIControlEventTouchUpInside];
        [registerLoginView addSubview:registerButton];

        //    [self makeRegisterView];

        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(71, 193, 180, 60);
        //    [loginButton setBackgroundImage:[UIImage
        //    imageNamed:@"button_login_normal_l"]
        //    forState:UIControlStateNormal];
        loginButton.backgroundColor = [UIColor whiteColor];
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor colorWithRed:72.0 / 255
                                                   green:80.0 / 255
                                                    blue:88.0 / 255
                                                   alpha:1.0]
                          forState:UIControlStateNormal];
        loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [loginButton addTarget:self
                        action:@selector(login)
              forControlEvents:UIControlEventTouchUpInside];
        [registerLoginView addSubview:loginButton];

    } else {
        [AppUtilities showHUD:@"当前无网络连接" andView:self.view];
    }
}

- (IBAction)addAvatarButtonOnClickInSelfView {
    //隐藏键盘，解决UIActionSheet位置错位的问题
    [self.view endEditing:YES];
    FromSelf = YES;
    [self performSelector:@selector(addAvatarInSelfView)
               withObject:nil
               afterDelay:0.4];
}

//添加头像选择
- (void)addAvatarInSelfView {
    uploadImageActionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"浏览相册"
                           otherButtonTitles:@"现在拍照", nil];

    [uploadImageActionSheet showFromRect:CGRectMake(210, 120, 300, 150)
                                  inView:selfInfoView
                                animated:YES];
}

- (IBAction)addAvatarButtonOnClick {
    //隐藏键盘，解决UIActionSheet位置错位的问题
    [self.view endEditing:YES];
    FromSelf = NO;

    [self performSelector:@selector(addAvatar) withObject:nil afterDelay:0.4];
}

//添加头像选择
- (void)addAvatar {
    uploadImageActionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"浏览相册"
                           otherButtonTitles:@"现在拍照", nil];

    [uploadImageActionSheet showFromRect:CGRectMake(210, 120, 300, 150)
                                  inView:registerView
                                animated:YES];
}

- (void)loginFloatingLayerViewTapGestureRecognizer:
            (UITapGestureRecognizer *)tap {
    //    if (myCoursesView.hidden)
    //    {
    //        [allCoursesButton setBackgroundImage:[UIImage
    //        imageNamed:@"button_sidemenu_normal"]
    //        forState:UIControlStateNormal];
    //        [registerLoginButton setBackgroundImage:[UIImage
    //        imageNamed:@"button_sidemenu_normal"]
    //        forState:UIControlStateNormal];
    //        //此时应显示的是设置View
    //        [settingButton setBackgroundImage:[UIImage
    //        imageNamed:@"icon_set_normal_selected"]
    //        forState:UIControlStateNormal];
    //    }
    //    else
    //    {
    //        [registerLoginButton setBackgroundImage:[UIImage
    //        imageNamed:@"button_sidemenu_normal"]
    //        forState:UIControlStateNormal];
    //        [settingButton setBackgroundImage:[UIImage
    //        imageNamed:@"icon_set_normal"] forState:UIControlStateNormal];
    //        [allCoursesButton setBackgroundImage:[UIImage
    //        imageNamed:@"button_sidemenu_selected"]
    //        forState:UIControlStateNormal];
    //    }
    //    if(registerView)

    CGPoint currentPoint = [tap locationInView:loginFloatingLayerBg_EmptyView];
    if (currentPoint.x > 240 && currentPoint.x < 790 && currentPoint.y > 140 &&
        currentPoint.y < 545) {
        return;
    } else {
        if (registerLoginView.hidden == NO) {
            //             [loginFloatingLayerBg_EmptyView removeFromSuperview];
            loginFloatingLayerBg_EmptyView.hidden = YES;
        }
        //        loginFloatingLayerBg_EmptyView.hidden = YES;
        else if (registerView.frame.origin.y > 0 ||
                 loginWebViewBg.frame.origin.y > 30) {

            //        [loginFloatingLayerBg_EmptyView removeFromSuperview];
            loginFloatingLayerBg_EmptyView.hidden = YES;
        }
    }
}

- (void)registerButtonOnClick {
    registerLoginView.hidden = YES;
    //    loginWebViewBg.hidden = YES;

    registerView.frame =
        CGRectMake(240, 140, 550, registerView.frame.size.height);
    registerView.hidden = NO;
    [loginFloatingLayerBg_EmptyView addSubview:registerView];

    tfEmail.text = @"";
    tfPwd.text = @"";
    //    tfRealName.text = @"";
    tfNickName.text = @"";
    tfFalseDetail.text = @"";
    registerViewAvatar.image = [UIImage imageNamed:@"avater_Default"];

    detailView1.image = nil;
    detailView2.image = nil;
    detailView3.image = nil;
    detailView4.image = nil;
    detailView5.image = nil;

    registerBtn.enabled = YES;

    UIImage *image = registerViewAvatar.image;
    NSData *data = UIImagePNGRepresentation([image fixOrientation]);

    [data writeToFile:[AppUtilities getAvatarPath] atomically:YES];

    /*
     if ([GlobalOperator sharedInstance].isLogin)//修改信息
     {
     registerViewTitle.text = @"修改个人信息";
     registerViewAddAvatarButton.hidden = YES;
     registerViewEditAvatarButton.hidden = NO;

     registerViewRegisterButton.hidden = YES;
     registerViewEditButton.hidden = NO;

     [registerViewAvatar sd_setImageWithURL:[NSURL URLWithString:[GlobalOperator
     sharedInstance].user4Request.user.avatar.url]];

     emailTextField.text = [GlobalOperator
     sharedInstance].user4Request.pseudonym.unique_id;
     passwordTextField.text = [GlobalOperator
     sharedInstance].user4Request.pseudonym.password;
     nickName.text = [GlobalOperator
     sharedInstance].user4Request.user.short_name;
     realNameTextField.text = [GlobalOperator
     sharedInstance].user4Request.user.name;
     }
     else
     {//注册
     registerViewTitle.text = @"注册新账号";

     emailTextField.text = @"";
     passwordTextField.text = @"";
     nickName.text = @"";
     realNameTextField.text = @"";

     registerViewAvatar.image = [UIImage imageNamed:@"avatar_normal"];
     registerViewEditAvatarButton.hidden = YES;

     [registerViewAddAvatarButton setBackgroundImage:[UIImage
     imageNamed:@"button_add_normal"] forState:UIControlStateNormal];
     registerViewAddAvatarButton.hidden = NO;

     registerViewEditButton.hidden = YES;
     registerViewRegisterButton.hidden = NO;
     }

     registerView.hidden = NO;
     */
}

//修改个人信息
- (void)editUser {
    /*
     [self.view endEditing:YES];

     if ([ToolsObject isBlankString:emailTextField.text])
     {
     [ToolsObject showHUD:@"邮箱不能为空，请填写正确邮箱地址"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedEmail:emailTextField.text])
     {
     [ToolsObject showHUD:@"邮箱填写不合规，请填写正确邮箱地址"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:passwordTextField.text])
     {
     [ToolsObject
     showHUD:@"密码不能为空，请输入6-20位字符（包括字母、数字和符号）"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedPassword:passwordTextField.text])
     {
     [ToolsObject
     showHUD:@"密码填写不合规，请输入6-20位字符（包括字母、数字和符号）"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:nickName.text])
     {
     [ToolsObject showHUD:@"昵称不能为空，3~20个字符，不能包含特殊字符"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedUserName:nickName.text])
     {
     [ToolsObject showHUD:@"昵称填写不合规，3~20个字符，不能包含特殊字符"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:realNameTextField.text])
     {
     [ToolsObject showHUD:@"真实姓名不能为空，只允许2~6个中文"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedUserName:realNameTextField.text])
     {
     [ToolsObject showHUD:@"真实姓名不合规，只允许2~6个中文" andView:self.view];
     return;
     }

     [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id =
     emailTextField.text;
     [GlobalOperator sharedInstance].user4Request.pseudonym.password =
     passwordTextField.text;
     [GlobalOperator sharedInstance].user4Request.user.short_name =
     nickName.text;
     [GlobalOperator sharedInstance].user4Request.user.name =
     realNameTextField.text;
     [GlobalOperator sharedInstance].user4Request.user.sortable_name =
     [GlobalOperator sharedInstance].user4Request.user.name;


     if ([[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject
     getAvatarPath]])
     {
     [homePageOperator requestEditUserWithAvatar:self token:DEVELOPER_TOKEN
     user4Request:[GlobalOperator sharedInstance].user4Request];
     }
     else
     {
     if ([ToolsObject isBlankString:[GlobalOperator
     sharedInstance].user4Request.user.avatar.url])
     {
     [ToolsObject showHUD:@"您还没有选择头像，请选择头像" andView:self.view];
     return;
     }

     [homePageOperator requestEditUser:self token:DEVELOPER_TOKEN
     user4Request:[GlobalOperator sharedInstance].user4Request];
     }
     */
}

//获取账户详细信息
- (void)getAccountProfiles:(NSString *)accountId token:(NSString *)token {
    [GlobalOperator sharedInstance].isLogin = YES;

    [homePageOperator requestAccountProfiles:self
                                       token:token
                                   accoundId:accountId];
    //    [self loadAccountProfiles:NO]; // get
}

//去注册
- (IBAction)toRegister {
    [tfEmail resignFirstResponder];
    [tfPwd resignFirstResponder];
    [tfNickName resignFirstResponder];
    //    [tfRealName resignFirstResponder];

    BOOL isFit = YES;
    //    detailView1.image = [UIImage imageNamed:@"Validate_true"];
    detailView2.image = [UIImage imageNamed:@"Validate_true"];
    detailView3.image = [UIImage imageNamed:@"Validate_true"];
    detailView4.image = [UIImage imageNamed:@"Validate_true"];
    //    detailView5.image = [UIImage imageNamed:@"Validate_true"];

    //    if (![[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject
    //    getAvatarPath]])
    //    {
    //        tfFalseDetail.hidden = NO;
    //        tfFalseDetail.text = @"请添加一个头像!";
    //        detailView1.image = [UIImage imageNamed:@"Validate_false"];
    //        isFit = NO;
    //    }

    //    if ([ToolsObject isBlankString:tfRealName.text])
    //    {
    //        tfFalseDetail.hidden = NO;
    //        tfFalseDetail.text = @"请输入您的真实姓名";
    //        detailView5.image = [UIImage imageNamed:@"Validate_false"];
    //        isFit = NO;
    //
    //    }
    //    else if (![ToolsObject isMatchedChinese:tfRealName.text])
    //    {
    //        tfFalseDetail.hidden = NO;
    //        tfFalseDetail.text = @"真实姓名2~6个中文";
    //        detailView5.image = [UIImage imageNamed:@"Validate_false"];
    //        isFit = NO;
    //    }

    if ([AppUtilities isBlankString:tfNickName.text]) {
        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"请输入昵称";
        detailView4.image = [UIImage imageNamed:@"Validate_false"];

        isFit = NO;

    } else if (![AppUtilities isMatchedChinese:tfNickName.text]) {
        if (![AppUtilities isMatchedUserName:tfNickName.text]) {
            tfFalseDetail.hidden = NO;
            tfFalseDetail.text = @"3-18个字符或2-6个汉字，不能包含特殊字符";
            detailView4.image = [UIImage imageNamed:@"Validate_false"];
            isFit = NO;
        }
    }

    if ([AppUtilities isBlankString:tfPwd.text]) {
        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"请输入密码!";
        detailView3.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;

    } else if (![AppUtilities isMatchedPassword:tfPwd.text]) {
        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"密码6-" @"20位（包括字母、数字和符号）";
        detailView3.image = [UIImage imageNamed:@"Validate_false"];

        isFit = NO;
    }
    if ([AppUtilities isBlankString:tfEmail.text]) {
        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"请填写一个邮箱!";
        detailView2.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;

    } else if (![AppUtilities isMatchedEmail:tfEmail.text]) {
        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"请填写正确的邮箱地址!";
        detailView2.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;
    }

    //    detailView1.hidden = NO;
    detailView2.hidden = NO;
    detailView3.hidden = NO;
    detailView4.hidden = NO;
    //    detailView5.hidden = NO;

    if (isFit == YES) {
        tfFalseDetail.hidden = YES;

        User4Request *_user4Request = [[User4Request alloc] init];
        _user4Request.pseudonym.unique_id = tfEmail.text;
        _user4Request.pseudonym.password = tfPwd.text;
        _user4Request.user.short_name = tfNickName.text;
        //        _user4Request.user.name = tfRealName.text;
        _user4Request.user.sortable_name = _user4Request.user.name;
        [GlobalOperator sharedInstance].user4Request = _user4Request;
        NSMutableDictionary *allDict = [[NSMutableDictionary alloc] init];
        //        [allDict setObject:@"mobile" forKey:@"from"];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:tfNickName.text forKey:@"username"];
        [dict setObject:tfEmail.text forKey:@"email"];
        [dict setObject:tfPwd.text forKey:@"password"];

        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *stringDate = [formatter stringFromDate:date];

        [dict setObject:stringDate forKey:@"confirmed_at"];
        [dict setObject:@"mobile" forKey:@"from"];
        [allDict setObject:dict forKey:@"user"];
        [self loadCreateUser:allDict];
        //        [homePageOperator requestCreateUser:self token:DEVELOPER_TOKEN
        //        user4Request:[GlobalOperator sharedInstance].user4Request];

        //        [homePageOperator requestCreateUser:self token:DEVELOPER_TOKEN
        //        user4Request:[GlobalOperator sharedInstance].user4Request];
        registerBtn.enabled = NO;
    }

    /*
     [emailTextField resignFirstResponder];
     [passwordTextField resignFirstResponder];
     [nickName resignFirstResponder];
     [realNameTextField resignFirstResponder];

     if (![[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject
     getAvatarPath]])
     {
     [ToolsObject showHUD:@"您还没有选择头像，请选择头像" andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:emailTextField.text])
     {
     [ToolsObject showHUD:@"邮箱不能为空，请填写正确邮箱地址"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedEmail:emailTextField.text])
     {
     [ToolsObject showHUD:@"邮箱填写不合规，请填写正确邮箱地址"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:passwordTextField.text])
     {
     [ToolsObject
     showHUD:@"密码不能为空，请输入6-20位字符（包括字母、数字和符号）"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedPassword:passwordTextField.text])
     {
     [ToolsObject
     showHUD:@"密码填写不合规，请输入6-20位字符（包括字母、数字和符号）"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:nickName.text])
     {
     [ToolsObject showHUD:@"昵称不能为空，3~20个字符，不能包含特殊字符"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedUserName:nickName.text])
     {
     [ToolsObject showHUD:@"昵称填写不合规，3~20个字符，不能包含特殊字符"
     andView:self.view];
     return;
     }

     if ([ToolsObject isBlankString:realNameTextField.text])
     {
     [ToolsObject showHUD:@"真实姓名不能为空，只允许2~6个中文"
     andView:self.view];
     return;
     }
     else if (![ToolsObject isMatchedChinese:realNameTextField.text])
     {
     [ToolsObject showHUD:@"真实姓名不合规，只允许2~6个中文" andView:self.view];
     return;
     }


     User4Request *_user4Request = [[User4Request alloc] init];
     _user4Request.pseudonym.unique_id = emailTextField.text;
     _user4Request.pseudonym.password = passwordTextField.text;
     _user4Request.user.short_name = nickName.text;
     _user4Request.user.name = realNameTextField.text;
     _user4Request.user.sortable_name = _user4Request.user.name;
     [GlobalOperator sharedInstance].user4Request = _user4Request;
     [_user4Request release];

     [homePageOperator requestCreateUser:self token:DEVELOPER_TOKEN
     user4Request:[GlobalOperator sharedInstance].user4Request];
     */
}
- (IBAction)ToEditUser {
    [tfEmailInSelfView resignFirstResponder];
    [tfNickNameInSelfView resignFirstResponder];
    //    [tfRealNameInSelfView resignFirstResponder];
    [[[SidebarViewControllerInPadViewController share] contentView]
        addGestureRecognizer:sidebarGestureR];

    if ([AppUtilities isExistenceNetwork]) {

        BOOL isFit = YES;
        //    detailView1.image = [UIImage imageNamed:@"Validate_true"];
        //    detailView3.image = [UIImage imageNamed:@"Validate_true"];
        //    detailView4.image = [UIImage imageNamed:@"Validate_true"];
        //    detailView5.image = [UIImage imageNamed:@"Validate_true"];
        //
        //    if (![[NSFileManager defaultManager] fileExistsAtPath:[ToolsObject
        //    getAvatarPath]])
        //    {
        //        tfFalseDetailInSelfView.hidden = NO;
        //        tfFalseDetailInSelfView.text = @"请添加一个头像!";
        //        detailView1InSelfView.image = [UIImage
        //        imageNamed:@"Validate_false"];
        //        isFit = NO;
        //    }

        //        if ([ToolsObject isBlankString:tfRealNameInSelfView.text])
        //        {
        //            tfFalseDetailInSelfView.hidden = NO;
        //            tfFalseDetailInSelfView.text = @"请输入您的真实姓名";
        //            detailView5InSelfView.image = [UIImage
        //            imageNamed:@"Validate_false"];
        //            detailView5InSelfView.hidden = NO;
        //            isFit = NO;
        //
        //        }
        //        else if (![ToolsObject
        //        isMatchedChinese:tfRealNameInSelfView.text])
        //        {
        //            tfFalseDetailInSelfView.hidden = NO;
        //            tfFalseDetailInSelfView.text = @"2~6个中文";
        //            detailView5InSelfView.image = [UIImage
        //            imageNamed:@"Validate_false"];
        //            detailView5InSelfView.hidden = NO;
        //            isFit = NO;
        //        }

        if ([AppUtilities isBlankString:tfNickNameInSelfView.text]) {
            tfFalseDetailInSelfView.hidden = NO;
            tfFalseDetailInSelfView.text = @"请输入昵称";
            detailView4InSelfView.image =
                [UIImage imageNamed:@"Validate_false"];
            detailView4InSelfView.hidden = NO;
            isFit = NO;

        } else if (![AppUtilities isMatchedChinese:tfNickNameInSelfView.text]) {
            if (![AppUtilities isMatchedUserName:tfNickNameInSelfView.text]) {
                tfFalseDetailInSelfView.hidden = NO;
                tfFalseDetailInSelfView.text =
                    @"3-18个字符或2-6个汉字，不能包含特殊字符";
                detailView4InSelfView.image =
                    [UIImage imageNamed:@"Validate_false"];
                detailView4InSelfView.hidden = NO;
                isFit = NO;
            }
        }

        if ([AppUtilities isBlankString:tfEmailInSelfView.text]) {
            tfFalseDetailInSelfView.hidden = NO;
            tfFalseDetailInSelfView.text = @"请填写一个邮箱!";
            detailView3InSelfView.image =
                [UIImage imageNamed:@"Validate_false"];
            detailView3InSelfView.hidden = NO;
            isFit = NO;

        } else if (![AppUtilities isMatchedEmail:tfEmailInSelfView.text]) {
            tfFalseDetailInSelfView.hidden = NO;
            tfFalseDetailInSelfView.text = @"请填写正确的邮箱地址!";
            detailView3InSelfView.image =
                [UIImage imageNamed:@"Validate_false"];
            detailView3InSelfView.hidden = NO;
            isFit = NO;
        }

        //    detailView1.hidden = NO;
        //    detailView3.hidden = NO;
        //    detailView4.hidden = NO;
        //    detailView5.hidden = NO;

        if (isFit == YES) {
            tfFalseDetailInSelfView.hidden = YES;

            detailView5InSelfView.hidden = YES;
            detailView4InSelfView.hidden = YES;
            //            detailView5InSelfView.hidden = YES;

            [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id =
                tfEmailInSelfView.text;
            [GlobalOperator sharedInstance].user4Request.user.short_name =
                tfNickNameInSelfView.text;
            //            [GlobalOperator sharedInstance].user4Request.user.name
            //            = tfRealNameInSelfView.text;
            [GlobalOperator sharedInstance].user4Request.user.sortable_name =
                [GlobalOperator sharedInstance].user4Request.user.name;

            //        [homePageOperator requestEditUserWithAvatar:self
            //        token:DEVELOPER_TOKEN user4Request:[GlobalOperator
            //        sharedInstance].user4Request];
            if ([[NSFileManager defaultManager]
                    fileExistsAtPath:[AppUtilities getAvatarPath]]) {
                [homePageOperator
                    requestEditUserWithAvatar:self
                                        token:DEVELOPER_TOKEN
                                 user4Request:[GlobalOperator sharedInstance]
                                                  .user4Request];
                [self loadEditUserWithAvatar:NO];
            } else {
                if ([AppUtilities
                        isBlankString:[GlobalOperator sharedInstance]
                                          .user4Request.user.avatar.url]) {
                    [AppUtilities
                        showHUD:@"您还没有选择头像，请选择头像"
                        andView:self.view];
                    return;
                }

                [homePageOperator
                    requestEditUser:self
                              token:DEVELOPER_TOKEN
                       user4Request:[GlobalOperator sharedInstance]
                                        .user4Request];
                [self loadEditUser:NO];
            }
            [AppUtilities showLoading:@"正在修改信息" andView:self.view];
        }

    } else {
        [AppUtilities showHUD:@"当前无网络连接" andView:self.view];
    }
}

#pragma mark - DownloadDelegate Methods
- (void)updateNumbersOfDownloading:(NSDictionary *)numbersByCourse {
}
#pragma mark - 全部课程界面

//加载全部课程Header数据
- (void)loadAllCoursesHeaderData {
    NSMutableArray *viewsArray = [@[] mutableCopy];

    if ([self.headerSliderArray count] > 0) {
        for (int i = 0; i < [headerSliderArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc]
                initWithFrame:CGRectMake(i * 1024, 0, 1024, 325)];
            //            imageView.contentMode =
            //            UIViewContentModeScaleAspectFill;
            //            [imageView setClipsToBounds:YES];

            //            [imageView sd_setImageWithURL:[NSURL
            //            URLWithString:[ToolsObject
            //            adaptImageURL:((HomePageSliderItem
            //            *)[self.headerSliderArray
            //            objectAtIndex:i]).sliderImage]]
            //            placeholderImage:[UIImage
            //            imageNamed:@"allcourse_cover_default"]];
            NSDictionary *dic = [self.headerSliderArray objectAtIndex:i];
            NSString *imageUrlString = [dic objectForKey:@"sliderImage"];
            NSURL *imageUrl =
                [NSURL URLWithString:[AppUtilities
                                         adaptImageURLforPhone:imageUrlString]];
            [imageView
                sd_setImageWithURL:imageUrl
                  placeholderImage:[UIImage
                                       imageNamed:@"allcourse_cover_default"]];
            //            NSLog(@"%@",((HomePageSliderItem
            //            *)[self.headerSliderArray
            //            objectAtIndex:i]).sliderImage);
            imageView.contentMode = UIViewContentModeScaleAspectFill;

            [viewsArray addObject:imageView];

            //            UIButton *button = [[UIButton
            //            buttonWithType:UIButtonTypeCustom] retain];
            //            button.frame = CGRectMake(i * 320, 0, 320, 200);
            //            button.tag = i;
            //            [button addTarget:self action:@selector(clickHeader:)
            //            forControlEvents:UIControlEventTouchUpInside];
            //            [headerScrollView addSubview:button];
            //            [button release];
        }

        //        courseTitleLabel.text = ((HomePageSliderItem
        //        *)[self.headerSliderArray objectAtIndex:0]).courseTitle;
        //        courseBriefLabel.text = ((HomePageSliderItem
        //        *)[self.headerSliderArray objectAtIndex:0]).courseBrief;
        // add
        courseTitleLabel.text = [[self.headerSliderArray objectAtIndex:0]
            objectForKey:@"courseTitle"];
        courseBriefLabel.text = [[self.headerSliderArray objectAtIndex:0]
            objectForKey:@"courseBrief"];

        [courseBriefLabel alignTop];
    }

    //    for (int i = 0; i < 5; ++i) {
    //        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
    //        0, 320, 300)];
    //        [viewsArray addObject:tempLabel];
    //    }

    //    headerScrollView.CycleDelegate = self;
    self.headerScrollView.fetchContentViewAtIndex =
        ^UIView * (NSInteger pageIndex) {
        return viewsArray[pageIndex];
    };
    __unsafe_unretained HomePageViewController *weakSelf = self;
    self.headerScrollView.totalPagesCount =
        ^NSInteger(void) { return [weakSelf.headerSliderArray count]; };
    self.headerScrollView.TapActionBlock = ^(NSInteger pageIndex) {
        //        NSLog(@"点击了第%d个",pageIndex);
        [weakSelf clickOnHeader];
    };
    self.headerScrollView.ScrollBlock = ^(NSInteger pageIndex) {
        //        NSLog(@"当前第%d个",pageIndex);
        weakSelf.headerPageControl.currentPage = pageIndex;

        weakSelf->tickIndex = (int)pageIndex;

        //        courseTitleLabel.text = ((HomePageSliderItem
        //        *)[headerSliderArray objectAtIndex:pageIndex]).courseTitle;
        //        courseBriefLabel.text = ((HomePageSliderItem
        //        *)[headerSliderArray objectAtIndex:pageIndex]).courseBrief;
        // add
        weakSelf.courseTitleLabel.text =
            [[weakSelf.headerSliderArray objectAtIndex:pageIndex]
                objectForKey:@"courseTitle"];
        weakSelf.courseBriefLabel.text =
            [[weakSelf.headerSliderArray objectAtIndex:pageIndex]
                objectForKey:@"courseBrief"];

        [weakSelf.courseBriefLabel alignTop];
    };
    [headerView addSubview:headerScrollView];
    [headerView sendSubviewToBack:headerScrollView];

    headerPageControl.numberOfPages = [headerSliderArray count];
}
- (void)clickOnHeader {
    if ([AppUtilities isExistenceNetwork]) {
        for (NSDictionary *allCoursesDict in self.allCoursesArray) {
            NSDictionary *selectCourseDict =
                [self.headerSliderArray objectAtIndex:tickIndex];
            if ([[allCoursesDict objectForKey:@"id"] intValue] ==
                [[selectCourseDict objectForKey:@"id"] intValue]) {
                self.currentAllCoursesItem = allCoursesDict;
                [KKBUserInfo shareInstance].courseId =
                    [allCoursesDict objectForKey:@"id"];
                [self viewCourseDetails];
            }
        }
    }
}

/*
//自动播放图片的函数
- (void)tick
{
    if ([self.headerSliderArray count] >= 2)
    {
        if (tickIndex >= [self.headerSliderArray count])
        {
            tickIndex = 0;
        }

        CGFloat pageWidth = headerScrollView.frame.size.width;
        [headerScrollView setContentOffset:CGPointMake(tickIndex * pageWidth, 0)
animated:YES];

        headerPageControl.currentPage = tickIndex;

        courseTitleLabel.text = ((HomePageSliderItem *)[self.headerSliderArray
objectAtIndex:tickIndex]).courseTitle;
        courseBriefLabel.text = ((HomePageSliderItem *)[self.headerSliderArray
objectAtIndex:tickIndex]).courseBrief;
        [courseBriefLabel alignTop];
        viewTheCourseButton.tag = ((HomePageSliderItem *)[self.headerSliderArray
objectAtIndex:tickIndex])._id.intValue;

        tickIndex ++;
    }
}
*/
//查看课程详情
- (void)viewTheCourseButtonOnClick:(UIButton *)button {
    for (int i = 0; i < [self.allCoursesDataArray count]; i++) {
        if (button.tag ==
            ((AllCoursesItem *)[self.allCoursesDataArray objectAtIndex:i])
                .courseId.intValue) {
            [self gridView:gridView didSelectRowAt:i / 4 AndColumnAt:i % 4];
        }
    }
}

#pragma mark - 我的课程界面

//获取我的课程信息
- (void)checkMyCourses {
    /*
     settingsView.hidden = YES;
     allCoursesView.hidden = YES;
     floatingLayerBg_EmptyView.hidden = YES;
     loginFloatingLayerBg_EmptyView.hidden = YES;
     myCoursesView.hidden = NO;
     activityView.hidden = YES;
     selfButton.hidden = NO;

     [allCoursesButton setBackgroundImage:[UIImage
     imageNamed:@"button_sidemenu_selected"] forState:UIControlStateNormal];
     [settingButton setBackgroundImage:[UIImage imageNamed:@"icon_set_normal"]
     forState:UIControlStateNormal];
     [registerLoginButton setBackgroundImage:[UIImage
     imageNamed:@"button_sidemenu_selected"] forState:UIControlStateNormal];
     */

    //    [self.myCoursesDataArray removeAllObjects];
    //    [myCourseCollectionView reloadData];
    //    [homePageOperator requestMyCourses:self token:[GlobalOperator
    //    sharedInstance].user4Request.user.avatar.token];
    [self loadMyCourses:NO];

    //    [homePageOperator requestActivityStream:self token:[GlobalOperator
    //    sharedInstance].user4Request.user.avatar.token];
    [self loadActivityStream:NO];
}

//进入课程单元
- (void)enteringIntoCourseUnit:(NSDictionary *)myCourseItem {
    if ([[[SidebarViewControllerInPadViewController
                 share] contentView] gestureRecognizers].count > 0) {
        sidebarGestureR = [[[[SidebarViewControllerInPadViewController
                share] contentView] gestureRecognizers] objectAtIndex:0];
        if (sidebarGestureR != nil) {
            [[[SidebarViewControllerInPadViewController share] contentView]
                removeGestureRecognizer:sidebarGestureR];
        }
    }
    CourseUnitViewController *courseUnitViewController =
        [[CourseUnitViewController alloc]
            initWithNibName:@"CourseUnitViewController"
                     bundle:nil];
    courseUnitViewController.courseId = [myCourseItem objectForKey:@"id"];
    courseUnitViewController.courseName =
        [myCourseItem objectForKey:@"courseName"];
    courseUnitViewController.imgStr = [myCourseItem objectForKey:@"coverImage"];
    courseUnitViewController.sidebarGestureR = sidebarGestureR;
    if ([AppUtilities isLaterCurrentSystemDate:[myCourseItem
                                                  objectForKey:@"startDate"]]) {
        courseUnitViewController.isLocked = YES;
    }

    [self.navigationController pushViewController:courseUnitViewController
                                         animated:YES];
}

#pragma mark - 设置界面

//登出
- (IBAction)logout {

    if (![GlobalOperator sharedInstance].isLogin) {
        if ([AppUtilities isExistenceNetwork]) {

            [self loginButtonOnClick];
        } else {
            [AppUtilities showHUD:@"当前无网络连接" andView:self.view];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:[NSString stringWithFormat:@"是否注销？"]
                      message:nil
                     delegate:self
            cancelButtonTitle:@"确定"
            otherButtonTitles:@"取消", nil];
        alert.tag = 2;
        [alert show];
    }
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100001) {
        if (buttonIndex == 1) {
            [self.moviePlayer play];
        }
    }

    if (alertView.tag == 2) {
        switch (buttonIndex) {
        case 0: {

            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager
                    removeItemAtPath:[AppUtilities getTokenJSONFilePathForPad]
                               error:nil]) {

                [GlobalOperator sharedInstance].isLogin = NO;

                lbLogout.text = @"登录/注册";
                updateInfoBtn.enabled = NO;
                updateInfoBtn.titleLabel.textColor = [UIColor lightGrayColor];

                [self.anncoumentsArray removeAllObjects];
                [self.messageArray removeAllObjects];
                [self.discussArray removeAllObjects];
                [self.allMyCoursesDataArray removeAllObjects];

                if ([leftDelegate
                        respondsToSelector:@selector(controllSidebar:)]) {
                    [leftDelegate controllSidebar:NO];
                }

                //开始全部暂停
                [[ASIHTTPRequest sharedQueue] cancelAllOperations];
                [self.downingList
                    enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                        NSMutableArray *obj,
                                                        BOOL *stop) {
                        for (ASIHTTPRequest *req in obj) {
                            if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                                [[FilesDownManage sharedInstance]
                                    stopRequest:req];
                                continue;
                            } else if ([req isKindOfClass:[FileModel class]]) {
                                FileModel *model = (FileModel *)req;
                                model.isDownloading = NO;
                            }
                        }
                    }];
                [self.downloadCollectionView reloadData];
            }

            if ([AppUtilities isExistenceNetwork]) {
                [homePageOperator requestLogout:self token:PUBLIC_TOKEN];
            }
        } break;
        case 1: {

        } break;
        }
    } else if (alertView.tag == 1) {
        switch (buttonIndex) {
        case 0: {

        } break;
        case 1: {
            NSURL *url = [NSURL URLWithString:KAIKEBA_APPSTORE_URL];
            [[UIApplication sharedApplication] openURL:url];
        } break;
        }
    }
    if (alertView.tag == 3) {
        switch (buttonIndex) {
        case 0: {
            @synchronized(self.downingList) {
                NSString *deleteCourseID =
                    objc_getAssociatedObject(alertView, &kRepresentedObject);
                NSMutableArray *obj =
                    [self.downingList objectForKey:deleteCourseID];
                if (obj.count > 0) {
                    for (ASIHTTPRequest *req in obj) {
                        if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                            [req cancel];
                            [[FilesDownManage sharedInstance]
                                deleteRequest:req];
                        } else {
                            [[FilesDownManage sharedInstance]
                                deleteFileModel:(FileModel *)req];
                        }
                    }
                }
                [self.downingList removeObjectForKey:deleteCourseID];
            }
            /*
             [self.downingList enumerateKeysAndObjectsUsingBlock:^(NSString
             *key, NSMutableArray *obj, BOOL *stop) {


                 for (ASIHTTPRequest *req in obj) {
                     if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                         [req cancel];
                         [[FilesDownManage sharedFilesDownManage]
             deleteRequest:req];
                     } else {
                         [[FilesDownManage sharedFilesDownManage]
             deleteFileModel:(FileModel*)req];
                     }
                 }

             }];
             */

            [downloadCollectionView reloadData];

        } break;
        case 1: {

        } break;
        }
    }
}
- (void)logoutPublicUser {
    [homePageOperator requestLogout:self token:GUEST_TOKEN];
}
//个人信息
- (IBAction)clickSelfInfo {
    loginFloatingLayerBg_EmptyView.hidden = NO;
    selfInfoView.hidden = NO;

    loginWebViewBg.hidden = YES;

    selfInfoView.frame = CGRectMake(240, 100, 550, 472);
    [loginFloatingLayerBg_EmptyView addSubview:selfInfoView];
    [loginFloatingLayerBg_EmptyView bringSubviewToFront:selfInfoView];

    [self.view bringSubviewToFront:loginFloatingLayerBg_EmptyView];
    if ([[[SidebarViewControllerInPadViewController
                 share] contentView] gestureRecognizers].count > 0) {
        sidebarGestureR = [[[[SidebarViewControllerInPadViewController
                share] contentView] gestureRecognizers] objectAtIndex:0];
        if (sidebarGestureR != nil) {
            [[[SidebarViewControllerInPadViewController share] contentView]
                removeGestureRecognizer:sidebarGestureR];
        }
    }

    tfFalseDetailInSelfView.text = @"";
    detailView4InSelfView.image = nil;

    self.tfNickNameInSelfView.text =
        [GlobalOperator sharedInstance].user4Request.user.short_name;
    self.tfEmailInSelfView.text =
        [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id;
    //    self.tfRealNameInSelfView.text =[GlobalOperator
    //    sharedInstance].user4Request.user.name;
    [self.registerViewAvatarInSelfView
        sd_setImageWithURL:
            [NSURL URLWithString:
                       [AppUtilities
                           adaptImageURL:[GlobalOperator sharedInstance]
                                             .user4Request.user.avatar.url]]
          placeholderImage:[UIImage imageNamed:@"avater_Default"]];
}
//检查更新
- (IBAction)getUpdate {
    if ([AppUtilities isExistenceNetwork]) {

        NSString *updateInfo = [NSString
            stringWithContentsOfURL:
                [NSURL URLWithString:
                           @"http://itunes.apple.com/lookup?id=659238439"]
                           encoding:NSUTF8StringEncoding
                              error:nil];
        NSDictionary *updateInfoDic = [updateInfo objectFromJSONString];
        NSDictionary *dic = [updateInfoDic valueForKey:@"results"];
        NSArray *latestVersion = [dic valueForKey:@"version"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
            objectForKey:(NSString *)kCFBundleVersionKey];
        //    NSLog(@"%@",latestVersion);
        //    NSLog(@"%@",[latestVersion objectAtIndex:0]);
        //    NSLog(@"%@",currentVersion);
        if ([latestVersion objectAtIndex:0] &&
            ![[latestVersion objectAtIndex:0] isEqual:currentVersion]) {
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:@"版本有更新"
                                          delegate:self
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:@"更新", nil];
            alert.tag = 1;
            [alert show];
        } else {
            [AppUtilities showHUD:@"当前已是最新版本" andView:self.view];
        }
    } else {
        [AppUtilities showHUD:@"当前无网络连接" andView:self.view];
    }
}
//反馈
- (IBAction)showFeedBack {
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone) {
        [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY_IPHONE];
    } else {
        [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY_IPAD];
    }
}
//关于
- (IBAction)showAboutUS {

    settingsWebView =
        [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, 1024, 700)];
    titleLable.text = @"关于我们";
    backInAbout.hidden = NO;
    menuBtn.hidden = YES;
    if ([AppUtilities isExistenceNetwork]) {

        NSString *path =
            @"http://kaikeba-file.b0.upaiyun.com/pages/about4tablet.html";
        NSURL *url = [NSURL URLWithString:path];
        [settingsWebView loadRequest:[NSURLRequest requestWithURL:url]];
        [settingView addSubview:settingsWebView];
    } else {
        NSURL *baseURL =
            [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"aboutlearn"
                                                         ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];

        [settingsWebView loadHTMLString:html baseURL:baseURL];

        [settingView addSubview:settingsWebView];
    }
}
- (IBAction)backToSettingInAboutUs {

    [settingsWebView removeFromSuperview];
    backInAbout.hidden = YES;
    titleLable.text = @"设置";
    menuBtn.hidden = NO;
}
//评价
- (IBAction)pinjia {
    NSURL *url = [NSURL URLWithString:KAIKEBA_APPSTORE_URL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - FloatingLayerView 浮层界面
- (IBAction)enrollCourseOnclick:(id)sender {
    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegant.isClickEntrollment = YES;

    if ([AppUtilities isExistenceNetwork]) {
        if ([GlobalOperator sharedInstance].isLogin) {

            if ([btnEntroll.titleLabel.text isEqualToString:@"继续学习"]) {

                for (NSDictionary *item in self.allMyCoursesDataArray) {
                    if ([[item objectForKey:@"id"] integerValue] ==
                        [[currentAllCoursesItem
                            objectForKey:@"id"] integerValue]) {

                        AppDelegate *delegant = (AppDelegate *)
                            [[UIApplication sharedApplication] delegate];

                        delegant.isFromActivityAnn = NO;
                        delegant.isFromActivityMes = NO;
                        delegant.isFromActivityDis = NO;
                        delegant.isFromDownLoad = NO;

                        [self enteringIntoCourseUnit:item];

                        [self hiddenFloatingLayerView];
                        break;
                    }
                }

            } else {

                //                [homePageOperator requestEnrollments:self
                //                token:DEVELOPER_TOKEN
                //                courseID:[currentAllCoursesItem
                //                objectForKey:@"id"] user_id:[GlobalOperator
                //                sharedInstance].userId];
                [self loadEnrollments:NO];
                [AppUtilities showLoading:@"正在添加课程" andView:self.view];
            }
        } else {
            [self makeLoginFloatingLayerView];
        }
    } else {
        [AppUtilities showHUD:@"当前无网络" andView:self.view];
    }
}
//创建浮层界面
- (void)makeFloatingLayerView {
    floatingLayerBg_EmptyView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"alpha_black_bg"]];

    floatingLayerBg_EmptyView.frame = CGRectMake(0, 0, 1024, 748);

    floatingLayerBg_EmptyView.userInteractionEnabled = YES;
    floatingLayerBg_EmptyView.hidden = YES;
    [self.view addSubview:floatingLayerBg_EmptyView];

    UITapGestureRecognizer *floatingLayerTapGestureRecognizer =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(floatingLayerTapGestureRecognizer:)];
    floatingLayerTapGestureRecognizer.delegate = self;
    [floatingLayerBg_EmptyView
        addGestureRecognizer:floatingLayerTapGestureRecognizer];

    floatingLayerView.frame = CGRectMake(574, 0, 450, 748);

    [floatingLayerBg_EmptyView addSubview:floatingLayerView];

    loginFloatingLayerBg_EmptyView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"alpha_black_bg"]];

    loginFloatingLayerBg_EmptyView.frame = CGRectMake(0, 0, 1024, 748);

    loginFloatingLayerBg_EmptyView.userInteractionEnabled = YES;
    loginFloatingLayerBg_EmptyView.hidden = YES;
    [self.view addSubview:loginFloatingLayerBg_EmptyView];

    UITapGestureRecognizer *
    loginFloatingLayerViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(loginFloatingLayerViewTapGestureRecognizer:)];
    [loginFloatingLayerBg_EmptyView
        addGestureRecognizer:loginFloatingLayerViewTapGestureRecognizer];
}

//进入课程详情，浮层
- (void)viewCourseDetails {
    //    floatingLayerViewPayView.hidden = YES;
    //    floatingLayerViewWebView.hidden = YES;
    floatingLayerView.hidden = NO;
    floatingLayerBg_EmptyView.hidden = NO;
    //    NSLog(@"%f",myScrollView.contentOffset.y);
    [headView setFrame:CGRectMake(0, 253, 450, 70)];
    [myScrollView
        setContentOffset:CGPointMake(myScrollView.contentOffset.x, 0)];

    //    floatingLayerViewCourseArrangementTableView.hidden = NO;

    //    myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width,
    //    748+400);
    //    myScrollView.scrollEnabled = YES;
    //    myScrollView.delegate = self;

    //    [self makeFloatingLayerView];

    //    NSArray *views = [floatingLayerView subviews];
    //    for(UIView* view in views)
    //    {
    //        [view removeFromSuperview];
    //    }
    [self jibenButtonOnClick];

    [btnEntroll setTitle:@"学习此课程" forState:UIControlStateNormal];
    for (NSDictionary *item in self.myCoursesDataArray) {
        if ([[item objectForKey:@"id"] integerValue] ==
            [[currentAllCoursesItem objectForKey:@"id"] integerValue]) {
            [btnEntroll setTitle:@"继续学习" forState:UIControlStateNormal];
            break;
        }
    }
    if ([@"guide" isEqualToString:[currentAllCoursesItem
                                      objectForKey:@"courseType"]]) {
        lbType.text = @"导学课";
    } else {
        lbType.text = @"公开课";
    }
    self.lbDayTime.text = [currentAllCoursesItem objectForKey:@"estimate"];
    self.lbStartTime.text = [AppUtilities
        convertTimeStyleToDayDetial:[currentAllCoursesItem
                                        objectForKey:@"startDate"]];
    self.lbNumber.text = [currentAllCoursesItem objectForKey:@"courseNum"];
    self.lbSchool.text = [currentAllCoursesItem objectForKey:@"schoolName"];
    self.lbTeacher.text =
        [currentAllCoursesItem objectForKey:@"instructorName"];
    self.lbKeyWords.text =
        [NSString stringWithFormat:@"课程关键字：%@",
                                   [currentAllCoursesItem
                                       objectForKey:@"courseKeywords"]];
    self.lbBrief.text = [currentAllCoursesItem objectForKey:@"courseIntro"];
    self.lbTitle.text = [currentAllCoursesItem objectForKey:@"courseName"];
    self.lbCourseName.text = [currentAllCoursesItem objectForKey:@"courseName"];

    [imgView
        sd_setImageWithURL:
            [NSURL
                URLWithString:
                    [AppUtilities adaptImageURL:[currentAllCoursesItem
                                                   objectForKey:@"coverImage"]]]
          placeholderImage:[UIImage imageNamed:@"allcourse_cover_default"]];

    if (myBadgeDataArray.count == 0) {
        //从缓存加载badge图标
        //        [self uncacheBadges];
    }

    if ([(NSArray *)
            [currentAllCoursesItem objectForKey:@"courseBadges"] count] == 0) {
        badgeView.hidden = YES;
        myScrollView.contentSize =
            CGSizeMake(myScrollView.frame.size.width, 1200.0f);
    } else {
        badgeView.hidden = NO;

        int rows;
        if ([(NSArray *)
                [currentAllCoursesItem objectForKey:@"courseBadges"] count] %
                2 ==
            0) {
            rows = (int)([(NSArray *)[currentAllCoursesItem
                             objectForKey:@"courseBadges"] count] /
                         2);
        } else {
            rows = (int)([(NSArray *)[currentAllCoursesItem
                             objectForKey:@"courseBadges"] count] /
                         2) +
                   1;
        }

        NSArray *views = [badgeView subviews];
        for (UIView *view in views) {
            [view removeFromSuperview];
        }

        badgeView.frame = CGRectMake(10, 713, 430, 42 * rows + 18);

        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([(NSArray *)
                [currentAllCoursesItem objectForKey:@"courseBadges"] count] >
            0) {
            for (int i = 0; i < [(NSArray *)[currentAllCoursesItem
                                    objectForKey:@"courseBadges"] count];
                 i++) {
                [array addObject:
                           [myBadgeDataArray
                               objectAtIndex:[[[currentAllCoursesItem
                                                 objectForKey:@"courseBadges"]
                                                 objectAtIndex:i] intValue] -
                                             1]];
            }
        }
        if (array.count > 0) {

            for (int i = 0; i < array.count; i++) {
                //                MyBadges* badge = [array objectAtIndex:i];
                NSDictionary *badge = [array objectAtIndex:i];
                //            NSLog(@"%@",badge);
                if ((i + 1) % 2 == 0) {
                    //                int k = (int)(i/2);
                    UIImageView *imageView = [[UIImageView alloc]
                        initWithFrame:CGRectMake(35 + 220,
                                                 18 + 42 * (int)(i / 2), 24,
                                                 24)];
                    [imageView
                        sd_setImageWithURL:
                            [NSURL
                                URLWithString:
                                    [AppUtilities
                                        adaptImageURLforPhone:
                                            [badge objectForKey:@"image4big"]]]
                          placeholderImage:nil];
                    [badgeView addSubview:imageView];
                    UILabel *lable = [[UILabel alloc]
                        initWithFrame:CGRectMake(80 + 220,
                                                 18 + 42 * (int)(i / 2), 100,
                                                 24)];
                    lable.text = [badge objectForKey:@"badgeTitle"];
                    lable.font = [UIFont fontWithName:@"Helvetica" size:14];
                    lable.textColor = [UIColor colorWithRed:102.0 / 255.0
                                                      green:102.0 / 255.0
                                                       blue:102.0 / 255.0
                                                      alpha:1.0];
                    [badgeView addSubview:lable];
                } else {
                    UIImageView *imageView = [[UIImageView alloc]
                        initWithFrame:CGRectMake(35, 18 + 42 * (int)(i / 2), 24,
                                                 24)];
                    [imageView
                        sd_setImageWithURL:
                            [NSURL
                                URLWithString:
                                    [AppUtilities
                                        adaptImageURLforPhone:
                                            [badge objectForKey:@"image4big"]]]
                          placeholderImage:nil];
                    [badgeView addSubview:imageView];

                    UILabel *lable = [[UILabel alloc]
                        initWithFrame:CGRectMake(80, 18 + 42 * (int)(i / 2),
                                                 100, 24)];
                    lable.text = [badge objectForKey:@"badgeTitle"];
                    lable.font = [UIFont fontWithName:@"Helvetica" size:14];
                    lable.textColor = [UIColor colorWithRed:102.0 / 255.0
                                                      green:102.0 / 255.0
                                                       blue:102.0 / 255.0
                                                      alpha:1.0];
                    [badgeView addSubview:lable];
                }
            }
        }
        myScrollView.contentSize =
            CGSizeMake(myScrollView.frame.size.width,
                       900.0f + badgeView.frame.size.height + 40.0f);
    }

    myScrollView.scrollEnabled = YES;
    myScrollView.delegate = self;

    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.delegate = self;
    [floatingLayerView.layer addAnimation:transition forKey:nil];

    //     floatingLayerView.frame = CGRectMake(574, 0, 450, 748);
    //
    //     [floatingLayerBg_EmptyView addSubview:floatingLayerView];

    //    if([ToolsObject isExistenceNetwork]){
    //    [homePageOperator requestModules:self token:PUBLIC_TOKEN
    //    courseID:self.currentAllCoursesItem.courseId];
    //    [ToolsObject showLoading:@"正在努力加载数据中..."
    //    andView:floatingLayerViewCourseArrangementTableView];
    //    }
    //    [self.floatingLayerViewCurrentUnitList removeAllObjects];
    //    [floatingLayerViewCurrentSecondLevelUnitList removeAllObjects];

    //    [floatingLayerViewCourseArrangementTableView reloadData];
}

- (void)floatingLayerTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    CGPoint currentPoint = [tap locationInView:floatingLayerBg_EmptyView];

    if (currentPoint.x < 574) {
        [self hiddenFloatingLayerView];
    }
}

- (void)hiddenFloatingLayerView {
    if ([self.moviePlayer isKindOfClass:[KKBMoviePlayerController class]]) {
        [self.moviePlayer stop];
        //销毁播放通知
        [[NSNotificationCenter defaultCenter]
            removeObserver:self
                      name:MPMoviePlayerPlaybackDidFinishNotification
                    object:self.moviePlayer];
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer.view removeFromSuperview];
        // 释放视频对象
        //        [self.moviePlayer release];
        self.moviePlayer = nil;
    }
    floatingLayerView.hidden = YES;

    //    [floatingLayerView removeFromSuperview];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    //       transition.type = @"cube";
    transition.subtype = kCATransitionFromLeft;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    transition.delegate = self;
    [floatingLayerView.layer addAnimation:transition forKey:nil];
    //
    //
    //
    //
    [self performSelector:@selector(transitionFinished)
               withObject:nil
               afterDelay:0.4];
    //    [floatingLayerBg_EmptyView removeFromSuperview];
}

- (void)transitionFinished {
    floatingLayerBg_EmptyView.hidden = YES;
}
- (IBAction)playMovieAtURL {
    if ([AppUtilities isExistenceNetwork] == NO) {
        UIAlertView *noWifi =
            [[UIAlertView alloc] initWithTitle:@"提示"
                                       message:@"您已断开网络连接"
                                      delegate:self
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@"设值", nil];
        noWifi.tag = 100001;
        [noWifi show];
    }

    NSString *promoVideoStr =
        [NSString stringWithFormat:@"%@", [self.currentAllCoursesItem
                                              objectForKey:@"promoVideo"]];
    NSURL *url = [NSURL URLWithString:promoVideoStr];

    KKBMoviePlayerController *theMoviePlayer =
        [[KKBMoviePlayerController alloc] initWithContentURL:url];
    self.moviePlayer = theMoviePlayer;
    [theMoviePlayer.view setFrame:CGRectMake(0, 0, 450, 253)];
    [playView addSubview:theMoviePlayer.view];
    [self.moviePlayer play];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(myMovieFinishedCallback:)
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:theMoviePlayer];
    // 注册一个播放结束的通知
}

- (void)myMovieFinishedCallback:(NSNotification *)notify {
    //视频播放对象
    KKBMoviePlayerController *theMoviePlayer = [notify object];

    //销毁播放通知
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MPMoviePlayerPlaybackDidFinishNotification
                object:theMoviePlayer];
    theMoviePlayer.fullscreen = NO;
    [theMoviePlayer.view removeFromSuperview];
    // 释放视频对象
    //    [theMoviePlayer release];
    self.moviePlayer = nil;
}
- (void)resetbtn {
    [btnInfo setTitleColor:[UIColor colorWithRed:170.0 / 255
                                           green:174.0 / 255
                                            blue:178.0 / 255
                                           alpha:1.0]
                  forState:UIControlStateNormal];
    [btnbreif setTitleColor:[UIColor colorWithRed:170.0 / 255
                                            green:174.0 / 255
                                             blue:178.0 / 255
                                            alpha:1.0]
                   forState:UIControlStateNormal];
    [btnArrange setTitleColor:[UIColor colorWithRed:170.0 / 255
                                              green:174.0 / 255
                                               blue:178.0 / 255
                                              alpha:1.0]
                     forState:UIControlStateNormal];
}

- (IBAction)courseIntroductionButtonOnClick {
    [self resetbtn];
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    [btnbreif setTitleColor:[UIColor colorWithRed:61.0 / 255
                                            green:69.0 / 255
                                             blue:76.0 / 255
                                            alpha:1.0]
                   forState:UIControlStateNormal];

    floatingLayerViewCourseArrangementTableView.hidden = YES;
    floatingLayerViewWebView.hidden = NO;
    jinbenView.hidden = YES;
    badgeView.hidden = YES;
    btnEntroll.hidden = YES;

    [AppUtilities showLoading:@"正在加载课程简介..."
                     andView:floatingLayerViewWebView];

    //    [homePageOperator requestCourseBriefIntroduction:self
    //    token:PUBLIC_TOKEN courseID:[self.currentAllCoursesItem
    //    objectForKey:@"id"]];
    [self loadCourseBriefIntroduction:NO];

    //    myScrollView.contentSize = CGSizeMake(myScrollView.frame.size.width,
    //    748+100);
}

- (IBAction)jibenButtonOnClick {
    [self resetbtn];
    self.myScrollView.backgroundColor = [UIColor colorWithRed:224.0 / 255
                                                        green:224.0 / 255
                                                         blue:224.0 / 255
                                                        alpha:1.0];
    [btnInfo setTitleColor:[UIColor colorWithRed:61.0 / 255
                                           green:69.0 / 255
                                            blue:76.0 / 255
                                           alpha:1.0]
                  forState:UIControlStateNormal];

    floatingLayerViewCourseArrangementTableView.hidden = YES;
    floatingLayerViewWebView.hidden = YES;
    jinbenView.hidden = NO;
    badgeView.hidden = NO;
    btnEntroll.hidden = NO;
}

- (IBAction)courseArrangementButtonOnClick {

    if ([AppUtilities isExistenceNetwork]) {
        //        [homePageOperator requestModules:self token:PUBLIC_TOKEN
        //        courseID:[self.currentAllCoursesItem objectForKey:@"id"]];
        [self loadModules:NO];
        [AppUtilities showLoading:@"正在努力加载数据中..."
                         andView:floatingLayerViewCourseArrangementTableView];
    }

    [self resetbtn];
    [btnArrange setTitleColor:[UIColor colorWithRed:61.0 / 255
                                              green:69.0 / 255
                                               blue:76.0 / 255
                                              alpha:1.0]
                     forState:UIControlStateNormal];

    jinbenView.hidden = YES;
    badgeView.hidden = YES;
    btnEntroll.hidden = YES;
    floatingLayerViewWebView.hidden = YES;
    floatingLayerViewCourseArrangementTableView.hidden = NO;
}
- (void)retBtnInActivey {
    [btnAnn setTitleColor:[UIColor colorWithRed:121.0 / 255
                                          green:124.0 / 255
                                           blue:128.0 / 255
                                          alpha:1.0]
                 forState:UIControlStateNormal];
    [btnAnn
        setBackgroundImage:[UIImage imageNamed:@"recently_tab_left_selected"]
                  forState:UIControlStateNormal];
    [btnMessage setTitleColor:[UIColor colorWithRed:121.0 / 255
                                              green:124.0 / 255
                                               blue:128.0 / 255
                                              alpha:1.0]
                     forState:UIControlStateNormal];
    [btnMessage
        setBackgroundImage:[UIImage imageNamed:@"recently_tab_middle_selected"]
                  forState:UIControlStateNormal];
    [btnDiscuss setTitleColor:[UIColor colorWithRed:121.0 / 255
                                              green:124.0 / 255
                                               blue:128.0 / 255
                                              alpha:1.0]
                     forState:UIControlStateNormal];
    [btnDiscuss
        setBackgroundImage:[UIImage imageNamed:@"recently_tab_right_selected"]
                  forState:UIControlStateNormal];
}
- (IBAction)tapAnncoument {
    [self retBtnInActivey];
    [btnAnn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAnn setBackgroundImage:[UIImage imageNamed:@"recently_tab_left_normal"]
                      forState:UIControlStateNormal];

    self.tempArray = self.anncoumentsArray;

    if ([AppUtilities isExistenceNetwork]) {
        if (self.tempArray.count == 0) {
            lbActivty.text = @"还没有通知啊。去预约课程吧！";
        } else {
            lbActivty.text = @"";
        }
        [self.activityTableView reloadData];
    }
}
- (IBAction)tapMessage {
    [self retBtnInActivey];
    [btnMessage setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [btnMessage
        setBackgroundImage:[UIImage imageNamed:@"recently_tab_middle_normal"]
                  forState:UIControlStateNormal];

    self.tempArray = self.messageArray;
    if ([AppUtilities isExistenceNetwork]) {
        if (self.tempArray.count == 0) {
            lbActivty.text = @"还没有通知啊。去预约课程吧！";
        } else {
            lbActivty.text = @"";
        }
        [self.activityTableView reloadData];
    }
}
- (IBAction)tapDiscuss {
    [self retBtnInActivey];
    [btnDiscuss setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [btnDiscuss
        setBackgroundImage:[UIImage imageNamed:@"recently_tab_right_normal"]
                  forState:UIControlStateNormal];

    self.tempArray = self.discussArray;
    if ([AppUtilities isExistenceNetwork]) {
        if (self.tempArray.count == 0) {
            lbActivty.text = @"还没有通知啊。去预约课程吧！";
        } else {
            lbActivty.text = @"";
        }
        [self.activityTableView reloadData];
    }
}
#pragma mark - UIGridViewDelegate

- (CGFloat)gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex {
    if ([grid isEqual:gridView]) {

        return 253;
    }
    return 0;
}

- (CGFloat)gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex {
    if ([grid isEqual:gridView]) {
        return 325;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInUIGridView:(UIGridView *)grid {
    if ([grid isEqual:gridView]) {
        return 1;
    }
    return 0;
}
- (NSInteger)numberOfCellsOfGridView:(UIGridView *)grid {

    if ([grid isEqual:gridView]) {
        return self.allCoursesDataArray.count;
    }
    return 0;
}

- (NSInteger)numberOfColumnsOfGridView:(UIGridView *)grid {
    if ([grid isEqual:gridView]) {
        return 4;
    }
    return 0;
}

- (NSString *)identifierOfGridView:(UIGridView *)grid {

    if ([grid isEqual:gridView]) {
        return @"GridViewIdentifier";
    }
    return nil;
}
- (UIView *)gridView:(UIGridView *)grid
    viewForHeaderInSection:(NSInteger)section {
    if ([grid isEqual:gridView]) {
        return sectionView;
    }
    return nil;
}
- (UIGridCell *)gridView:(UIGridView *)grid
                    cell:(UIGridCell *)cell
            cellForRowAt:(int)rowIndex
             AndColumnAt:(int)columnIndex {

    AllCoursesCell *allCoursesCell = (AllCoursesCell *)cell;
    if (!allCoursesCell) {
        allCoursesCell = [[AllCoursesCell alloc] initWithFrame:CGRectZero];
    }

    int idx = rowIndex * 4 + columnIndex;

    if (idx < self.allCoursesDataArray.count) {
        //        AllCoursesItem *allCoursesItem = [self.allCoursesDataArray
        //        objectAtIndex:idx];
        NSDictionary *allCoursesItem =
            [self.allCoursesDataArray objectAtIndex:idx];

        UIImageView *_coverImage =
            (UIImageView *)[allCoursesCell viewWithTag:101];
        //        [_coverImage sd_setImageWithURL:[NSURL
        //        URLWithString:[ToolsObject
        //        adaptImageURL:allCoursesItem.coverImage]]
        //                    placeholderImage:[UIImage
        //                    imageNamed:@"cover_allcourse_default"]];
        [_coverImage
            sd_setImageWithURL:
                [NSURL URLWithString:
                           [AppUtilities
                               adaptImageURL:[allCoursesItem
                                                 objectForKey:@"coverImage"]]]
              placeholderImage:[UIImage imageNamed:@"cover_allcourse_default"]];

        UILabel *courseName = (UILabel *)[allCoursesCell viewWithTag:106];

        CGSize size = CGSizeMake(400, 2000);

        // CGSize labelsize = [allCoursesItem.courseName
        // sizeWithFont:courseName.font constrainedToSize:size
        // lineBreakMode:NSLineBreakByCharWrapping];

        CGRect rect1 = [[allCoursesItem objectForKey:@"courseName"]
            boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont
                              systemFontOfSize:courseName.font.pointSize]
                      } context:nil];

        CGSize labelsize = rect1.size;

        if (labelsize.width > 220) {
            courseName.frame = CGRectMake(10, 11, 220, 54);
        } else {
            courseName.frame = CGRectMake(10, -1.5, 220, 54);
        }

        //        courseName.text = allCoursesItem.courseName;
        courseName.text = [allCoursesItem objectForKey:@"courseName"];

        UILabel *schoolName = (UILabel *)[allCoursesCell viewWithTag:105];
        //        schoolName.text = allCoursesItem.schoolName;
        schoolName.text = [allCoursesItem objectForKey:@"schoolName"];

        UILabel *startDate = (UILabel *)[allCoursesCell viewWithTag:104];

        //        if ([ToolsObject isBlankString:allCoursesItem.startDate])
        if ([AppUtilities
                isBlankString:[allCoursesItem objectForKey:@"startDate"]]) {
            startDate.text = @"精彩预告";
        }
        //        else if([ToolsObject
        //        isLaterCurrentSystemDate:allCoursesItem.startDate])
        else if ([AppUtilities
                     isLaterCurrentSystemDate:[allCoursesItem
                                                  objectForKey:@"startDate"]]) {
            //            startDate.text =[NSString
            //            stringWithFormat:@"开课时间：%@",allCoursesItem.startDate];
            startDate.text = [NSString
                stringWithFormat:@"开课时间：%@",
                                 [allCoursesItem objectForKey:@"startDate"]];
        } else {
            startDate.text = @"课程进行中...";
        }

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setDateFormat:@"yyyy-MM-dd"];
        //        NSDate *dateTime = [formatter
        //        dateFromString:allCoursesItem.startDate];
        NSDate *dateTime = [formatter
            dateFromString:[allCoursesItem objectForKey:@"startDate"]];

        [formatter setDateFormat:@"yyyy"];
        NSString *date = [formatter stringFromDate:dateTime];
        if ([date isEqualToString:@"2020"]) {
            startDate.text = @"精彩预告";
        }

        UILabel *detail = (UILabel *)[allCoursesCell viewWithTag:107];
        //        detail.text =allCoursesItem.courseIntro;
        detail.text = [allCoursesItem objectForKey:@"courseIntro"];
    }

    return allCoursesCell;
}

- (void)gridView:(UIGridView *)grid
    didSelectRowAt:(int)rowIndex
       AndColumnAt:(int)columnIndex {

    if (self.allCoursesArray.count == 0 && [AppUtilities isExistenceNetwork]) {
        //加载全部课程数据
        //        [homePageOperator requestAllCourses:self token:PUBLIC_TOKEN];

        //        [homePageOperator requestAllCoursesCategory:self
        //        token:PUBLIC_TOKEN];

        //        [homePageOperator requestBadge:self token:PUBLIC_TOKEN];

        [self loadAllCourses:NO];
        [self loadAllCoursesCategory:NO];
        [self loadBadge:NO];
    }

    if (floatingLayerBg_EmptyView.hidden == YES &&
        [AppUtilities isExistenceNetwork]) {
        NSDictionary *allCoursesItem = [self.allCoursesDataArray
            objectAtIndex:(rowIndex * 4 + columnIndex)];

        self.currentAllCoursesItem = allCoursesItem;
        [KKBUserInfo shareInstance].courseId =
            [allCoursesItem objectForKey:@"id"];
        [self viewCourseDetails];
    } else {
        [AppUtilities showHUD:@"当前无网络" andView:self.view];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ([actionSheet isEqual:uploadImageActionSheet]) {
        if (buttonIndex == 0) {
            if ([UIImagePickerController
                    isSourceTypeAvailable:
                        UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker =
                    [[UIImagePickerController alloc] init];
                imagePicker.sourceType =
                    UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;

                [GlobalOperator sharedInstance].isLandscape = NO;

                UIPopoverController *popover = [[UIPopoverController alloc]
                    initWithContentViewController:imagePicker];
                popover.delegate = self;
                self.popoverController = popover;
                if (FromSelf == YES) {
                    [self.popoverController
                          presentPopoverFromRect:CGRectMake(187, 10, 300, 150)
                                          inView:selfInfoView
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];

                } else {
                    [self.popoverController
                          presentPopoverFromRect:CGRectMake(187, 10, 300, 150)
                                          inView:registerView
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];
                }
            }
        } else if (buttonIndex == 1) {
            if ([UIImagePickerController
                    isSourceTypeAvailable:
                        UIImagePickerControllerSourceTypeCamera]) {
                cameraImagePicker = [[UIImagePickerController alloc] init];
                cameraImagePicker.sourceType =
                    UIImagePickerControllerSourceTypeCamera;
                cameraImagePicker.delegate = self;
                cameraImagePicker.allowsEditing = YES;

                [GlobalOperator sharedInstance].isLandscape = NO;

                [self presentViewController:cameraImagePicker
                                   animated:YES
                                 completion:nil];
                //                UIPopoverController *popover =
                //                [[UIPopoverController alloc]
                //                initWithContentViewController:imagePicker];
                //                popover.delegate = self;
                //                self.popoverController = popover;
                //
                //                [self.popoverController
                //                presentPopoverFromRect:CGRectMake(187, 10,
                //                300, 150) inView:registerView
                //                permittedArrowDirections:UIPopoverArrowDirectionUp
                //                animated:YES];
                //                [imagePicker release];
                //                [popover release];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (FromSelf == YES) {

        if ([picker isEqual:cameraImagePicker]) {
            [cameraImagePicker dismissViewControllerAnimated:YES
                                                  completion:nil];
            //            loginWebViewBg.hidden = YES;

            [GlobalOperator sharedInstance].isLandscape = YES;
        } else {
            [self.popoverController dismissPopoverAnimated:YES];
        }

        UIImage *image =
            [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSData *data = UIImagePNGRepresentation([image fixOrientation]);

        [data writeToFile:[AppUtilities getAvatarPath] atomically:YES];
        registerViewAvatarInSelfView.image =
            [UIImage imageWithContentsOfFile:[AppUtilities getAvatarPath]];
        registerViewAvatarInSelfView.clipsToBounds = YES;
    } else {

        if ([picker isEqual:cameraImagePicker]) {
            [cameraImagePicker dismissViewControllerAnimated:YES
                                                  completion:nil];
            if (FromSelf == NO) {
                loginWebViewBg.hidden = YES;
            }

            [GlobalOperator sharedInstance].isLandscape = YES;
        } else {
            [self.popoverController dismissPopoverAnimated:YES];
        }

        UIImage *image =
            [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSData *data = UIImagePNGRepresentation([image fixOrientation]);

        [data writeToFile:[AppUtilities getAvatarPath] atomically:YES];
        registerViewAvatar.image =
            [UIImage imageWithContentsOfFile:[AppUtilities getAvatarPath]];
        registerViewAvatar.clipsToBounds = YES;
    }

    //    [registerViewAddAvatarButton setBackgroundImage:[UIImage
    //    imageNamed:@"button_modifyavatar_normal"]
    //    forState:UIControlStateNormal];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    if ([picker isEqual:cameraImagePicker]) {
        [cameraImagePicker dismissViewControllerAnimated:YES completion:nil];
        loginWebViewBg.hidden = YES;

        [GlobalOperator sharedInstance].isLandscape = YES;
    } else {
        [self.popoverController dismissPopoverAnimated:YES];
    }

    //    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:
            (UIPopoverController *)popoverController {
    //只打开横屏，关闭竖屏
    [GlobalOperator sharedInstance].isLandscape = YES;

    return YES;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {
        UIView *mySectionView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, 450, 60)];
        mySectionView.backgroundColor = [UIColor
            colorWithPatternImage:[UIImage imageNamed:@"unit_Ititlebar_nav"]];
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame = CGRectMake(0, 0, 450, 40);
        myButton.tag = 100 + section;
        [myButton addTarget:self
                      action:@selector(tapHeader:)
            forControlEvents:UIControlEventTouchUpInside];
        [mySectionView addSubview:myButton];

        UILabel *myLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 400, 30)];
        myLabel.backgroundColor = [UIColor clearColor];
        //        NSString *name = ((UnitItem
        //        *)[self.floatingLayerViewCurrentUnitList
        //        objectAtIndex:section]).name;
        NSString *name =
            [[self.floatingLayerViewCurrentUnitList objectAtIndex:section]
                objectForKey:@"name"];
        myLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        myLabel.text = name;
        [myButton addSubview:myLabel];

        return mySectionView;
    } else if ([tableView isEqual:activityTableView]) {
        UIView *bgview =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 10)];
        bgview.backgroundColor = [UIColor clearColor];
        return bgview;
    }
    return nil;
}
- (void)tapHeader:(UIButton *)sender {
    if ([[openedInSectionArr objectAtIndex:sender.tag - 100] intValue] == 0) {
        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100
                                      withObject:@"1"];
        //        NSLog(@"%d打开",sender.tag);
    } else {
        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100
                                      withObject:@"0"];
        //        NSLog(@"%d关闭",sender.tag);
    }

    [floatingLayerViewCourseArrangementTableView reloadData];
}

#pragma mark - tableview datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int numberOfSections = 0;

    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {
        numberOfSections = (int)[self.floatingLayerViewCurrentUnitList count];
    } else if ([tableView isEqual:activityTableView]) {
        numberOfSections = 1;
    }

    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {
        if ([[openedInSectionArr objectAtIndex:section] intValue] == 1) {
            return [(NSArray *)[self.floatingLayerViewCurrentSecondLevelUnitList
                objectAtIndex:section] count];
        }
    } else if ([tableView isEqual:activityTableView]) {
        return self.tempArray.count;
    }

    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {
        return 60;
    } else if ([tableView isEqual:activityTableView]) {
        return 10;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int heightForRow = 0;

    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {

        heightForRow = 60;

    } else if ([tableView isEqual:activityTableView]) {
        return 90;
    }

    return heightForRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:floatingLayerViewCourseArrangementTableView]) {

        NSString *CellIdentifier =
            [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section],
                                       (long)[indexPath row]];
        Cell2 *cell = (Cell2 *)
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = (Cell2 *)[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];

            UIImage *img = [UIImage imageNamed:@"unit_item_bg"];
            UIImageView *imgv = [[UIImageView alloc] initWithImage:img];
            imgv.frame = CGRectMake(0, 0, 450, 60);
            [cell addSubview:imgv];
            [cell sendSubviewToBack:imgv];

            unitCellIcon = [[UIImageView alloc] init];
            unitCellIcon.frame = CGRectMake(45, 14, 30, 30);
            [cell addSubview:unitCellIcon];

            UILabel *title =
                [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 300, 60)];
            title.tag = 61;
            title.backgroundColor = [UIColor clearColor];
            title.textColor = [UIColor colorWithRed:61.0 / 255
                                              green:69.0 / 255
                                               blue:76.0 / 255
                                              alpha:1];
            title.font = [UIFont fontWithName:@"Helvetica" size:16];
            [cell.contentView addSubview:title];

            NSArray *array = [self.floatingLayerViewCurrentSecondLevelUnitList
                objectAtIndex:indexPath.section];
            //                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            NSLog(@"array ==== %@",array);
            //                   NSLog(@"%d",indexPath.row);
            if (![array isKindOfClass:[NSArray class]]) {
                return cell;
            }
            NSString *type =
                [((NSDictionary *)[array objectAtIndex:indexPath.row])
                    objectForKey:@"type"];
            //                 NSLog(@"%@",type);
            if ([type isEqual:@"Page"]) //页面
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_page_active_grey"];
            } else if ([type isEqual:@"Discussion"]) //讨论
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_dis_active_grey"];
            } else if ([type isEqual:@"Assignment"]) //作业
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_assignment_active_grey"];
            } else if ([type isEqual:@"Quiz"]) //测验
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_quiz_active_grey"];
            } else if ([type isEqual:@"File"]) //文件
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_download_active_grey"];
            } else if ([type isEqual:@"ExternalTool"]) //文件
            {
                unitCellIcon.image =
                    [UIImage imageNamed:@"unit_icon_video_active_gray"];
            }

            UILabel *nameLabel = (UILabel *)[cell viewWithTag:61];
            nameLabel.text =
                [((NSDictionary *)[array objectAtIndex:indexPath.row])
                    objectForKey:@"title"];
            //        NSLog(@"%@",nameLabel.text);
        }
        return cell;

    } else if ([tableView isEqual:activityTableView]) {
        NSString *cellIdentifier = @"anncouments";
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"announcement"
                                                         owner:self
                                                       options:nil];
            cell = [arr objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        UILabel *messageLable = (UILabel *)[cell viewWithTag:501];
        UILabel *timeLable = (UILabel *)[cell viewWithTag:502];
        UILabel *courseLable = (UILabel *)[cell viewWithTag:503];

        NSDictionary *myAnnouncement =
            [self.tempArray objectAtIndex:indexPath.row];
        //        messageLable.text = myAnnouncement.title;

        timeLable.text = [AppUtilities
            convertTimeStyleToM:[myAnnouncement objectForKey:@"created_at"]];

        for (NSDictionary *myCourseItem in self.allMyCoursesDataArray) {
            if ([[myAnnouncement objectForKey:@"course_id"] intValue] ==
                [[myCourseItem objectForKey:@"id"] intValue]) {
                courseLable.text = [NSString
                    stringWithFormat:@"%@  %@",
                                     [myCourseItem objectForKey:@"courseName"],
                                     [myAnnouncement objectForKey:@"title"]];
            }
        }

        return cell;
    }

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"null"];
}

////使UITableViewCell无法选中
//- (NSIndexPath*)tableView:(UITableView *)tableView
// willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([tableView isEqual:settingsTableView])
//    {
//        if (indexPath.section == 0)
//        {
//            if (indexPath.row == 1)
//            {
//                if ([Config sharedInstance].isLogin)
//                {
//                    return indexPath;
//                }
//                else
//                {
////
//                    return nil;
//                }
//            }
//        }
//    }
//    return indexPath;
//
//}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:activityTableView]) {
        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (self.tempArray == self.anncoumentsArray) {
            NSDictionary *myAnnouncement =
                [self.anncoumentsArray objectAtIndex:indexPath.row];
            for (NSDictionary *myCourseItem in self.allMyCoursesDataArray) {
                // 我的通告 与 我的课程id是否相同
                if ([[myAnnouncement objectForKey:@"course_id"] intValue] ==
                    [[myCourseItem objectForKey:@"id"] intValue]) {
                    delegant.isFromActivityAnn = YES;
                    delegant.isFromActivityMes = NO;
                    delegant.isFromActivityDis = NO;
                    delegant.annStr =
                        [myAnnouncement objectForKey:@"announcement_id"];
                    [self enteringIntoCourseUnit:myCourseItem];
                }
            }
        } else if (self.tempArray == self.messageArray) {
            NSDictionary *myAnnouncement =
                [self.messageArray objectAtIndex:indexPath.row];
            for (NSDictionary *myCourseItem in self.allMyCoursesDataArray) {
                if ([[myAnnouncement objectForKey:@"course_id"] intValue] ==
                    [[myCourseItem objectForKey:@"id"] intValue]) {
                    delegant.isFromActivityAnn = NO;
                    delegant.isFromActivityMes = YES;
                    delegant.isFromActivityDis = NO;
                    delegant.annStr =
                        [myAnnouncement objectForKey:@"announcement_id"];
                    [self enteringIntoCourseUnit:myCourseItem];
                }
            }

        } else if (self.tempArray == self.discussArray) {
            NSDictionary *myAnnouncement =
                [self.discussArray objectAtIndex:indexPath.row];
            for (NSDictionary *myCourseItem in self.allMyCoursesDataArray) {
                if ([[myAnnouncement objectForKey:@"course_id"] intValue] ==
                    [[myCourseItem objectForKey:@"id"] intValue]) {
                    delegant.isFromActivityAnn = NO;
                    delegant.isFromActivityMes = NO;
                    delegant.isFromActivityDis = YES;
                    delegant.annStr =
                        [myAnnouncement objectForKey:@"announcement_id"];
                    [self enteringIntoCourseUnit:myCourseItem];
                }
            }
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

//解决UITapGestureRecognizer截获了touch事件，导致didSelectRowAtIndexPath方法无法响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class])
            isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }

    return YES;
}

#pragma mark - UIWebViewDelegate

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest
//*)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if ([webView isEqual:loginWebView])
//    {
//        NSString *domain = [NSString stringWithFormat:@"%@",
//        request.URL.absoluteString];
//
//
//    }
//
//    return YES;
//}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([webView isEqual:loginWebView]) {
        [AppUtilities showLoading:@"加载中......" andView:loginWebView];

        NSString *urlWithAuthCode =
            [webView.request mainDocumentURL].absoluteString;

        NSString *regex = @"auth?code";
        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];

        if ([predicate evaluateWithObject:urlWithAuthCode]) {
            //截取字符串AuthCode
            NSString *str_character = @"auth?code=";
            NSRange range = [urlWithAuthCode rangeOfString:str_character];

            NSString *authCode =
                [urlWithAuthCode substringFromIndex:range.location + 10];

            loginFloatingLayerBg_EmptyView.hidden = YES;
            [homePageOperator requestExchangeToken:self
                                             token:nil
                                              code:authCode];
            //            [self loadExchangeToken:NO withCode:authCode];

            //            //保存cookie
            //            NSMutableArray *cookieArray = [[NSMutableArray alloc]
            //            init];
            //            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage
            //            sharedHTTPCookieStorage] cookies])
            //            {
            //                [cookieArray addObject:cookie.name];
            //                NSMutableDictionary *cookieProperties =
            //                [NSMutableDictionary dictionary];
            //                [cookieProperties setObject:cookie.name
            //                forKey:NSHTTPCookieName];
            //                [cookieProperties setObject:cookie.value
            //                forKey:NSHTTPCookieValue];
            //                [cookieProperties setObject:cookie.domain
            //                forKey:NSHTTPCookieDomain];
            //                [cookieProperties setObject:cookie.path
            //                forKey:NSHTTPCookiePath];
            //                [cookieProperties setObject:[NSNumber
            //                numberWithInt:cookie.version]
            //                forKey:NSHTTPCookieVersion];
            //
            //                [cookieProperties setObject:[[NSDate date]
            //                dateByAddingTimeInterval:31104000]
            //                forKey:NSHTTPCookieExpires];
            //
            //                [[NSUserDefaults standardUserDefaults]
            //                setValue:cookieProperties forKey:cookie.name];
            //                [[NSUserDefaults standardUserDefaults]
            //                synchronize];
            //            }
            //
            //            [[NSUserDefaults standardUserDefaults]
            //            setValue:cookieArray forKey:@"cookieArray"];
            //            [[NSUserDefaults standardUserDefaults] synchronize];
            //            [cookieArray release];

            //更改了公共账号，以后为个人账号自动登陆
            //            [[NSUserDefaults standardUserDefaults] setBool:YES
            //            forKey:@"isPublicUser"];
            //            [self makeLeftButtonForMe];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView isEqual:loginWebView]) {
        [AppUtilities closeLoading:loginWebView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([webView isEqual:loginWebView]) {
        [AppUtilities closeLoading:loginWebView];
    }
}

#pragma mark 网络代理回调
- (void)loadData:(BOOL)fromCache {
    [self loadHeaderSliders:fromCache];
    [self loadAllCourses:fromCache];
    [self loadAllCoursesCategory:fromCache];
    [self loadBadge:fromCache];
}
// 滚动条
- (void)loadHeaderSliders:(BOOL)fromCache {
    NSString *jsonUrlForHeaderSliders = @"home-slider.json";
    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrlForHeaderSliders
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            self.headerSliderArray = (NSMutableArray *)result;
            [self loadAllCoursesHeaderData];
            BrirfVIew.hidden = NO; // ?
        }
        failure:^(id result) {}];
}

//- (void)loadCreateUser:(NSMutableDictionary *)dic{
//    NSString *jsonUrlForCreateUser = [NSString
//    stringWithFormat:@"%@users",API_CMS_V4];
//    [[KKBHttpClient shareInstance] requestPostUrlPath:jsonUrlForCreateUser
//    method:@"POST" param:dic success:^(id result) {
//        NSDictionary *dic = result;
//        [GlobalOperator sharedInstance].userId = [dic objectForKey:@"id"];
//        if([GlobalOperator sharedInstance].userId != nil){
//            UpYun *uy = [[[UpYun alloc] init] autorelease];
//            uy.delegate = self;
//            uy.expiresIn = UPYUN_EXPIRATION;
//            uy.bucket = UPYUN_BUCKETNAME;
//            uy.passcode = UPYUN_KEY;
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            [params setObject:@"create" forKey:@"type"];
//            uy.params = params;
//            NSString *savekey = [NSString
//            stringWithFormat:@"/user-avatar/%@-%d", [GlobalOperator
//            sharedInstance].userId, (int)[[NSDate date]
//            timeIntervalSinceReferenceDate]];
//            [GlobalOperator sharedInstance].user4Request.user.avatar.url =
//            [NSString stringWithFormat:@"%@%@", UPYUN_URL, savekey];
//            [uy uploadImagePath:[ToolsObject getAvatarPath] savekey:savekey];
//            return;
//        }
//        if([GlobalOperator sharedInstance].userId == nil){
//            tfFalseDetail.hidden = NO;
//            tfFalseDetail.text = @"该邮箱已被注册，请更换一个邮箱!";
//            detailView2.image = [UIImage imageNamed:@"Validate_false"];
//            registerBtn.enabled = YES;
//        }
//
//
//    } failure:^(id result) {
//        NSLog(@"%@",result);
//    }];
//}

//- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error
//{
//    NSString *string = nil;
//    if ([ERROR_DOMAIN isEqualToString:error.domain])
//    {
//        string = [error.userInfo objectForKey:@"message"];
//    }
//    else
//    {
//        string = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
//                                                    message:@"上传头像失败"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"关闭"
//                                          otherButtonTitles:nil, nil];
//    [alert show];
//    [alert release];
//}

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result {
    //清楚旧的缓存文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[AppUtilities getAvatarPath] error:nil];

    if ([[upYun.params objectForKey:@"type"] isEqual:@"edit"]) {
        //        [self requestEditUser:self token:[dictionary
        //        objectForKey:@"token"] user4Request:[GlobalOperator
        //        sharedInstance].user4Request];
    } else if ([[upYun.params objectForKey:@"type"] isEqual:@"create"]) {
        //        [self requestEditAfterCreateUser:self token:[dictionary
        //        objectForKey:@"token"] user4Request:[GlobalOperator
        //        sharedInstance].user4Request];
        [AppUtilities closeLoading:self.view];
        [AppUtilities showHUD:@"注册成功" andView:self.view];
        [registerView removeFromSuperview];
        [self login];

        // CPA注册
        [[KKBUploader sharedInstance]
            bufferCPAInfoWithUserID:[GlobalOperator sharedInstance].userId
                             action:@"register"];
        [[KKBUploader sharedInstance] startUpload];
    }
}

// 所有课程
- (void)loadAllCourses:(BOOL)fromCache {
    NSString *jsonUrlForAllCourses = @"all-courses-meta.json";
    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrlForAllCourses
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            self.allCoursesArray = result;
            self.allCoursesDataArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in(NSArray *)result) {
                if ([[dict objectForKey:@"visible"] intValue] == 1) {
                    [self.allCoursesDataArray addObject:dict];
                }
            }
            [gridView reloadData];
        }
        failure:^(id result) {}];
}
// 所有课程Catrgory
- (void)loadAllCoursesCategory:(BOOL)fromCache {
    NSString *jsonUrlForCategory = @"categories.json";
    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrlForCategory
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            [self.pickerArray removeAllObjects];
            [self.pickerArray addObject:@"全部类别"];
            [self.pickerArray addObjectsFromArray:result];
        }
        failure:^(id result) {}];
}
// 角标
- (void)loadBadge:(BOOL)fromCache {
    NSString *jsonUrlForBadge = @"badges-info.json";
    [[KKBHttpClient shareInstance] requestCMSUrlPath:jsonUrlForBadge
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            self.myBadgeDataArray = [[NSMutableArray alloc] init];
            self.myBadgeDataArray = result;
        }
        failure:^(id result) {
        
        }];
}
// 我的课程
- (void)loadMyCourses:(BOOL)fromCache {
    NSString *jsonUrlForMyCourses = @"courses?per_page=999999";
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForMyCourses
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {

            self.myCoursesDataArray = [[NSMutableArray alloc] init];
            self.myCoursesDataArray = result;
            [self getAllMyCourseData:self.myCoursesDataArray];
            if (self.myCoursesDataArray.count == 0) {
                lbMyCourse.hidden = NO;
                lbMyCourse.text = @"您" @"还" @"没"
                    @"有课程啊，去全部课程看看吧" @"！";
            } else {
                lbMyCourse.hidden = YES;
                lbMyCourse.text = @"";
            }
            [myCourseCollectionView reloadData];
        }
        failure:^(id result) {}];
}
// 个人中心
- (void)loadActivityStream:(BOOL)fromCache {
    NSString *jsonUrlForAcitvityStream =
        @"users/self/activity_stream?per_page=999999";
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlForAcitvityStream
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            for (NSDictionary *item in result) {
                if ([[item objectForKey:@"type"]
                        isEqualToString:@"Announcement"]) {
                    [self.anncoumentsArray addObject:item];
                } else if ([[item objectForKey:@"type"]
                               isEqualToString:@"Message"]) {
                    [self.messageArray addObject:item];
                } else if ([[item objectForKey:@"type"]
                               isEqualToString:@"DiscussionTopic"]) {
                    [self.discussArray addObject:item];
                }
            }
            self.tempArray = self.anncoumentsArray;
            if (self.tempArray.count == 0) {
                lbActivty.text = @"还没有通知啊。去预约课程吧！";
            } else {
                lbActivty.text = @"";
            }
            [activityTableView reloadData];
        }
        failure:^(id result) {}];
}
// 课程简介
- (void)loadCourseBriefIntroduction:(BOOL)fromCache {
    NSString *jsonUrlForCourseBriefIntroduction = [NSString
        stringWithFormat:@"courses/%@/pages/course-introduction-4tablet",
                         [self.currentAllCoursesItem objectForKey:@"id"]];
    [[KKBHttpClient shareInstance]
        requestLMSUrlPath:jsonUrlForCourseBriefIntroduction
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            NSDictionary *dict = (NSDictionary *)result;
            [floatingLayerViewWebView loadHTMLString:[dict objectForKey:@"body"]
                                             baseURL:nil];
            [AppUtilities closeLoading:floatingLayerViewWebView];
        }
        failure:^(id result) {}];
}
// 单元详情
- (void)loadModules:(BOOL)fromCache {
    NSString *jsonUrlModules = [NSString
        stringWithFormat:@"courses/%@/modules?per_page=%d",
                         [KKBUserInfo shareInstance].courseId, 999999];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlModules
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            self.floatingLayerViewCurrentUnitList = result;
            for (int k = 0; k < self.floatingLayerViewCurrentUnitList.count;
                 k++) {
                [self.openedInSectionArr addObject:@"1"];
            }
            dispatch_async(dispatch_get_global_queue(
                               DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                @synchronized(
                    self.floatingLayerViewCurrentSecondLevelUnitList) {
                    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                    NSMutableArray *tempSecondLevelUnitList =
                        [[NSMutableArray alloc] init];
                    for (int i = 0;
                         i < [self.floatingLayerViewCurrentUnitList count];
                         i++) {
                        NSDictionary *item =
                            [self.floatingLayerViewCurrentUnitList
                                objectAtIndex:i];
                        NSString *itemId = [item objectForKey:@"id"];
                        NSString *jsonUrlModulesItems = [NSString
                            stringWithFormat:
                                @"courses/%@/modules/%@/items?per_page=%d",
                                [KKBUserInfo shareInstance].courseId, itemId,
                                999999];
                        [[KKBHttpClient shareInstance]
                            requestLMSUrlPath:jsonUrlModulesItems
                            method:@"GET"
                            param:nil
                            fromCache:fromCache
                            success:^(id result) {
                                [tempSecondLevelUnitList
                                    addObject:(NSArray *)result];
                                dispatch_semaphore_signal(sema);
                            }
                            failure:^(id result) {
                                dispatch_semaphore_signal(sema);
                            }];
                        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                    }
                    self.floatingLayerViewCurrentSecondLevelUnitList =
                        tempSecondLevelUnitList;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [floatingLayerViewCourseArrangementTableView reloadData];
                    [AppUtilities
                        closeLoading:
                            floatingLayerViewCourseArrangementTableView];
                });
            });
        }
        failure:^(id result) {}];
}
// 点击学习
- (void)loadEnrollments:(BOOL)fromCache {
    [[KKBHttpClient shareInstance]
        enrollCourseId:[currentAllCoursesItem objectForKey:@"id"]
        userId:[GlobalOperator sharedInstance].userId
        success:^(id result) {
            [AppUtilities closeLoading:self.view];
            [self loadMyCourses:NO];
            lbMyCourse.hidden = YES;
            lbMyCourse.text = @"";

            [myCourseCollectionView reloadData];

            [[LocalStorage shareInstance]
                saveLearnStatus:YES
                         course:[currentAllCoursesItem objectForKey:@"id"]];

            [self enteringIntoCourseUnit:currentAllCoursesItem];

            [self hiddenFloatingLayerView];
        }
        failure:^(id result) {}];
}
// 注册用户
- (void)loadCreateUser:(NSMutableDictionary *)dic {
    NSString *jsonUrlForCreateUser =
        [NSString stringWithFormat:@"http://www.kaikeba.com/api/v4/users"];
    [[KKBHttpClient shareInstance] requestPostUrlPath:jsonUrlForCreateUser
        method:@"POST"
        param:dic
        success:^(id result) {
            userInfoDict = result;
            [KKBUserInfo shareInstance].userId =
                [userInfoDict objectForKey:@"id"];
            if ([KKBUserInfo shareInstance].userId == nil) {
                tfFalseDetail.hidden = NO;
                tfFalseDetail.text = @"该" @"邮" @"箱"
                    @"已被注册，请更换一个邮箱" @"!";
                detailView2.image = [UIImage imageNamed:@"Validate_false"];
                registerBtn.enabled = YES;
            }
            if ([KKBUserInfo shareInstance].userId != nil) {
                UpYun *uy = [[UpYun alloc] init];
                uy.delegate = self;
                uy.expiresIn = UPYUN_EXPIRATION;
                uy.bucket = UPYUN_BUCKETNAME;
                uy.passcode = UPYUN_KEY;
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@"create" forKey:@"type"];
                uy.params = params;

                NSString *savekey = [NSString
                    stringWithFormat:
                        @"/user-avatar/%@-%d",
                        [KKBUserInfo shareInstance].userId,
                        (int)[[NSDate date] timeIntervalSinceReferenceDate]];
                [GlobalOperator sharedInstance].user4Request.user.avatar.url =
                    [NSString stringWithFormat:@"%@%@", UPYUN_URL, savekey];
                [uy uploadImagePath:[AppUtilities getAvatarPath]
                            savekey:savekey];
                return;
            }
        }
        failure:^(id result) {}];
}
// 注册成功
- (void)loadEditAfterCreateUser:(BOOL)fromCache {
    NSString *jsonUrlForEditAfterCreateUser =
        [NSString stringWithFormat:@"http://learn.kaikeba.com/api/v1/users/%@",
                                   [KKBUserInfo shareInstance].userId];
    NSMutableDictionary *dict =
        [[GlobalOperator sharedInstance].user4Request toDictionary];

    [AppUtilities closeLoading:self.view];
    [AppUtilities showHUD:@"注册成功" andView:self.view];
    [registerView removeFromSuperview];
    [self login];

    //    NSMutableDictionary *adict = (NSMutableDictionary *)userInfoDict;
    [[KKBHttpClient shareInstance]
        requestPostUrlPath:jsonUrlForEditAfterCreateUser
        method:@"PUT"
        param:dict
        success:^(id result) {}
        failure:^(id result) {}];
}
// 修改用户信息
- (void)loadEditUser:(BOOL)fromCache {
}
// 修改用户信息（头像）
- (void)loadEditUserWithAvatar:(BOOL)fromCache {
}

// 用户切换
- (void)loadExchangeToken:(BOOL)fromCache withCode:(NSString *)code {
    NSString *jsonForExchangeToken =
        [NSString stringWithFormat:@"http://learn.kaikeba.com/login/oauth2/"
                                   @"token?client_id=4&client_secret="
                                   @"znuZbCRiLGbsUiCWP64eM2CwwnSfW87LkvRu8EfwE"
                                   @"NjFkFUbztChqQnuMcTFw1VH&redirect_uri=urn:"
                                   @"ietf:wg:oauth:2.0:oob&code=%@",
                                   code];
    [[KKBHttpClient shareInstance] requestPostUrlPath:jsonForExchangeToken
        method:@"POST"
        param:nil
        success:^(id result) {
            NSLog(@"request result is %@", result);
            NSData *data = [NSJSONSerialization dataWithJSONObject:result
                                                           options:0
                                                             error:nil];
            [AppUtilities writeFile:@"token.json"
                            subDir:KAIKEBA_CONFIG_DIR
                          contents:data];
            NSDictionary *tokenDictionary = result;
            [GlobalOperator sharedInstance].userId =
                [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
            [KKBUserInfo shareInstance].userId =
                [[tokenDictionary objectForKey:@"user"] objectForKey:@"id"];
            [GlobalOperator sharedInstance].user4Request.user.avatar.token =
                [tokenDictionary objectForKey:@"access_token"];
            [[KKBHttpClient shareInstance]
                setUserToken:[tokenDictionary objectForKey:@"access_token"]];
            [self getAccountProfiles:[GlobalOperator sharedInstance].userId
                               token:[GlobalOperator sharedInstance]
                                         .user4Request.user.avatar.token];
        }
        failure:^(id result) {}];
}
// 文件描述
- (void)loadAccountProfiles:(BOOL)fromCache {
    NSString *jsonUrlAccountProfiles =
        [NSString stringWithFormat:@"users/%@/profile",
                                   [GlobalOperator sharedInstance].userId];
    [[KKBHttpClient shareInstance] requestLMSUrlPath:jsonUrlAccountProfiles
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result) {
            NSLog(@"result is %@", result);
            NSDictionary *accountProfilesDictionary = result;
            [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id =
                [accountProfilesDictionary objectForKey:@"login_id"];
            [GlobalOperator sharedInstance].user4Request.user.name =
                [accountProfilesDictionary objectForKey:@"name"];
            [GlobalOperator sharedInstance].user4Request.user.short_name =
                [accountProfilesDictionary objectForKey:@"short_name"];
            [GlobalOperator sharedInstance].user4Request.user.sortable_name =
                [GlobalOperator sharedInstance].user4Request.user.name;
            NSString *regex = @"upaiyun.com";
            NSPredicate *predicate =
                [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
            if ([predicate
                    evaluateWithObject:[accountProfilesDictionary
                                           objectForKey:@"avatar_url"]]) {
                [GlobalOperator sharedInstance].user4Request.user.avatar.url =
                    [accountProfilesDictionary objectForKey:@"avatar_url"];
            } else {
                //本地默认的头像
                [GlobalOperator sharedInstance].user4Request.user.avatar.url =
                    [[NSBundle mainBundle] pathForResource:@"icon_login_normal"
                                                    ofType:@"png"];
            }
            lbLogout.text = @"注销";
            logoutBtn.enabled = YES;
            updateInfoBtn.enabled = YES;
            logoutBtn.titleLabel.textColor = [UIColor colorWithRed:61.0 / 255
                                                             green:69.0 / 255
                                                              blue:76.0 / 255
                                                             alpha:1.0];
            updateInfoBtn.titleLabel.textColor =
                [UIColor colorWithRed:61.0 / 255
                                green:69.0 / 255
                                 blue:76.0 / 255
                                alpha:1.0];
            [self allCoursesButtonOnClick];
            [self checkMyCourses];
            if ([leftDelegate respondsToSelector:@selector(controllSidebar:)]) {
                [leftDelegate controllSidebar:YES];
            }
            AppDelegate *delegant =
                (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (delegant.isClickEntrollment == YES) {
                [homePageOperator
                    requestEnrollments:self
                                 token:DEVELOPER_TOKEN
                              courseID:[currentAllCoursesItem
                                           objectForKey:@"id"]
                               user_id:[GlobalOperator sharedInstance].userId];
                [self loadEnrollments:NO];
            } else {
                if (FromLogin == YES) {
                    [self performSelector:@selector(showLeftSideBar:)
                               withObject:nil
                               afterDelay:0];
                }
            }
        }
        failure:^(id result) {}];
}
// 登出
- (void)loadLogout:(BOOL)fromCache {
}

- (void)getAllMyCourseData:(NSMutableArray *)myCourseDataArray {
    self.allMyCoursesDataArray =
        [NSMutableArray arrayWithCapacity:myCourseDataArray.count];
    for (int i = 0; i < myCourseDataArray.count; i++) {
        NSDictionary *myCourseDic = [myCourseDataArray objectAtIndex:i];
        NSString *courseId = [myCourseDic objectForKey:@"id"];
        for (int j = 0; j < self.allCoursesDataArray.count; j++) {
            NSDictionary *allCourseDic =
                [self.allCoursesDataArray objectAtIndex:j];
            NSString *allCourseId = [allCourseDic objectForKey:@"id"];
            if ([courseId intValue] == [allCourseId intValue]) {
                [self.allMyCoursesDataArray addObject:allCourseDic];
            }
        }
    }
    NSLog(@"allM count si %lu",
          (unsigned long)self.allMyCoursesDataArray.count);
}

- (void)requestSuccess:(NSString *)cmd {
    if ([cmd compare:HTTP_CMD_HOMEPAGE_HEADERSLIDER] == NSOrderedSame) {
        //        self.headerSliderArray =
        //        homePageOperator.homePage.headerSliderArray;
        //        [self loadAllCoursesHeaderData];
        //        BrirfVIew.hidden = NO;
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_ALLCOURSES] == NSOrderedSame) {
        //        self.allCoursesDataArray = [[NSMutableArray alloc]init];
        //        for(int i = 0; i
        //        <homePageOperator.homePage.allCoursesArray.count;i++){
        //            AllCoursesItem *item =
        //            [homePageOperator.homePage.allCoursesArray
        //            objectAtIndex:i];
        //            if([item.visible boolValue] == 1){
        //                [self.allCoursesDataArray addObject:item];
        //            }
        //        }
        //        [gridView reloadData];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_MYCOURSES] == NSOrderedSame) {
        //        self.myCoursesDataArray =
        //        homePageOperator.homePage.myCoursesArray;
        //        if(self.myCoursesDataArray.count == 0)
        //        {
        //            lbMyCourse.text = @"您还没有课程啊，去全部课程看看吧！";
        //        }else
        //        {
        //            lbMyCourse.text = @"";
        //        }
        //        [myCourseCollectionView reloadData];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_LOGOUT] == NSOrderedSame) {
        //        NSFileManager *fileManager = [NSFileManager defaultManager];
        //        if ([fileManager removeItemAtPath:[ToolsObject
        //        getTokenJSONFilePath] error:nil])
        //        {
        //            [GlobalOperator sharedInstance].isLogin = NO;
        //            lbLogout.text = @"登录/注册";
        //            updateInfoBtn.enabled = NO;
        //            updateInfoBtn.titleLabel.textColor = [UIColor
        //            lightGrayColor];
        //            [self.anncoumentsArray removeAllObjects];
        //            [self.messageArray removeAllObjects];
        //            [self.discussArray removeAllObjects];
        //            [self.myCoursesDataArray removeAllObjects];
        //        }
    } else if ([cmd compare:HTTP_CMD_ACTIVITY_STREAM] == NSOrderedSame) {
        //        for(MyAnnouncement* item in
        //        homePageOperator.homePage.announcementArray)
        //        {
        //            //            NSLog(@"self.messageArray ===
        //            %@",item.type);
        //            if ([item.type isEqualToString:@"Announcement"])
        //            {
        //                [self.anncoumentsArray addObject:item];
        //            }else if ([item.type isEqualToString:@"Message"])
        //            {
        //                [self.messageArray addObject:item];
        //                //                NSLog(@"self.messageArray ===
        //                %@",self.messageArray);
        //            }else if ([item.type isEqualToString:@"DiscussionTopic"])
        //            {
        //                [self.discussArray addObject:item];
        //            }
        //        }
        //        self.tempArray = self.anncoumentsArray;
        //        if(self.tempArray.count == 0)
        //        {
        //            lbActivty.text = @"还没有通知啊。去预约课程吧！";
        //        }
        //        //        countLabel.hidden = NO;
        //        //        countLabel.text = [NSString
        //        stringWithFormat:@"%d",self.anncoumentsArray.count];
        //        [activityTableView reloadData];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_CATEGORY] == NSOrderedSame) {
        //        [self.pickerArray removeAllObjects];
        //        [self.pickerArray addObject:@"全部类别"];
        //        [self.pickerArray
        //        addObjectsFromArray:homePageOperator.homePage.categoryArray];
        //        self.pickerArray = homePageOperator.homePage.categoryArray;
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_MYBADGES] == NSOrderedSame) {
        //        [self.myBadgeDataArray removeAllObjects];
        //        self.myBadgeDataArray = homePageOperator.homePage.badgesArray;
        //        [self.tbvAllCourses reloadData];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_ENROLLUSER] == NSOrderedSame) {
        //        [ToolsObject closeLoading:self.view];
        //        self.myCoursesDataArray =
        //        homePageOperator.homePage.myCoursesArray;
        //         lbMyCourse.text = @"";
        //        [myCourseCollectionView reloadData];
        //        for(MyCourseItem * item in self.myCoursesDataArray)
        //        {
        //            if([item.courseId integerValue] == [[currentAllCoursesItem
        //            objectForKey:@"id"] integerValue])
        //            {
        //                [self enteringIntoCourseUnit:item];
        //                [self hiddenFloatingLayerView];
        //                break;
        //            }
        //        }
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] ==
               NSOrderedSame) {
        //        [floatingLayerViewWebView
        //        loadHTMLString:homePageOperator.courseBriefIntroduction
        //        baseURL:nil];
        //        [ToolsObject closeLoading:floatingLayerViewWebView];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] ==
               NSOrderedSame) {
        [floatingLayerViewWebView
            loadHTMLString:homePageOperator.introductionOfLecturer
                   baseURL:nil];
        [AppUtilities closeLoading:floatingLayerViewWebView];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_CREATEUSER] == NSOrderedSame) {
        // attention
        if ([GlobalOperator sharedInstance].userId == nil) {
            tfFalseDetail.hidden = NO;
            tfFalseDetail.text = @"该" @"邮" @"箱" @"已"
                @"被注册，请更换一个邮箱" @"!";
            detailView2.image = [UIImage imageNamed:@"Validate_false"];
            registerBtn.enabled = YES;
        }
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_EDITAFTERCREATEUSER] ==
               NSOrderedSame) {
        [AppUtilities closeLoading:self.view];
        [AppUtilities showHUD:@"注册成功" andView:self.view];
        [registerView removeFromSuperview];
        [self login];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_EXCHANGETOKEN] == NSOrderedSame) {

        [self getAccountProfiles:[GlobalOperator sharedInstance].userId
                           token:[GlobalOperator sharedInstance]
                                     .user4Request.user.avatar.token];

        //        [homePageOperator requestAllCourses:self token:PUBLIC_TOKEN];

        //        if (!isfloatingLayerViewEnteringCourseUnit)
        //        {// 正常登录
        //            [self checkMyCourses];
        //        }
        //        else
        //        {//FloatingLayerView中的登陆，获取我的课程信息，供判断是否已购买
        //            loginFloatingLayerBg_EmptyView.hidden = YES;
        //            [homePageOperator requestMyCourses:self
        //            token:[GlobalOperator
        //            sharedInstance].user4Request.user.avatar.token];
        //        }
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_ACCOUNTPROFILES] ==
               NSOrderedSame) {
        lbLogout.text = @"注销";
        logoutBtn.enabled = YES;
        updateInfoBtn.enabled = YES;

        logoutBtn.titleLabel.textColor = [UIColor colorWithRed:61.0 / 255
                                                         green:69.0 / 255
                                                          blue:76.0 / 255
                                                         alpha:1.0];
        updateInfoBtn.titleLabel.textColor = [UIColor colorWithRed:61.0 / 255
                                                             green:69.0 / 255
                                                              blue:76.0 / 255
                                                             alpha:1.0];

        [self allCoursesButtonOnClick];
        [self checkMyCourses];

        if ([leftDelegate respondsToSelector:@selector(controllSidebar:)]) {
            [leftDelegate controllSidebar:YES];
        }
        //        [self checkUsedDisk];
        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (delegant.isClickEntrollment == YES) {
            //            [homePageOperator requestEnrollments:self
            //            token:DEVELOPER_TOKEN courseID:[currentAllCoursesItem
            //            objectForKey:@"id"] user_id:[GlobalOperator
            //            sharedInstance].userId];
            [self loadEnrollments:NO];
        } else {
            if (FromLogin == YES) {
                [self performSelector:@selector(showLeftSideBar:)
                           withObject:nil
                           afterDelay:0];
            }
        }
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_EDITUSER] == NSOrderedSame) {
        [AppUtilities closeLoading:self.view];
        [AppUtilities showHUD:@"修改信息成功" andView:self.view];

        if ([leftDelegate respondsToSelector:@selector(controllSidebar:)]) {
            [leftDelegate controllSidebar:YES];
        }
        if ([leftDelegate respondsToSelector:@selector(editSuccess)]) {
            [leftDelegate editSuccess];
        }
        [selfInfoView removeFromSuperview];
        loginFloatingLayerBg_EmptyView.hidden = YES;
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    if ([cmd compare:HTTP_CMD_COURSE_MODULES] == NSOrderedSame) {
        [AppUtilities closeLoading:floatingLayerViewCourseArrangementTableView];
    } else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] ==
                   NSOrderedSame ||
               [cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] ==
                   NSOrderedSame) {
        [AppUtilities closeLoading:floatingLayerViewWebView];
    }

    [AppUtilities showHUD:errMsg andView:self.view];
}

#pragma mark - Custom Methods
- (NSArray *)sortItems:(NSArray *)array {
    NSArray *orderedArray =
        [array sortedArrayUsingComparator:^(id obj1, id obj2) {
            FileModel *file1 = (FileModel *)obj1;
            FileModel *file2 = (FileModel *)obj2;

            NSString *moduleId1 = [self getModuleIdFromFile:file1.fileName];
            NSString *moduleId2 = [self getModuleIdFromFile:file2.fileName];

            if ([moduleId1 integerValue] < [moduleId2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }

            if ([moduleId1 integerValue] > [moduleId2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            return (NSComparisonResult)NSOrderedSame;
        }];

    return orderedArray;
}

- (NSString *)getModuleIdFromFile:(NSString *)fileName {
    NSArray *fields = [fileName componentsSeparatedByString:@"_"];
    NSString *lastField = [fields objectAtIndex:(fields.count - 1)];
    NSArray *twoItems = [lastField componentsSeparatedByString:@"."];
    NSString *moduleId = twoItems[0];

    return moduleId;
}

#pragma mark - UpYun
//- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result
//{
//    //清楚旧的缓存文件
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:[ToolsObject getAvatarPath] error:nil];
//
//    if ([[upYun.params objectForKey:@"type"] isEqual:@"edit"])
//    {
////        [self loadEditUser:NO];
//    }
//    else if ([[upYun.params objectForKey:@"type"] isEqual:@"create"])
//    {
////        [self loadEditAfterCreateUser:NO];
//        [ToolsObject closeLoading:self.view];
//        [ToolsObject showHUD:@"注册成功" andView:self.view];
//        [registerView removeFromSuperview];
//        [self login];
//
//    }
//}

- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error {
    NSString *string = nil;
    if ([ERROR_DOMAIN isEqualToString:error.domain]) {
        string = [error.userInfo objectForKey:@"message"];
    } else {
        string = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    }

    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:string
                                   message:@"上传头像失败"
                                  delegate:nil
                         cancelButtonTitle:@"关闭"
                         otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark 处理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
    numberOfRowsInComponent:(NSInteger)component {
    return [pickerArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return [pickerArray objectAtIndex:row];
}
- (IBAction)canclePress:(id)sender {
    [bgView removeFromSuperview];
}
- (IBAction)selectListPress:(id)sender {
    NSInteger row = [pickerView selectedRowInComponent:0];
    NSString *mys = [pickerArray objectAtIndex:row];

    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    [self.allCoursesDataArray removeAllObjects];
    if ([AppUtilities isExistenceNetwork]) {
        for (int i = 0; i < self.allCoursesArray.count; i++) {
            NSDictionary *item = [self.allCoursesArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    } else {
        for (int i = 0; i < self.allCourseFromCacheArray.count; i++) {
            NSDictionary *item = [self.allCourseFromCacheArray objectAtIndex:i];
            if ([[item objectForKey:@"visible"] boolValue] == 1) {
                [self.allCoursesDataArray addObject:item];
            }
        }
    }

    if (![@"全部类别" isEqualToString:mys]) {
        for (NSDictionary *item in self.allCoursesDataArray) {
            if ([[item objectForKey:@"courseCategory"] isEqualToString:mys]) {
                [tempArr addObject:item];
            }
        }
        [self.allCoursesDataArray removeAllObjects];
        self.allCoursesDataArray = tempArr;
        self.courseCateogy = mys;
    } else {
        self.courseCateogy = @"全部类别";
    }
    allLable.text = mys;
    //    [gridView reloadData];
    if ([self.courseType isEqualToString:@"public"]) {
        [self performSelector:@selector(clickPublicBtn:)
                   withObject:nil
                   withObject:nil];
    } else if ([self.courseType isEqualToString:@"guide"]) {
        [self performSelector:@selector(clickGuideBtn:)
                   withObject:nil
                   withObject:nil];
    } else if ([self.courseType isEqualToString:@"all"]) {
        [self performSelector:@selector(clickAllBtn:)
                   withObject:nil
                   withObject:nil];
    }

    [bgView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
#pragma mark -
#pragma mark uncache data
- (void)uncacheHeaderSliders {

    NSString *cacheFileName = CACHE_HOMEPAGE_HEADERSLIDER;
    // unarchiver
    NSString *homeSliderPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR,
                                    ARCHIVER_HOMEPAGE_HEADERSLIDER, nil];
    self.headerSliderArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:homeSliderPath];
    [self loadAllCoursesHeaderData];
    BrirfVIew.hidden = NO;
}

- (void)uncacheAllCourse {
    NSString *cacheFileName = CACHE_HOMEPAGE_ALLCOURSE;
    // unarchiver
    NSString *allCoursePath =
        [FileUtil getDocumentFilePathWithFile:cacheFileName
                                          dir:ARCHIVER_DIR,
                                              CACHE_HOMEPAGE_ALLCOURSE, nil];
    self.allCourseFromCacheArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:allCoursePath];

    self.allCoursesDataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < allCourseFromCacheArray.count; i++) {
        AllCoursesItem *item = [allCourseFromCacheArray objectAtIndex:i];
        if ([item.visible boolValue] == 1) {
            [self.allCoursesDataArray addObject:item];
        }
    }

    [gridView reloadData];
}
- (void)uncacheCourseCategory {
    NSString *cacheFileName = CACHE_HOMEPAGE_CATEGORY;
    // unarchiver
    NSString *courseCategoryPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_CATEGORY, nil];

    [self.pickerArray
        addObjectsFromArray:[NSKeyedUnarchiver
                                unarchiveObjectWithFile:courseCategoryPath]];
}
- (void)uncacheMyCourse {
    NSString *cacheFileName = CACHE_HOMEPAGE_MYCOURSE;
    // unarchiver
    NSString *myCoursePath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_MYCOURSE, nil];

    self.myCoursesDataArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:myCoursePath];

    if (self.myCoursesDataArray.count == 0) {
        lbMyCourse.text = @"您" @"还" @"没" @"有" @"课"
                                                      @"程啊，去全部课程看看吧"
                                                      @"！";
    } else {
        lbMyCourse.text = @"";
    }
    [myCourseCollectionView reloadData];
}
- (void)uncacheBadges {
    NSString *cacheFileName = CACHE_HOMEPAGE_BADGE;
    // unarchiver
    NSString *courseCategoryPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_BADGE, nil];

    self.myBadgeDataArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:courseCategoryPath];
}
- (void)uncacheAccountProfiles {
    NSString *cacheFileName = CACHE_HOMEPAGE_SELFINFO;
    // unarchiver
    NSString *courseCategoryPath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_SELFINFO, nil];
    NSArray *accountProfilesArr =
        [NSKeyedUnarchiver unarchiveObjectWithFile:courseCategoryPath];

    [GlobalOperator sharedInstance].user4Request.pseudonym.unique_id =
        [accountProfilesArr objectAtIndex:0];
    [GlobalOperator sharedInstance].user4Request.user.name =
        [accountProfilesArr objectAtIndex:1];
    [GlobalOperator sharedInstance].user4Request.user.short_name =
        [accountProfilesArr objectAtIndex:2];
    [GlobalOperator sharedInstance].user4Request.user.avatar.url =
        [accountProfilesArr objectAtIndex:3];
}

#pragma mark -
#pragma mark downloadManage
- (IBAction)clickStartAllDownload {
    [startLabel setTextColor:[UIColor grayColor]];
    [stopLabel setTextColor:[UIColor colorWithRed:61.0 / 255
                                            green:69.0 / 255
                                             blue:76.0 / 255
                                            alpha:1.0]];
    startBtn.enabled = NO;
    stopBtn.enabled = YES;

    //开始全部下载

    [self.downingList
        enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *obj,
                                            BOOL *stop) {
            for (id one in obj) {
                if ([one isKindOfClass:[ASIHTTPRequest class]]) {
                    ASIHTTPRequest *req = one;
                    FileModel *fileInfo = [req.userInfo objectForKey:@"File"];
                    if (![req isExecuting]) {
                        NSLog(@"fileInfo.fileReceivedSize == %@",
                              fileInfo.fileReceivedSize);
                        NSLog(@"fileInfo.fileSize  == %@", fileInfo.fileSize);
                        if ([fileInfo.fileReceivedSize longLongValue] <
                            [fileInfo.fileSize longLongValue]) {
                            [req cancel];
                            [req startAsynchronous];
                        }
                    }
                } else if ([one isKindOfClass:[FileModel class]]) {
                    FileModel *model = one;
                    if ([model.fileReceivedSize longLongValue] <
                        [model.fileSize longLongValue]) {
                        model.isDownloading = YES;
                        [[FilesDownManage sharedInstance]
                            downFileUrl:model.fileURL
                               filename:model.fileName
                             filetarget:@"mp4"
                              fileimage:[GlobalOperator sharedInstance].userId
                              fileTitle:model.fileTitle
                               courseID:model.courseId
                                 fileId:model.fileID
                              showAlert:NO];
                    }
                }
            }
        }];
    [self.downloadCollectionView reloadData];
}
- (IBAction)clickStopAllDownload {
    [startLabel setTextColor:[UIColor colorWithRed:61.0 / 255
                                             green:69.0 / 255
                                              blue:76.0 / 255
                                             alpha:1.0]];
    [stopLabel setTextColor:[UIColor grayColor]];
    startBtn.enabled = YES;
    stopBtn.enabled = NO;

    //开始全部暂停
    [[ASIHTTPRequest sharedQueue] cancelAllOperations];
    [self.downingList
        enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *obj,
                                            BOOL *stop) {
            for (ASIHTTPRequest *req in obj) {
                if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                    [[FilesDownManage sharedInstance] stopRequest:req];
                    continue;
                } else if ([req isKindOfClass:[FileModel class]]) {
                    FileModel *model = (FileModel *)req;

                    model.isDownloading = NO;
                }
            }
        }];

    /*
    [self.downingList removeAllObjects];

    [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad"
    TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp4"]];
    [FilesDownManage sharedFilesDownManage].downloadDelegate = self;
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];

    //    [filedownmanage startLoad];
           for (FileModel *model in filedownmanage.filelist) {
        //        NSLog(@"user = %@",[model.usrname class]);
        //        NSLog(@"real = %@",[[GlobalOperator sharedInstance].userId
    class]);
        if([[NSString stringWithFormat:@"%@",[GlobalOperator
    sharedInstance].userId] isEqualToString:[NSString
    stringWithFormat:@"%@",model.usrname]]){
            if (model.courseId == nil) {
                continue;
            }
            if([[self.downingList allKeys] containsObject:model.courseId]) {
                NSMutableArray *arr = [downingList objectForKey:model.courseId];
                BOOL duplicate = NO;
                for (FileModel *m in arr) {
                    if ([m isKindOfClass:[FileModel class]]) {
                        if ([[m fileName] isEqualToString:[model fileName]]) {
                            duplicate = YES;
                            break;
                        }
                    } else {
                        if ([[[(ASIHTTPRequest*)m url] absoluteString]
    isEqualToString:[model fileURL]]) {
                            duplicate = YES;
                            break;
                        }
                    }
                }
                if (!duplicate ) {
                    [arr addObject:model];
                }
            } else {
                NSMutableArray *arr = [NSMutableArray arrayWithObject:model];
                [self.downingList setObject:arr forKey:model.courseId];
            }
        }
    }

    @synchronized(filedownmanage.downinglist){
        for (ASIHTTPRequest *theRequest in filedownmanage.downinglist) {
            if (theRequest!=nil) {
                FileModel *fileInfo = [theRequest.userInfo
    objectForKey:@"File"];
                //                NSLog(@"user = %@",fileInfo.usrname);
                //                  NSLog(@"real = %@",[GlobalOperator
    sharedInstance].userId);
                if (fileInfo.courseId != nil && [[NSString
    stringWithFormat:@"%@",[GlobalOperator sharedInstance].userId]
    isEqualToString:[NSString stringWithFormat:@"%@",fileInfo.usrname]]) {
                    if([[self.downingList allKeys]
    containsObject:fileInfo.courseId]) {
                        NSMutableArray *arr = [downingList
    objectForKey:fileInfo.courseId];
                        BOOL duplicate = NO;
                        for (ASIHTTPRequest *req in arr) {
                            if ([req isKindOfClass:[ASIHTTPRequest class]]) {
                                if ([[req.url absoluteString]
    isEqualToString:[theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            } else {
                                if ([[(FileModel*)req fileURL]
    isEqualToString:[theRequest.url absoluteString]]) {
                                    duplicate = YES;
                                    break;
                                }
                            }
                        }
                        if (!duplicate ) {
                            [arr addObject:theRequest];
                        }
                    } else {
                        NSMutableArray *arr = [NSMutableArray
    arrayWithObject:theRequest];
                        [self.downingList setObject:arr
    forKey:fileInfo.courseId];
                    }
                }
            }
        }
    }

    @synchronized(filedownmanage.finishedlist){
        for (FileModel *fileInfo in filedownmanage.finishedlist) {
            //            NSLog(@"user = %@",fileInfo.usrname);
            //            NSLog(@"real = %@",[GlobalOperator
    sharedInstance].userId);

            if (fileInfo!=nil && fileInfo.courseId != nil && [[NSString
    stringWithFormat:@"%@",[GlobalOperator sharedInstance].userId]
    isEqualToString:[NSString stringWithFormat:@"%@",fileInfo.usrname]]) {
                if([[self.downingList allKeys]
    containsObject:fileInfo.courseId]) {
                    NSMutableArray *arr = [downingList
    objectForKey:fileInfo.courseId];
                    [arr addObject:fileInfo];
                } else {
                    NSMutableArray *arr = [NSMutableArray
    arrayWithObject:fileInfo];
                    [self.downingList setObject:arr forKey:fileInfo.courseId];
                }
            }
        }
    }

  */
    [self.downloadCollectionView reloadData];
}
- (IBAction)clickEdit {
    if ([manageLabel.text isEqualToString:@"管理"]) {

        manageLabel.text = @"完成";
        startLabel.hidden = YES;
        stopLabel.hidden = YES;
        startBtn.enabled = NO;
        stopBtn.enabled = NO;
        ableUseDiskLabel.textColor = [UIColor whiteColor];
        UsedDiskLabel.textColor = [UIColor whiteColor];

        EnableEdit = YES;
        barView.image = [UIImage imageNamed:@"Shape"];

    } else if ([manageLabel.text isEqualToString:@"完成"]) {
        manageLabel.text = @"管理";
        EnableEdit = NO;

        startLabel.hidden = NO;
        stopLabel.hidden = NO;
        startBtn.enabled = YES;
        stopBtn.enabled = YES;

        ableUseDiskLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                     green:161.0 / 255
                                                      blue:219.0 / 255
                                                     alpha:1.0];
        UsedDiskLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                  green:161.0 / 255
                                                   blue:219.0 / 255
                                                  alpha:1.0];

        barView.image = [UIImage imageNamed:@"recently_tab_bg"];
    }

    //编辑
    [self.downloadCollectionView reloadData];
}
#pragma mark -
#pragma mark controllBtnEnabled
- (void)controllBtn:(BOOL)enabled;
{
    self.headerScrollView.userInteractionEnabled = enabled;

    self.sectionView.userInteractionEnabled = enabled;

    self.activityView.userInteractionEnabled = enabled;

    self.startBtn.enabled = enabled;
    self.stopBtn.enabled = enabled;

    gridView.userInteractionEnabled = enabled;

    self.settingView.userInteractionEnabled = enabled;

    if (floatingLayerView.hidden == NO &&
        floatingLayerBg_EmptyView.hidden == NO) {

        [self hiddenFloatingLayerView];
    }
}

#pragma mark -
#pragma mark checkDisk
- (void)checkUsedDisk {

    NSString *path = [NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *usedPath = [NSHomeDirectory()
        stringByAppendingPathComponent:@"Documents/DownLoad/mp4"];
    NSString *usedTempPath = [NSHomeDirectory()
        stringByAppendingPathComponent:@"Documents/DownLoad/Temp"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileSysAttributes =
        [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    //    NSNumber *totalSpace = [fileSysAttributes
    //    objectForKey:NSFileSystemSize];

    NSString *used = [NSString
        stringWithFormat:@"%.2fG", [self folderSizeAtPath:usedPath] +
                                       [self folderSizeAtPath:usedTempPath]];
    //    NSLog(@"use ==== \n%@",[NSString stringWithFormat:@"%.2fG",[self
    //    folderSizeAtPath:usedPath]]);

    //    NSString *total = [NSString
    //    stringWithFormat:@"总空间为:%0.1fG",([totalSpace
    //    doubleValue])/1024.0/1024.0/1024.0];
    NSString *free =
        [NSString stringWithFormat:@"%.2fG", ([freeSpace doubleValue]) /
                                                 1024.0 / 1024.0 / 1024.0];
    //    NSString *use = [NSString
    //    stringWithFormat:@"已用空间:%0.1fG",([totalSpace
    //    doubleValue]-[freeSpace doubleValue])/1024.0/1024.0/1024.0];
    NSLog(@"free === \n%@", free);
    ableUseDiskLabel.text = free;
    UsedDiskLabel.text = used;
}
- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (float)folderSizeAtPath:(NSString *)folderPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
        return 0;
    NSEnumerator *childFilesEnumerator =
        [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath =
            [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0 * 1024.0);
}
#pragma mark - collection数据源代理

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {

    if ([collectionView isEqual:downloadCollectionView]) {
        CollectionHeadView *collectionHeadView =
            [collectionView dequeueReusableSupplementaryViewOfKind:
                                UICollectionElementKindSectionHeader
                                               withReuseIdentifier:@"head"
                                                      forIndexPath:indexPath];
        [collectionHeadView setUserInteractionEnabled:YES];

        if (EnableEdit == YES) {
            collectionHeadView.button.hidden = NO;
            [collectionHeadView.button addTarget:self
                                          action:@selector(deleteAll:)
                                forControlEvents:UIControlEventTouchUpInside];
        } else {
            collectionHeadView.button.hidden = YES;
            [collectionHeadView.button
                    removeTarget:self
                          action:@selector(deleteAll:)
                forControlEvents:UIControlEventTouchUpInside];
        }
        NSMutableArray *arr = [self.downingList
            objectForKey:[[self.downingList allKeys]
                             objectAtIndex:indexPath.section]];

        if ([arr count] <= indexPath.row) {
            collectionHeadView.label.text = @"";
            collectionHeadView.button.hidden = YES;
        } else if ([[arr objectAtIndex:indexPath.row]
                       isKindOfClass:[FileModel class]] == YES) {
            FileModel *fileInfo = [arr objectAtIndex:indexPath.row];
            for (NSDictionary *item in self.allMyCoursesDataArray) {
                //                NSLog(@"%@",item.courseId);
                if ([[item objectForKey:@"id"] intValue] ==
                    [fileInfo.courseId intValue]) {
                    collectionHeadView.button.tag =
                        100 + [fileInfo.courseId integerValue];
                    collectionHeadView.label.text =
                        [item objectForKey:@"courseName"];
                }
            }
        } else if ([[arr objectAtIndex:indexPath.row]
                       isKindOfClass:[ASIHTTPRequest class]] == YES) {
            ASIHTTPRequest *theRequest = [arr objectAtIndex:indexPath.row];
            if (theRequest != nil) {

                FileModel *fileInfo =
                    [theRequest.userInfo objectForKey:@"File"];
                for (NSDictionary *item in self.allMyCoursesDataArray) {
                    //                    NSLog(@"%@",item.courseId);
                    if ([[item objectForKey:@"id"] intValue] ==
                        [fileInfo.courseId intValue]) {
                        collectionHeadView.button.tag =
                            100 + [fileInfo.courseId integerValue];
                        collectionHeadView.label.text =
                            [item objectForKey:@"courseName"];
                    }
                }
            }
        }
        return collectionHeadView;
    } else if ([collectionView isEqual:myCourseCollectionView]) {

        CollectionFootView *collectionFootView =
            [collectionView dequeueReusableSupplementaryViewOfKind:
                                UICollectionElementKindSectionFooter
                                               withReuseIdentifier:@"foot"
                                                      forIndexPath:indexPath];

        return collectionFootView;
    }

    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:downloadCollectionView]) {
        return [(NSArray *)
            [self.downingList objectForKey:[[self.downingList allKeys]
                                               objectAtIndex:section]] count];
    } else if ([collectionView isEqual:myCourseCollectionView]) {
        return self.allMyCoursesDataArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:
                 (UICollectionView *)collectionView {
    if ([collectionView isEqual:downloadCollectionView]) {
        return [self.downingList allKeys].count;
    } else if ([collectionView isEqual:myCourseCollectionView]) {
        return 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([collectionView isEqual:downloadCollectionView]) {
        /*************************** DOWNLOAD MANAGEMENT
         * ****************************/
        DownloadCell *cell = (DownloadCell *)
            [collectionView dequeueReusableCellWithReuseIdentifier:KCellID
                                                      forIndexPath:indexPath];
        [cell setActionTarget:self];

        NSMutableArray *arr = [self.downingList
            objectForKey:[[self.downingList allKeys]
                             objectAtIndex:indexPath.section]];

        if ([[arr objectAtIndex:indexPath.row]
                isKindOfClass:[FileModel class]] == YES) {
            /////////======================= FileModel ====================
            FileModel *fileInfo = [arr objectAtIndex:indexPath.row];
            [cell configureWithFileModel:fileInfo];

            cell.deleteButton.hidden = !EnableEdit;
            cell.playButton.hidden = [fileInfo.fileReceivedSize integerValue] >=
                                     [fileInfo.fileSize integerValue];
            cell.pView.hidden = YES;
            for (NSDictionary *item in self.allMyCoursesDataArray) {
                if ([[item objectForKey:@"id"] intValue] ==
                    [fileInfo.courseId intValue]) {
                    [cell.videoImv
                        sd_setImageWithURL:
                            [NSURL
                                URLWithString:
                                    [AppUtilities
                                        adaptImageURL:
                                            [item objectForKey:@"coverImage"]]]
                          placeholderImage:
                              [UIImage imageNamed:@"cover_allcourse_default"]];
                    break;
                }
            }
        } else if ([[arr objectAtIndex:indexPath.row]
                       isKindOfClass:[ASIHTTPRequest class]] == YES) {
            /////////======================= ASIHTTPRequest ====================
            ASIHTTPRequest *theRequest = [arr objectAtIndex:indexPath.row];
            if (theRequest == nil) {
                return nil;
            }

            FileModel *fileInfo = [theRequest.userInfo objectForKey:@"File"];
            [cell configureWithFileModel:fileInfo];

            cell.deleteButton.hidden = !EnableEdit;

            if ([fileInfo.fileReceivedSize integerValue] <
                [fileInfo.fileSize integerValue]) {
                cell.videoStateLabel.text = @"下载中";
            } else {
                cell.videoStateLabel.text = @"下载完成";
            }
            cell.playButton.selected = !theRequest.isExecuting;

            cell.playButton.hidden = [fileInfo.fileReceivedSize integerValue] >=
                                     [fileInfo.fileSize integerValue];

            for (NSDictionary *item in self.allMyCoursesDataArray) {
                if ([[item objectForKey:@"id"] intValue] ==
                    [fileInfo.courseId intValue]) {
                    [cell.videoImv
                        sd_setImageWithURL:
                            [NSURL
                                URLWithString:
                                    [AppUtilities
                                        adaptImageURL:
                                            [item objectForKey:@"coverImage"]]]
                          placeholderImage:
                              [UIImage imageNamed:@"cover_allcourse_default"]];
                    break;
                }
            }
        }
        return cell;
    } else if ([collectionView isEqual:myCourseCollectionView]) {

        MyCourseCell *cell = (MyCourseCell *)[collectionView
            dequeueReusableCellWithReuseIdentifier:MyCoyrseCellID
                                      forIndexPath:indexPath];

        //        MyCourseItem *item = [self.myCoursesDataArray
        //        objectAtIndex:indexPath.row];
        NSDictionary *item =
            [self.allMyCoursesDataArray objectAtIndex:indexPath.row];
        cell.symbl.text = @"%";
        CGSize size = CGSizeMake(400, 2000);
        // CGSize labelsize = [item.courseName
        // sizeWithFont:cell.courseNameLabel.font constrainedToSize:size
        // lineBreakMode:NSLineBreakByWordWrapping];

        CGRect rect1 = [[item objectForKey:@"courseName"]
            boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont
                              systemFontOfSize:cell.courseNameLabel.font
                                                   .pointSize]
                      } context:nil];
        CGSize labelsize = rect1.size;

        if (labelsize.width > 146) {
            cell.courseNameLabel.frame = CGRectMake(250, 5, 146, 61);
        } else {
            cell.courseNameLabel.frame = CGRectMake(250, -5, 146, 61);
        }

        cell.courseNameLabel.text = [item objectForKey:@"courseName"];

        [cell.coverImv
            sd_setImageWithURL:
                [NSURL URLWithString:
                           [AppUtilities
                               adaptImageURL:[item objectForKey:@"coverImage"]]]
              placeholderImage:[UIImage imageNamed:@"cover_allcourse_default"]];
        cell.schoolNameLabel.text = [item objectForKey:@"schoolName"];

        if ([AppUtilities
                isLaterCurrentSystemDate:[item objectForKey:@"startDate"]]) {
            cell.percentLabel.text = @"0";
            cell.percentLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                          green:161.0 / 255
                                                           blue:219.0 / 255
                                                          alpha:1.0];
            cell.symbl.textColor = [UIColor colorWithRed:47.0 / 255
                                                   green:161.0 / 255
                                                    blue:219.0 / 255
                                                   alpha:1.0];

            cell.stateLabel.text = @"进入课程";
            cell.stateLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                        green:161.0 / 255
                                                         blue:219.0 / 255
                                                        alpha:1.0];

            cell.percentView.backgroundColor = [UIColor clearColor];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateTime =
                [formatter dateFromString:[item objectForKey:@"startDate"]];

            [formatter setDateFormat:@"yyyy"];
            NSString *date = [formatter stringFromDate:dateTime];
            if (![date isEqualToString:@"2020"]) {
                cell.startTimeLabel.text = [NSString
                    stringWithFormat:
                        @"开课时间：%@",
                        [AppUtilities
                            convertTimeStyle:[item objectForKey:@"startDate"]]];
                cell.endTimeLabel.text = [NSString
                    stringWithFormat:
                        @"结束时间：%@",
                        [AppUtilities
                            convertTimeStyle:[item objectForKey:@"end_at"]]];

            } else {
                cell.startTimeLabel.text = @"";
                cell.endTimeLabel.text = @"";

                cell.percentLabel.text = @"";
                cell.symbl.text = @"";
            }
            if ([[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                cell.typeLabel.text = @"导学课";
            } else {
                cell.endTimeLabel.text = @"";
                cell.typeLabel.text = @"公开课";
                cell.symbl.text = @"";
            }

        } else {

            if ([AppUtilities
                    isLaterCurrentSystemDate:[item objectForKey:@"end_at"]]) {
                cell.stateLabel.text = @"进入课程";
                cell.stateLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                            green:161.0 / 255
                                                             blue:219.0 / 255
                                                            alpha:1.0];
                cell.percentLabel.textColor = [UIColor colorWithRed:170.0 / 255
                                                              green:174.0 / 255
                                                               blue:178.0 / 255
                                                              alpha:1.0];
                cell.symbl.textColor = [UIColor colorWithRed:47.0 / 255
                                                       green:161.0 / 255
                                                        blue:219.0 / 255
                                                       alpha:1.0];
            } else {
                cell.stateLabel.text = @"课程已结束";
                cell.stateLabel.textColor = [UIColor colorWithRed:170.0 / 255
                                                            green:174.0 / 255
                                                             blue:178.0 / 255
                                                            alpha:1.0];
                cell.percentLabel.textColor = [UIColor colorWithRed:170.0 / 255
                                                              green:174.0 / 255
                                                               blue:178.0 / 255
                                                              alpha:1.0];
                cell.symbl.textColor = [UIColor colorWithRed:170.0 / 255
                                                       green:174.0 / 255
                                                        blue:178.0 / 255
                                                       alpha:1.0];
            }

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateTime =
                [formatter dateFromString:[item objectForKey:@"startDate"]];

            [formatter setDateFormat:@"yyyy"];
            NSString *date = [formatter stringFromDate:dateTime];
            if (![date isEqualToString:@"2020"]) {

                cell.startTimeLabel.text = [NSString
                    stringWithFormat:
                        @"开课时间：%@",
                        [AppUtilities
                            convertTimeStyle:[item objectForKey:@"startDate"]]];
                cell.endTimeLabel.text = [NSString
                    stringWithFormat:
                        @"结束时间：%@",
                        [AppUtilities
                            convertTimeStyle:[item objectForKey:@"end_at"]]];

            } else {
                cell.startTimeLabel.text = @"";
                cell.endTimeLabel.text = @"";
                cell.percentLabel.text = @"";
                cell.symbl.text = @"";
            }

            if ([[item objectForKey:@"courseType"] isEqualToString:@"guide"]) {
                cell.typeLabel.text = @"导学课";

                NSDate *currentdate = [NSDate date];

                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date1 =
                    [formatter dateFromString:[item objectForKey:@"startDate"]];

                NSString *num =
                    [[item objectForKey:@"estimate"] substringToIndex:1];
                //            NSDateFormatter *formatter = [[NSDateFormatter
                //            alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date =
                    [formatter dateFromString:[item objectForKey:@"startDate"]];
                NSLog(@"%@", date);
                NSTimeInterval some_day = 24 * 60 * 60 * [num intValue] * 7;
                NSDate *endDate = [date dateByAddingTimeInterval:some_day];
                NSLog(@"%@", endDate);

                NSString *confromTimespStr = [formatter stringFromDate:endDate];
                NSLog(@"confromTimespStr =  %@", confromTimespStr);

                //            NSDate* date2 = [formatter dateFromString:[item
                //            objectForKey:@"end_at"]];
                NSDate *date2 = [formatter dateFromString:confromTimespStr];
                NSTimeInterval secondsInterval =
                    [currentdate timeIntervalSinceDate:date1];
                //            NSLog(@"secondsInterval ===%lf",secondsInterval);
                NSTimeInterval secondsInterval1 =
                    [date2 timeIntervalSinceDate:date1];
                //            NSLog(@"secondsInterval1===%lf",secondsInterval1);
                if (secondsInterval > secondsInterval1) {
                    cell.percentLabel.text = @"100";
                    cell.percentView.frame = CGRectMake(241, 152, 256, 1);
                    cell.percentView.backgroundColor =
                        [UIColor colorWithRed:170.0 / 255
                                        green:174.0 / 255
                                         blue:178.0 / 255
                                        alpha:1.0];
                } else if (secondsInterval > 0) {
                    double percent = secondsInterval / secondsInterval1;
                    cell.percentLabel.text = [NSString
                        stringWithFormat:@"%d", (int)round(percent * 100)];
                    cell.percentLabel.textColor =
                        [UIColor colorWithRed:47.0 / 255
                                        green:161.0 / 255
                                         blue:219.0 / 255
                                        alpha:1.0];
                    cell.percentView.frame =
                        CGRectMake(241, 152, 256 * percent, 1);
                    cell.percentView.backgroundColor =
                        [UIColor colorWithRed:47.0 / 255
                                        green:161.0 / 255
                                         blue:219.0 / 255
                                        alpha:1.0];
                }
            } else {
                cell.endTimeLabel.text = @"";
                cell.typeLabel.text = @"公开课";
                cell.stateLabel.text = @"进入课程";
                cell.stateLabel.textColor = [UIColor colorWithRed:47.0 / 255
                                                            green:161.0 / 255
                                                             blue:219.0 / 255
                                                            alpha:1.0];
                cell.percentLabel.text = @"";
                cell.symbl.text = @"";
                cell.percentView.backgroundColor = [UIColor clearColor];
            }
        }

        return cell;
    }

    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([collectionView isEqual:myCourseCollectionView]) {

        delegant.isFromActivityAnn = NO;
        delegant.isFromActivityMes = NO;
        delegant.isFromActivityDis = NO;
        delegant.isFromDownLoad = NO;
        //        MyCourseItem *myCourseItem = [self.myCoursesDataArray
        //        objectAtIndex:indexPath.row];
        NSDictionary *myCourseItem =
            [self.allMyCoursesDataArray objectAtIndex:indexPath.row];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

        [formatter setDateFormat:@"yyyy-MM-dd"];
        //        NSDate *dateTime = [formatter
        //        dateFromString:myCourseItem.start_at];
        NSDate *dateTime =
            [formatter dateFromString:[myCourseItem objectForKey:@"startDate"]];

        [formatter setDateFormat:@"yyyy"];
        NSString *date = [formatter stringFromDate:dateTime];
        if (![date isEqualToString:@"2020"]) {
            [self enteringIntoCourseUnit:myCourseItem];

        } else {
            [AppUtilities showHUD:@"尚未开始，敬请期待" andView:self.view];
        }

    } else if ([collectionView isEqual:downloadCollectionView]) {

        if (EnableEdit == NO) {
            NSMutableArray *arr = [self.downingList
                objectForKey:[[self.downingList allKeys]
                                 objectAtIndex:indexPath.section]];

            if ([[arr objectAtIndex:indexPath.row]
                    isKindOfClass:[FileModel class]] == YES) {

                FileModel *fileInfo = [arr objectAtIndex:indexPath.row];

                if ([fileInfo.fileReceivedSize longLongValue] >=
                        [fileInfo.fileSize longLongValue] &&
                    [fileInfo.fileReceivedSize longLongValue] != 0) {

                    for (NSDictionary *item in self.allMyCoursesDataArray) {
                        if ([[item objectForKey:@"id"] intValue] ==
                            [fileInfo.courseId intValue]) {
                            delegant.isFromDownLoad = YES;
                            delegant.annStr = fileInfo.targetPath;

                            NSLog(@"%@", fileInfo.targetPath);
                            [self enteringIntoCourseUnit:item];
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (IBAction)deleteAll:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:[NSString stringWithFormat:@"是否全部删除？"]
                  message:nil
                 delegate:self
        cancelButtonTitle:@"确定"
        otherButtonTitles:@"取消", nil];
    alert.tag = 3;
    UIButton *btn = (UIButton *)sender;
    //    deleteCourseID = [NSString stringWithFormat:@"%d",(btn.tag - 100)];

    objc_setAssociatedObject(
        alert, &kRepresentedObject,
        [NSString stringWithFormat:@"%ld", (long)(btn.tag - 100)],
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [alert show];
}

- (void)deleteDownload:(FileModel *)model {
    __block ASIHTTPRequest *request = nil;
    [self.downingList enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                          NSMutableArray *obj,
                                                          BOOL *stop) {
        for (ASIHTTPRequest *req in obj) {
            if ([req isKindOfClass:[ASIHTTPRequest class]] &&
                [[(FileModel *)[[req userInfo] objectForKey:@"File"] fileName]
                    isEqualToString:model.fileName]) {
                request = req;
                [request cancel];
                [[FilesDownManage sharedInstance] deleteRequest:request];
                break;
            } else if ([[(FileModel *)req fileName]
                           isEqualToString:model.fileName]) {
                request = req;
                [[FilesDownManage sharedInstance]
                    deleteFileModel:(FileModel *)request];
                break;
            }
        }
        if (request != nil) {
            [obj removeObject:request];
            *stop = YES;
        }
    }];

    [downloadCollectionView reloadData];
}
@end
