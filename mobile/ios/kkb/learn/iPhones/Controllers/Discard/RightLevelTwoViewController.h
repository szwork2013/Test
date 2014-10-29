//
//  RightLevelTwoViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-28.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
@interface RightLevelTwoViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic,retain) IBOutlet UIButton * courseBriefBtn;
@property (nonatomic,retain) IBOutlet UIButton * teacherBriefBtn;
@property (nonatomic,retain) IBOutlet UIButton * UnitBtn;
@property (nonatomic,retain) IBOutlet UILabel * lbcourseBrief;
@property (nonatomic,retain) IBOutlet UILabel * lbteacherBrief;
@property (nonatomic,retain) IBOutlet UILabel * lbUnit;
@property (nonatomic,retain) IBOutlet UILabel * courseName;

@end
