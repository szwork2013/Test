//
//  AboutUsViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-21.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"

@interface AboutUsViewController : KKBBaseViewController <UIWebViewDelegate>

@property(retain, nonatomic) IBOutlet UIWebView *aboutUsView;

@end
