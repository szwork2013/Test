//
//  UsersInCourseViewController.h
//  learn
//
//  Created by User on 13-7-12.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRGridView.h"

@class UsersInCourseOperator;

@interface UsersInCourseViewController : UIViewController<NRGridViewDelegate, NRGridViewDataSource>
{
    UsersInCourseOperator *op;
    
    NRGridView *_gridView;
}

@property (nonatomic, retain) NSMutableArray *teachersAndTas; //人员中老师、助教
@property (nonatomic, retain) NSMutableArray *students; //人员中学生
@property (nonatomic, copy) NSString *courseId;
@property (nonatomic, copy) NSString *courseName;

@end
