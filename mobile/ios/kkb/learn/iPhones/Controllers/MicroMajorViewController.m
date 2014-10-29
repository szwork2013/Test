//
//  SelfViewController.m
//  learn
//
//  Created by zxj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "MicroMajorViewController.h"
#import "KKBHttpClient.h"
#import "MiniMajorViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "LocalStorage.h"

@interface MicroMajorViewController ()

@end

@implementation MicroMajorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = TabBarOnlyMode;
    }
    return self;
}

- (CGRect)baseScrollViewFrame {
    int x = 0;
    int y = gStatusBarHeight;
    int width = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - y - gTabBarHeight;

    return CGRectMake(x, y, width, height);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    majorViewArray = [[NSMutableArray alloc] init];

    baseScrollView =
        [[UIScrollView alloc] initWithFrame:[self baseScrollViewFrame]];
    baseScrollView.backgroundColor = G_TABLEVIEW_BGCKGROUND_COLOR;
    //    baseScrollView.contentSize = CGSizeMake(320, 600);
    baseScrollView.showsHorizontalScrollIndicator = NO;
    baseScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:baseScrollView];

    [[LocalStorage shareInstance] setMajorViewContentSizeHeight:0];

    UILabel *introduceLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(gScreenToCardLine, 0, gMajorCardWidth,
                                 gNavigationBarHeight)];
    introduceLabel.font = [UIFont systemFontOfSize:12];
    introduceLabel.text = @"实" @"战"
        @"为导向，就业为目的，获权威认证，揍是介么简"
        @"单！";
    introduceLabel.textAlignment = NSTextAlignmentLeft;
    introduceLabel.textColor = UIColorRGB(115, 115, 128);
    [baseScrollView addSubview:introduceLabel];

    [self requestData:YES];
    [self requestData:NO];

    AppDelegate *appDelegate =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view addSubview:[appDelegate statusBar]];

    [self.loadingFailedView setTapTarget:self
                                  action:@selector(reloadTableViewData)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [self requestData:NO];

    [self.navigationController.navigationBar setHidden:YES];

    [MobClick beginLogPageView:@"MicroCourse"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"MicroCourse"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods
- (void)initDataAndView {

    BOOL hasViews = (majorViewArray != nil && majorViewArray.count > 0);
    if ([[LocalStorage shareInstance] majorViewContentSizeHeight] == 0) {
        [baseScrollView
            setContentSize:CGSizeMake(G_SCREEN_WIDTH,
                                      microSpecialitiesArray.count * 144 +
                                          gNavigationBarHeight)];
        [[LocalStorage shareInstance]
            setMajorViewContentSizeHeight:microSpecialitiesArray.count * 144 +
                                          gNavigationBarHeight];
    } else {
        [baseScrollView
            setContentSize:
                CGSizeMake(
                    G_SCREEN_WIDTH,
                    [[LocalStorage shareInstance] majorViewContentSizeHeight])];
    }
    // i < microSpecialitiesArray.count
    for (int i = 0; i < microSpecialitiesArray.count; i++) {
        NSDictionary *aCourse = microSpecialitiesArray[i];
        NSString *course = [aCourse objectForKey:@"name"];
        NSArray *microMajors = [aCourse objectForKey:@"micro_specialties"];
        NSInteger SpecialityId = [[aCourse objectForKey:@"id"] integerValue];

        if (!hasViews) {
            /***************************** [ Views ]
             * ******************************/
            MajorViews *majorView = [[MajorViews alloc]
                   initWithFrame:CGRectMake(8, 44 + i * (128 + 16), 304, 128)
                      parentView:baseScrollView
                andSubItemsCount:microMajors.count];

            majorView.row = i;
            majorView.delegate = self;

            [[NSNotificationCenter defaultCenter]
                addObserver:majorView
                   selector:@selector(changeMajor:)
                       name:@"changeMajor"
                     object:nil];

            UILabel *courseNameLabel = (UILabel *)
                [majorView.majorView viewWithTag:MajorViewCourseNameLabelTag];
            courseNameLabel.text = course;
            [courseNameLabel setNeedsDisplay]; // redraw view

            majorView.majorViewTitle.text = course;
            majorView.majorIntroTitle.text = course;
            NSString *introContent = [[aCourse objectForKey:@"intro"]
                stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceCharacterSet]];
            majorView.majorIntroContent.text = introContent;
            //            majorView.majorIntroContent.text = [aCourse
            //            objectForKey:@"intro"];

            // bug
            [majorView.majorImageView
                sd_setImageWithURL:
                    [NSURL URLWithString:[aCourse objectForKey:@"img_url"]]];

            [majorViewArray addObject:majorView];

            /***************************** [ Data ]
             * ******************************/
            for (int j = 0; j < microMajors.count; j++) {
                NSDictionary *aMicroMajor = microMajors[j];
                NSString *microMajorName = [aMicroMajor objectForKey:@"name"];
                NSUInteger microMajorId =
                    [[aMicroMajor objectForKey:@"id"] intValue];

                UIView *aSubView = (UIView *)majorView.subMajorViews[j];
                aSubView.tag = SpecialityId * 10 + microMajorId;
                UILabel *aTitleLabel = (UILabel *)
                    [aSubView viewWithTag:(MicroMajorCourseTitleLabelTag + j)];

                aTitleLabel.text = microMajorName;
                [aTitleLabel setNeedsDisplay]; // redraw view

                UILabel *subTitleLabel = [[aSubView subviews] objectAtIndex:2];
                subTitleLabel.text = [aMicroMajor objectForKey:@"name"];
                UILabel *subCourseLabel = [[aSubView subviews] objectAtIndex:3];
                NSArray *subCourseArray = [aMicroMajor objectForKey:@"courses"];
                //                NSString *string = [subCourseArray
                //                componentsJoinedByString:@"、"];
                NSMutableArray *subCourseNameArray =
                    [[NSMutableArray alloc] init];
                for (NSDictionary *courseDict in subCourseArray) {
                    [subCourseNameArray
                        addObject:[NSString
                                      stringWithFormat:
                                          @"《%@》",
                                          [courseDict objectForKey:@"name"]]];
                }
                subCourseLabel.text =
                    [subCourseNameArray componentsJoinedByString:@"、"];
            }
        } else { // 已经创建了视图的话，则找到相应的视图，然后赋值并刷新
                 /***************************** [ Views ]
                  * ******************************/
            MajorViews *majorView = majorViewArray[i];

            UILabel *courseNameLabel = (UILabel *)
                [majorView.majorView viewWithTag:MajorViewCourseNameLabelTag];
            courseNameLabel.text = course;
            [courseNameLabel setNeedsDisplay]; // redraw view

            /***************************** [ Data ]
             * ******************************/
            for (int j = 0; j < microMajors.count; j++) {
                NSDictionary *aMicroMajor = microMajors[j];
                NSString *microMajorName = [aMicroMajor objectForKey:@"name"];
                NSUInteger microMajorId =
                    [[aMicroMajor objectForKey:@"id"] intValue];

                UIView *aSubView = (UIView *)majorView.subMajorViews[j];
                aSubView.tag = SpecialityId * 10 + microMajorId;
                UILabel *aTitleLabel = (UILabel *)
                    [aSubView viewWithTag:(MicroMajorCourseTitleLabelTag + j)];

                aTitleLabel.text = microMajorName;
                [aTitleLabel setNeedsDisplay]; // redraw view
            }
        }
    }
}

- (void)requestData:(BOOL)fromCache {
    if (fromCache) {
        [self.loadingView showInView:self.view];
    }
    NSString *jsonForSpecialty =
        [NSString stringWithFormat:@"v1/specialty/user"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForSpecialty
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            microSpecialitiesArray = result;

            [self initDataAndView];
            if (fromCache) {

                [self.loadingView hideView];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            if (fromCache) {
                [self.view bringSubviewToFront:self.loadingFailedView];
                [self.loadingView hideView];
                [self.loadingFailedView show];
            }
        }];
}

- (CGRect)loadingViewFrame {
    int x = 0;
    int y = gStatusBarHeight;
    int widht = self.view.frame.size.width;
    int height = self.view.frame.size.height - y - gTabBarHeight;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (void)reloadTableViewData {

    [self.loadingView showInView:self.view];
    [self.loadingFailedView hide];

    [self requestData:YES];
}

#pragma mark - MiniMajorDelegate Methods
- (void)miniMajorViewDidSelect:(UIView *)miniView {
    MiniMajorViewController *controller = [[MiniMajorViewController alloc]
        initWithNibName:@"MiniMajorViewController"
                 bundle:nil];
    NSString *speId = [NSString stringWithFormat:@"%d", miniView.tag / 10];
    NSString *microId = [NSString stringWithFormat:@"%d", miniView.tag % 10];

    for (NSDictionary *majorDict in microSpecialitiesArray) {

        if ([[[majorDict objectForKey:@"id"] stringValue]
                isEqualToString:speId]) {

            NSArray *microSpecialtiesArray =
                [majorDict objectForKey:@"micro_specialties"];

            for (NSDictionary *microMajorDict in microSpecialtiesArray) {
                if ([[[microMajorDict objectForKey:@"id"] stringValue]
                        isEqualToString:microId]) {
                    controller.currentMajor = microMajorDict;
                }
            }
        }
    }

    [self.navigationController pushViewController:controller animated:YES];
    //    controller.majorId = [NSString stringWithFormat:@"%ld",
    //    (long)miniView.tag];
}

- (void)miniMajorViewDidMove:(UIView *)miniView {
    // 动态改变scrollView的contentSize属性

    int scrollViewContentSizeHeight = gNavigationBarHeight;
    for (MajorViews *majorView in majorViewArray) {
        if (majorView.opened) {
            scrollViewContentSizeHeight += gMajorCardOpenHeight;
            scrollViewContentSizeHeight +=
                (majorView.subItemsCount * gMicroMajorInfoHeight);
            scrollViewContentSizeHeight += gMajorCardsSpaceHeight;
        } else {
            scrollViewContentSizeHeight += gMajorCardClosePlusSpaceHeight;
        }
    }

    [baseScrollView
        setContentSize:CGSizeMake(G_SCREEN_WIDTH, scrollViewContentSizeHeight)];
    [[LocalStorage shareInstance]
        setMajorViewContentSizeHeight:scrollViewContentSizeHeight];
}

@end
