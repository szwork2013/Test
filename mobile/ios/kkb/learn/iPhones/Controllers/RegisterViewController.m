//
//  LoginAndRegistViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-16.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "RegisterViewController.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "UMFeedback.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "HomePageOperator.h"
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
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

static const CGFloat registerBtnOriginYPlusHeight = 380;
static const CGFloat registerBtnAndKeyboardSpace = 12;

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface RegisterViewController () <UIActionSheetDelegate,
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

@implementation RegisterViewController
@synthesize index;
@synthesize isFromRigthView;
@synthesize registView;
@synthesize tfEmail, tfNickName, tfPwd, tfFalseDetail;
@synthesize registerViewAvatar;
@synthesize detailView1, detailView2, detailView3;
@synthesize btnToHomeView;
@synthesize registerBtn;
@synthesize addAvatarButton;

#pragma mark - LifeCycle Methods
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

    [self setTitle:@"注册"];
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];

    self.title = @"注册";
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
    }

    [self turnImageViewToCircle];

    self.registerVCForTPKeyboard.showsVerticalScrollIndicator = NO;
    [self.registerVCForTPKeyboard
        setContentSize:CGSizeMake(G_SCREEN_WIDTH,
                                  registerBtnOriginYPlusHeight +
                                      registerBtnAndKeyboardSpace)];
    self.registerVCForTPKeyboard.bounces = NO;

    [self prepareTextField];
    [self turnRegisterButtonRoundCorner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {

    self.navigationController.navigationBar.hidden = NO;

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

#pragma mark - IBAction Methods

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

#pragma mark - IBAction Methods
- (void)registeViaQQButtonDidPress:(id)sender {
    //    [[LocalStorage shareInstance] setLoginVia:TencentQQ];
    [tencentOAuth authorize:tencentPermissionsArray inSafari:YES];
}

- (void)registeViaSinaWeiboButtonDidPress:(id)sender {

    //`snsName`
    //代表各个支持云端分享的平台名，有`UMShareToSina`,`UMShareToTencent`等五个。
    UMSocialSnsPlatform *snsPlatform =
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(
        self, [UMSocialControllerService defaultControllerService], YES,
        ^(UMSocialResponseEntity *response) {
            DDLogDebug(@"response is %@", response);

            DDLogDebug(@"response is %@", response);

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
        ^(UMSocialResponseEntity *response) { DDLogDebug(@"%@", response); });
}

#pragma mark - Custom Methods
- (void)turnImageViewToCircle {

    registerViewAvatar.layer.backgroundColor = [[UIColor clearColor] CGColor];
    registerViewAvatar.layer.cornerRadius =
        (registerViewAvatar.frame.size.width / 2);
    registerViewAvatar.layer.borderWidth = 1.0;
    registerViewAvatar.layer.masksToBounds = YES;
    registerViewAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)changeRgistBtnState {
    [registerBtn setBackgroundColor:UIColorRGB(0, 142, 236)];
}

- (void)modifyAvatar {
    [self addAvatar:nil];
}

- (void)hideKeyboard {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
    [tfPwd resignFirstResponder];
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

            NSString *nickName = [dict objectForKey:@"nickname"];
            NSString *avatar = [dict objectForKey:@"figureurl_qq_1"];

            tfNickName.text = nickName;

            [registerViewAvatar
                sd_setImageWithURL:[NSURL URLWithString:avatar]];
        }
        failure:^(AFHTTPRequestOperation *operation,
                  NSError *error) { DDLogDebug(@"Error: %@", error); }];
}

- (BOOL)checkEmailFormat {

    tfEmail.text = [tfEmail.text lowercaseString];

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfEmail.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"邮箱不能为空";
        detailView1.image = [UIImage imageNamed:@"Validate_false"];
        [detailView1 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedEmail:tfEmail.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"邮" @"箱" @"格" @"式"
            @"错误，请输入正确的邮" @"箱";
        detailView1.image = [UIImage imageNamed:@"Validate_false"];
        [detailView1 setHidden:NO];

        matched = NO;
    }

    [self checkEmailExisted:tfEmail.text];

    if (matched) {
        [tfFalseDetail setHidden:YES];
        [detailView1 setHidden:NO];

        detailView1.image = [UIImage imageNamed:@"Validate_true"];
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
                detailView1.image = [UIImage imageNamed:@"Validate_false"];
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
                detailView2.image = [UIImage imageNamed:@"Validate_false"];
                [detailView2 setHidden:NO];

                userNameFormatMatched = NO;
            } else {

                tfFalseDetail.hidden = YES;
                detailView2.image = [UIImage imageNamed:@"Validate_true"];
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
        detailView3.image = [UIImage imageNamed:@"Validate_false"];
        [detailView3 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedPassword:tfPwd.text]) {

        tfFalseDetail.hidden = NO;
        tfFalseDetail.text = @"密码长度必须为6-16位";
        detailView3.image = [UIImage imageNamed:@"Validate_false"];
        [detailView3 setHidden:NO];

        matched = NO;
    }

    if (matched) {
        [tfFalseDetail setHidden:YES];
        detailView3.image = [UIImage imageNamed:@"Validate_true"];
        [detailView3 setHidden:NO];
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
        detailView2.image = [UIImage imageNamed:@"Validate_false"];
        [detailView2 setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedChinese:tfNickName.text]) {

        if (![AppUtilities isMatchedUserName:tfNickName.text]) {
            tfFalseDetail.hidden = NO;
            tfFalseDetail.text = @"用"
                @"户名由中英文、数字、下划线组成，长度3-"
                @"18位";
            detailView2.image = [UIImage imageNamed:@"Validate_false"];
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

        detailView2.image = [UIImage imageNamed:@"Validate_true"];
    } else {

        [registerBtn setEnabled:NO];
        [registerBtn setBackgroundColor:[UIColor grayColor]];

        detailView2.image = [UIImage imageNamed:@"Validate_false"];
    }

    userNameFormatMatched = matched;

    return matched;
}

- (void)turnRegisterButtonRoundCorner {
    registerBtn.layer.cornerRadius = 2.0f;
    registerBtn.layer.masksToBounds = YES;
}

#pragma mark - TencentSessionDelegate Methods
- (void)tencentDidLogin {
    DDLogDebug(@"登录完成");

    if (tencentOAuth.accessToken && [tencentOAuth.accessToken length] != 0) {
        //  记录登录用户的OpenID、Token以及过期时间
        DDLogDebug(@"tencentOAuth.accessToken = %@", tencentOAuth.accessToken);
        DDLogDebug(@"tencentOAuth.openId = %@", tencentOAuth.openId);
        DDLogDebug(@"tencentOAuth.appId = %@", tencentOAuth.appId);
        DDLogDebug(@"tencentOAuth.expirationDate = %@",
                   tencentOAuth.expirationDate);

        [[LocalStorage shareInstance]
            setTencentAccessToken:tencentOAuth.accessToken];
        [[LocalStorage shareInstance] setTencentOpenId:tencentOAuth.openId];
        [[LocalStorage shareInstance] setTencentAppId:tencentOAuth.appId];

    } else {
        DDLogDebug(@"登录不成功 没有获取accesstoken");
    }
}

- (void)tencentDidLogout {
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        DDLogDebug(@"用户取消登录");
    } else {
        DDLogDebug(@"登录失败");
    }
}

- (void)tencentDidNotNetWork {
    DDLogDebug(@"无网络连接，请设置网络");
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

- (void)textFieldValueDidChange:(UITextField *)textField {

    if (textField == tfPwd) {

        [self checkPasswordFormat];
    }

    if (emailFormatMatched && userNameFormatMatched && passwordFormatMatched) {
        [self setRegisterButtonEnabled:YES];
    } else {
        [self setRegisterButtonEnabled:NO];
    }
}

- (void)prepareTextField {

    [tfPwd addTarget:self
                  action:@selector(textFieldValueDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)setRegisterButtonEnabled:(BOOL)enabled {

    if (enabled) {

        registerBtn.enabled = YES;
        [registerBtn setBackgroundColor:UIColorRGB(0, 142, 236)];
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
    [imageInfo setObject:@"registerImageFile" forKey:@"fileName"];
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
}

- (IBAction)backgroundTouched {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
    [tfPwd resignFirstResponder];
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

#pragma mark 网络代理回调
- (void)loadCreateUser:(NSMutableDictionary *)dic {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
    [tfPwd resignFirstResponder];

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
                            [UIImage imageNamed:@"Validate_false"];
                        DDLogInfo(@"%@", [[dic objectForKey:@"error"]
                                             objectForKey:@"email"]);
                        tfFalseDetail.text = [NSString
                            stringWithFormat:@"邮箱%@",
                                             [[[dic objectForKey:@"error"]
                                                 objectForKey:@"email"]
                                                 objectAtIndex:0]];
                    } else if ([[dic objectForKey:@"error"]
                                   objectForKey:@"username"]) {
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

                [self createSearchHistoryTable];

                // 注册成功自动跳转
                [self changeUserInfo];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogDebug(@"failure ");
            DDLogDebug(@"%@", result);
            [AppUtilities closeLoading:self.view];

            tfFalseDetail.text = @"注册失败";
            [tfFalseDetail setHidden:NO];

            [self setRegisterButtonEnabled:YES];
        }];
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

- (void)createSearchHistoryTable {
    [KKBDatabaseManager createSearchRecordsTable];
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

    DDLogDebug(@"userInfoDict is %@", userInfoDict);

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
    [registerBtn setBackgroundColor:UIColorRGB(0, 142, 236)];
    registerBtn.userInteractionEnabled = YES;
    registerBtn.enabled = YES;
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

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
