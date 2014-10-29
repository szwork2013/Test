//
//  GuideCourseVideoItemModel.h
//  learn
//
//  Created by zengmiao on 8/9/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideCourseItemModelProtocol.h"

@interface GuideCourseVideoItemModel : NSObject <GuideCourseItemModelProtocol>

@property(nonatomic, assign) GuideCourseItemType guideType;

@property(nonatomic, copy) NSString *video_count;
@property(nonatomic, copy) NSString *view_count;

@end
