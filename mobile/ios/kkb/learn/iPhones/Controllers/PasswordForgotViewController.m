//
//  PasswordForgotViewController.m
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "PasswordForgotViewController.h"
#import "MobClick.h"

@interface PasswordForgotViewController ()

@end

@implementation PasswordForgotViewController

@synthesize btnSend;
@synthesize tfEmail;
@synthesize ivValidateEmail;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"password_forget"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"password_forget"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods
- (IBAction)btnSendClick:(id)sender {
    //    NSString *emailStr = tfEmail.text;
}
@end
