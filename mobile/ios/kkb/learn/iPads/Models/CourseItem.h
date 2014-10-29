//
//  CourseItem.h
//  learn
//
//  Created by Kenrick on 13-4-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"


@interface CourseItem : Jastor

@end

@interface Metas : Jastor

@property (nonatomic, retain) NSArray  *metas;

@end

@interface Meta : Jastor

@property (nonatomic, copy) NSString *metaId;
@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *coverImage;
@property (nonatomic, copy) NSString *promoVideo;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, copy) NSString *trialURL;
@property (nonatomic, copy) NSString *payURL;
@property (nonatomic, copy) NSString *instructorAvatar;
@property (nonatomic, copy) NSString *instructorName;
@property (nonatomic, copy) NSString *instructorTitle;

@end