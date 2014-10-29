//
//  SelfCenterViewController.h
//  learn
//
//  Created by zxj on 14-7-23.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfCenterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *certificationArray;
    NSMutableArray *myPublicCourseArray;
    NSMutableArray *myGuideCourseArray;
    

}
@property (weak, nonatomic) IBOutlet UITableView *centerTableView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageVIew;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *headerTitleView;

@end
