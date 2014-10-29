//
//  MyPublicClass.m
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MyPublicClassViewController.h"
#import "KKBHttpClient.h"
#import "MyPublicClassCell.h"
#import "KKBUserInfo.h"
#import "UIImageView+WebCache.h"
#import "PublicClassViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MobClick.h"
#import "KKBLoadingFailedView.h"

#define TableViewCellHeight 94

@interface MyPublicClassViewController () {
    UIView *_coolStartView;
    KKBLoadingFailedView *loadingFailedView;
}
@end

@implementation MyPublicClassViewController

#pragma mark - Custom Methods
- (void)requestData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    NSString *urlPath = [NSString stringWithFormat:@"v1/open_courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            myPublicArray = result;
            if (myPublicArray.count == 0) {
                _coolStartView.hidden = NO;
            } else {
                _coolStartView.hidden = YES;
            }
            [self.tableView reloadData];

            if (fromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

- (void)initCoolStartView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, 320, G_SCREEN_HEIGHT - 44)];

    [self.view addSubview:_coolStartView];
    _coolStartView.backgroundColor = [UIColor colorWithRed:240 / 256.0
                                                     green:240 / 256.0
                                                      blue:240 / 256.0
                                                     alpha:1];

    UIImageView *coolStartImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(80, 122, 160, 120)];
    [coolStartImageView setImage:[UIImage imageNamed:@"icon_box"]];
    [_coolStartView addSubview:coolStartImageView];

    UILabel *coolStartLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 280, 16)];
    coolStartLabel.textAlignment = NSTextAlignmentCenter;
    coolStartLabel.font = [UIFont systemFontOfSize:16];
    coolStartLabel.textColor = [UIColor colorWithRed:125 / 256.0
                                               green:125 / 256.0
                                                blue:128 / 256.0
                                               alpha:1];
    coolStartLabel.text = @"你的课程表是空的耶~";
    [_coolStartView addSubview:coolStartLabel];

    _coolStartView.hidden = YES;
}

- (void)reloadTableViewData {
    [self.loadingView showInView:self.view];
    [loadingFailedView setHidden:YES];

    [self requestData:YES];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return myPublicArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    if (section == myPublicArray.count - 1) {
        return 12;
    } else {
        return 11;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 12;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identify = @"MyPublicClassCell";
    MyPublicClassCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identify];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyPublicClassCell"
                                              owner:self
                                            options:nil] lastObject];
    }

    cell.layer.cornerRadius = 2.0f;
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.layer.masksToBounds = YES;

    NSDictionary *dic = [myPublicArray objectAtIndex:indexPath.section];

    cell.courseName.text = [dic objectForKey:@"name"];

    NSString *imageUrl = [dic objectForKey:@"cover_image"];

    [cell.courseImageView
        sd_setImageWithURL:[NSURL URLWithString:imageUrl]
          placeholderImage:[UIImage imageNamed:@"allcourse_cover_default"]];

    cell.courseImageView.layer.cornerRadius = 2.0f;
    cell.courseImageView.layer.borderWidth = 0.5f;
    cell.courseImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.courseImageView.layer.masksToBounds = YES;

    NSNumber *updateNum = [dic objectForKey:@"updated_amount"];

    cell.UpdateLabel.text =
        [NSString stringWithFormat:@"更新至第%@节", updateNum];

    NSNumber *viewNum = [dic objectForKey:@"number"];
    if ([viewNum intValue] == 0) {
        [cell.watchLabel setHidden:YES];
    } else {
        cell.watchLabel.text =
            [NSString stringWithFormat:@"观看至第%@节", viewNum];
    }
    return cell;
}

- (float)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PublicClassViewController *public =
        [[PublicClassViewController alloc] init];

    NSNumber *courseID =
        [[myPublicArray objectAtIndex:indexPath.section] objectForKey:@"id"];
    [KKBCourseManager
          getCourseWithID:courseID
              forceReload:NO
        completionHandler:^(id model, NSError *error) {
          public
            .currentCourse = model;
            [self.navigationController pushViewController:public animated:YES];
        }];
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - viewDidLoad
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setHeight:G_SCREEN_HEIGHT - 84];
    self.navigationItem.title = @"我的公开课";
    [self initCoolStartView];

    loadingFailedView = [[KKBLoadingFailedView alloc]
        initWithFrame:CGRectMake(0, 0, 320, G_SCREEN_HEIGHT - 64)];
    [loadingFailedView setHidden:YES];
    [loadingFailedView setTapTarget:self action:@selector(reloadTableViewData)];
    [self.view addSubview:loadingFailedView];
    loadingFailedView.hidden = YES;

    [self requestData:YES];
    [self requestData:NO];
    [self.navigationController.navigationBar setHidden:NO];

    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"MyOpenCourse"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"MyOpenCourse"];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView
        setFrameHeight:G_SCREEN_HEIGHT - gNavigationAndStatusHeight];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
