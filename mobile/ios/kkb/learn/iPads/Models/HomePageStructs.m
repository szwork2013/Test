//
//  HomePageStructs.m
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "HomePageStructs.h"

@implementation HomePageStructs

@synthesize headerSliderArray;
@synthesize allCoursesArray;
@synthesize myCoursesArray;
@synthesize modulesArray;
@synthesize modulesItemArray;
@synthesize badgesArray;
@synthesize announcementArray;

- (id)init
{
    if (self = [super init])
    {
        self.headerSliderArray = [NSMutableArray array];
        self.allCoursesArray = [NSMutableArray array];
        self.myCoursesArray = [NSMutableArray array];
        self.modulesArray = [NSMutableArray array];
        self.modulesItemArray = [NSMutableArray array];
        self.badgesArray = [NSMutableArray array];
        self.announcementArray = [NSMutableArray array];
        self.categoryArray = [NSMutableArray array];
    }
    
    return self;
}


@end


@implementation HomePageSliderItem

@synthesize courseBrief;
@synthesize courseTitle;
@synthesize _id;
@synthesize sliderImage;



static NSString *couBrief = @"courseBrief";
static NSString *couTitle = @"courseTitle";
static NSString *cou_id = @"_id";
static NSString *couSliderImage = @"sliderImage";

#pragma mark coding
-(id) initWithCoder:(NSCoder*)decoder {
    HomePageSliderItem *hsItem = [self init];
        // Auto-generated decoding of instance-variables
        hsItem.courseBrief = [decoder decodeObjectForKey:couBrief];
        hsItem.courseTitle = [decoder decodeObjectForKey:couTitle];
        hsItem._id = [decoder decodeObjectForKey:cou_id];
        hsItem.sliderImage = [decoder decodeObjectForKey:couSliderImage];

    return hsItem;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.courseBrief forKey:couBrief];
    [aCoder encodeObject:self.courseTitle forKey:couTitle];
    [aCoder encodeObject:self._id forKey:cou_id];
    [aCoder encodeObject:self.sliderImage forKey:couSliderImage];
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end

@implementation AllCoursesItem

@synthesize courseId;
@synthesize courseName;
@synthesize courseType;
@synthesize courseBrief;
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
@synthesize courseIntro;
@synthesize courseKeywords;
@synthesize estimate;
@synthesize courseNum;
@synthesize courseBadges;
@synthesize visible;
@synthesize courseCategory;

static NSString *couId = @"courseId";
static NSString *couName = @"courseName";
static NSString *couType = @"courseType";
static NSString *couIntro = @"courseIntro";
static NSString *covImage = @"coverImage";
static NSString *stDate = @"startDate";
static NSString *vis = @"visible";
static NSString *couCategory = @"courseCategory";
static NSString *school = @"schoolName";
static NSString *estimateInAll = @"estimate";
static NSString *instructorNameInAll = @"instructorName";
static NSString *courseNumInAll = @"courseNum";
static NSString *courseBadgesInAll = @"courseBadges";
static NSString *courseKeywordsInAll = @"courseKeywords";
static NSString *instructorTitleInAll = @"instructorTitle";
static NSString *instructorAvatarInAll = @"instructorAvatar";
static NSString *promoVdieoInMy = @"promoVdieo";
static NSString *priceInMy = @"priceInMy";
static NSString *payURLInMy = @"payURLInMy";
static NSString *trialURLInMy = @"trialURLInMy";
- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}



#pragma mark coding
-(id) initWithCoder:(NSCoder*)decoder {
    AllCoursesItem *item = [self init];
    // Auto-generated decoding of instance-variables
    
    item.instructorAvatar = [decoder decodeObjectForKey:instructorAvatarInAll];
    item.instructorName = [decoder decodeObjectForKey:instructorNameInAll];
    item.instructorTitle = [decoder decodeObjectForKey:instructorTitleInAll];
    item.courseNum = [decoder decodeObjectForKey:courseNumInAll];
    item.courseBadges = [decoder decodeObjectForKey:courseBadgesInAll];
    item.courseKeywords = [decoder decodeObjectForKey:courseKeywordsInAll];
    item.courseId = [decoder decodeObjectForKey:couId];
    item.courseIntro = [decoder decodeObjectForKey:couIntro];
    item.courseName = [decoder decodeObjectForKey:couName];
    item.coverImage = [decoder decodeObjectForKey:covImage];
    item.startDate = [decoder decodeObjectForKey:stDate];
    item.visible = [decoder decodeObjectForKey:vis];
    item.promoVideo = [decoder decodeObjectForKey:promoVdieoInMy];
    item.price = [decoder decodeObjectForKey:priceInMy];
    item.payURL = [decoder decodeObjectForKey:payURLInMy];
    item.trialURL = [decoder decodeObjectForKey:trialURLInMy];
    item.courseType = [decoder decodeObjectForKey:couType];
    item.courseCategory = [decoder decodeObjectForKey:couCategory];
    item.schoolName = [decoder decodeObjectForKey:school];
    item.estimate = [decoder decodeObjectForKey:estimateInAll];
    return item;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.instructorAvatar forKey:instructorAvatarInAll];
    [aCoder encodeObject:self.instructorTitle forKey:instructorTitleInAll];
    [aCoder encodeObject:self.courseIntro forKey:couIntro];
    [aCoder encodeObject:self.courseId forKey:couId];
    [aCoder encodeObject:self.courseName forKey:couName];
    [aCoder encodeObject:self.coverImage forKey:covImage];
    [aCoder encodeObject:self.promoVideo forKey:promoVdieoInMy];
    [aCoder encodeObject:self.price forKey:priceInMy];
    [aCoder encodeObject:self.payURL forKey:payURL];
    [aCoder encodeObject:self.trialURL forKey:trialURLInMy];
    [aCoder encodeObject:self.startDate forKey:stDate];
    [aCoder encodeObject:self.visible forKey:vis];
    [aCoder encodeObject:self.courseType forKey:couType];
    [aCoder encodeObject:self.courseCategory forKey:couCategory];
    [aCoder encodeObject:self.schoolName forKey:school];
    [aCoder encodeObject:self.estimate forKey:estimateInAll];
    [aCoder encodeObject:self.instructorName forKey:instructorNameInAll];
    [aCoder encodeObject:self.courseNum forKey:courseNumInAll];
    [aCoder encodeObject:self.courseBadges forKey:courseBadgesInAll];
    [aCoder encodeObject:self.courseKeywords forKey:courseKeywordsInAll];

    
}

