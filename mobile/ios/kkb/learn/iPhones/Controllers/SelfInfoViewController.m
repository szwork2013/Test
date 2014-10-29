//
//  SelfInfoViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-25.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "SelfInfoViewController.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "HomePageOperator.h"
#import "UIImage+fixOrientation.h"
#import <QuartzCore/QuartzCore.h>
#import "SuspensionHintView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import "UpYun.h"
#import "KKBHttpClient.h"
#import "MobClick.h"
#import "KKBActivityIndicatorView.h"
#import "KKBLoadingFailedView.h"
#import "KKBUserInfo.h"
#import "CourseCategories.h"
#import "AppDelegate.h"

@interface SelfInfoViewController () <UIActionSheetDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate> {

    UIActionSheet *uploadImageActionSheet; //上传头像ActionSheet

    UIImagePickerController *cameraImagePicker;
    UIImagePickerController *imagePicker;
    NSMutableDictionary *_userInfoDic;
}

@end

@implementation SelfInfoViewController
@synthesize tfEmail, tfNickName;
@synthesize viewAvatar;
@synthesize changeBtn;
@synthesize errorInfoLabel;

#pragma mark - LifeCycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.viewMode = NavigationBarOnlyMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userInfoDic = [[NSMutableDictionary alloc] init];

    tfNickName.text = [KKBUserInfo shareInstance].userName;
    if (self.registerName != nil) {
        tfNickName.text = self.registerName;
    }
    tfEmail.text = [KKBUserInfo shareInstance].userEmail;

    [viewAvatar
        sd_setImageWithURL:[NSURL URLWithString:[KKBUserInfo shareInstance]
                                                    .avatar_url]];

    if (self.registerImage != nil) {
        [viewAvatar
            sd_setImageWithURL:[NSURL URLWithString:self.registerImage]];
    }
    [self setTitle:@"个人信息"];

    // modify loading view frame
    CGRect loadingViewFrame = self.loadingView.frame;
    loadingViewFrame.origin.y = 0;
    self.loadingView.frame = loadingViewFrame;
    [self.loadingView setViewStyle:GrayStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"UpdateUserInfo"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"UpdateUserInfo"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods
- (IBAction)touchNext:(id)sender {
    if ([tfNickName isFirstResponder]) {
        [tfEmail isFirstResponder];
    } else if ([tfEmail isFirstResponder]) {
        [self editUser];
    }
}

- (IBAction)modifyAvatarButtonDidPress:(id)sender {
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

- (IBAction)closeKeyboard:(id)sender {
    [tfEmail resignFirstResponder];
    [tfNickName resignFirstResponder];
}

//修改个人信息
- (IBAction)editUser {
    [self.view endEditing:YES];

    BOOL matched = [self checkNicknameFormat];
    if (!matched) {
        return;
    }

    if (![AppUtilities isExistenceNetwork]) {
        [self.netDisconnectView showInView:self.view];
        return;
    }

    [self.loadingView showInView:self.view];
    [self requestModifyProfile];
}

#pragma mark - Custom Methods
- (void)requestModifyProfile {
    errorInfoLabel.hidden = YES;

    NSString *url = @"v1/user/modify";

    [_userInfoDic setObject:tfNickName.text forKey:@"username"];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:url
        method:@"MODIFY"
        param:_userInfoDic
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {

            NSDictionary *dict = (NSDictionary *)result;

            [KKBUserInfo shareInstance].avatar_url =
                [dict objectForKey:@"avatar_url"];
            [KKBUserInfo shareInstance].userName =
                [dict objectForKey:@"username"];
            [[SDImageCache sharedImageCache]
                removeImageForKey:[KKBUserInfo shareInstance].avatar_url
                         fromDisk:YES];

            [self saveUserInfo:dict];
            [self sendNotification];
            [self.loadingView hideView];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            [self.loadingView hideView];
            NSDictionary *failureDict =
                (NSDictionary *)operation.responseObject;

            errorInfoLabel.hidden = NO;
            errorInfoLabel.text = (failureDict != nil)
                                      ? [failureDict objectForKey:@"message"]
                                      : @"个人信息修改失败";
        }];
}

- (void)saveUserInfo:(NSDictionary *)userInfo {

    NSDictionary *userInfoDict = @{
        @"userId" : [userInfo objectForKey:@"id"],
        @"userName" : [userInfo objectForKey:@"username"],
        @"email" : [userInfo objectForKey:@"email"],
        @"avatar_url" : [userInfo objectForKey:@"avatar_url"],
        @"password" : [KKBUserInfo shareInstance].userPassword
    };

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
}

- (void)sendNotification {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:NotificationProfileDidModify
                      object:nil
                    userInfo:nil];
}

- (BOOL)checkNicknameFormat {

    BOOL matched = YES;

    if ([AppUtilities isBlankString:tfNickName.text]) {

        [errorInfoLabel setHidden:NO];
        [errorInfoLabel setText:@"用户名不能为空，3~"
                        @"18个字符，不能包含特殊字符"];
        matched = NO;

    } else if (![AppUtilities isMatchedChinese:tfNickName.text]) {

        if (![AppUtilities isMatchedUserName:tfNickName.text]) {

            [errorInfoLabel setHidden:NO];
            [errorInfoLabel
                setText:@"用"
                @"户名由中英文、数字、下划线组成，长度3-"
                @"18位"];

            matched = NO;
        }
    }

    if (matched) {
        [errorInfoLabel setHidden:YES];
        [self setEditButtonEnabled:YES];
    } else {
        [self setEditButtonEnabled:NO];
    }

    return matched;
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

            if (existed &&
                ![nickname
                    isEqualToString:[KKBUserInfo shareInstance].userName]) {

                errorInfoLabel.hidden = NO;
                errorInfoLabel.text = @"用户名已存在";
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {}];
}

- (void)setEditButtonEnabled:(BOOL)enabled {

    if (enabled) {
        [changeBtn setBackgroundColor:UIColorFromRGB(0x008eec)];
        [changeBtn setEnabled:YES];
    } else {
        [changeBtn setBackgroundColor:UIColorRGBTheSame(204)];
        [changeBtn setEnabled:NO];
    }
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidEndEditing:(UITextField *)textField {

    [self setEditButtonEnabled:YES];
    if (textField == tfNickName) {
        BOOL matched = [self checkNicknameFormat];
        if (matched) {
            [self checkNicknameExisted:tfNickName.text];
        }
    }
}

#pragma mark - Loading Method
- (CGRect)loadingViewFrame {
    int x = 0;
    int y = gNavigationBarHeight + gStatusBarHeight;
    int widht = G_SCREEN_WIDTH;
    int height = G_SCREEN_HEIGHT - y;
    CGRect frame = CGRectMake(x, y, widht, height);

    return frame;
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
    // refresh here
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

    NSMutableDictionary *imageInfo = [[NSMutableDictionary alloc] init];
    [imageInfo setObject:data forKey:@"imageData"];
    [imageInfo setObject:@"registerImageFile" forKey:@"fileName"];
    [_userInfoDic setObject:imageInfo forKey:@"imageInfo"];
    [viewAvatar setImage:image];

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

#pragma mark - Life Cycle Methods
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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
