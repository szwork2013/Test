//
//  LoginViewController.h
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "LocalStorage.h"
#import "KCourseItem.h"
#import "KKBBaseViewController.h"

@interface LoginViewController
    : KKBBaseViewController <TencentSessionDelegate, UITextFieldDelegate> {
    TencentOAuth *tencentOAuth;
}

@end