@end


@implementation MyCourseItem

@synthesize account_id;
@synthesize courseId;
@synthesize courseBigImage;
@synthesize courseSmallImage;
@synthesize courseName;
@synthesize start_at;
@synthesize end_at;
@synthesize course_code;
@synthesize hide_final_grades;
@synthesize schoolName;
@synthesize instructorName;
@synthesize instructorTitle;
@synthesize instructorAvatar;
@synthesize coverImage;
@synthesize promoVideo;
@synthesize price;
@synthesize startDate;
@synthesize trialURL;
@synthesize payURL;
@synthesize courseType;
@synthesize courseBrief;


static NSString *couIdInMy = @"courseId";
static NSString *couNameInMy = @"courseName";
static NSString *couTypeInMy = @"courseType";
static NSString *covImageInMy = @"coverImage";
static NSString *stDateInMy = @"start_at";
static NSString *endDateInMy = @"end_at";
static NSString *schoolNameInMy = @"schoolName";
static NSString *courseBriefInMy = @"courseBrief";
static NSString *instructorTitleInMy = @"instructorTitle";
static NSString *instructorAvatarInMy = @"instructorAvatar";
static NSString *instructorNameInMy = @"instructorName";
static NSString *promoVideoInMy = @"promoVideo";


#pragma mark coding
-(id) initWithCoder:(NSCoder*)decoder {
    MyCourseItem *item = [self init];
    // Auto-generated decoding of instance-variables
    item.courseId = [decoder decodeObjectForKey:couIdInMy];
    item.courseName = [decoder decodeObjectForKey:couNameInMy];
    item.coverImage = [decoder decodeObjectForKey:covImageInMy];
    item.start_at = [decoder decodeObjectForKey:stDateInMy];
    item.courseType = [decoder decodeObjectForKey:couTypeInMy];
    item.end_at = [decoder decodeObjectForKey:endDateInMy];
    item.schoolName = [decoder decodeObjectForKey:schoolNameInMy];
    item.courseBrief = [decoder decodeObjectForKey:courseBriefInMy];
    item.instructorTitle = [decoder decodeObjectForKey:instructorTitleInMy];
    item.instructorAvatar = [decoder decodeObjectForKey:instructorAvatarInMy];
    item.instructorName = [decoder decodeObjectForKey:instructorNameInMy];
    item.promoVideo = [decoder decodeObjectForKey:promoVideoInMy];
    return item;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.schoolName forKey:schoolNameInMy];
    [aCoder encodeObject:self.courseId forKey:couIdInMy];
    [aCoder encodeObject:self.courseName forKey:couNameInMy];
    [aCoder encodeObject:self.coverImage forKey:covImageInMy];
    [aCoder encodeObject:self.start_at forKey:stDateInMy];
    [aCoder encodeObject:self.courseType forKey:couType];
    [aCoder encodeObject:self.end_at forKey:endDateInMy];
    [aCoder encodeObject:self.courseBrief forKey:courseBriefInMy];
    [aCoder encodeObject:self.instructorTitle forKey:instructorTitleInMy];
    [aCoder encodeObject:self.instructorAvatar forKey:instructorAvatarInMy];
    [aCoder encodeObject:self.instructorName forKey:instructorNameInMy];
    [aCoder encodeObject:self.promoVideo forKey:promoVideoInMy];
    
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

@end

@implementation MyBadges
@synthesize badge_id;
@synthesize badgeTitle;
@synthesize image4big;
@synthesize image4small;

static NSString *badgeId = @"badge_id";
static NSString *badgeTi = @"badgeTitle";
static NSString *image4b = @"image4big";
static NSString *image4s = @"image4small";

#pragma mark coding
-(id) initWithCoder:(NSCoder*)decoder {
    MyBadges *item = [self init];
    // Auto-generated decoding of instance-variables
    item.badge_id = [decoder decodeObjectForKey:badgeId];
    item.badgeTitle = [decoder decodeObjectForKey:badgeTi];
    item.image4big = [decoder decodeObjectForKey:image4b];
    item.image4small = [decoder decodeObjectForKey:image4s];
    return item;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.badge_id forKey:badgeId];
    [aCoder encodeObject:self.badgeTitle forKey:badgeTi];
    [aCoder encodeObject:self.image4big forKey:image4b];
    [aCoder encodeObject:self.image4small forKey:image4s];
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

@end

@implementation MyAnnouncement
@synthesize course_id;
@synthesize announcement_id;
@synthesize type;
@synthesize title;
@synthesize created_at;
@synthesize url;

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

@end