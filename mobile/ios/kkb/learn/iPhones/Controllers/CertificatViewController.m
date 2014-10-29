//
//  CertificatViewController.m
//  learn
//
//  Created by xgj on 14-7-14.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CertificatViewController.h"

@interface CertificatViewController ()

@end

@implementation CertificatViewController

@synthesize imageUrl;

- (void)dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Custom Method
- (void)setImage {
    if (imageUrl) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl]
                     placeholderImage:nil];
    }
}

- (void)initScrollView {
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 6.0f;
}

#pragma mark - UIScrollViewDelegate Method
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];

    [self setImage];
    [self initScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"viewFrame:%@", NSStringFromCGRect(self.view.frame));

    self.scrollView.center = self.view.center;
}

#pragma mark - top Mehtod

- (IBAction)viewTouchDown:(UIControl *)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

@end
