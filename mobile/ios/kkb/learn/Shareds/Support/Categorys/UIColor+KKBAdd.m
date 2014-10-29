//
//  UIColor+KKBAdd.m
//  Preferential
//
//  Created by Maveriks on 3/13/14.
//  Copyright (c) 2014 Maveriks. All rights reserved.
//

#import "UIColor+KKBAdd.h"

@implementation UIColor (KKBAdd)

+ (UIColor *)kkb_colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------

    unsigned int hexint = 0;

    // convert the hex value into an unsigned integer
    // 1. Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];

    // 2. Tell scanner to skip the # character
    [scanner
        setCharactersToBeSkipped:[NSCharacterSet
                                     characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];

    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    // create a UIColor object by doing a bitwise ‘&’ operation to isolate the
    // various color attributes and divide each by 255 to get the float value
    // for the same.

    UIColor *color =
        [UIColor colorWithRed:((CGFloat)((hexint & 0xFF0000) >> 16)) / 255
                        green:((CGFloat)((hexint & 0xFF00) >> 8)) / 255
                         blue:((CGFloat)(hexint & 0xFF)) / 255
                        alpha:alpha];

    return color;
}

+ (UIColor *)tableViewCellSelectedColor {
    return UIColorFromRGB(0xf5f5f5);
}

@end
