//
//  KKBDownloadSingleHierarchyController.h
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBDownloadClassModel.h"
#import "KKBBaseViewController.h"
@class KKBDownloadSingleHierarchyController;

@protocol KKBDownloadSingleVCDelegate <NSObject>
- (void)downloadControlTapped:(KKBDownloadSingleHierarchyController *)vc;

@end

@interface KKBDownloadSingleHierarchyController :KKBBaseViewController

@property (nonatomic, assign) id<KKBDownloadSingleVCDelegate> delegate;

@property (strong ,nonatomic) KKBDownloadClassModel *classModel;
@property (strong ,nonatomic) NSArray *videoItems;

@end
