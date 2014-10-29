//
//  KKBBaseViewController.h
//  learn
//
//  Created by xgj on 8/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBNetworkDisconnectView.h"
#import "KKBActivityIndicatorView.h"
#include "KKBLoadingFailedView.h"
#import "KKBSuccessView.h"

typedef enum {
    NavigationBarPlusTabBarMode,
    NavigationBarOnlyMode,
    TabBarOnlyMode,
    FullViewMode
} KKBViewMode;

@interface KKBBaseViewController : UIViewController

@property(nonatomic, assign) KKBViewMode viewMode;
@property(nonatomic, retain) KKBActivityIndicatorView *loadingView;
@property(strong, nonatomic) KKBNetworkDisconnectView *netDisconnectView;
@property(strong, nonatomic) KKBLoadingFailedView *loadingFailedView;
@property(strong,nonatomic)KKBSuccessView *successView;

// TODO: byzpc
- (void)networkStatusDidChange;
-(void)popSuccessView;

@end
