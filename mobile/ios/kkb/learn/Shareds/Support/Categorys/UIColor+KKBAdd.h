//
//  UIColor+KKBAdd.h
//  Preferential
//
//  Created by Maveriks on 3/13/14.
//  Copyright (c) 2014 Maveriks. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorRGB(r, g, b)                                                    \
    [UIColor colorWithRed:(r / 255.0)green:(g / 255.0)blue:(b / 255.0)alpha:1]
#define UIColorRGBA(r, g, b, a)                                                \
    [UIColor colorWithRed:(r / 255.0)green:(g / 255.0)blue:(b / 255.0)alpha:(a)]
#define UIColorFromRGB(rgbValue)                                               \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0       \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0          \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                   \
                    alpha:1.0]

@interface UIColor (KKBAdd)

/**
 *  from
 *http://iosdevelopertips.com/conversion/how-to-create-a-uicolor-object-from-a-hex-value.html
 *  sample
 *  UIColor *color = [UIColor colorwithHexString:@"123ABC" alpha:.9];
 *  UIColor *color = [UIColor colorwithHexString:@"#123ABC" alpha:.9];
 *  UIColor *color = [UIColor colorwithHexString:@"0x123ABC" alpha:.9];
 *  @param hexStr hexStr description
 *  @param alpha  alpha description
 *
 *  @return return value description
 */

+ (UIColor *)kkb_colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (UIColor *)tableViewCellSelectedColor;

@end
