//
//  SideBarSelectedInPadDelegate.h
//  learn
//
//  Created by User on 14-3-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _SideBarShowDirectionInPad
{
    SideBarShowInPadDirectionNone = 0,
    SideBarShowInPadDirectionLeft = 1,
    SideBarShowInPadDirectionRight = 2
}SideBarShowDirectionInPad;

@protocol SideBarSelectedInPadDelegate <NSObject>

- (void)leftSideBarSelectWithControllerInPad:(UIViewController *)controller;
- (void)rightSideBarSelectWithControllerInPad:(UIViewController *)controller;
- (void)showSideBarControllerWithDirectionInPad:(SideBarShowDirectionInPad)direction;
-(BOOL)getSideBarInPadShowing;

@end
