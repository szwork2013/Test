//
//  MyMicroMajorViewController.m
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MyMicroMajorViewController.h"
#import "KKBUserInfo.h"
#import "GlobalOperator.h"
#import "KKBHttpClient.h"
#import "UIImageView+WebCache.h"
#import "MyMicroMajorCell.h"
#import "MiniMajorViewController.h"
#import "GuideCourseViewController.h"
#import "PublicClassViewController.h"
#import "MyMicroMajorFooterView.h"
#import "MobClick.h"

static CGFloat const coolStartImageOriginY = 122;
static CGFloat const coolStartLabelOriginY = 250;
static CGFloat const indicatorImageWidth = 48;
static CGFloat const indicatorImageHeight = 16;
static CGFloat const myMicroMajorHeadViewHeight = 44;

@interface MyMicroMajorViewController () {
    UIView *_coolStartView;
    NSArray *microSpecialitiesArray;
}

@end

@implementation MyMicroMajorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Custom Methods
- (void)initCoolStartView {
    _coolStartView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                 G_SCREEN_HEIGHT - gNavigationBarHeight)];

    [self.view addSubview:_coolStartView];

    _coolStartView.backgroundColor = UIColorRGBTheSame(240);

    UIImageView *coolStartImageView = [[UIImageView alloc]
        initWithFrame:CGRectMake(gCoolStartImageOriginX, coolStartImageOriginY,
                                 gCoolStartImageOriginWidth,
                                 gCoolStartImageOriginHeight)];
    [coolStartImageView setImage:[UIImage imageNamed:@"icon_box"]];
    [_coolStartView addSubview:coolStartImageView];

    UILabel *coolStartLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(0, coolStartLabelOriginY, G_SCREEN_WIDTH,
                                 gCoolStartLabelHeight)];
    coolStartLabel.textAlignment = NSTextAlignmentCenter;
    coolStartLabel.font = [UIFont systemFontOfSize:16];
    coolStartLabel.textColor = UIColorRGB(125, 125, 128);
    coolStartLabel.text = @"你的课程表是空的耶~";
    [_coolStartView addSubview:coolStartLabel];

    _coolStartView.hidden = YES;
}

