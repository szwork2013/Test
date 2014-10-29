//
//  LoginAndRegistViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-16.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "RegisterViaUmViewController.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UMFeedback.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "HomePageOperator.h"
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "SidebarViewController.h"
#import "SuspensionHintView.h"
#import "AppDelegate.h"
#import "MobClick.h"
#import "KKBActivityIndicatorView.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

#import "DynamicsViewController.h"

#import "CourseHomeViewController.h"
#import "FindCourseViewController.h"
#import "MicroMajorViewController.h"
#import "MeViewController.h"
#import "UIColor+KKBAdd.h"
#import "KKBDataBase.h"
#import "KKBUploader.h"

#define kMaxLengthUserName 18
#define kMaxLengthPsw 16
#define API_CMS_V4 @"http://www.kaikeba.com/api/v4/"

#define NAVIGATION_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20
#define KKB_ACTIVITY_INDICATOR_TAG 120

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface RegisterViaUmViewController () <UIActionSheetDelegate,
                                            UIImagePickerControllerDelegate,
                                            UINavigationControllerDelegate> {
    UIActionSheet *uploadImageActionSheet; //上传头像ActionSheet
    UIImagePickerController *cameraImagePicker;
    UIImagePickerController *imagePicker;
    int tick;
    HomePageOperator *homePageOperator;

    NSMutableDictionary *_userInfoDic;

    BOOL emailFormatMatched;
    BOOL userNameFormatMatched;
    BOOL passwordFormatMatched;
}

@end

@implementation RegisterViaUmViewController
@synthesize index;
@synthesize isFromRigthView;
@synthesize loginView, registView;
@synthesize tfEmail, tfNickName, tfPwd, tfRealName, tfFalseDetail;
@synthesize registerViewAvatar;
@synthesize detailView1, detailView2, detailView3, detailView4, detailView5;
@synthesize loginWebView;
@synthesize btnBack, logoView, btnBack2, logoView2;
@synthesize btnToHomeView;
//@synthesize sideBarViewController;
@synthesize registerBtn;
@synthesize addAvatarButton;
@synthesize avatarCoverImageView;

- (void)dealloc {
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[SuspensionHintView appearance] setPopupColor:[UIColor whiteColor]];
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(changeRgistBtnState)
                   name:@"changeRgistBtnState"
                 object:nil];
        homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        isFromRigthView = NO;
        _userInfoDic = [[NSMutableDictionary alloc] init];

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self setTitle:@"注册"];
    // Do any additional setup after loading the view from its nib.
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    self.title = @"完善个人信息";
    [tfEmail setValue:[UIColor colorWithRed:153 / 256.0
                                      green:153 / 256.0
                                       blue:153 / 256.0
                                      alpha:1.0]
           forKeyPath:@"_placeholderLabel.textColor"];
    [tfEmail setValue:[UIFont boldSystemFontOfSize:14]
           forKeyPath:@"_placeholderLabel.font"];

    [tfPwd setValue:[UIColor colorWithRed:153 / 256.0
                                    green:153 / 256.0
                                     blue:153 / 256.0
                                    alpha:1.0]
         forKeyPath:@"_placeholderLabel.textColor"];
    [tfPwd setValue:[UIFont boldSystemFontOfSize:14]
         forKeyPath:@"_placeholderLabel.font"];

    [tfNickName setValue:[UIColor colorWithRed:153 / 256.0
                                         green:153 / 256.0
                                          blue:153 / 256.0
                                         alpha:1.0]
              forKeyPath:@"_placeholderLabel.textColor"];
    [tfNickName setValue:[UIFont boldSystemFontOfSize:14]
              forKeyPath:@"_placeholderLabel.font"];

    tfFalseDetail.right = 300;

    [self.registerBtn
        setBackgroundColor:[UIColor kkb_colorwithHexString:@"008eec" alpha:1]];

    self.tfPwd.delegate = self;
    self.tfNickName.delegate = self;
    self.tfPwd.tag = 11;
    self.tfNickName.tag = 12;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.registView.frame = CGRectMake(0, 20, self.view.frame.size.width,
                                           self.view.frame.size.height - 20);
        self.loginView.frame = CGRectMake(0, 20, self.view.frame.size.width,
                                          self.view.frame.size.height - 20);
    }

    //    [self.view addSubview:registView];
    //    [self.view addSubview:loginView];

    //    registView.hidden= NO;

    [self loadloginView];

    UIImage *image = [UIImage imageNamed:@"mine_head_user"];
    NSData *data = UIImagePNGRepresentation([image fixOrientation]);

    [data writeToFile:[AppUtilities getAvatarPath] atomically:YES];

    [self turnImageViewToCircle];
    if (self.registerName !=nil) {
         tfNickName.text = self.registerName;
    }
    if (self.registerImage !=nil) {
        [registerViewAvatar sd_setImageWithURL:[NSURL URLWithString:self.registerImage]];
    }
    
}

