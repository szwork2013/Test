//
//  KKBBaseViewController.m
//  learn
//
//  Created by xgj on 8/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBBaseViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "AppDelegate.h"
#import "KKBSuccessView.h"

@interface KKBBaseViewController ()

@end

@implementation KKBBaseViewController

@synthesize viewMode;
@synthesize loadingView;
@synthesize loadingFailedView;
@synthesize successView;

#pragma mark - Custom Methods
- (CGRect)networkDisconnectViewFrame {

    CGRect frame;

    switch (viewMode) {
    case NavigationBarPlusTabBarMode:
        frame = [self frame1];
        break;

    case NavigationBarOnlyMode:
        frame = [self frame2];
        break;

    case TabBarOnlyMode:
        frame = [self frame3];
        break;

    case FullViewMode:
        frame = [self frame4];
        break;

    default:
        break;
    }

    return frame;
}

- (CGRect)netDisconnectViewFrame {
    CGRect frame = CGRectMake(0, 0, G_SCREEN_WIDTH, G_SCREEN_HEIGHT);
    return frame;
}

- (CGRect)loadingViewFrame {
    return [self networkDisconnectViewFrame];
}

- (CGRect)loadingFailedViewFrame {
    return [self networkDisconnectViewFrame];
}

#pragma mark - networkDisconnectViewFrame
- (CGRect)frame1 { // Nav Bar + Tab bar
    int x = 0;
    int y = 0;
    int widht = G_SCREEN_WIDTH;
    int height =
        G_SCREEN_HEIGHT - TabBarHeight - NavigationBarHeight - StatusBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (CGRect)frame2 { // Nav bar only
    int x = 0;
    int y = 0;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - NavigationBarHeight - StatusBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (CGRect)frame3 { // Tab bar only
    int x = 0;
    int y = 0;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - TabBarHeight - StatusBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (CGRect)frame4 { // FullViewMode
    int x = 0;
    int y = StatusBarHeight;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)networkStatusDidChange {

    __weak KKBBaseViewController *weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager]
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                [weakSelf.netDisconnectView
                    showInView:weakSelf.view
                     LabelText:@"当前使用2G/3G网络"];
            } break;

            case AFNetworkReachabilityStatusReachableViaWiFi: {

            } break;
            case AFNetworkReachabilityStatusNotReachable: {

                [weakSelf.netDisconnectView showInView:weakSelf.view];
            } break;
            default:
                break;
            }
        }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    /************************* network **************************/
    _netDisconnectView = [[KKBNetworkDisconnectView alloc]
        initWithFrame:[self netDisconnectViewFrame]];

    [self networkStatusDidChange];

    /************************* loading view **************************/
    loadingView = [[KKBActivityIndicatorView alloc]
        initWithFrame:[self loadingViewFrame]];

    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    /************************* loading failed view **************************/
    loadingFailedView = [[KKBLoadingFailedView alloc]
        initWithFrame:[self loadingFailedViewFrame]];

    [loadingFailedView setHidden:YES];
    [self.view addSubview:loadingFailedView];
     /************************* success view **************************/
    successView = [[KKBSuccessView alloc]initWithFrame:CGRectZero];
    successView.hidden = YES;
    [self.view addSubview:successView];
}
-(void)popSuccessView{
    [UIView animateWithDuration:0.3 animations:^{
        successView.hidden = NO;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismissSuccessView) withObject:nil afterDelay:2.0];
    }];
}

-(void)dismissSuccessView{
    [UIView animateWithDuration:0.2 animations:^{
        successView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _netDisconnectView = nil;
    loadingView = nil;
}

@end
