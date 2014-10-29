//
//  AnnouncementViewController.h
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnouncementOperator;


@interface AnnouncementViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
//    UITableView *announcementTableView;
    AnnouncementOperator *op;
    
    UIView *announcementBlankView; //没有数据时提示显示
}

@property (nonatomic, retain) NSMutableArray *announcementsArray;
@property (nonatomic, copy) NSString *courseId;


@property (nonatomic,retain) IBOutlet UITableView *announcementTableView;
@end
