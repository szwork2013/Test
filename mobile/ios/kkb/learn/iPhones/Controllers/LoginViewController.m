//
//  LoginViewController.m
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "LoginViewController.h"
#import "MobClick.h"
#import "PasswordForgotViewController.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import <UMSocial.h>
#import "UMSocialControllerServiceComment.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+WebCache.h"
#import "KKBHttpClient.h"
#import "AppUtilities.h"
#import "DynamicsViewController.h"
#import "FindCourseViewController.h"
#import "MicroMajorViewController.h"
#import "MeViewController.h"
#import "GuideCourseEnrolledViewController.h"
#import "GlobalOperator.h"
#import "KKBUserInfo.h"
#import "LocalStorage.h"

#import "SelfInfoViewController.h"
#import "RegisterViewController.h"
#import "KKBDataBase.h"
#import "KKBUploader.h"

#import "RegisterViaUmViewController.h"
static CGFloat const baseViewHeight = 172;
static CGFloat const buttonWidth = 54;
static const int ddLogLevel = LOG_LEVEL_INFO;
@interface LoginViewController ()

@property(retain, nonatomic) IBOutlet UIButton *btnLogin;
@property(retain, nonatomic) IBOutlet UIButton *btnForgetPassword;
@property(retain, nonatomic) IBOutlet UIButton *btnRegister;

@property(retain, nonatomic) IBOutlet UITextField *tfEmail;
@property(retain, nonatomic) IBOutlet UITextField *tfPassword;

@property(retain, nonatomic) IBOutlet UIImageView *ivValidateEmail;
@property(retain, nonatomic) IBOutlet UIImageView *ivValidatePassword;

@property(retain, nonatomic) IBOutlet UIButton *registeViaQQButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaSinaWeiboButton;
@property(retain, nonatomic) IBOutlet UIButton *registeViaRenrenButton;

@property(weak, nonatomic) IBOutlet UILabel *lbPrompt;
@property(retain, nonatomic) KCourseItem *courseItem;

- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnForgetPasswordClick:(id)sender;
- (IBAction)btnRegisterClick:(id)sender;

- (IBAction)registeViaQQButtonDidPress:(id)sender;
- (IBAction)registeViaSinaWeiboButtonDidPress:(id)sender;
- (IBAction)registeViaRenrenButtonDidPress:(id)sender;

@end

@implementation LoginViewController

@synthesize btnForgetPassword, btnLogin, btnRegister;
@synthesize tfEmail, tfPassword;
@synthesize ivValidatePassword, ivValidateEmail;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == tfEmail) {
        [self checkEmailFormat];
    } else if (textField == tfPassword) {
        [self checkPasswordFormat];
    }
}

#pragma mark - Custome Methods
- (void)gotoModifyViewControoler:(NSString *)avatarUrl
                    withNickName:(NSString *)nickName {
}

- (void)gotoModifyViewControoler:(NSDictionary *)userInfo {
}

- (BOOL)checkEmailFormat {

    tfEmail.text = [tfEmail.text lowercaseString];

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfEmail.text]) {

        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"邮箱不能为空";
        ivValidateEmail.image = [UIImage imageNamed:@"Validate_false"];
        [ivValidateEmail setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedEmail:tfEmail.text]) {

        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"邮" @"箱" @"格" @"式" @"错"
            @"误，请输入正确的邮" @"箱";
        ivValidateEmail.image = [UIImage imageNamed:@"Validate_false"];
        [ivValidateEmail setHidden:NO];

        matched = NO;
    }

    if (matched) {
        [_lbPrompt setHidden:YES];
        ivValidateEmail.image = [UIImage imageNamed:@"Validate_true"];
        [ivValidateEmail setHidden:NO];
    }

    return matched;
}

- (BOOL)checkPasswordFormat {

    BOOL matched = YES;
    if ([AppUtilities isBlankString:tfPassword.text]) {

        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"密码不能为空";
        ivValidatePassword.image = [UIImage imageNamed:@"Validate_false"];
        [ivValidatePassword setHidden:NO];

        matched = NO;
    } else if (![AppUtilities isMatchedPassword:tfPassword.text]) {

        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"密码长度必须为6-16位";
        ivValidatePassword.image = [UIImage imageNamed:@"Validate_false"];
        [ivValidatePassword setHidden:NO];

        matched = NO;
    }

    if (matched) {
        [_lbPrompt setHidden:YES];
        ivValidatePassword.image = [UIImage imageNamed:@"Validate_true"];
        [ivValidatePassword setHidden:NO];
    }

    return matched;
}

