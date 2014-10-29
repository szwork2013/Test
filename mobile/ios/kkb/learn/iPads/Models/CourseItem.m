//
//  CourseItem.m
//  learn
//
//  Created by Kenrick on 13-4-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "CourseItem.h"

@implementation CourseItem

@end



@implementation Metas

@synthesize metas;

+ (Class)metas_class
{
    return [Meta class];
}


@end

@implementation Meta

@synthesize metaId;
@synthesize courseName;
@synthesize coverImage;
@synthesize promoVideo;
@synthesize price;
@synthesize startDate;
@synthesize schoolName;
@synthesize trialURL;
@synthesize payURL;
@synthesize instructorAvatar;
@synthesize instructorName;
@synthesize instructorTitle;


@end