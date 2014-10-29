//
//  AssignmentDetailViewController.m
//  learn
//
//  Created by User on 14-1-3.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "AssignmentDetailViewController.h"
#import "AssignmentInCourseStructs.h"
#import "AppUtilities.h"
@interface AssignmentDetailViewController ()

@end

@implementation AssignmentDetailViewController
@synthesize assArr,assWebView,assignmentItem;
@synthesize pointsLabel,timeLable,titleLable;
@synthesize selectIndex;
@synthesize btnLast,btnNext;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.assArr.count == 1) {
        btnNext.enabled = NO;
        btnLast.enabled = NO;
    }else{
        if(selectIndex == self.assArr.count - 1)
        {
            btnNext.enabled = NO;
            btnLast.enabled = YES;
            
        }else if(selectIndex == 0)
        {
            btnLast.enabled = NO;
            btnNext.enabled = YES;
            
        }
    }
    // Do any additional setup after loading the view from its nib.
    [self setData];
    
    
}
-(void)setData
{
    self.pointsLabel.text = [NSString stringWithFormat:@"满分%@分",assignmentItem.points];
    self.titleLable.text = assignmentItem.name;
    id atValue = assignmentItem.due_at;
    id unlockValue = assignmentItem.unlock_at;
    id lockValue = assignmentItem.lock_at;
    NSLog(@"assignmentItem.due_at== %@",assignmentItem.due_at);
     NSLog(@"assignmentItem.unlock_at== %@",assignmentItem.unlock_at);
     NSLog(@"assignmentItem.lock_at== %@",assignmentItem.lock_at);
    
    if(atValue != [NSNull null] && [AppUtilities isLaterCurrentSystemDate:assignmentItem.due_at]&& assignmentItem.due_at !=nil)
    {
        timeLable.text =[NSString stringWithFormat:@"到期时间：%@",[AppUtilities convertTimeStyleTo:assignmentItem.due_at]];
    }else if(unlockValue != [NSNull null] && [AppUtilities isLaterCurrentSystemDate:assignmentItem.unlock_at] && assignmentItem.unlock_at !=nil)
    {
        timeLable.text = [NSString stringWithFormat:@"到期时间：%@",[AppUtilities convertTimeStyleTo:assignmentItem.unlock_at]];
    }else if(lockValue != [NSNull null] && [AppUtilities isLaterCurrentSystemDate:assignmentItem.lock_at] && assignmentItem.lock_at !=nil)
    {
        timeLable.text = [NSString stringWithFormat:@"到期时间：%@",[AppUtilities convertTimeStyleTo:assignmentItem.lock_at]];
    }else
    {
        timeLable.text = @"";
    }
    
    [assWebView loadHTMLString:assignmentItem.message baseURL:nil];
    
}
- (IBAction)nextAss
{
    btnLast.enabled = YES;
    
    self.assignmentItem = [self.assArr objectAtIndex:selectIndex + 1];
    [self setData];
    selectIndex = selectIndex + 1;
    
    if(selectIndex == self.assArr.count - 1)
    {
        btnNext.enabled = NO;
        
    }

    
}
- (IBAction)lastAss
{
    
    btnNext.enabled = YES;
    
    self.assignmentItem = [self.assArr objectAtIndex:selectIndex - 1];
    [self setData];
    selectIndex = selectIndex - 1;
    if(selectIndex == 0)
    {
        btnLast.enabled = NO;
        
        
    }
}
- (IBAction)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIWebViewDelegate

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if ([webView isEqual:loginWebView])
//    {
//        NSString *domain = [NSString stringWithFormat:@"%@", request.URL.absoluteString];
//
//
//    }
//
//    return YES;
//}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
   [AppUtilities showLoading:@"加载中......" andView:assWebView];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [AppUtilities closeLoading:assWebView];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
   [AppUtilities closeLoading:assWebView];

}

@end