- (void)rightBtnTapped {

    RegisterViewController *controller = [[RegisterViewController alloc]
        initWithNibName:@"RegisterViewController"
                 bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)registerViaQQButtonDidPress:(id)sender {
    [[LocalStorage shareInstance] setLoginVia:TencentQQ];
    NSArray *_permissions =
        [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo",
                                  @"add_t", nil];
    [tencentOAuth authorize:_permissions inSafari:YES];
}

- (IBAction)registerViaSinaWeiboButtonDidPress:(id)sender {
    //`snsName`
    //代表各个支持云端分享的平台名，有`UMShareToSina`,`UMShareToTencent`等五个。
    UMSocialSnsPlatform *snsPlatform =
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    snsPlatform.loginClickHandler(
        self, [UMSocialControllerService defaultControllerService], YES,
        ^(UMSocialResponseEntity *response) {

            BOOL isSinaWeibo =
                [snsPlatform.platformName isEqualToString:UMShareToSina];
            if (isSinaWeibo && [response.message isEqualToString:@"no error"]) {
                NSDictionary *info = (NSDictionary *)response.data;
                NSDictionary *sina =
                    (NSDictionary *)[info objectForKey:@"sina"];

                NSString *avatar = [sina objectForKey:@"icon"];
                NSString *userName = [sina objectForKey:@"username"];
                RegisterViaUmViewController *infoCtr =
                    [[RegisterViaUmViewController alloc] init];
                infoCtr.registerName = userName;
                infoCtr.registerImage = avatar;

                [self.navigationController pushViewController:infoCtr
                                                     animated:YES];
            }
        });
}

- (IBAction)registerViaRenrenButtonDidPress:(id)sender {

    //`snsName`
    //代表各个支持云端分享的平台名，有`UMShareToSina`,`UMShareToTencent`等五个。
    UMSocialSnsPlatform *snsPlatform =
        [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToRenren];
    snsPlatform.loginClickHandler(self, [UMSocialControllerService
                                                defaultControllerService],
                                  YES, ^(UMSocialResponseEntity *response) {
        BOOL isRenren =
            [snsPlatform.platformName isEqualToString:UMShareToRenren];
        if (isRenren) {
            [[UMSocialDataService defaultDataService]
                requestSnsInformation:UMShareToRenren
                           completion:^(UMSocialResponseEntity *respose) {
                               DDLogCInfo(@"get openid  response is %@",
                                          respose);

                               NSDictionary *dic = response.data;
                               NSDictionary *dataDic =
                                   [dic objectForKey:@"renren"];
                               NSString *userName =
                                   [dataDic objectForKey:@"username"];
                               NSString *imageUrl =
                                   [dataDic objectForKey:@"icon"];
                               RegisterViaUmViewController *infoCtr =
                                   [[RegisterViaUmViewController alloc] init];
                               infoCtr.registerName = userName;
                               infoCtr.registerImage = imageUrl;

                               [self.navigationController
                                   pushViewController:infoCtr
                                             animated:YES];
                           }];
        }
    });
}

- (void)createSearchHistoryTable{
    [KKBDatabaseManager createSearchRecordsTable];
}

#pragma mark - IBAction Methods
- (IBAction)backViewTouchDown:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)btnLoginClick:(id)sender {
    _lbPrompt.hidden = YES;

    [tfEmail resignFirstResponder];
    [tfPassword resignFirstResponder];
    btnLogin.titleLabel.text = @"正在登陆";

    BOOL isFit = YES;

    ivValidateEmail.image = [UIImage imageNamed:@"Validate_true"];
    ivValidatePassword.image = [UIImage imageNamed:@"Validate_true"];

    if ([AppUtilities isBlankString:tfPassword.text]) {
        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"请输入密码";
        ivValidatePassword.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;
        btnLogin.titleLabel.text = @"登陆";

    } else if (![AppUtilities isMatchedPassword:tfPassword.text]) {
        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"邮箱密码不匹配";
        ivValidatePassword.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;
        btnLogin.titleLabel.text = @"登陆";
    }
    if ([AppUtilities isBlankString:tfEmail.text]) {
        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"请输入邮箱!";
        ivValidateEmail.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;
        btnLogin.titleLabel.text = @"登陆";

    } else if (![AppUtilities isMatchedEmail:tfEmail.text]) {
        _lbPrompt.hidden = NO;
        _lbPrompt.text = @"邮箱密码不匹配!";
        ivValidateEmail.image = [UIImage imageNamed:@"Validate_false"];
        isFit = NO;
        btnLogin.titleLabel.text = @"登陆";
    }

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    if (isFit == YES) {
        [self loadLoginRequest];
    }
}

