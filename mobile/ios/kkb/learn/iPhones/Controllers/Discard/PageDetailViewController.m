//
//  PageDetailViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-30.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "PageDetailViewController.h"
#import "CourseUnitOperator.h"
#import "JSONKit.h"
#import "ToolsObject.h"
#import "GlobalOperator.h"
#import "GlobalDefine.h"
#import "UIImageView+WebCache.h"
#import "KKBHttpClient.h"
@interface PageDetailViewController ()
{
     CourseUnitOperator *courseUnitOperator;
}

@end

@implementation PageDetailViewController
@synthesize strCourseID,strUrl,lbtitle;
@synthesize webView;
@synthesize playView;
@synthesize coverImageView;
@synthesize imageUrl;
@synthesize videoUrl;
@synthesize codeDic;
@synthesize html;
@synthesize promoVideoStr;
@synthesize moviePlayer;
@synthesize coverView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        courseUnitOperator = (CourseUnitOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_COURSEUNIT];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:[ToolsObject adaptImageURLforPhone:self.imageUrl]] placeholderImage:[UIImage imageNamed:@"allcourse_cover_default.png"]];
    
    if([videoUrl isEqualToString:@"null"]){
    
    //[courseUnitOperator requestPage:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.strCourseID pageURL:self.strUrl];
      NSString *jsonUrl = [NSString stringWithFormat:@"courses/%@/pages/%@",self.strCourseID,self.strUrl];
        [[KKBHttpClient shareInstance]requestLMSUrlPath:jsonUrl method:@"GET" param:nil fromCache:YES success:^(id result){
            NSDictionary *dic = result;
        courseUnitOperator.page= [dic objectForKey:@"body"];
            NSString *body = [NSString stringWithFormat:@"%@", courseUnitOperator.page];
            
            NSRange range=[body rangeOfString:@"<div id=\"embed_media_0\""];
            if(range.length != 0){
                
                
                [self getVideoCode];
                
                NSString* str = [body substringFromIndex:range.location];
                //       NSLog(@"str ==%@",str);
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                //             NSLog(@" ==%@",[[ToolsObject cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]);
                self.html = [body substringToIndex:range.location];
                self.promoVideoStr =[NSString stringWithFormat:@"%@.mp4",[codeDic objectForKey:[[ToolsObject cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]]];
                NSLog(@"self.pro = %@",promoVideoStr);
                
                playView.hidden = NO;
                if(IS_IOS_7){
                    webView.frame = CGRectMake(0, 260, 320, 508);
                }else{
                    webView.frame = CGRectMake(0, 240, 320, 240);
                }
                
                
            }else
            {
                self.html = body;
                playView.hidden = YES;
                if(IS_IOS_7){
                    webView.frame = CGRectMake(0, 80, 320, 508);
                }else{
                    webView.frame = CGRectMake(0, 60, 320, 420);
                }
                
            }
            [webView loadHTMLString:html baseURL:nil];
            
            coverView.hidden = YES;
            
            //        }
            //        else
            //        {
            //            NSString *html = [NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /></head><body>%@</body></html>", body];
            //
            //            [unitDetailsWebView loadHTMLString:html baseURL:nil];
            //        }
            
            [ToolsObject closeLoading:self.view];

            
        } failure:^(id result) {
            
        }];
    
        
    [ToolsObject showLoading:@"加载数据中..." andView:self.view];
    }else
    {
        coverView.hidden = YES;
        playView.hidden = NO;
        
        if(IS_IOS_7){
            webView.frame = CGRectMake(0, 260, 320, 508);
        }else{
            webView.frame = CGRectMake(0, 240, 320, 240);
        }
        self.promoVideoStr = self.videoUrl;
    }
    
//    if(IS_IPHONE_5){
//        webView.frame = CGRectMake(0, 80, 320, 500);
//    }

}

