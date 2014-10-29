//
//  ContentCell.h
//  learn
//
//  Created by zxj on 6/25/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCell : UICollectionViewCell
@property (retain,nonatomic)UILabel *label;
@property (retain,nonatomic)NSString *text;
@property (retain,nonatomic)UIImageView *lineImageView;

+(CGSize)sizeForContentString:(NSString *)s;
@end
