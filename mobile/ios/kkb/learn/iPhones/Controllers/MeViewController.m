//
//  MeViewController.m
//  learn
//
//  Created by zxj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MeViewController.h"
#import "KKBUserInfo.h"
#import "KKBHttpClient.h"
#import "UIImageView+AFNetworking.h"
#import "DownloadManagerViewController.h"
#import "SettingViewController.h"
#import "GlobalDefine.h"
#import "SelfCenterViewController.h"
#import "MyCollectionViewController.h"
#import "GlobalOperator.h"
#import "MyMicroMajorViewController.h"
#import "AppDelegate.h"
#import "GuideCourseViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "MyPublicClassViewController.h"
#import "MyGuideClassViewController.h"
#import "UIImageView+WebCache.h"
#import "AppUtilities.h"
#import "MobClick.h"
#import "KKBDownloadControlViewController.h"

#define TableViewCellHeight 50

static const CGFloat imageBackgroundViewHeight = 164;
static const CGFloat sectionSpace = 16;
static const CGFloat sectionSpaceToTopView = 15;

@interface MeViewController () {
    NSArray *courseSectionArray;
    NSArray *courseSectionIconArray;
    NSDictionary *userDic;
}

@end

@implementation MeViewController

@synthesize profileImageView;
@synthesize profileNameLabel;

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
    self.tableView.showsVerticalScrollIndicator = NO;
    self.view.backgroundColor = UIColorRGBTheSame(240);

    self.automaticallyAdjustsScrollViewInsets = NO;

    NSArray *section0 = [NSArray arrayWithObjects:@"下载中心", nil];

    NSArray *section2 =
        [NSArray arrayWithObjects:@"我的微专业", @"我的公开课",
                                  @"我的导学课", @"收藏的课程", nil];
    NSArray *section3 = [NSArray arrayWithObjects:@"设置", nil];

    courseSectionArray =
        [NSArray arrayWithObjects:section0, section2, section3, nil];

    NSArray *iconSection0 =
        [NSArray arrayWithObjects:@"kkb-iphone-me-downloadcenter", nil];

    NSArray *iconSection2 =
        [NSArray arrayWithObjects:@"icon_micro", @"icon_open", @"icon_ins",
                                  @"icon_collection", nil];
    NSArray *iconSection3 = [NSArray arrayWithObjects:@"icon_setting", nil];
    courseSectionIconArray = [NSArray
        arrayWithObjects:iconSection0, iconSection2, iconSection3, nil];

    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view addSubview:[appDelegate statusBar]];

    profileNameLabel.text = [KKBUserInfo shareInstance].userName;

    if ([KKBUserInfo shareInstance].avatar_url == nil) {
        [profileImageView setImage:[UIImage imageNamed:@"mine_head_user"]];
    } else {
        [profileImageView
            sd_setImageWithURL:[NSURL URLWithString:[KKBUserInfo shareInstance]
                                                        .avatar_url]
              placeholderImage:[UIImage imageNamed:@"mine_head_user"]];
    }

    [self listenToProfileModificationNotification];
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidLayoutSubviews {
    self.tableView.frame =
        CGRectMake(0, imageBackgroundViewHeight + gStatusBarHeight,
                   G_SCREEN_WIDTH, G_SCREEN_HEIGHT - imageBackgroundViewHeight -
                                       gStatusBarHeight - gTabBarHeight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [self.navigationController.navigationBar setHidden:YES];

    [MobClick beginLogPageView:@"UserCenter"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"UserCenter"];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Custom Methods
- (void)listenToProfileModificationNotification {

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(notificationDidReceive)
               name:NotificationProfileDidModify
             object:nil];
}

- (void)notificationDidReceive {

    profileNameLabel.text = [KKBUserInfo shareInstance].userName;
    [profileImageView
        sd_setImageWithURL:[NSURL URLWithString:[KKBUserInfo shareInstance]
                                                    .avatar_url]
          placeholderImage:[UIImage imageNamed:@"mine_head_user"]];
}
#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return courseSectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {

    return ((NSArray *)courseSectionArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:SimpleTableIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text =
        ((NSArray *)courseSectionArray[indexPath.section])[indexPath.row];
    cell.imageView.image =
        [UIImage imageNamed:((NSArray *)courseSectionIconArray
                                 [indexPath.section])[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return sectionSpace;
    } else {
        return sectionSpaceToTopView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return sectionSpace;
    } else {
        return sectionSpace - sectionSpaceToTopView;
    }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SettingViewController *setCtr = [[SettingViewController alloc] init];

    MyCollectionViewController *myCollection =
        [[MyCollectionViewController alloc]
            initWithNibName:@"MyCollectionViewController"
                     bundle:nil];
    MyMicroMajorViewController *myMicroMajor =
        [[MyMicroMajorViewController alloc]
            initWithNibName:@"MyMicroMajorViewController"
                     bundle:nil];
    MyPublicClassViewController *myPublicClass =
        [[MyPublicClassViewController alloc] init];
    MyGuideClassViewController *myGuideClass =
        [[MyGuideClassViewController alloc] init];

    if (indexPath.section == 0) {
        KKBDownloadControlViewController *downloadViewController =
            [[KKBDownloadControlViewController alloc] init];

        [self.navigationController pushViewController:downloadViewController
                                             animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:myMicroMajor
                                                 animated:YES];
        } else if (indexPath.row == 1) {
            [self.navigationController pushViewController:myPublicClass
                                                 animated:YES];
        } else if (indexPath.row == 2) {
            [self.navigationController pushViewController:myGuideClass
                                                 animated:YES];
        } else if (indexPath.row == 3) {
            [self.navigationController pushViewController:myCollection
                                                 animated:YES];
        }
    } else if (indexPath.section == 2) {
        [self.navigationController pushViewController:setCtr animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

@end
