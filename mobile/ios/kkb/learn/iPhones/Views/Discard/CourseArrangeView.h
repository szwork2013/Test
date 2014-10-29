//
//  CourseArrangeView.h
//  learn
//
//  Created by zxj on 14-6-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
// add delegate
#import "PlayerFrameView.h"
@protocol CourseArrangeViewDelegate
- (void)loadingWebView:(NSArray*)ary url:(NSMutableString*)webUrl indexPath:(NSIndexPath *)webIndexPath;
@end
typedef NS_ENUM(NSInteger, KKBCourseState)
{
    KKBCourseStart = 0,
    KKBCourseStarted,
    KKBCourseStateNone
};

@class PlayerFrameView;
@class HomePageOperator;
@class CourseUnitOperator;

// add PlayerFrameViewDelegate
@interface CourseArrangeView : UIView<UITableViewDataSource,UITableViewDelegate,PlayerFrameViewDelegate>
@property (nonatomic, assign)KKBCourseState courseState;
@property (nonatomic, retain)UITableView *courseArrangeList;
@property (nonatomic, retain)PlayerFrameView *playerFrameView;
@property (nonatomic, retain)NSMutableArray *courseUnits;
@property (nonatomic, retain)NSMutableArray *currentSecondLevelUnitList;
@property (nonatomic, retain)NSMutableArray *openedInSectionArr;
@property (nonatomic, assign)NSInteger *selectIndex;
@property (nonatomic, retain)HomePageOperator *homePageOperator;
@property (nonatomic, retain)CourseUnitOperator *courseUnitOperator;
@property (nonatomic, assign)id<CourseArrangeViewDelegate> couseArrangeDelegate;
@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *courseImage;
// add
@property (nonatomic,retain)NSMutableArray *videoUrlArray;
@property (nonatomic,assign)int videoArrCount;
@property (nonatomic,retain)NSMutableDictionary *modulesItemDic;
@property (nonatomic,retain)NSMutableArray *videoTitleArray;

- (void)initbackImage;
@end
