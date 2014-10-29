//
//  collectionItemView.h
//  learn
//
//  Created by zxj on 7/2/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionItemView : UIView
@property (retain,nonatomic)UILabel *label;
@property (retain,nonatomic)UIButton *labelButton;
@property (retain,nonatomic)NSString *text;
@property (retain,nonatomic)UIImageView *lineImageView;
@property (retain,nonatomic)UIImageView *pressImageView;

+(CGSize)sizeForContentString:(NSString *)s;
@end
