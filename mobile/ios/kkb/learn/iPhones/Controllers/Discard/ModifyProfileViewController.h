//
//  ModifyProfileViewController.h
//  learn
//
//  Created by xgj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyProfileViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *nicknameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *password;

- (IBAction) backButtonDidPress:(id)sender;
@end
