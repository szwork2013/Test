//
//  SidebarLevelTwoViewController.m
//  learnForiPhone
//
//  Created by User on 13-10-28.
//  Copyright (c) 2013年 User. All rights reserved.
//

#import "SidebarLevelTwoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftSideBarViewController.h"
#import "RightLevelTwoViewController.h"
#import "GlobalDefine.h"
@interface SidebarLevelTwoViewController ()


@end

@implementation SidebarLevelTwoViewController
@synthesize leftSideBarViewController,rightSideBarViewController,contentView,navBackView;

static SidebarLevelTwoViewController *rootViewCon;
const int ContentOffset2=270;
const int ContentMinOffset2=60;
const float MoveAnimationDuration2 = 0.3;



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
    
    RightLevelTwoViewController *_rightCon = nil;
    
    if(IS_IPHONE_5){
        _rightCon= [[RightLevelTwoViewController alloc] initWithNibName:@"RightLevelTwoViewController_iph5" bundle:nil];
        
    }else{
        _rightCon = [[RightLevelTwoViewController alloc] initWithNibName:@"RightLevelTwoViewController" bundle:nil];
        
    }
    self.rightSideBarViewController = _rightCon;
    
    LeftSideBarViewController *_leftCon = [[LeftSideBarViewController alloc] initWithNibName:@"LeftSideBarViewController" bundle:nil];
    _leftCon.delegate = self;
    _leftCon.rightTwo = self.rightSideBarViewController;
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
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration2];
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
            UIView *view ;
            if (translation+currentTranslate>0)
            {
//                view = self.leftSideBarViewController.view;
            }else
            {
                view = self.rightSideBarViewController.view;
                [self.navBackView bringSubviewToFront:view];
            }
            
            
        } else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
        {
            currentTranslate = self.contentView.transform.tx;
            if (!sideBarShowing) {
                if (fabs(currentTranslate)<ContentMinOffset2) {
                    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration2];
                    
                    [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration2];
                }
                else if(currentTranslate>ContentMinOffset2)
                {
                    [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration2];
                }else
                {
                    [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration2];
                }
            }else
            {
                if (fabs(currentTranslate)<ContentOffset2-ContentMinOffset2) {
                    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration2];
                    
                }else if(currentTranslate>ContentOffset2-ContentMinOffset2)
                {
                    
                    [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration2];
                    
                }else
                {
                    [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration2];
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
        UIView *view = nil;
        if (direction == SideBarShowDirectionLeft)
        {
            view = self.leftSideBarViewController.view;
        }else if(direction == SideBarShowDirectionRight)
        {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration2];
}



#pragma animation

- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset2, 0);
            }
                break;
            case SideBarShowDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-ContentOffset2, 0);
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
