//
//  PasswordForgotViewController.h
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordForgotViewController : UIViewController

@property(retain, nonatomic) IBOutlet UIButton *btnSend;
@property(retain, nonatomic) IBOutlet UITextField *tfEmail;
@property(retain, nonatomic) IBOutlet UIImageView *ivValidateEmail;

- (IBAction)btnSendClick:(id)sender;

@end
