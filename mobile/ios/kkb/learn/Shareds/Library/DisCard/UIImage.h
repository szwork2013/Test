//
//  UIImage.h
//  learn
//
//  Created by User on 13-11-29.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(UIImageScale)
-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;
- (UIImage *)rescaleImageToSize:(CGSize)size;
- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
@end
