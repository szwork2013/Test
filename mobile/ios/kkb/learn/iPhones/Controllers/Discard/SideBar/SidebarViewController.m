//
//  ViewController.m
//  SideBarNavDemo
//
//  Created by JianYe on 12-12-11.
//  Copyright (c) 2012年 JianYe. All rights reserved.
//

#import "SidebarViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "GlobalDefine.h"
@interface SidebarViewController ()

@end

@implementation SidebarViewController
@synthesize leftSideBarViewController,rightSideBarViewController,contentView,navBackView;

static SidebarViewController *rootViewCon;
const int ContentOffset=270;
const int ContentMinOffset=60;
const float MoveAnimationDuration = 0.3;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

+ (id)share
{
    return rootViewCon;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    if (rootViewCon) {
        rootViewCon = nil;
    }
	rootViewCon = self;
    
    sideBarShowing = NO;
    currentTranslate = 0;
    
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
//    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 0;
    
    RightSideBarViewController *_rightCon = nil;

       if(IS_IPHONE_5){
    _rightCon= [[RightSideBarViewController alloc] initWithNibName:@"RightSideBarViewController_iph5" bundle:nil];
        
    }else{
    _rightCon = [[RightSideBarViewController alloc] initWithNibName:@"RightSideBarViewController" bundle:nil];
        
    }
    self.rightSideBarViewController = _rightCon;
    
    LeftSideBarViewController *_leftCon = [[LeftSideBarViewController alloc] initWithNibName:@"LeftSideBarViewController" bundle:nil];
    _leftCon.delegate = self;
    _leftCon.right = self.rightSideBarViewController;
    self.leftSideBarViewController = _leftCon;
    
    [self addChildViewController:self.leftSideBarViewController];
    [self addChildViewController:self.rightSideBarViewController];
    self.leftSideBarViewController.view.frame = self.navBackView.bounds;
    self.rightSideBarViewController.view.frame = self.navBackView.bounds;
    [self.navBackView addSubview:self.leftSideBarViewController.view];
    [self.navBackView addSubview:self.rightSideBarViewController.view];
    
    _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
   
   
    [self handleGestureRecognizer:YES];

    
}
-(void)handleGestureRecognizer:(BOOL)Recognizer
{
    if(Recognizer == YES){
    [self.contentView addGestureRecognizer:_panGestureReconginzer];
    }else
    {
        [self.contentView removeGestureRecognizer:_panGestureReconginzer];
    }

}
- (void)contentViewAddTapGestures
{
    if (_tapGestureRecognizer) {
        [self.contentView   removeGestureRecognizer:_tapGestureRecognizer];
        _tapGestureRecognizer = nil;
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapOnContentView:)];
    [self.contentView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)tapOnContentView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
}

- (BOOL)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{
    
    CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
    if (translation+currentTranslate>0){
        return false;
    }
    else{
	if (panGestureReconginzer.state == UIGestureRecognizerStateChanged)
    {
        
        CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
        self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
        UIView *view = nil;
        if (translation+currentTranslate>0)
        {
//            view = self.leftSideBarViewController.view;
        }else
        {
            view = self.rightSideBarViewController.view;
            [self.navBackView bringSubviewToFront:view];
        }
        
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
    {
		currentTranslate = self.contentView.transform.tx;
        if (!sideBarShowing) {
            if (fabs(currentTranslate)<ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
               
                    [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
            else if(currentTranslate>ContentMinOffset)
            {
               
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }else
        {
            if (fabs(currentTranslate)<ContentOffset-ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];

            
            }else if(currentTranslate>ContentOffset-ContentMinOffset)
            {
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }
        
        
	}
        return TRUE;
 }
   
}

#pragma mark - nav con delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController.viewControllers count]>1) {
        [self removepanGestureReconginzerWhileNavConPushed:YES];
    }else
    {
        [self removepanGestureReconginzerWhileNavConPushed:NO];
    }

}

- (void)removepanGestureReconginzerWhileNavConPushed:(BOOL)push
{
    if (push) {
        if (_panGestureReconginzer) {
            [self.contentView removeGestureRecognizer:_panGestureReconginzer];
            _panGestureReconginzer = nil;
        }
    }else
    {
        if (!_panGestureReconginzer) {
            _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
            [self.contentView addGestureRecognizer:_panGestureReconginzer];
        }
    }
}
#pragma mark - side bar select delegate
- (void)leftSideBarSelectWithController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller setDelegate:self];
    }
    if (_currentMainController == nil) {
		controller.view.frame = self.contentView.bounds;
		_currentMainController = controller;
		[self addChildViewController:_currentMainController];
		[self.contentView addSubview:_currentMainController.view];
		[_currentMainController didMoveToParentViewController:self];
	} else if (_currentMainController != controller && controller !=nil) {
		controller.view.frame = self.contentView.bounds;
		[_currentMainController willMoveToParentViewController:nil];
		[self addChildViewController:controller];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_currentMainController
						  toViewController:controller
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_currentMainController removeFromParentViewController];
									[controller didMoveToParentViewController:self];
									_currentMainController = controller;
								}
         ];
	}
    
    [self showSideBarControllerWithDirection:SideBarShowDirectionNone];
}

-(BOOL)getSideBarShowing
{
    return sideBarShowing;
}
- (void)rightSideBarSelectWithController:(UIViewController *)controller
{
}

- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    
    if (direction!=SideBarShowDirectionNone) {
        UIView *view ;
        if (direction == SideBarShowDirectionLeft)
        {
            view = self.leftSideBarViewController.view;
        }else {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];
}



#pragma animation

- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    if(sideBarShowing == NO)
    {
        self.rightSideBarViewController.homeViewController.headerScrollView.userInteractionEnabled = NO;
        self.rightSideBarViewController.homeViewController.tbvAllCourses.scrollEnabled = NO;
        
    }else
    {
        self.rightSideBarViewController.homeViewController.headerScrollView.userInteractionEnabled = YES;
        self.rightSideBarViewController.homeViewController.tbvAllCourses.scrollEnabled = YES;
        
 
    }
   
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            case SideBarShowDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-ContentOffset, 0);
            }
                break;
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
           
            if (_tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:_tapGestureRecognizer];
                _tapGestureRecognizer = nil;
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
             sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:animations completion:complete];
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