- (IBAction)btnForgetPasswordClick:(id)sender {

    [[UIApplication sharedApplication]
        openURL:
            [NSURL URLWithString:@"http://www.kaikeba.com/users/password/new"]];
    return;

    // 忘记密码
    PasswordForgotViewController *passwordForgot =
        [[PasswordForgotViewController alloc]
            initWithNibName:@"PasswordForgotViewController"
                     bundle:nil];

    [self.navigationController pushViewController:passwordForgot animated:YES];
}
- (IBAction)btnRegisterClick:(id)sender {
}

#pragma mark - TencentSessionDelegate Methods
- (void)tencentDidLogin {
    DDLogCInfo(@"登录完成");

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

        //        [[LocalStorage shareInstance]
        //        setTencentExpirationDate:expirationDate];
        BOOL qqInfoAvailable = [tencentOAuth getUserInfo];
        if (qqInfoAvailable) {
            [self.loadingView showInView:self.view];
            NSString *urlString = [NSString
                stringWithFormat:@"user/"
                                 @"get_user_info?access_token=%@&oauth_"
                                 @"consumer_key=%@&openid=%@",
                                 tencentOAuth.accessToken, tencentOAuth.appId,
                                 tencentOAuth.openId];
            [[KKBHttpClient shareInstance] requestUrlPath:urlString
                host:@"https://graph.qq.com"
                method:@"GET"
                param:nil
                fromCache:YES
                token:tencentOAuth.accessToken
                success:^(id result) {
                    NSDictionary *dataDic = result;
                    [self.loadingView hideView];
                    NSString *userName = [dataDic objectForKey:@"nickname"];
                    NSString *imageUrl = [dataDic objectForKey:@"figureurl_qq_2"];
                    RegisterViaUmViewController *infoCtr =
                        [[RegisterViaUmViewController alloc] init];
                    infoCtr.registerName = userName;
                    infoCtr.registerImage = imageUrl;

                    [self.navigationController pushViewController:infoCtr
                                                         animated:YES];
                }
                failure:^(id result) { [self.loadingView hideView]; }];
        }

        [self gotoModifyViewControoler:nil withNickName:nil];
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

#pragma mark - viewDidLoad Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self kkb_customLeftNarvigationBarWithImageName:nil highlightedName:nil];
    [tfEmail setPlaceholder:@"邮箱"];
    [tfEmail setValue:[UIColor colorWithRed:153 / 256.0
                                      green:153 / 256.0
                                       blue:153 / 256.0
                                      alpha:1.0]
           forKeyPath:@"_placeholderLabel.textColor"];
    [tfEmail setValue:[UIFont boldSystemFontOfSize:14]
           forKeyPath:@"_placeholderLabel.font"];

    [tfPassword setPlaceholder:@"密码"];
    [tfPassword setValue:[UIColor colorWithRed:153 / 256.0
                                         green:153 / 256.0
                                          blue:153 / 256.0
                                         alpha:1.0]
              forKeyPath:@"_placeholderLabel.textColor"];
    [tfPassword setValue:[UIFont boldSystemFontOfSize:14]
              forKeyPath:@"_placeholderLabel.font"];

    [self.btnLogin
        setBackgroundColor:[UIColor kkb_colorwithHexString:@"008eec" alpha:1]];

    ivValidateEmail.hidden = YES;
    ivValidatePassword.hidden = YES;
    tfPassword.secureTextEntry = YES;
    _lbPrompt.backgroundColor = [UIColor clearColor];
    _lbPrompt.textColor = [UIColor redColor];
    _lbPrompt.right = 300;
    _lbPrompt.hidden = YES;
    tencentOAuth =
        [[TencentOAuth alloc] initWithAppId:@"1101760842" andDelegate:self];

    [self.navigationController.navigationBar setHidden:NO];
    [self setTitle:@"登录"];

    [self kkb_customRightNarvigationBarWithTitle:@"注册"];
    [self.loadingView setViewStyle:GrayStyle];
    //---------隐藏第三方注册模块--------
    //[self initUmengRegisterButton];
}

