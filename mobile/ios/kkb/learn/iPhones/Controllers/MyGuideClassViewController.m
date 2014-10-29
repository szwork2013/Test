//
//  MyGuideClassViewController.m
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MyGuideClassViewController.h"
#import "KKBHttpClient.h"
#import "MyPublicClassCell.h"
#import "KKBUserInfo.h"
#import "UIImageView+WebCache.h"
#import "MyGuideClassCell.h"
#import "KCourseItem.h"
#import "GuideCourseEnrolledViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GuideCourseEnrolledViewController.h"

#import "MobClick.h"

#define TableViewCellHeight 94

@interface MyGuideClassViewController () {
    UIView *_coolStartView;

    BOOL isProgressHidden;
    BOOL isWillHidden;
    BOOL isDoneHidden;
}

@end

@implementation MyGuideClassViewController

#pragma mark - Custom Methods
- (void)requestData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    isProgressingArray = [[NSMutableArray alloc] init];
    doneArray = [[NSMutableArray alloc] init];
    willArray = [[NSMutableArray alloc] init];

    NSString *urlPath = [NSString stringWithFormat:@"v1/instructive_courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            myGuideClassArray = result;
            [isProgressingArray removeAllObjects];
            [doneArray removeAllObjects];
            [willArray removeAllObjects];

            for (NSDictionary *dic in myGuideClassArray) {
                if ([[dic objectForKey:@"number"] integerValue] == -2) {
                    [willArray addObject:dic];
                } else if ([[dic objectForKey:@"number"] integerValue] == -1) {
                    [doneArray addObject:dic];
                } else {
                    [isProgressingArray addObject:dic];
                }
            }
            if (isProgressingArray.count == 0) {
                isProgressHidden = NO;
                _coolStartView.hidden = NO;
            } else {
                isProgressHidden = YES;
                _coolStartView.hidden = YES;
            }
            if (willArray.count == 0) {
                isWillHidden = NO;
                //                _coolStartView.hidden = NO;
            } else {
                isWillHidden = YES;
                //                _coolStartView.hidden = YES;
            }
            if (doneArray.count == 0) {
                isDoneHidden = NO;
                //                _coolStartView.hidden = NO;
            } else {
                isDoneHidden = YES;
                //                _coolStartView.hidden = YES;
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

- (NSString *)getRatingStar:(int)ratingCount {
    if (ratingCount == 0) {
        return nil;
    } else {
        NSMutableString *rateString = [[NSMutableString alloc] init];

        float count = ceilf(ratingCount / 2.0f);
        for (int i = 0; i < count; i++) {
            [rateString appendString:@"★"];
        }

        return rateString;
    }
}

- (IBAction)segmentAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        isProgressing = YES;
        done = NO;
        will = NO;
        if (isProgressHidden == YES) {
            _coolStartView.hidden = YES;
        } else {
            _coolStartView.hidden = NO;
        }

    } else if (sender.selectedSegmentIndex == 1) {
        done = YES;
        isProgressing = NO;
        will = NO;
        if (isDoneHidden == YES) {
            _coolStartView.hidden = YES;
        } else {
            _coolStartView.hidden = NO;
        }

    } else {
        will = YES;
        isProgressing = NO;
        done = NO;
        if (isWillHidden == YES) {
            _coolStartView.hidden = YES;
        } else {
            _coolStartView.hidden = NO;
        }
    }
    [self.tableView reloadData];
}

- (KCourseItem *)model:(NSDictionary *)aCourseDict {
    NSString *name = [aCourseDict objectForKey:@"name"];
    NSString *imageUrl = [aCourseDict objectForKey:@"cover_image"];
    NSUInteger weeks = [[aCourseDict objectForKey:@"weeks"] intValue];
    NSUInteger viewCount = [[aCourseDict objectForKey:@"view_count"] intValue];
    NSString *type = [aCourseDict objectForKey:@"type"];
    NSUInteger rating = [[aCourseDict objectForKey:@"rating"] intValue];
    NSString *ratingText = [self getRatingStar:rating];
    CGFloat covertRating = rating / 2.0;
    if (covertRating > 5) {
        covertRating = 5;
    }

    NSUInteger updatedTo =
        [[aCourseDict objectForKey:@"updated_amount"] intValue];
    NSString *other =
        [NSString stringWithFormat:@"更新至第%d节视频", updatedTo];
    NSString *courseId = [aCourseDict objectForKey:@"id"];

    NSString *courseIntro = [aCourseDict objectForKey:@"intro"];
    NSString *courseLevel = [aCourseDict objectForKey:@"level"];
    NSString *keyWord = [aCourseDict objectForKey:@"slogan"];
    NSString *coverImage = [aCourseDict objectForKey:@"cover_image"];
    NSString *videoUrl = [aCourseDict objectForKey:@"promotional_video_url"];

    int courseType = ([type isEqualToString:@"OpenCourse"] ? 0 : 1);
    KCourseItem *aCourseItem = [[KCourseItem alloc] init:imageUrl
                                                    name:name
                                                duration:weeks
                                       learnTimeEachWeek:3
                                                    vote:ratingText
                                           learnerNumber:viewCount
                                                    type:courseType
                                                courseId:courseId
                                                   other:other
                                             courseIntro:courseIntro
                                             courseLevel:courseLevel
                                                 keyWord:keyWord
                                              coverImage:coverImage
                                                videoUrl:videoUrl];
    aCourseItem.rating = covertRating;
    return aCourseItem;
}