-(IBAction)back:(id)sender
{
    [self stopMovie];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    if (![[self.navigationController viewControllers] containsObject: self])
    {
        // the view has been removed from the navigation stack, back is probably the cause
        // this will be slow with a large stack however.
        [self stopMovie];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)requestSuccess:(NSString *)cmd
//{
//   if ([cmd compare:HTTP_CMD_COURSEUNIT_PAGE] == NSOrderedSame)
//    {
////        NSLog(@"%@",courseUnitOperator.page);
//        NSString *body = [NSString stringWithFormat:@"%@", courseUnitOperator.page];
//        
//        NSRange range=[body rangeOfString:@"<div id=\"embed_media_0\""];
//        if(range.length != 0){
//            
//            
//            [self getVideoCode];
//            
//            NSString* str = [body substringFromIndex:range.location];
//            //       NSLog(@"str ==%@",str);
//            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//            //             NSLog(@" ==%@",[[ToolsObject cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]);
//            self.html = [body substringToIndex:range.location];
//            self.promoVideoStr =[NSString stringWithFormat:@"%@.mp4",[codeDic objectForKey:[[ToolsObject cleanHtml:(NSMutableString *)str] stringByTrimmingCharactersInSet:whitespace]]];
//            NSLog(@"self.pro = %@",promoVideoStr);
//            
//            playView.hidden = NO;
//            if(IS_IOS_7){
//                  webView.frame = CGRectMake(0, 260, 320, 508);
//            }else{
//                   webView.frame = CGRectMake(0, 240, 320, 240);
//            }
//         
//            
//        }else
//        {
//            self.html = body;
//            playView.hidden = YES;
//            if(IS_IOS_7){
//            webView.frame = CGRectMake(0, 80, 320, 508);
//            }else{
//            webView.frame = CGRectMake(0, 60, 320, 420);
//            }
//            
//        }
//        [webView loadHTMLString:html baseURL:nil];
//        
//        coverView.hidden = YES;
//        
//        //        }
//        //        else
//        //        {
//        //            NSString *html = [NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, user-scalable=no\" /></head><body>%@</body></html>", body];
//        //
//        //            [unitDetailsWebView loadHTMLString:html baseURL:nil];
//        //        }
//        
//        [ToolsObject closeLoading:self.view];
//        //        }
//    }
//}
-(void)getVideoCode
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"obsoletecode" ofType:@"txt"];
    
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    self.codeDic = [str objectFromJSONString];
    
    //    NSLog(@"coed === %@",codeDic);
    
    
}
//视频播放
- (IBAction)playMovieAtURL
{
    /*
     
     NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     NSString *plistPath = [document stringByAppendingPathComponent:@"finishPlist.plist"];
     //    NSLog(@"%@",document);
     //    NSLog(@"%@",plistPath);
     NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
     //    NSLog(@"%@",data);
     //     NSLog(@"%@",[data objectForKey:@"test"] );
     //    NSLog(@"%@",[[data objectForKey:@"test"] objectForKey:@"filepath"]);
     //    NSURL *url = [NSURL URLWithString:[[data objectForKey:@"test"] objectForKey:@"filepath"]];
     NSURL *url =  [[NSURL alloc] initFileURLWithPath:[[data objectForKey:@"test.mp4"] objectForKey:@"filepath"]];
     NSLog(@"%@",url);
     */
    NSURL *url;
    
    url =  [NSURL URLWithString:promoVideoStr];
    
    KKBMoviePlayerController *theMoviePlayer = [[KKBMoviePlayerController alloc] initWithContentURL:url];
    self.moviePlayer = theMoviePlayer;
    
    //    self.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    
    [theMoviePlayer.view setFrame:CGRectMake(0, 0,320, 180)];
    theMoviePlayer.initialPlaybackTime = -1;
    theMoviePlayer.endPlaybackTime = -1;
    
    [playView addSubview:theMoviePlayer.view];
    [theMoviePlayer prepareToPlay];
    [theMoviePlayer play];
    
    // 注册一个播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:theMoviePlayer];
    
}

- (void)myMovieFinishedCallback:(NSNotification *)notify
{
    //视频播放对象
    KKBMoviePlayerController *theMoviePlayer = [notify object];
    
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMoviePlayer];
    theMoviePlayer.fullscreen = NO;
    [theMoviePlayer.view removeFromSuperview];
    // 释放视频对象
//    [theMoviePlayer release];
   self.moviePlayer = nil;
    
}
-(void)stopMovie
{
    if (self.moviePlayer)
    {
        [self.moviePlayer stop];
        //销毁播放通知
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:self.moviePlayer];
        self.moviePlayer.fullscreen = NO;
        [self.moviePlayer.view removeFromSuperview];
        
//        self.moviePlayer = nil;
    }
    
}


- (NSUInteger)supportedInterfaceOrientations
{
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    return UIInterfaceOrientationMaskAllButUpsideDown;
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}

@end
