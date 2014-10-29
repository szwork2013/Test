//
//  LoginAndRegisterView.h
//  learn
//
//  Created by 翟鹏程 on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginAndRegisterView : UIView {
    UIButton *loginButton;
    UIButton *registerButton;
}

@property(nonatomic, strong) UIButton *loginButton;
@property(nonatomic, strong) UIButton *registerButton;

@property(nonatomic, assign) id target;
@property(nonatomic, assign) SEL action;

@end
