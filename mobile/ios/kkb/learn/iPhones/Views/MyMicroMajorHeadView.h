//
//  MyMicroMajorHeadView.h
//  learn
//
//  Created by zxj on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeadViewDelegate <NSObject>

@required
- (void)headerViewDidSelectInSection:(NSInteger)section;

@end

@interface MyMicroMajorHeadView : UIControl

@property(strong, nonatomic) UIImageView *headImageView;
@property(strong, nonatomic) UILabel *majorNameLabel;
@property(strong, nonatomic) UILabel *progressLabel;
@property(nonatomic, assign) NSInteger section;

@property(nonatomic, weak) id<HeadViewDelegate> delegate;

@end
