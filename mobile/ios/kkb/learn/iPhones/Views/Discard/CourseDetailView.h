//
//  CourseDetailView.h
//  learn
//
//  Created by 翟鹏程 on 14-6-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadDelegate.h"
#import "KKBActivityIndicatorView.h"

#import "PlayerFrameView.h"

@protocol CourseDetailViewDelegate <NSObject>
@optional
- (void)pushToLoginViewController;
@end

@interface CourseDetailView : UIView <
UITableViewDataSource,
UITableViewDelegate,
DownloadDelegate,
PlayerFrameViewDelegate,
CourseDetailViewDelegate>{
    
    KKBActivityIndicatorView *_loadingView;
}

@property (nonatomic,strong) PlayerFrameView *playerFrameView;
@property (nonatomic,strong) UITableView *unitTableView;


@property (nonatomic, strong) NSMutableArray *myCoursesDataArray;
@property (nonatomic, strong) NSArray *currentUnitList;
@property (nonatomic, strong) NSMutableArray *currentSecondLevelUnitList;
@property (nonatomic, strong) NSArray *currentSecondLevelVideoList;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic, strong) NSDictionary *currentAllCoursesItem; //当前全部课程的Item
@property (nonatomic,copy) NSString *selectVideoURL;

@property (nonatomic,strong)NSMutableDictionary *progressLabelDict;
@property (nonatomic,strong)NSMutableDictionary *downloadBtnDict;

@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *courseImage;
@property (assign) BOOL isOpen;

@property (nonatomic,assign)float currentLocation;

@property (nonatomic,strong)NSMutableArray *viewControllerArray;
@property (nonatomic,strong)UIViewController *viewController;


@property (nonatomic,strong) NSDictionary *currentCourse;
@property (nonatomic,strong) NSArray *currentCourseVideoList;

@property (nonatomic,strong) NSString *playRecordVideoId;
@property (nonatomic,assign) NSTimeInterval playRecordVideoDuration;

@property (nonatomic,assign) id <CourseDetailViewDelegate> delegate;

- (void)initWithUI;

- (void)loadData:(BOOL)fromCache;

@end