- (void)initUmengRegisterButton {

    UIView *baseView = [[UIView alloc]
        initWithFrame:CGRectMake(0, G_SCREEN_HEIGHT - baseViewHeight -
                                        gNavigationAndStatusHeight,
                                 G_SCREEN_WIDTH, baseViewHeight)];
    if (G_SCREEN_HEIGHT == 480) {
        [baseView setFrame:CGRectMake(0, G_SCREEN_HEIGHT - baseViewHeight -
                                             gNavigationAndStatusHeight + 40,
                                      G_SCREEN_WIDTH, baseViewHeight - 40)];
    }

    [baseView setBackgroundColor:[UIColor clearColor]];
    UIImageView *backgroundImage = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"kkb-iphone-loginAndRegister-"
                               @"buttonBackGround.png"]];
    [backgroundImage setFrame:baseView.bounds];
    [baseView addSubview:backgroundImage];
    UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(50, 24, 250, 16)];
    label.text = @"可以使用合作伙伴账号注册哦";
    [baseView addSubview:label];
    NSArray *imageArray =
        [NSArray arrayWithObjects:@"kkb-iphone-loginAndRegister-qq.png",
                                  @"kkb-iphone-loginAndRegister-renren.png",
                                  @"kkb-iphone-loginAndRegister-sina.png", nil];
    //    NSArray *buttonAction = [NSArray
    //    arrayWithObjects:@"registeViaQQButtonDidPress:",@"registeViaRenrenButtonDidPress:",@"registeViaSinaWeiboButtonDidPress:",
    //    nil];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(36 + i * (36 + buttonWidth), 68,
                                    buttonWidth, buttonWidth)];
        UIImage *image = [UIImage imageNamed:[imageArray objectAtIndex:i]];
        [button setImage:image forState:UIControlStateNormal];
        if (i == 0) {
            [button addTarget:self
                          action:@selector(registerViaQQButtonDidPress:)
                forControlEvents:UIControlEventTouchUpInside];
        } else if (i == 1) {
            [button addTarget:self
                          action:@selector(registerViaRenrenButtonDidPress:)
                forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self
                          action:@selector(registerViaSinaWeiboButtonDidPress:)
                forControlEvents:UIControlEventTouchUpInside];
        }
        [baseView addSubview:button];
    }
    [self.view addSubview:baseView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    [MobClick beginLogPageView:@"Signin"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    [MobClick endLogPageView:@"Signin"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //    [tfEmail becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Request
- (void)loadLoginRequest {
    NSString *jsonUrlForLogin = @"v1/user/login";
    NSDictionary *dict = @{
        @"email" : tfEmail.text,
        @"password" : tfPassword.text
    };

    [self.loadingView showInView:self.view];

    NSMutableDictionary *param = (NSMutableDictionary *)dict;
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonUrlForLogin
        method:@"POST"
        param:param
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSDictionary *dict = result;

            [KKBUserInfo shareInstance].isLogin = YES;
            [KKBUserInfo shareInstance].userId = [dict objectForKey:@"id"];
            [KKBUserInfo shareInstance].userName =
                [dict objectForKey:@"username"];
            [KKBUserInfo shareInstance].userEmail =
                [dict objectForKey:@"email"];
            if ([[dict objectForKey:@"avatar_url"]
                    isKindOfClass:[NSNull class]]) {
                [KKBUserInfo shareInstance].avatar_url = nil;
            } else {
                [KKBUserInfo shareInstance].avatar_url =
                    [dict objectForKey:@"avatar_url"];
            }
            [KKBUserInfo shareInstance].userPassword = tfPassword.text;

            NSDictionary *userInfoDict = @{
                @"userId" : [dict objectForKey:@"id"],
                @"userName" : [dict objectForKey:@"username"],
                @"email" : [dict objectForKey:@"email"],
                @"avatar_url" : [dict objectForKey:@"avatar_url"],
                @"password" : tfPassword.text
            };

            if ([AppUtilities isFileExist:@"userInfo.json" subDir:@"UserInfo"]) {
                [[NSFileManager defaultManager]
                    removeItemAtPath:[AppUtilities getTokenJSONFilePath]
                               error:nil];
            }
            NSData *data = [NSJSONSerialization
                dataWithJSONObject:userInfoDict
                           options:NSJSONWritingPrettyPrinted
                             error:nil];
            [AppUtilities writeFile:@"userInfo.json"
                            subDir:@"UserInfo"
                          contents:data];

            [self.loadingView hideView];

            [self gotoTabBarController];

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

            NSDictionary *signInSuccess = @{
                @"user_id" : @"",
                @"signin_succeed" : @"true"
            };
            
            [self createSearchHistoryTable];
            [MobClick event:@"signin" attributes:signInSuccess];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSDictionary *signinFailed = @{
                @"user_id" : @"",
                @"signin_failed" : @"true"
            };
            [MobClick event:@"signin" attributes:signinFailed];

            NSDictionary *dict = operation.responseObject;
            if ([[dict objectForKey:@"message"]
                    isEqualToString:@"Invalid username or password"] &&
                [[dict objectForKey:@"status"] isEqualToString:@"fail"]) {
                _lbPrompt.text = @"错误的邮箱或密码";
                _lbPrompt.hidden = NO;
            }

            [self.loadingView hideView];
        }];
}

- (void)gotoTabBarController {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate isiPhoneLoginSuccess:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
