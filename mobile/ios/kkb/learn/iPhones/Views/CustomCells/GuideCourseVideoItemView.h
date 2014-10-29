//
//  GuideCourseVideoItemView.h
//  learn
//
//  Created by xgj on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ItemImageViewTag 2000
#define ItemTitleLabelTag 2001
#define ItemProgressViewTag 2003
#define ItemFlagImageViewTag 2004
#define ItemProgessLabelTag 2005

@class GuideCourseVideoItemModel;

@protocol GuideCourseVideoItemDelegate <NSObject>

@required
- (void)guideCourseVideoItemDidSelect;

@end

@interface GuideCourseVideoItemView : UIControl

@property(nonatomic, strong) GuideCourseVideoItemModel *model;
@property(nonatomic, weak) id<GuideCourseVideoItemDelegate> delegate;

@end
