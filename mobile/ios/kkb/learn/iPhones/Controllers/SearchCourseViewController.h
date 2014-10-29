//
//  SearchCourseViewController.h
//  learn
//
//  Created by guojun on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"
#import "KKBSearchView.h"

#import "PublicClassViewController.h"
#import "GuideCourseViewController.h"

#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyTextUnderstander.h"
#import "iflyMSC/IFlySpeechConstant.h"

@interface SearchCourseViewController
    : KKBBaseViewController <KKBSearchDelegate, IFlyRecognizerViewDelegate>

@end
