//
//  CourseUnitStructs.m
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "CourseUnitStructs.h"

@implementation CourseUnitStructs

@synthesize modulesArray;
@synthesize modulesItemDic;

- (id)init
{
    if (self = [super init])
    {
        self.modulesArray = [NSMutableArray array];
        self.modulesItemDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}


@end


@implementation UnitItem

@synthesize item_id;
@synthesize name;
@synthesize position;
@synthesize prerequisite_module_ids;
@synthesize require_sequential_progress;
@synthesize unlock_at;
@synthesize workflow_state;
@synthesize ableDownload;

static NSString *unitName = @"name";
static NSString *unitUnlock = @"unlock_at";
static NSString *unitAbleDownload = @"ableDownload";

#pragma mark coding
-(id) initWithCoder:(NSCoder*)decoder {
    UnitItem *item = [self init];
    // Auto-generated decoding of instance-variables
    item.name = [decoder decodeObjectForKey:unitName];
    item.unlock_at = [decoder decodeObjectForKey:unitUnlock];
     item.ableDownload = [decoder decodeObjectForKey:unitAbleDownload];
    return item;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:unitName];
    [aCoder encodeObject:self.unlock_at forKey:unitUnlock];
    [aCoder encodeObject:self.ableDownload forKey:unitAbleDownload];
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end

/*
@implementation UnitDetailItem

@synthesize html_url;
@synthesize _id;
@synthesize indent;
@synthesize position;
@synthesize title;
@synthesize type;
@synthesize videoUrl;

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    self.html_url = nil;
    self._id = nil;
    self.indent = nil;
    self.position = nil;
    self.title = nil;
    self.type = nil;
    self.videoUrl = nil;
    
    [super dealloc];
}

@end
*/
@implementation UnitDownladItem
@synthesize videoTitle;
@synthesize itemID;
@synthesize videoUrl;
@synthesize hasDownloaded;
- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end