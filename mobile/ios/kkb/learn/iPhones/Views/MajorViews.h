//
//  MajorViews.h
//  learn
//
//  Created by 翟鹏程 on 14-7-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CourseImageMargin 4
#define MajorViewCourseNameLabelTag 1000
#define MicroMajorCourseTitleLabelTag 1001

@protocol MiniMajorDelegate <NSObject>

- (void)miniMajorViewDidSelect:(UIView *)miniView;
- (void)miniMajorViewDidMove:(UIView *)miniView;

@end

@interface MajorViews : NSObject <UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)rect
          parentView:(UIView *)view
    andSubItemsCount:(NSUInteger)count;

@property(nonatomic) int row;
@property(nonatomic) BOOL opened;
@property(nonatomic, strong) UIControl *bgView;
@property(nonatomic, strong) UIView *majorView;

@property(nonatomic, strong) UIImageView *majorImageView;
@property(nonatomic, strong) UILabel *majorViewTitle;

@property(nonatomic, strong) UIView *majorIntro;
@property(nonatomic, strong) UILabel *majorIntroTitle;
@property(nonatomic, strong) UILabel *majorIntroContent;

@property(nonatomic, strong) NSMutableArray *subMajorViews;

@property(nonatomic, assign) NSUInteger subItemsCount;

@property(nonatomic, assign) float selfY;

@property(nonatomic, weak) id<MiniMajorDelegate> delegate;

- (void)openMajor;
- (void)closeMajor:(int)offsetY;
- (void)majorHeight;

+ (MajorViews *)createView;

@end
