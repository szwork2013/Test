//
//  LoginAndRegistViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-16.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "KKBActivityIndicatorView.h"
#import "UpYun.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "LocalStorage.h"
#import "KKBBaseViewController.h"
#import "UMSocial.h"
#import "TPKeyboardAvoidingScrollView.h"

@class SettingViewController;
@interface RegisterViewController
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
@property(retain, nonatomic) IBOutlet UITextField *tfEmail;
@property(retain, nonatomic) IBOutlet UITextField *tfPwd;
@property(retain, nonatomic) IBOutlet UITextField *tfNickName;
@property(retain, nonatomic) IBOutlet UILabel *tfFalseDetail;
@property(retain, nonatomic) IBOutlet UIImageView *registerViewAvatar;
@property(assign, nonatomic) BOOL isFromRigthView;
@property(retain, nonatomic) IBOutlet UIImageView *detailView1;
@property(retain, nonatomic) IBOutlet UIImageView *detailView2;
@property(retain, nonatomic) IBOutlet UIImageView *detailView3;

@property(retain, nonatomic) IBOutlet UIButton *addAvatarButton;

@property(retain, nonatomic) IBOutlet UIButton *btnToHomeView;

@property(retain, nonatomic) IBOutlet UIButton *registerBtn;

@property(retain, nonatomic) IBOutlet UIButton *registeViaQQButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaSinaWeiboButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaRenrenButton;

- (IBAction)registeViaQQButtonDidPress:(id)sender;
- (IBAction)registeViaSinaWeiboButtonDidPress:(id)sender;
- (IBAction)registeViaRenrenButtonDidPress:(id)sender;

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *registerVCForTPKeyboard;
@end