- (void)reloadSelfViewData {

    [self.loadingFailedView hide];
    [self.loadingView showInView:self.view];

    [self requestData:YES];
}

- (void)initCoolStartView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 54, 320, G_SCREEN_HEIGHT - 44)];

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

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isProgressing) {
        return isProgressingArray.count;
    } else if (done) {
        return doneArray.count;
    } else {
        return willArray.count;
    }
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identify = @"MyGuideClassCell";
    MyGuideClassCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identify];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyGuideClassCell"
                                              owner:self
                                            options:nil] lastObject];
    }

    cell.layer.cornerRadius = 2.0f;
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.layer.masksToBounds = YES;

    NSDictionary *dic = nil;
    if (isProgressing) {
        dic = [isProgressingArray objectAtIndex:indexPath.section];
    } else if (done) {
        dic = [doneArray objectAtIndex:indexPath.section];
    } else {
        dic = [willArray objectAtIndex:indexPath.section];
    }
    if ([[dic objectForKey:@"weeks"] isKindOfClass:[NSNull class]] ||
        [dic objectForKey:@"weeks"] == nil) {
        cell.textLabel1.text = @"";
    } else {
        cell.textLabel1.text = [[dic objectForKey:@"weeks"] stringValue];
    }
    cell.courseNameLabel.text = [dic objectForKey:@"name"];

    NSString *imageUrl = [dic objectForKey:@"cover_image"];
    [cell.courseImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];

    cell.courseImageView.layer.cornerRadius = 2.0f;
    cell.courseImageView.layer.borderWidth = 0.5f;
    cell.courseImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.courseImageView.layer.masksToBounds = YES;

    NSNumber *updateNum = [dic objectForKey:@"number"];
    NSNumber *totalNum = [dic objectForKey:@"weeks"];
    cell.textLabel1.text = [NSString stringWithFormat:@"%@周", totalNum];
    if ([updateNum intValue] > 0) {
        cell.textLabel2.text =
            [NSString stringWithFormat:@"已更新至第%@周", updateNum];
    } else if ([updateNum intValue] == -2) {
        // 即将开课
        NSNumber *min_duration = [dic objectForKey:@"min_duration"];
        NSNumber *max_duration = [dic objectForKey:@"max_duration"];
        if ([min_duration intValue] == [max_duration intValue]) {
            cell.textLabel2.text =
                [NSString stringWithFormat:@"每周%@小时", min_duration];
        } else {
            cell.textLabel2.text =
                [NSString stringWithFormat:@"每周%@-%@小时", min_duration,
                                           max_duration];
        }
    } else if ([updateNum intValue] == -1) {
        // 已结课
        cell.textLabel1.hidden = YES;
        cell.textLabel2.hidden = YES;
        UIView *view = [cell viewWithTag:100];
        view.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = nil;
    GuideCourseEnrolledViewController *guideCourseCtr =
        [[GuideCourseEnrolledViewController alloc] init];

    if (isProgressing) {
        dic = [isProgressingArray objectAtIndex:indexPath.section];
    } else if (done) {
        dic = [doneArray objectAtIndex:indexPath.section];
    } else {
        dic = [willArray objectAtIndex:indexPath.section];
    }

    guideCourseCtr.courseId = [dic objectForKey:@"id"];
    guideCourseCtr.courseNumberOfWeeks = [dic objectForKey:@"number"];
    guideCourseCtr.classId =
        [[[dic objectForKey:@"courses_lms"] objectForKey:@"id"] stringValue];
    [self.navigationController pushViewController:guideCourseCtr animated:YES];
}

- (float)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

#pragma mark - UINavigationController Delegate Method
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
    self.navigationItem.title = @"我的导学课";
    [self initCoolStartView];
    isProgressing = YES;

    [self requestData:YES];
    [self requestData:NO];
    [self.navigationController.navigationBar setHidden:NO];

    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

    [_segmentedControl setFrameHeight:29];

    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadSelfViewData)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"MyGuideCourse"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"MyGuideCourse"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
