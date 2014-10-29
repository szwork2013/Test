//
//  PageDetailViewController.h
//  learnForiPhone
//
//  Created by User on 13-10-30.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBMoviePlayerController.h"
@interface PageDetailViewController : UIViewController

@property(retain,nonatomic)IBOutlet UILabel *lbtitle;
@property(retain,nonatomic) NSString *strUrl;
@property(retain,nonatomic) NSString *strCourseID;
@property(retain,nonatomic) NSString *imageUrl;
@property(retain,nonatomic) NSString *videoUrl;

@property (nonatomic, retain)NSDictionary *codeDic;
@property (nonatomic, retain) NSString *html;

@property(retain,nonatomic)IBOutlet UIWebView *webView;
@property (nonatomic,retain) NSString *promoVideoStr;

@property(retain,nonatomic)IBOutlet UIView *playView;

@property(retain,nonatomic)IBOutlet UIImageView *coverImageView;
@property(retain,nonatomic)IBOutlet UIView *coverView;

//保存MPMoviePlayerController
@property (nonatomic, assign) KKBMoviePlayerController *moviePlayer;
@end
