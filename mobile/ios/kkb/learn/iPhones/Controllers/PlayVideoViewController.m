//
//  PlayVideoViewController.m
//  learn
//
//  Created by guojun on 9/16/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()
@end

@implementation PlayVideoViewController

#pragma mark - Custom Methods

- (void)dealloc {
}
- (void)preparePlayer {

    self.forceToFullScreen = YES;
    self.player.view.fullscreenButton.selected = YES;
    [self.player
        setLandscapeFrame:CGRectMake(0, 0, G_SCREEN_HEIGHT, G_SCREEN_WIDTH)];
    [self.player
        setPortraitFrame:CGRectMake(0, 0, G_SCREEN_WIDTH, G_SCREEN_HEIGHT)];

    [self.player.view setHidden:YES];
    [self.view addSubview:self.player.view];
}

- (void)videoPlayerViewFullScreenDidPress {
    [self dismissViewController];
}

- (void)dismissViewController {
    // fix iOS8 错乱问题
    self.player.forceRotate = YES;
    [self.player performOrientationChange:UIInterfaceOrientationPortrait];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parent Methods
- (BOOL)shouldNotHandleNetworkMonitor {
    return YES;
}

// 网络变化是是否允许外部检查网络变化处理
- (BOOL)shouldMonitorNetWorkChange {
    return NO;
}

- (void)handleError {

    UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle:@"提示"
                  message:@"视频文件被损坏了，无法播放"
                 delegate:nil
        cancelButtonTitle:@"我知道了"
        otherButtonTitles:nil];

    [alertView show];

    [self performSelector:@selector(dismissViewController)
               withObject:nil
               afterDelay:1.0f];
}

#pragma mark - Life Cycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self preparePlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [self.navigationController.navigationBar setHidden:NO];

    [self.player playButtonPressed];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.player.view setHidden:NO];
    [self.player fullScreenButtonTapped];

    self.player.forceRotate = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)videoPlayer:(VKVideoPlayer *)videoPlayer
    didChangeOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}
@end
