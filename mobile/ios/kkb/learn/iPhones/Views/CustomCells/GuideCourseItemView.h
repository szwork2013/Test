//
//  GuideCourseItemView.h
//  learn
//
//  Created by xgj on 14-7-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideCourseItemModelProtocol.h"

@class GuideCourseItemModel;

@protocol GuideCourseItemDelegate <NSObject>

@required
- (void)guideCourseItemDidSelect:(GuideCourseItemModel *)data;

@end

@interface GuideCourseItemView : UIControl

@property(strong, nonatomic) GuideCourseItemModel *model;
@property(nonatomic, strong) UIView *itemSeperateLine;

@property(nonatomic, weak) id<GuideCourseItemDelegate> delegate;

@end
