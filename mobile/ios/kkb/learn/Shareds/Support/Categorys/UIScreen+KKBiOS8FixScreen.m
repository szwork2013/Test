//
//  UIScreen+KKBiOS8FixScreen.m
//  learn
//
//  Created by zengmiao on 9/25/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "UIScreen+KKBiOS8FixScreen.h"

@implementation UIScreen (KKBiOS8FixScreen)

+ (CGRect)kkb_screenBoundsFixedToPortraitOrientation {
    UIScreen *screen = [UIScreen mainScreen];
    
    if ([screen respondsToSelector:@selector(fixedCoordinateSpace)]) {
        return [screen.coordinateSpace convertRect:screen.bounds toCoordinateSpace:screen.fixedCoordinateSpace];
    }
    return screen.bounds;
}

@end
