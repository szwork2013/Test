//
//  SelfInfoViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-25.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpYun.h"
#import "KKBBaseViewController.h"

@interface SelfInfoViewController
    : KKBBaseViewController <UpYunDelegate, UIImagePickerControllerDelegate,
                             UITextFieldDelegate> {
    BOOL isViewAlreadyLoaded;
}

@property(retain, nonatomic) IBOutlet UIButton *modifyAvatarButton;
@property(retain, nonatomic) IBOutlet UITextField *tfEmail;
@property(retain, nonatomic) IBOutlet UITextField *tfNickName;
@property(retain, nonatomic) IBOutlet UIImageView *viewAvatar;
@property(retain, nonatomic) IBOutlet UIButton *changeBtn;
@property(retain, nonatomic) IBOutlet UILabel *errorInfoLabel;
@property(copy,nonatomic)NSString *registerName;
@property(copy,nonatomic)NSString *registerImage;


- (IBAction)modifyAvatarButtonDidPress:(id)sender;
- (IBAction)closeKeyboard:(id)sender;

@end