- (void)initHeadView {
    if (myMicroMajorArray == nil || [myMicroMajorArray count] == 0) {
        return;
    }
    NSDictionary *dic = [myMicroMajorArray objectAtIndex:0];
    headView.majorNameLabel.text = [dic objectForKey:@"name"];
    NSString *imageUrl = [dic objectForKey:@"image_url"];
    [headView.headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void)requestDataFromCache:(BOOL)FromCache {
    if (FromCache) {
        [self.loadingView showInView:self.view];
    }
    NSString *urlPath =
        [NSString stringWithFormat:@"v1/micro_specialties/user"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:FromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSArray *microMajorArray = result;
            [myMicroMajorArray removeAllObjects];
            for (NSDictionary *microMajorDict in microMajorArray) {
                if ([[microMajorDict
                        objectForKey:@"join_status"] integerValue] == 1) {
                    [myMicroMajorArray addObject:microMajorDict];
                }
            }

            if (myMicroMajorArray.count == 0) {
                _coolStartView.hidden = NO;
            } else {
                _coolStartView.hidden = YES;
            }
            [self initHeadView];
            [self.tableView reloadData];

            if (FromCache) {
                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (FromCache) {
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

- (void)requestMicroMajorsData:(BOOL)fromCache {

    NSString *jsonForSpecialty =
        [NSString stringWithFormat:@"v1/specialty/user"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForSpecialty
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            microSpecialitiesArray = result;
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
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

- (void)reloadTableViewDataWhenFailed {

    [self.loadingFailedView hide];
    [self.loadingView showInView:self.view];

    [self requestDataFromCache:YES];
}

- (void)pushToMicroMajorDetailPage:(NSInteger)section {
    MiniMajorViewController *controller =
        [[MiniMajorViewController alloc] init];

    NSDictionary *targetSectionDictionary = myMicroMajorArray[section];
    NSString *position =
        [[targetSectionDictionary objectForKey:@"id"] stringValue];

    for (NSDictionary *majorDict in microSpecialitiesArray) {

        NSArray *microSpecialities =
            (NSArray *)[majorDict objectForKey:@"micro_specialties"];
        for (NSDictionary *dict in microSpecialities) {

            NSString *tempPosition = [[dict objectForKey:@"id"] stringValue];
            BOOL found = [position isEqualToString:tempPosition];
            if (found) {

                controller.currentMajor = dict;
            }
        }
    }

    if (controller.currentMajor != nil) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - HeadViewDelegate Methods
- (void)headerViewDidSelectInSection:(NSInteger)section {

    [self pushToMicroMajorDetailPage:section];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return myMicroMajorArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [myMicroMajorArray objectAtIndex:section];
    NSArray *courseArray = [dic objectForKey:@"courses"];

    return courseArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identify = @"MyCollectionCell";
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:identify];

        cell.accessoryType = UITableViewCellAccessoryNone;

        UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backView;
        cell.selectedBackgroundView.backgroundColor =
            [UIColor tableViewCellSelectedColor];
    }

    NSDictionary *dic = [myMicroMajorArray objectAtIndex:indexPath.section];
    NSArray *courseArray1 = [dic objectForKey:@"courses"];
    NSDictionary *courseDic = [NSDictionary dictionary];
    if (indexPath.row < courseArray1.count) {
        courseDic = [courseArray1 objectAtIndex:indexPath.row];
    }
    NSString *courseName = [courseDic objectForKey:@"name"];
    NSString *courseId = [courseDic objectForKey:@"id"];
    cell.textLabel.text = courseName;

    NSDictionary *learnStatusDict =
        (NSDictionary *)[dic objectForKey:@"learn_status"];

    int learnStatus = [[learnStatusDict
        objectForKey:[NSString stringWithFormat:@"%@", courseId]] integerValue];

    UIImageView *indicator =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, indicatorImageWidth,
                                                      indicatorImageHeight)];
    indicator.contentMode = UIViewContentModeRight;
    cell.accessoryView = indicator;

    if (learnStatus == 0) {
        indicator.image = [UIImage imageNamed:@"task_button_finish"];
        cell.accessoryView = indicator;
    } else if (learnStatus == 1) {
        indicator.image = [UIImage imageNamed:@"task_button_unfinished2"];
        cell.accessoryView = indicator;
    } else if (learnStatus == 2) {
        indicator.image = [UIImage imageNamed:@"mic_pro_button_willbegin_dis"];
        cell.accessoryView = indicator;
        [cell.textLabel setTextColor:[UIColor grayColor]];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }

    if (indexPath.row == courseArray1.count) {
        MyMicroMajorCell *lastCell =
            [[[NSBundle mainBundle] loadNibNamed:@"MyMicroMajorCell"
                                           owner:self
                                         options:nil] lastObject];

        lastCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return lastCell;
    } else {
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = [myMicroMajorArray objectAtIndex:indexPath.section];
    NSArray *courseArray = [dic objectForKey:@"courses"];
    if (courseArray.count > indexPath.row) {
        NSDictionary *dic1 = [courseArray objectAtIndex:indexPath.row];

        if ([[dic1 objectForKey:@"type"]
                isEqualToString:@"InstructiveCourse"]) {
            GuideCourseViewController *guideCourse =
                [[GuideCourseViewController alloc] init];
            guideCourse.courseId = [dic1 objectForKey:@"id"];
            [self.navigationController pushViewController:guideCourse
                                                 animated:YES];
        } else {
            PublicClassViewController *public =
                [[PublicClassViewController alloc] init];
          public
            .currentCourse = dic1;
            [self.navigationController pushViewController:public animated:YES];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    MyMicroMajorHeadView *view = [[MyMicroMajorHeadView alloc]
        initWithFrame:CGRectMake(0, 20, gMajorCardWidth,
                                 myMicroMajorHeadViewHeight)];
    view.delegate = self;
    view.section = section;

    NSDictionary *dic = [myMicroMajorArray objectAtIndex:section];
    view.majorNameLabel.text = [dic objectForKey:@"name"];
    view.progressLabel.text = [dic objectForKey:@"learn_progress"];

    if (section == 0) {
        UIView *view1 = [[UIView alloc]
            initWithFrame:CGRectMake(0, 0, gMajorCardWidth, 64)];
        [view1 setBackgroundColor:[UIColor clearColor]];
        [view1 addSubview:view];
        return view1;
    }

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 64;
    }
    return 44;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    myMicroMajorArray = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"我的微专业";
    [self.navigationController.navigationBar setHidden:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initCoolStartView];

    [self requestDataFromCache:YES];
    [self requestDataFromCache:NO];

    [self requestMicroMajorsData:YES];
    [self requestMicroMajorsData:NO];

    [self.view setBackgroundColor:UIColorFromRGB(0xf0f0f0)];

    [self.loadingFailedView
        setTapTarget:self
              action:@selector(reloadTableViewDataWhenFailed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"MyMicroCourse"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"MyMicroCourse"];
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
