//
//  KKBBaseNavigationController.m
//  learn
//
//  Created by zengmiao on 8/7/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBBaseNavigationController.h"

@interface KKBBaseNavigationController ()
@property(strong, nonatomic) UIView *coverView;

@end

@implementation KKBBaseNavigationController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - cover view method
- (void)tapAction:(UIGestureRecognizer *)gesture {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:navigationBarCoverTap
                      object:nil];
}

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.5;
        _coverView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(tapAction:)];
        [_coverView addGestureRecognizer:tap];
        [self.view addSubview:_coverView];
    }
    return _coverView;
}

- (void)setAllowShowCoverView:(BOOL)allowShowCoverView {
    [self.view bringSubviewToFront:self.coverView];
    _allowShowCoverView = allowShowCoverView;
    self.coverView.hidden = !allowShowCoverView;
}

@end
