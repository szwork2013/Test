//
//  LoginAndRegistViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-16.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
//#import "RightSideBarViewController.h"
#import "KKBActivityIndicatorView.h"
#import "UpYun.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LocalStorage.h"
#import "KKBBaseViewController.h"
#import "UMSocial.h"

@class SettingViewController;
@interface RegisterViaUmViewController
    : KKBBaseViewController <UITextFieldDelegate, UIScrollViewDelegate,
                             ASIHTTPRequestDelegate, UIWebViewDelegate,
                             UIGestureRecognizerDelegate, UpYunDelegate,
                             TencentSessionDelegate> {
    KKBActivityIndicatorView *_loadingView;

    TencentOAuth *tencentOAuth;
    NSArray *tencentPermissionsArray;
}

@property(assign, nonatomic) int index;
@property(retain, nonatomic) IBOutlet UIView *registView;
@property(retain, nonatomic) IBOutlet UIView *loginView;
@property(retain, nonatomic) IBOutlet UITextField *tfEmail;
@property(retain, nonatomic) IBOutlet UITextField *tfPwd;
@property(retain, nonatomic) IBOutlet UITextField *tfRealName;
@property(retain, nonatomic) IBOutlet UITextField *tfNickName;
@property(retain, nonatomic) IBOutlet UILabel *tfFalseDetail;
@property(retain, nonatomic) IBOutlet UIImageView *registerViewAvatar;
@property(retain, nonatomic) IBOutlet UIImageView *avatarCoverImageView;
@property(assign, nonatomic) BOOL isFromRigthView;
@property(retain, nonatomic) IBOutlet UIImageView *detailView1;
@property(retain, nonatomic) IBOutlet UIImageView *detailView2;
@property(retain, nonatomic) IBOutlet UIImageView *detailView3;
@property(retain, nonatomic) IBOutlet UIImageView *detailView4;
@property(retain, nonatomic) IBOutlet UIImageView *detailView5;
@property(retain, nonatomic) IBOutlet UIWebView *loginWebView;

@property(retain, nonatomic) IBOutlet UIButton *addAvatarButton;
@property(retain, nonatomic) IBOutlet UIButton *btnBack;
@property(retain, nonatomic) IBOutlet UIImageView *logoView;
@property(retain, nonatomic) IBOutlet UIButton *btnBack2;
@property(retain, nonatomic) IBOutlet UIImageView *logoView2;

@property(retain, nonatomic) IBOutlet UIButton *btnToHomeView;

@property(retain, nonatomic) IBOutlet UIButton *registerBtn;

@property(retain, nonatomic) IBOutlet UIButton *registeViaQQButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaSinaWeiboButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaRenrenButton;
@property(retain, nonatomic)NSString *registerName;
@property(retain, nonatomic)NSString *registerImage;

//@property(retain, nonatomic) RightSideBarViewController *sideBarViewController;

- (IBAction)registeViaQQButtonDidPress:(id)sender;
- (IBAction)registeViaSinaWeiboButtonDidPress:(id)sender;
- (IBAction)registeViaRenrenButtonDidPress:(id)sender;

@end
