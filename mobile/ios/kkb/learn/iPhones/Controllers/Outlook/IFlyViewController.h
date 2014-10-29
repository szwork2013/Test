//
//  IFlyViewController.h
//  learn
//
//  Created by 翟鹏程 on 14-7-18.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyRecognizerViewDelegate.h"

@class IFlyRecognizerView;

@interface IFlyViewController : UIViewController <IFlyRecognizerViewDelegate>

@property (nonatomic,strong) IFlyRecognizerView * iflyRecognizerView;
@property (nonatomic,strong) UITextField *textTF;
@property (nonatomic,strong) UILabel *label;

@end
