//
//  AboutUsViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-21.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "AboutUsViewController.h"
#import "GlobalDefine.h"
#import "MobClick.h"
#import "KKBActivityIndicatorView.h"
#import "KKBLoadingFailedView.h"
#import "AppDelegate.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController
@synthesize aboutUsView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

#pragma mark - UIWebView Delegate Method
- (void)webViewDidStartLoad:(UIWebView *)webView {

    [self.loadingView showInView:self.view];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [self.loadingView hideView];
    [self.loadingFailedView hide];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    [self.loadingView hideView];
    [self.loadingFailedView show];
}

#pragma mark - Loading Failed Method

- (void)refresh {

    [self loadWebPage];
}

- (void)loadWebPage {
    NSString *path =
        @"http://kaikeba-file.b0.upaiyun.com/pages/about4phone.html";
    NSURL *url = [NSURL URLWithString:path];
    [aboutUsView loadRequest:[NSURLRequest requestWithURL:url]];
    [(UIScrollView *)[[aboutUsView subviews] objectAtIndex:0]
        setShowsVerticalScrollIndicator:NO];
}

#pragma mark - viewDidLoad Method
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWebPage];
    [self setTitle:@"关于我们"];
    [self.loadingFailedView setTapTarget:self action:@selector(refresh)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"AboutUs"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"AboutUs"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    //    interfaceOrientation == UIInterfaceOrientationLandscapeRight);

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
