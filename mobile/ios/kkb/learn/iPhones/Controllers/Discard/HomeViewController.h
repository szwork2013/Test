//
//  HomeViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "PullTableView.h"
#import "CycleScrollView.h"
#import "KKBActivityIndicatorView.h"
#import "KKBLoadingFailedView.h"


@interface HomeViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate, ASIHTTPRequestDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,PullTableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>{
    KKBActivityIndicatorView *_loadingView;
}



@property (assign,nonatomic) int index;
@property (nonatomic,copy)NSString *courseId;
@property (retain,nonatomic) CycleScrollView * headerScrollView;
@property (retain,nonatomic)IBOutlet UIPageControl* headerPageControl;
@property (retain,nonatomic)IBOutlet  UILabel *courseTitleLabel;
@property (retain,nonatomic)IBOutlet  UILabel *courseBriefLabel;
@property (nonatomic, retain) NSMutableArray *headerSliderArray; //首页推荐数据
@property (nonatomic, retain) NSMutableArray *allCoursesDataArray; //全部课程数据
@property (nonatomic, retain) NSMutableArray *allCoursesDataArrayVisible;
@property (nonatomic, retain) NSMutableArray *myCoursesDataArray; //我的课程数据
@property (nonatomic, retain) NSMutableArray *allMyCoursesDataArray;
@property (nonatomic,retain)NSMutableArray *courseFilter;
@property (nonatomic,retain)NSArray *filterResult;
@property (nonatomic,retain) IBOutlet PullTableView* tbvAllCourses;
@property (nonatomic,retain) IBOutlet UITableView* tbvMyCourses;
@property (nonatomic,retain) IBOutlet UIView* headerView;

@property (nonatomic,retain) IBOutlet UIImageView* logoView;
@property (nonatomic,retain) IBOutlet UILabel* logoLable;
@property (nonatomic,retain) IBOutlet UIImageView* noCourseView;
@property (nonatomic,retain) IBOutlet UIButton *showButton;

@property (nonatomic, retain) NSMutableArray *allCourseFromCacheArray;//从缓存中取到的数据

@property (nonatomic, retain) NSMutableArray *tempCoursesDataArray; //
@property NSInteger pageIndex;
@property (retain, nonatomic) IBOutlet UIView *allCourseContentView;
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (retain, nonatomic) IBOutlet UIView *allCourseButtonView;
@property (retain,nonatomic)UIView *line;
@property (retain, nonatomic) IBOutlet UIButton *allCourseButton;
//@property (retain, nonatomic) IBOutlet UIView *coverview;
@property (retain, nonatomic) IBOutlet UILabel *courseLabel;

@property(assign,nonatomic)BOOL isButtonFold;
@property(assign,nonatomic)BOOL isFilter;
@property (retain, nonatomic) IBOutlet UIView *collectionReplaceView;
@property (retain,nonatomic)NSMutableArray *itemArray;
@property (retain, nonatomic) IBOutlet UIView *coverTableView;
- (IBAction)showCourseName:(UIButton *)sender;

- (IBAction)showRightSideBar:(id)sender;
- (void)loadData:(BOOL)fromCache;
-(void)showMyCourseView;
-(void)showAllCourse;
- (void) popDownloadManagerView;
//-(void)requestAllCourses;

+ (void)clearCacheMyCourse;
- (void) showDownloadManagerView;
- (void) showTestViewCtr;

- (void)showQRCodeViewController;

- (void)showIFlyViewController;

@end



