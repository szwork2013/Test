//
//  SettingViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-18.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutUsViewController.h"
#import "UMFeedback.h"
#import "GlobalDefine.h"
#import "HomePageOperator.h"
#import "GlobalOperator.h"
#import "JSONKit.h"
#import "AppUtilities.h"
#import "SelfInfoViewController.h"
#import "RegisterViewController.h"
#import "SuspensionHintView.h"
#import "KKBHttpClient.h"
#import "MobClick.h"
#import "KKBActivityIndicatorView.h"
#import "KKBUserInfo.h"
#import "CourseHomeViewController.h"
#import "AppDelegate.h"
#import "KKBUploader.h"
#import "KKBDataBase.h"

#import "KKBDownloadManager.h"

#define NAVIGATION_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20
#define KKB_ACTIVITY_INDICATOR_TAG 120

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface SettingViewController () {
    HomePageOperator *homePageOperator;
}

@end

@implementation SettingViewController

#pragma mark - Life Cycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[SuspensionHintView appearance] setPopupColor:[UIColor whiteColor]];
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(updateSetView)
                   name:NOTIFICATION_UPDATE_SETTING_VIEW
                 object:nil];

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingsTableView.scrollEnabled = YES;
    self.settingsTableView.height =
        G_SCREEN_HEIGHT - gNavigationAndStatusHeight;
    self.settingsTableView.backgroundColor = [UIColor colorWithRed:240 / 256.0
                                                             green:240 / 256.0
                                                              blue:240 / 256.0
                                                             alpha:1];
    NSString *versionText = [[[NSBundle mainBundle] infoDictionary]
        objectForKey:(NSString *)kCFBundleVersionKey];
    self.appVersion.font = [UIFont systemFontOfSize:12];
    self.appVersion.text =
        [NSString stringWithFormat:@"当前版本：v %@", versionText];
    //    self.appVersion.frame =
    //        CGRectMake(0, G_SCREEN_HEIGHT - 24 - gNavigationAndStatusHeight,
    //                   G_SCREEN_WIDTH, 21);

    self.settingsTableView.tableFooterView = self.appVersion;
    [self.navigationController.navigationBar setHidden:NO];
    [self setTitle:@"设置"];

    NSArray *section1 = [[NSArray alloc] initWithObjects:@"修改个人信息", nil];
    NSArray *section2 = [[NSArray alloc] initWithObjects:@"消息推送", nil];
    NSArray *section3 =
        [[NSArray alloc] initWithObjects:@"检查更新", @"意见反馈",
                                         @"评价一下", @"关于我们", nil];
    NSArray *section4 = [[NSArray alloc] initWithObjects:@"注销当前账号", nil];
    dataSource = [[NSMutableArray alloc]
        initWithObjects:section1, section2, section3, section4, nil];
}
- (void)viewWillAppear:(BOOL)animated {

    [MobClick beginLogPageView:@"Setting"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Setting"];
}

#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT;
    int widht = self.view.frame.size.width;
    int height = self.view.frame.size.height - y;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (void)showLoadingView {
    if (_loadingView == nil) {
        _loadingView = [KKBActivityIndicatorView sharedInstance];
        [_loadingView updateFrame:[self loadingViewFrame]];
        [self.view addSubview:_loadingView];
    }

    [_loadingView setHidden:NO];
}

- (void)removeLoadingView {
    [_loadingView setHidden:YES];
}

#pragma mark - Custom Methods
//检查更新
- (void)getUpdate {
    if ([AppUtilities isExistenceNetwork]) {

        NSString *updateInfo = [NSString
            stringWithContentsOfURL:
                [NSURL URLWithString:
                           @"http://itunes.apple.com/lookup?id=659238439"]
                           encoding:NSUTF8StringEncoding
                              error:nil];

        NSData *jsonData = [updateInfo dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *updateInfoDic =
            [NSJSONSerialization JSONObjectWithData:jsonData
                                            options:NSJSONReadingAllowFragments
                                              error:&error];

        NSDictionary *dic =
            [[updateInfoDic valueForKey:@"results"] objectAtIndex:0];
        NSString *latestVersion = [dic valueForKey:@"version"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
            objectForKey:(NSString *)kCFBundleVersionKey];
        if ([latestVersion caseInsensitiveCompare:currentVersion] ==
            NSOrderedDescending) {
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:nil
                                           message:@"版本有更新"
                                          delegate:self
                                 cancelButtonTitle:@"取消"
                                 otherButtonTitles:@"更新", nil];
            alert.tag = 1;
            [alert show];
        } else {
            [AppUtilities showHUD:@"当前已是最新版本" andView:self.view];
        }
    } else {
        [AppUtilities showHUD:@"当前无网络连接" andView:self.view];
    }
}
- (void)showAboutView {
    AboutUsViewController *controller =
        [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController"
                                                bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - IBAction Method
- (void)modifyProfile {

    SelfInfoViewController *controller = [[SelfInfoViewController alloc]
        initWithNibName:@"SelfInfoViewController"
                 bundle:nil];

    [self.navigationController pushViewController:controller animated:YES];
}
- (void)feedback {
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==
        UIUserInterfaceIdiomPhone) {
        [MobClick beginLogPageView:@"Feedback"];
        [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY_IPHONE];
        [MobClick endLogPageView:@"Feedback"];

    } else {
        [UMFeedback showFeedback:self withAppkey:UMENG_APPKEY_IPAD];
    }
}

- (void)evaluate {
    NSURL *url = [NSURL URLWithString:KAIKEBA_APPSTORE_URL];
    [[UIApplication sharedApplication] openURL:url];
}
//登出
- (void)logout {

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    if ([KKBUserInfo shareInstance].isLogin) {
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:[NSString stringWithFormat:@"是否注销？"]
                      message:nil
                     delegate:self
            cancelButtonTitle:@"确定"
            otherButtonTitles:@"取消", nil];
        alert.tag = 2;
        [alert show];
    } else {
        RegisterViewController *controller = nil;

        controller = [[RegisterViewController alloc]
            initWithNibName:@"RegisterViewController"
                     bundle:nil];

        controller.isFromRigthView = YES;

        [self.navigationController pushViewController:controller animated:YES];
        controller.registView.hidden = YES;
    }
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {

    return ((NSArray *)dataSource[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"settingsCell";

    UITableViewCell *cell = (UITableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    if (!cell) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text =
        ((NSArray *)dataSource[indexPath.section])[indexPath.row];

    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        // 判断开启状态
        [switchview setOn:[[LocalStorage shareInstance] pushSwitchIsOpen]];
        [switchview addTarget:self
                       action:@selector(updateSwitch:atIndexPath:)
             forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchview;
    }

    if (indexPath.section == (dataSource.count - 1)) { // last section
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = UIColorFromRGB(0xf75756);
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        [self modifyProfile];
    }
    // TODO:byzpc
    else if (indexPath.section == 1) {

    } else if (indexPath.section == 2) {

        if (indexPath.row == 0) {
            [self getUpdate];
        } else if (indexPath.row == 1) {
            [self feedback];
        } else if (indexPath.row == 2) {
            [self evaluate];
        } else if (indexPath.row == 3) {
            [self showAboutView];
        }
    } else if (indexPath.section == 3) {
        [self logout];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (G_SCREEN_HEIGHT == 480) {
    //        return 40.0f;
    //    } else
    //        return 50.0f;
    return 50.0f;
}

#pragma mark - SwitchMethod
- (void)updateSwitch:(UISwitch *)aSwitch atIndexPath:(NSIndexPath *)indexPath {
    UISwitch *selectSwitch = aSwitch;

    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([selectSwitch isOn]) {
        // 打开状态
        [[LocalStorage shareInstance] setPushSwitchStatus:YES];
        DDLogDebug(@"push is on");
        [appDelegate startSdkWith:KKBGETUIAPPID
                           appKey:KKBGETUIAPPKEY
                        appSecret:KKBGETUIAPPSECRET];
    } else {
        // 关闭状态
        [[LocalStorage shareInstance] setPushSwitchStatus:NO];
        [appDelegate stopSdk];
        DDLogDebug(@"push is off");
    }
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        switch (buttonIndex) {
        case 0: {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager
                    removeItemAtPath:[AppUtilities getTokenJSONFilePath]
                               error:nil]) {
                AppDelegate *appDelegate = APPDELEGATE;
                [appDelegate isiPhoneLoginSuccess:NO];
            }
            // PUSH
            NSString *clientId = [KKBUserInfo shareInstance].geTuiClientId;
            if (clientId != nil) {
                [[KKBUploader sharedInstance]
                    bufferPushNotificationInfoWithUserID:@""
                                                clientID:clientId
                                               userEmail:@""];
                [[KKBUploader sharedInstance] startUpload];
            }

            [[NSURLCache sharedURLCache] removeAllCachedResponses];

            // pasue all download Task
            [KKBDownloadManager pauseAllDownloadingTaskInQueue];

        } break;
        case 1: {

        } break;
        }
    } else if (alertView.tag == 1) {
        switch (buttonIndex) {
        case 0: {

        } break;
        case 1: {
            NSURL *url = [NSURL URLWithString:KAIKEBA_APPSTORE_URL];
            [[UIApplication sharedApplication] openURL:url];
        } break;
        }
    }
}

#pragma mark - Life Cycle Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
