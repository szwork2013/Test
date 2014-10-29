//
//  CourseHomeViewController.h
//  learn
//
//  Created by zxj on 7/8/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushUpScrollView.h"
#import "CourseCategories.h"
#import "MajorViews.h"

#import "KKBBaseViewController.h"
#import "EAIntroView.h"
#import "SMPageControl.h"

@interface CourseHomeViewController
    : KKBBaseViewController <EGORefreshTableHeaderDelegate,
                             PushUpScrollViewDelegate, UIScrollViewDelegate,
                             UIScrollViewAccessibilityDelegate,
                             MiniMajorDelegate, CourseCategoryDelegate> {

    UIButton *toTabsPageButton;

    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

    NSArray *microSpecialitiesArray; //里面存储的数据类型是NSDictionary
    NSArray *categoryArray;          //里面存储的数据类型是
}

@property (strong, nonatomic) IBOutlet UIScrollView *allScrollView;

@property(nonatomic, strong) CourseCategories *courseCategoriesView;

@end