- (void)turnImageViewToCircle {

    registerViewAvatar.layer.backgroundColor = [[UIColor clearColor] CGColor];
    registerViewAvatar.layer.cornerRadius =
        (registerViewAvatar.frame.size.width / 2);
    registerViewAvatar.layer.borderWidth = 1.0;
    registerViewAvatar.layer.masksToBounds = YES;
    registerViewAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
}
- (void)loadloginView {
    loginWebView.userInteractionEnabled = YES;
    loginWebView.delegate = self;
    loginWebView.scalesPageToFit = YES;
    loginWebView.scrollView.showsHorizontalScrollIndicator = NO;
    loginWebView.scrollView.showsVerticalScrollIndicator = NO;
    loginWebView.backgroundColor = [UIColor clearColor];
    NSString *url =
        [NSString stringWithFormat:@"%@login/oauth2/"
                                   @"auth?client_id=4&response_type=code&"
                                   @"redirect_uri=urn:ietf:wg:oauth:2.0:oob",
                                   SERVER_HOST];
    [loginWebView
        loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
- (void)viewWillAppear:(BOOL)animated {
    detailView1.hidden = YES;
    detailView2.hidden = YES;
    detailView3.hidden = YES;
    detailView4.hidden = YES;
    detailView5.hidden = YES;

    self.navigationController.navigationBar.hidden = NO;
    //    DDLogInfo(@"%@",self.navigationController.navigationBar);

    [registerBtn setBackgroundImage:nil forState:UIControlStateNormal];
    registerBtn.userInteractionEnabled = YES;
    tfEmail.delegate = self;
    [MobClick beginLogPageView:@"Signup"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    [MobClick endLogPageView:@"Signup"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [tfEmail becomeFirstResponder];
}

#pragma registView
- (IBAction)showLoginView {
    //    self.loginView.hidden = NO;
    //    self.registView.hidden = YES;
    [self backgroundTouched];
}
- (IBAction)goToHomeView {
    [self.navigationController popViewControllerAnimated:YES];
    //    if (![self isBeingDismissed]){
    //     [self dismissViewControllerAnimated:YES completion:NO];
    //    }
    [AppUtilities setIsNotFromLoginView:isFromRigthView];

    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (delegant.isClickEntrollment == NO) {
        //        [self.sideBarViewController showAllCourseView];
    }

    //    [self showRightSideBar];
}
- (IBAction)showRegistView:(id)sender {
    self.registView.hidden = NO;
    self.loginView.hidden = YES;
    NSString *url =
        [NSString stringWithFormat:@"%@login/oauth2/"
                                   @"auth?client_id=4&response_type=code&"
                                   @"redirect_uri=urn:ietf:wg:oauth:2.0:oob",
                                   SERVER_HOST];
    [loginWebView
        loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
- (IBAction)doRegist:(UIButton *)button {
    if ([AppUtilities isExistenceNetwork]) {

        tfFalseDetail.hidden = YES;

        [_userInfoDic setObject:tfNickName.text forKey:@"username"];
        [_userInfoDic setObject:tfEmail.text forKey:@"email"];
        [_userInfoDic setObject:tfPwd.text forKey:@"password"];
        [_userInfoDic setObject:@"mobile" forKey:@"from"];

        [self loadCreateUser:_userInfoDic];

        [self setRegisterButtonEnabled:NO];

        [AppUtilities showLoading:@"注册中..." andView:self.view];
    } else {

        [self.netDisconnectView showInView:self.view];
    }
}

- (void)changeRgistBtnState {
    [registerBtn setBackgroundColor:[UIColor blueColor]];
}
- (IBAction)addAvatar:(id)sender {

    [self hideKeyboard];

    uploadImageActionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"浏览相册"
                           otherButtonTitles:@"现在拍照", nil];

    uploadImageActionSheet.actionSheetStyle = UIActionSheetStyleDefault;

    [uploadImageActionSheet
        showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)modifyAvatar {
    [self addAvatar:nil];
}

- (void)hideKeyboard {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
    [tfPwd resignFirstResponder];
}

#pragma mark - IBAction Methods
- (void)registeViaQQButtonDidPress:(id)sender {
    //    [[LocalStorage shareInstance] setLoginVia:TencentQQ];
    [tencentOAuth authorize:tencentPermissionsArray inSafari:NO];
}

- (void)registeViaSinaWeiboButtonDidPress:(id)sender {

    //`snsName`
    //代表各个支持云端分享的平台名，有`UMShareToSina`,`UMShareToTencent`等五个。
    UMSocialSnsPlatform *snsPlatform =
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(
        self, [UMSocialControllerService defaultControllerService], YES,
        ^(UMSocialResponseEntity *response) {
            NSLog(@"response is %@", response);

            NSLog(@"response is %@", response);

            NSDictionary *info = (NSDictionary *)response.data;
            NSDictionary *sina = (NSDictionary *)[info objectForKey:@"sina"];

            NSString *avatar = [sina objectForKey:@"icon"];
            NSString *userName = [sina objectForKey:@"username"];

            tfNickName.text = userName;
            [registerViewAvatar
                sd_setImageWithURL:[NSURL URLWithString:avatar]];
        });
}

- (void)registeViaRenrenButtonDidPress:(id)sender {
    //`snsName`
    //代表各个支持云端分享的平台名，有`UMShareToSina`,`UMShareToTencent`等五个。
    UMSocialSnsPlatform *snsPlatform =
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
    snsPlatform.loginClickHandler(
        self, [UMSocialControllerService defaultControllerService], YES,
        ^(UMSocialResponseEntity *response) {
            NSLog(@"%@",response);
        });
}

#pragma mark - Custome Methods
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

            NSString *nickName = [dict objectForKey:@"nickname"];
            NSString *avatar = [dict objectForKey:@"figureurl_qq_1"];

            tfNickName.text = nickName;

            [registerViewAvatar
                sd_setImageWithURL:[NSURL URLWithString:avatar]];
        }
        failure:^(AFHTTPRequestOperation *operation,
                  NSError *error) { NSLog(@"Error: %@", error); }];
}

- (BOOL)checkEmailFormat {

    tfEmail.text = [tfEmail.text lowercaseString];

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfEmail.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"邮箱不能为空";
        detailView1.image = [UIImage imageNamed:@"Validate_false.png"];
        [detailView1 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedEmail:tfEmail.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"邮" @"箱" @"格" @"式"
            @"错误，请输入正确的邮" @"箱";
        detailView1.image = [UIImage imageNamed:@"Validate_false.png"];
        [detailView1 setHidden:NO];

        matched = NO;
    }

    [self checkEmailExisted:tfEmail.text];

    if (matched) {
        [tfFalseDetail setHidden:YES];
        [detailView1 setHidden:NO];

        detailView1.image = [UIImage imageNamed:@"Validate_true.png"];
    } else {
        [registerBtn setEnabled:NO];
        [registerBtn setBackgroundColor:[UIColor grayColor]];
    }

    emailFormatMatched = matched;

    return matched;
}

- (void)checkEmailExisted:(NSString *)email {

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:email forKey:@"email"];
    [dict setObject:@"" forKey:@"nickname"];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:@"v1/user/register/check"
        method:@"POST"
        param:dict
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {

            NSDictionary *resultDict = (NSDictionary *)result;
            BOOL existed = [[resultDict objectForKey:@"email"] integerValue];

            if (existed) {

                tfFalseDetail.hidden = NO;
                tfFalseDetail.text = @"邮箱已注册";
                detailView1.image = [UIImage imageNamed:@"Validate_false.png"];
                [detailView1 setHidden:NO];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)checkNicknameExisted:(NSString *)nickname {

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"" forKey:@"email"];
    [dict setObject:nickname forKey:@"nickname"];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:@"v1/user/register/check"
        method:@"POST"
        param:dict
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {

            NSDictionary *resultDict = (NSDictionary *)result;
            BOOL existed = [[resultDict objectForKey:@"nickname"] integerValue];

            if (existed) {

                tfFalseDetail.hidden = NO;
                tfFalseDetail.text = @"用户名已存在";
                detailView2.image = [UIImage imageNamed:@"Validate_false.png"];
                [detailView2 setHidden:NO];

                userNameFormatMatched = NO;
            } else {

                tfFalseDetail.hidden = YES;
                detailView2.image = [UIImage imageNamed:@"Validate_true.png"];
                [detailView2 setHidden:NO];

                userNameFormatMatched = YES;
            }

            if (emailFormatMatched && userNameFormatMatched &&
                passwordFormatMatched) {
                [self setRegisterButtonEnabled:YES];
            } else {
                [self setRegisterButtonEnabled:NO];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {

            userNameFormatMatched = YES;
        }];
}

- (BOOL)checkPasswordFormat {

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfPwd.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"密码不能为空";
        detailView3.image = [UIImage imageNamed:@"Validate_false.png"];
        [detailView3 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedPassword:tfPwd.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"密码长度必须为6-16位";
        detailView3.image = [UIImage imageNamed:@"Validate_false.png"];
        [detailView3 setHidden:NO];

        matched = NO;
    }

    if (matched) {
        [tfFalseDetail setHidden:YES];
        [detailView3 setHidden:NO];

        detailView3.image = [UIImage imageNamed:@"Validate_true.png"];
    } else {

        [registerBtn setEnabled:NO];
        [registerBtn setBackgroundColor:[UIColor grayColor]];
    }

    passwordFormatMatched = matched;

    return matched;
}

- (BOOL)checkNicknameFormat {

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfNickName.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"用户名不能为空";
        detailView2.image = [UIImage imageNamed:@"Validate_false.png"];
        [detailView2 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedChinese:tfNickName.text]) {

        if (![AppUtilities isMatchedUserName:tfNickName.text]) {
            tfFalseDetail.hidden = NO;
            tfFalseDetail.text = @"用"
                @"户名由中英文、数字、下划线组成，长度3-"
                @"18位";
            detailView2.image = [UIImage imageNamed:@"Validate_false.png"];
            [detailView2 setHidden:NO];

            matched = NO;
        }
    }

    if (matched) {

        if (![AppUtilities isBlankString:tfNickName.text]) {
            [self checkNicknameExisted:tfNickName.text];
        }

        [tfFalseDetail setHidden:YES];
        [detailView2 setHidden:NO];

        detailView2.image = [UIImage imageNamed:@"Validate_true.png"];
    } else {

        [registerBtn setEnabled:NO];
        [registerBtn setBackgroundColor:[UIColor grayColor]];

        detailView2.image = [UIImage imageNamed:@"Validate_false.png"];
    }

    userNameFormatMatched = matched;

    return matched;
}

#pragma mark - TencentSessionDelegate Methods
- (void)tencentDidLogin {
    NSLog(@"登录完成");

    if (tencentOAuth.accessToken && [tencentOAuth.accessToken length] != 0) {
        //  记录登录用户的OpenID、Token以及过期时间
        NSLog(@"tencentOAuth.accessToken = %@", tencentOAuth.accessToken);
        NSLog(@"tencentOAuth.openId = %@", tencentOAuth.openId);
        NSLog(@"tencentOAuth.appId = %@", tencentOAuth.appId);
        NSLog(@"tencentOAuth.expirationDate = %@", tencentOAuth.expirationDate);

        //        NSString *expirationDate = [NSDateFormatter
        //        localizedStringFromDate:tencentOAuth.expirationDate
        //                                       dateStyle:NSDateFormatterShortStyle
        //                                       timeStyle:NSDateFormatterFullStyle];
        //
        [[LocalStorage shareInstance]
            setTencentAccessToken:tencentOAuth.accessToken];
        [[LocalStorage shareInstance] setTencentOpenId:tencentOAuth.openId];
        [[LocalStorage shareInstance] setTencentAppId:tencentOAuth.appId];
        //        [[LocalStorage shareInstance]
        //        setTencentExpirationDate:expirationDate];

    } else {
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

- (void)tencentDidLogout {
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        NSLog(@"用户取消登录");
    } else {
        NSLog(@"登录失败");
    }
}

- (void)tencentDidNotNetWork {
    NSLog(@"无网络连接，请设置网络");
}

- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth {
}

- (void)tencentFailedUpdate:(UpdateFailType)reason {
}

- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth
                   withPermissions:(NSArray *)permissions {
    return NO;
}

- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    return NO;
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth
              didSendBodyData:(NSInteger)bytesWritten
            totalBytesWritten:(NSInteger)totalBytesWritten
    totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
                     userData:(id)userData {
}

- (void)tencentOAuth:(TencentOAuth *)tencentOAuth
    doCloseViewController:(UIViewController *)viewController {
}

#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT;
    int widht = self.view.frame.size.width;
    int height = self.view.frame.size.height - y;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
}

- (void)showLoadingView {
    if (_loadingView == nil) {
        _loadingView = [KKBActivityIndicatorView sharedInstance];
        [_loadingView updateFrame:[self loadingViewFrame]];
        [self.view addSubview:_loadingView];
    }

    [_loadingView setHidden:NO];
}

- (void)removeLoadingView {
    [_loadingView setHidden:YES];
}

#pragma mark - Loading Failed Method
- (void)showLoadingFailedView {
    KKBLoadingFailedView *_loadingFailedView =
        [KKBLoadingFailedView sharedInstance];
    [_loadingFailedView updateFrame:[self loadingViewFrame]];
    [_loadingFailedView setTapTarget:self action:@selector(refresh)];
    [self.view addSubview:_loadingFailedView];

    [_loadingFailedView setHidden:NO];
}

- (void)removeLoadingFailedView {
    KKBLoadingFailedView *_loadingFailedView =
        [KKBLoadingFailedView sharedInstance];
    [_loadingFailedView setHidden:YES];
}

- (void)refresh {
    [self removeLoadingFailedView];
    // reload data here
    [self loadloginView];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {

    if (textField == tfEmail) {
        [self checkEmailFormat];
    } else if (textField == tfPwd) {
        [self checkPasswordFormat];
    } else if (textField == tfNickName) {
        [self checkNicknameFormat];
    }

    if (emailFormatMatched && userNameFormatMatched && passwordFormatMatched) {
        [self setRegisterButtonEnabled:YES];
    } else {
        [self setRegisterButtonEnabled:NO];
    }
}

- (void)setRegisterButtonEnabled:(BOOL)enabled {

    if (enabled) {

        registerBtn.enabled = YES;
        [registerBtn setBackgroundColor:[UIColor blueColor]];
        [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        registerBtn.userInteractionEnabled = YES;
    } else {

        registerBtn.enabled = NO;
        [registerBtn setBackgroundColor:[UIColor grayColor]];
        [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        registerBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:uploadImageActionSheet]) {
        if (buttonIndex == 0) {
            if ([UIImagePickerController
                    isSourceTypeAvailable:
                        UIImagePickerControllerSourceTypePhotoLibrary]) {
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType =
                    UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.modalTransitionStyle =
                    UIModalTransitionStyleCoverVertical;
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;

                //                if ([[[UIDevice currentDevice] systemVersion]
                //                floatValue] >= 7) {
                //
                //
                //                 imagePicker.view.frame =
                //                 CGRectMake(0,20,imagePicker.view.frame.size.width,imagePicker.view.frame.size.height-20);
                //                }

                [self presentViewController:imagePicker
                                   animated:YES
                                 completion:nil];
            }
        } else if (buttonIndex == 1) {
            if ([UIImagePickerController
                    isSourceTypeAvailable:
                        UIImagePickerControllerSourceTypeCamera]) {
                cameraImagePicker = [[UIImagePickerController alloc] init];
                cameraImagePicker.sourceType =
                    UIImagePickerControllerSourceTypeCamera;
                cameraImagePicker.delegate = self;
                cameraImagePicker.allowsEditing = YES;

                [self presentViewController:cameraImagePicker
                                   animated:YES
                                 completion:nil];
            }
        }
    }
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([picker isEqual:cameraImagePicker]) {
        [cameraImagePicker dismissViewControllerAnimated:YES completion:nil];

        [GlobalOperator sharedInstance].isLandscape = YES;
    }

    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSData *data = UIImagePNGRepresentation([image fixOrientation]);

    registerViewAvatar.image = image;
    UITapGestureRecognizer *gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(modifyAvatar)];

    [registerViewAvatar addGestureRecognizer:gesture];

    [registerViewAvatar setHidden:NO];

    [addAvatarButton setHidden:YES];

    NSMutableDictionary *imageInfo = [[NSMutableDictionary alloc] init];
    [imageInfo setObject:data forKey:@"imageData"];
    [imageInfo setObject:[AppUtilities getAvatarPath] forKey:@"fileName"];
    [_userInfoDic setObject:imageInfo forKey:@"imageInfo"];

    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    if ([picker isEqual:cameraImagePicker]) {
        [cameraImagePicker dismissViewControllerAnimated:YES completion:nil];

        [GlobalOperator sharedInstance].isLandscape = YES;
    } else {
        [imagePicker dismissViewControllerAnimated:YES completion:nil];
    }

    //    [picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)backgroundTouched {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
    [tfPwd resignFirstResponder];
    //    [tfRealName resignFirstResponder];
}
- (IBAction)touchNext:(id)sender {

    if ([tfEmail isFirstResponder]) {
        [tfNickName becomeFirstResponder];
    } else if ([tfNickName isFirstResponder]) {
        [tfNickName becomeFirstResponder];
    } else if ([tfPwd isFirstResponder]) {
        [self doRegist:registerBtn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView isEqual:loginWebView]) {
        NSString *meta = [NSString
            stringWithFormat:@"document.getElementsByName(\"viewport\")[0]."
                             @"content = \"width=%f, initial-scale=1.0, "
                             @"minimum-scale=1.0, maximum-scale=1.0, "
                             @"user-scalable=no\"",
                             webView.frame.size.width];
        [webView stringByEvaluatingJavaScriptFromString:meta];
        //        [ToolsObject closeLoading:loginWebView];
        [self removeLoadingView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([webView isEqual:loginWebView]) {
        //        [ToolsObject closeLoading:loginWebView];
        [self removeLoadingView];
        [self showLoadingFailedView];
    }
}

#pragma mark - showTheloginView
- (void)showWebLoginView {
    [self showLoginView];
    [self loadloginView];
}

#pragma mark 网络代理回调
- (void)loadCreateUser:(NSMutableDictionary *)dic {

    NSString *jsonUrlForRegister = @"v1/user/register";

    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonUrlForRegister
        method:@"REGISTER"
        param:dic
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"register result is %@", result);
            DDLogDebug(@"success");
            NSDictionary *dic = result;
            [KKBUserInfo shareInstance].userId = [dic objectForKey:@"id"];
            [KKBUserInfo shareInstance].userEmail = [dic objectForKey:@"email"];
            [KKBUserInfo shareInstance].userPassword = tfPwd.text;
            [KKBUserInfo shareInstance].userName =
                [dic objectForKey:@"username"];
            if ([[dic objectForKey:@"avatar_url"]
                    isKindOfClass:[NSNull class]]) {
                [KKBUserInfo shareInstance].avatar_url = @"";
            } else {
                [KKBUserInfo shareInstance].avatar_url =
                    [dic objectForKey:@"avatar_url"];
            }
            if ([KKBUserInfo shareInstance].userId == nil) { // 注册不成功
                tfFalseDetail.hidden = NO;
                if ([dic objectForKey:@"error"]) {
                    DDLogInfo(@"error is %@", [dic objectForKey:@"error"]);

                    if ([[dic objectForKey:@"error"] objectForKey:@"email"]) {
                        detailView2.image =
                            [UIImage imageNamed:@"Validate_false.png"];
                        DDLogInfo(@"%@", [[dic objectForKey:@"error"]
                                             objectForKey:@"email"]);
                        tfFalseDetail.text = [NSString
                            stringWithFormat:@"邮箱%@",
                                             [[[dic objectForKey:@"error"]
                                                 objectForKey:@"email"]
                                                 objectAtIndex:0]];
                    } else if ([[dic objectForKey:@"error"]
                                   objectForKey:@"username"]) {
                        detailView4.image =
                            [UIImage imageNamed:@"Validate_false.png"];
                        DDLogInfo(@"%@", [[dic objectForKey:@"error"]
                                             objectForKey:@"username"]);
                        tfFalseDetail.text = [NSString
                            stringWithFormat:@"用户名%@",
                                             [[[dic objectForKey:@"error"]
                                                 objectForKey:@"username"]
                                                 objectAtIndex:0]];
                        tfFalseDetail.text = @"用户名已存在";
                    }
                    [AppUtilities closeLoading:self.view];

                } else {
                    tfFalseDetail.text = @"该邮箱已注册";
                    [AppUtilities closeLoading:self.view];
                }

                NSDictionary *dict = @{
                    @"user_id" : @"",
                    @"signup_failed" : @"true"
                };
                [MobClick event:@"signup" attributes:dict];
            } else { // 注册成功

                [self saveImageToFile];

                [AppUtilities showHUD:@"注册成功" andView:self.view];
                NSDictionary *dict = @{
                    @"user_id" : [KKBUserInfo shareInstance].userId,
                    @"signup_succeed" : @"true"
                };
                [MobClick event:@"signup" attributes:dict];
                [self saveUserId];

                // PUSH
                NSString *userId = [KKBUserInfo shareInstance].userId;
                NSString *clientId = [KKBUserInfo shareInstance].geTuiClientId;
                NSString *userEmail = [KKBUserInfo shareInstance].userEmail;
                if (clientId != nil) {
                    [[KKBUploader sharedInstance]
                     bufferPushNotificationInfoWithUserID:userId
                     clientID:clientId
                     userEmail:userEmail];
                    [[KKBUploader sharedInstance] startUpload];
                }
                
                // 注册成功自动跳转
                [self changeUserInfo];

            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"failure ");
            DDLogDebug(@"%@", result);
            [AppUtilities closeLoading:self.view];

            [self setRegisterButtonEnabled:YES];
        }];
}

- (BOOL)saveImageToFile {
    NSData *data =
        UIImagePNGRepresentation([registerViewAvatar.image fixOrientation]);
    BOOL success =
        [data writeToFile:[AppUtilities getAvatarPath] atomically:YES];

    return success;
}

- (void)upYun:(UpYun *)upYun requestDidFailWithError:(NSError *)error {
    NSString *string = nil;
    if ([ERROR_DOMAIN isEqualToString:error.domain]) {
        string = [error.userInfo objectForKey:@"message"];
    } else {
        string = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    }
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:string
                                   message:@"上传头像失败"
                                  delegate:nil
                         cancelButtonTitle:@"关闭"
                         otherButtonTitles:nil, nil];
    [alert show];
}

- (void)upYun:(UpYun *)upYun requestDidSucceedWithResult:(id)result {
}

- (void)requestSuccess:(NSString *)cmd {
}

- (void)changeUserInfo {

    [KKBUserInfo shareInstance].isLogin = YES;
    NSDictionary *userInfoDict = @{
        @"userId" : [KKBUserInfo shareInstance].userId,
        @"userName" : [KKBUserInfo shareInstance].userName,
        @"email" : [KKBUserInfo shareInstance].userEmail,
        @"avatar_url" : [KKBUserInfo shareInstance].avatar_url,
        @"password" : [KKBUserInfo shareInstance].userPassword
    };

    NSLog(@"userInfoDict is %@", userInfoDict);

    if ([AppUtilities isFileExist:@"userInfo.json" subDir:@"UserInfo"]) {
        [[NSFileManager defaultManager]
            removeItemAtPath:[AppUtilities getTokenJSONFilePath]
                       error:nil];
    }
    NSData *data =
        [NSJSONSerialization dataWithJSONObject:userInfoDict
                                        options:NSJSONWritingPrettyPrinted
                                          error:nil];
    [AppUtilities writeFile:@"userInfo.json" subDir:@"UserInfo" contents:data];

    [self gotoTabBarController];
}

- (void)gotoTabBarController {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate isiPhoneLoginSuccess:YES];
}

- (void)saveUserId {
}

- (NSString *)getUserId {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId = [prefs objectForKey:@"USER_ID"];

    return userId;
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    [self removeLoadingView];
    [self showLoadingFailedView];

    [self showHint:@"亲~,您的网络不给力哦!"];
    [registerBtn setBackgroundColor:[UIColor blueColor]];
    registerBtn.userInteractionEnabled = YES;
    registerBtn.enabled = YES;
    if (self.loginView.hidden == NO) {
        NSDictionary *dict = @{ @"user_id" : @"", @"signin_failed" : @"true" };
        NSLog(@"dict is %@", dict);
        [MobClick event:@"signin" attributes:dict];
    } else {
        NSDictionary *dict = @{ @"user_id" : @"", @"signup_failed" : @"true" };
        NSLog(@"dict is %@", dict);
        [MobClick event:@"signup" attributes:dict];
    }
}
- (void)showHint:(NSString *)contentText {
    SuspensionHintView *popup = [SuspensionHintView popupWithText:contentText];
    [popup showInView:self.view
        centerAtPoint:self.view.center
             duration:kLPPopupDefaultWaitDuration
           completion:nil];
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {

    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    //    interfaceOrientation == UIInterfaceOrientationLandscapeRight);

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - 输入框编辑代理
//- (BOOL)textField:(UITextField *)textField
// shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString
//*)string
//{
//    NSString* textContent = [textField.text
//    stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"%d",textField.tag);
//    switch (textField.tag) {
//        case 11:
//        {
//            [self isRightText:textField textRange:range textType:kMaxLengthPsw
//            textContent:textContent];
//        }
//            break;
//        case 12:
//        {
//            [self isRightText:textField textRange:range
//            textType:kMaxLengthUserName textContent:textContent];
//        }
//            break;
//        default:
//            break;
//    }
//    return YES;
//
//}
//- (void)isRightText:(UITextField*)textField textRange:(NSRange)range
// textType:(NSUInteger)type textContent:(NSString*)content
//{
//    if (content.length > type && range.length != 1) {
//        textField.text = [content substringToIndex:type-1];
//    }
//}
@end
