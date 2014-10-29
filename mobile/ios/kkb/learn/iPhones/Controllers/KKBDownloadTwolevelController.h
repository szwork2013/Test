//
//  KKBDownloadTwolevelController.h
//  learn
//
//  Created by zengmiao on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"
@class KKBDownloadTwolevelController;
@class KKBDownloadClassModel;

@protocol KKBDownloadTwoLevelVCDelegate <NSObject>
- (void)downloadControlTapped:(KKBDownloadTwolevelController *)vc;
@end

@interface KKBDownloadTwolevelController : KKBBaseViewController

@property (nonatomic, assign) id<KKBDownloadTwoLevelVCDelegate> delegate;
@property (copy ,nonatomic) NSArray *videoItems;
@property (nonatomic, copy) NSNumber *classID;
@property (strong ,nonatomic) KKBDownloadClassModel *classModel;

@end
