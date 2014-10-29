//
//  SearchCourseViewController.m
//  learn
//
//  Created by guojun on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "SearchCourseViewController.h"
#import "KKBSearchFailedView.h"

static const CGFloat SearchFailedViewOriginY = 68.0f;

@interface SearchCourseViewController () {

    NSArray *searchRecords;
    KKBSearchView *searchBarView;

    IFlyRecognizerView *iFlyRecognizerView;
    KKBSearchFailedView *searchFailedView;
}

@end

@implementation SearchCourseViewController

#pragma mark - Custom Methods
- (void)initSearchBar {

    searchBarView = [[KKBSearchView alloc] initWithSearchList:searchRecords
                                                  andDelegate:self];

    [searchBarView.searchTextField becomeFirstResponder];
}

- (void)getSearchRecordsFromDB {
    searchRecords = [[LocalStorage shareInstance] getSearchRecords];
}

- (void)addSearchBar {
    [self getSearchRecordsFromDB];
    [self initSearchBar];
    [self.view addSubview:searchBarView];
}

- (void)initVoiceReconizer {

    NSString *initString =
        [[NSString alloc] initWithFormat:@"appid=%@", @"53c7c41d"];
    [IFlySpeechUtility createUtility:initString];

    iFlyRecognizerView =
        [[IFlyRecognizerView alloc] initWithCenter:self.view.center];

    [iFlyRecognizerView setParameter:@"domain"
                              forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [iFlyRecognizerView setParameter:@"plain"
                              forKey:[IFlySpeechConstant RESULT_TYPE]];

    [self hideVendorInfoLabel];

    iFlyRecognizerView.delegate = self;
}

- (void)hideVendorInfoLabel {
    UILabel *vendorLabel =
        (UILabel *)((NSArray *)((UIView *)((NSArray *)iFlyRecognizerView
                                               .subviews)[0]).subviews)[1];
    [vendorLabel setHidden:YES];
}

- (void)hideNavigationBar {
    [self.navigationController.navigationBar setHidden:YES];
}

#pragma mark - KKBSearchDelegate Methods

- (void)recordAudioButtonDidPress {

    [iFlyRecognizerView start];
}

- (void)cancelButtonDidPress {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)searchResultTableViewCellDidSelect:(KCourseItem *)aCourseItem {

    if (aCourseItem.type) {
        // instructive course

        GuideCourseViewController *controller =
            [[GuideCourseViewController alloc] init];
        controller.courseId = aCourseItem.courseId;
        [self.navigationController pushViewController:controller animated:YES];

    } else {
        // open course
        PublicClassViewController *controller =
            [[PublicClassViewController alloc]
                initWithNibName:@"PublicClassViewController"
                         bundle:nil];

        NSNumber *courseId =
            [NSNumber numberWithInteger:[aCourseItem.courseId integerValue]];
        [KKBCourseManager getCourseWithID:courseId
                              forceReload:NO
                        completionHandler:^(id model, NSError *error) {
                            if (!error) {
                                controller.currentCourse = model;
                                [self.navigationController
                                    pushViewController:controller
                                              animated:YES];
                            } else {
                            }
                        }];
    }
}

- (void)addStatusBar {
    AppDelegate *appDelegate = APPDELEGATE;
    [self.view addSubview:[appDelegate statusBar]];
}

- (void)addSearchFailedView {

    searchFailedView = [[KKBSearchFailedView alloc] init];
    [searchFailedView setFrameOriginY:SearchFailedViewOriginY];
    [searchFailedView setHidden:YES];
    [self.view addSubview:searchFailedView];
}

#pragma mark - IFlyRecognizerViewDelegate Methods
- (void)onError:(IFlySpeechError *)error {
}

- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast {

    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = resultArray[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@", key];
    }

    NSString *keyword =
        [resultString stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    keyword =
        [keyword stringByReplacingOccurrencesOfString:@"。" withString:@""];
    keyword =
        [keyword stringByReplacingOccurrencesOfString:@"，" withString:@""];
    keyword =
        [keyword stringByReplacingOccurrencesOfString:@"！" withString:@""];
    keyword =
        [keyword stringByReplacingOccurrencesOfString:@"？" withString:@""];

    searchBarView.searchTextField.text = [NSString
        stringWithFormat:@"%@%@", searchBarView.searchTextField.text, keyword];
    
    [searchBarView.searchTextField becomeFirstResponder];
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

    [self addSearchBar];
    [self initVoiceReconizer];
    [self addStatusBar];
    [self addSearchFailedView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
