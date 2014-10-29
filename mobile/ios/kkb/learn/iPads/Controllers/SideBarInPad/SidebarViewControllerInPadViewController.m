//
//  SidebarViewControllerInPadViewController.m
//  learn
//
//  Created by User on 14-3-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "SidebarViewControllerInPadViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftSideBarInPadViewController.h"
#import "RightSideBarInPadViewController.h"

@interface SidebarViewControllerInPadViewController ()
{
    UIViewController  *_currentMainController;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}
@property (strong,nonatomic)LeftSideBarInPadViewController *leftSideBarViewController;
@property (strong,nonatomic)RightSideBarInPadViewController *rightSideBarViewController;
@end

@implementation SidebarViewControllerInPadViewController
@synthesize leftSideBarViewController,rightSideBarViewController,contentView,navBackView,homePage;

static SidebarViewControllerInPadViewController *rootViewCon;
const int IPAD_ContentOffset=124;
const int IPAD_ContentMinOffset=60;
const float IPAD_MoveAnimationDuration = 0.1;



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

+ (id)share
{
    return rootViewCon;
}
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (rootViewCon) {
        rootViewCon = nil;
    }
	rootViewCon = self;
    
    sideBarShowing = NO;
    currentTranslate = 0;
    
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = 1;
    
    LeftSideBarInPadViewController *_leftCon = [[LeftSideBarInPadViewController alloc] initWithNibName:@"LeftSideBarInPadViewController" bundle:nil];
    _leftCon.delegate = self;
    self.leftSideBarViewController = _leftCon;
    
    RightSideBarInPadViewController *_rightCon = [[RightSideBarInPadViewController alloc] initWithNibName:@"RightSideBarInPadViewController" bundle:nil];
    self.rightSideBarViewController = _rightCon;
    
    [self addChildViewController:self.leftSideBarViewController];
    [self addChildViewController:self.rightSideBarViewController];
    self.leftSideBarViewController.view.frame = self.navBackView.bounds;
    self.rightSideBarViewController.view.frame = self.navBackView.bounds;
    [self.navBackView addSubview:self.leftSideBarViewController.view];
    [self.navBackView addSubview:self.rightSideBarViewController.view];
    
    _panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    [self.contentView addGestureRecognizer:_panGestureReconginzer];
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
    [self moveAnimationWithDirection:SideBarShowInPadDirectionNone duration:IPAD_MoveAnimationDuration];
}

- (BOOL)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{
    
    CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
    if (translation+currentTranslate<0){
        return false;
    } else{
        
       
        if (panGestureReconginzer.state == UIGestureRecognizerStateChanged)
        {
            CGFloat translation = [panGestureReconginzer translationInView:self.contentView].x;
//             NSLog(@"%f",translation);
             if(currentTranslate + translation <=124 && translation > 0){
            self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
//            NSLog(@"%f",translation+currentTranslate);
             }else if (currentTranslate + translation <=124 && translation < 0){
//                self.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
                 [self moveAnimationWithDirection:SideBarShowInPadDirectionNone duration:IPAD_MoveAnimationDuration];

             }
            UIView *view ;
            if (translation+currentTranslate>0)
            {
                view = self.leftSideBarViewController.view;
            }else
            {
                view = self.rightSideBarViewController.view;
            }
            [self.navBackView bringSubviewToFront:view];
            
        } else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
        {
            currentTranslate = self.contentView.transform.tx;
            if (!sideBarShowing) {
                if (fabs(currentTranslate)<IPAD_ContentMinOffset) {
//                     NSLog(@"none");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionNone duration:IPAD_MoveAnimationDuration];
                }else if(currentTranslate>IPAD_ContentMinOffset )
                {
//                    NSLog(@"left");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionLeft duration:IPAD_MoveAnimationDuration];
                }else
                {
//                    NSLog(@"right");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionRight duration:IPAD_MoveAnimationDuration];
                }
            }else
            {
                if (fabs(currentTranslate)<IPAD_ContentOffset-IPAD_ContentMinOffset) {
//                    NSLog(@"none 111");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionNone duration:IPAD_MoveAnimationDuration];
                    
                }else if(currentTranslate>IPAD_ContentOffset-IPAD_ContentMinOffset)
                {
//                      NSLog(@"left 1111");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionLeft duration:IPAD_MoveAnimationDuration];
                    
                }else
                {
//                     NSLog(@"right 1111");
                    [self moveAnimationWithDirection:SideBarShowInPadDirectionRight duration:IPAD_MoveAnimationDuration];
                }
            }
            
            
        }
    }
    return TRUE;
    
    
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
- (void)leftSideBarSelectWithControllerInPad:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller setDelegate:self];
    }
    NSArray *arr =  [controller childViewControllers];
    self.homePage = (HomePageViewController *)[arr objectAtIndex:0];
    
    
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
    
    [self showSideBarControllerWithDirectionInPad:SideBarShowInPadDirectionNone];
}


- (void)rightSideBarSelectWithControllerInPad:(UIViewController *)controller
{
    
}

- (void)showSideBarControllerWithDirectionInPad:(SideBarShowDirectionInPad)direction
{
    
    if (direction!=SideBarShowInPadDirectionNone) {
        UIView *view ;
        if (direction == SideBarShowInPadDirectionLeft)
        {
            view = self.leftSideBarViewController.view;
        }else
        {
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:IPAD_MoveAnimationDuration];
}



#pragma animation

- (void)moveAnimationWithDirection:(SideBarShowDirectionInPad)direction duration:(float)duration
{
    NSLog(@"sideBarShowing ==%d",sideBarShowing);
    NSLog(@"direction ==%d",direction);
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowInPadDirectionNone:
            {
                [self.homePage controllBtn:YES];
                
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowInPadDirectionLeft:
            {
                [self.homePage controllBtn:NO];
                self.contentView.transform  = CGAffineTransformMakeTranslation(IPAD_ContentOffset, 0);
            }
                break;
            case SideBarShowInPadDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-IPAD_ContentOffset, 0);
            }
                break;
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowInPadDirectionNone) {
            
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

-(BOOL)getSideBarInPadShowing
{
    return sideBarShowing;
}
@end
