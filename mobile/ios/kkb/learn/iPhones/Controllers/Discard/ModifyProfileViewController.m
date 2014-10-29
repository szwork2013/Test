//
//  ModifyProfileViewController.m
//  learn
//
//  Created by xgj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "ModifyProfileViewController.h"
#import "LocalStorage.h"
#import "UIImageView+WebCache.h"

//#import "AFHTTPRequestOperation.h"
//#import "AFHTTPRequestOperationManager.h"

#import "AFHTTPRequestOperationManager.h"

@interface ModifyProfileViewController ()

@end

@implementation ModifyProfileViewController

@synthesize avatarUrl;
@synthesize email;
@synthesize nickname;
@synthesize password;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)requestTencentApi {
    // params
    NSString *tentcentAccessToken =
        [[LocalStorage shareInstance] getTencentAccessToken];
    NSString *tentcentOpenId = [[LocalStorage shareInstance] getTencentOpenId];
    NSString *tentcentAppId = [[LocalStorage shareInstance] getTencentAppId];

    NSString *api = [NSString
        stringWithFormat:@"https://graph.qq.com/user/"
                         @"get_simple_userinfo?access_token=%@&oauth_consumer_"
                         @"key=%@&openid=%@",
                         tentcentAccessToken, tentcentAppId, tentcentOpenId];

    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
        @"Accept" : @"application/json",
        @"Request" : @"application/json",
        @"Content-Type" : @"application/json",
    };

    manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObject:@"text/html"];
    [manager GET:api
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSDictionary *dict = (NSDictionary *)responseObject;

            nickname = [dict objectForKey:@"nickname"];
            avatarUrl = [dict objectForKey:@"figureurl_qq_1"];

            [self setProfile];
        }
        failure:^(AFHTTPRequestOperation *operation,
                  NSError *error) { NSLog(@"Error: %@", error); }];
}

- (IBAction)backButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setProfile {
    if (avatarUrl) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]];
    }

    if (nickname) {
        self.nicknameTextField.text = nickname;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestTencentApi];

    [self setProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
