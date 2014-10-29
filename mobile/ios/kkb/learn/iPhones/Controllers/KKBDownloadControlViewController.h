//
//  KKBViewController.h
//  VideoDownload
//
//  Created by zengmiao on 8/27/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBExpandableTableViewController.h"

@interface KKBDownloadControlViewController : KKBExpandableTableViewController

@property(strong, nonatomic) NSNumber *classID; //根据课程ID展开对应的section

@property (nonatomic,assign) BOOL fromStudyVC;

@end
