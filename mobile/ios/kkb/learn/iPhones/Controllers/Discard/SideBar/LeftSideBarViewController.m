//
//  LeftSideBarViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-14.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "LeftSideBarViewController.h"
#import "SideBarSelectedDelegate.h"
#import "HomeViewController.h"
#import "GlobalDefine.h"
#import "AppDelegate.h"
@interface LeftSideBarViewController ()
{
 
}

@end

@implementation LeftSideBarViewController
@synthesize delegate;
@synthesize right;
@synthesize rightTwo;
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
    // Do any additional setup after loading the view from its nib.
    if ([delegate respondsToSelector:@selector(leftSideBarSelectWithController:)]) {
        [delegate leftSideBarSelectWithController:[self subConWithIndex:0]];
//        _selectIdnex = 0;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UINavigationController *)subConWithIndex:(int)index
{
    AppDelegate *appDelegate = ( AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.TwoLevel){
        
    }else{
    HomeViewController *con = nil;
    if(IS_IPHONE_5){
    con = [[HomeViewController alloc] initWithNibName:@"HomeViewController_iph5" bundle:nil];
    }else
    {
        con = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    con.index = index+1;
    self.right.homeViewController = con;
    UINavigationController *nav= [[UINavigationController alloc] initWithRootViewController:con];
    nav.navigationBar.hidden = YES;
    return nav ;
    }
    return nil;
}

@end
