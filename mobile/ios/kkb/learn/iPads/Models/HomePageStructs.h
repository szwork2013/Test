//
//  HomePageStructs.h
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////
//首页信息
/////////////////////////////////////////////

@interface HomePageStructs : NSObject
{
    
}

@property (nonatomic, retain) NSMutableArray *headerSliderArray; //首页推荐数据
@property (nonatomic, retain) NSMutableArray *allCoursesArray; //全部课程数据
@property (nonatomic, retain) NSMutableArray *myCoursesArray; //我的课程数据
@property (nonatomic, retain) NSMutableArray *modulesArray; //指定课程的单元Modules
@property (nonatomic, retain) NSMutableArray *modulesItemArray; //指定课程的单元Module的item
@property (nonatomic, retain) NSMutableArray *badgesArray;//badge图标
@property (nonatomic, retain) NSMutableArray *announcementArray;//个人中心通告
@property (nonatomic, retain) NSMutableArray *categoryArray;//课程类型
@end


@interface HomePageSliderItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *courseBrief;
@property (nonatomic, copy) NSString *courseTitle;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *sliderImage;

@end


@interface AllCoursesItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *courseId;//
@property (nonatomic, copy) NSString *courseName;//
@property (nonatomic, copy) NSString *courseType;//
@property (nonatomic, copy) NSString *courseBrief;
@property (nonatomic, copy) NSString *courseIntro;//
@property (nonatomic, copy) NSString *coverImage;//
@property (nonatomic, copy) NSString *promoVideo;//
@property (nonatomic, copy) NSString *price;//
@property (nonatomic, copy) NSString *startDate;//
@property (nonatomic, copy) NSString *schoolName;//
@property (nonatomic, copy) NSString *trialURL;//
@property (nonatomic, copy) NSString *payURL;//
@property (nonatomic, copy) NSString *instructorAvatar;//
@property (nonatomic, copy) NSString *instructorName;//
@property (nonatomic, copy) NSString *instructorTitle;//
@property (nonatomic, copy) NSString *estimate;//
@property (nonatomic, copy) NSString *courseNum;//
@property (nonatomic, copy) NSString *courseKeywords;//
@property  (nonatomic, copy) NSString * visible;//
@property (nonatomic, copy) NSArray *courseBadges;//
@property (nonatomic, copy) NSString *courseCategory;//
@end


@interface MyCourseItem :NSObject

@property (nonatomic, copy) NSString *account_id;
@property (nonatomic, copy) NSString *courseId;//
@property (nonatomic, copy) NSString *courseBigImage;
@property (nonatomic, copy) NSString*courseSmallImage;
@property (nonatomic, copy) NSString *courseName;//
@property (nonatomic, copy) NSString *start_at;//
@property (nonatomic, copy) NSString *end_at;//
@property (nonatomic, copy) NSString *course_code;
@property (nonatomic, copy) NSString *hide_final_grades;
@property (nonatomic,copy) NSString *schoolName;//
@property (nonatomic,copy) NSString *instructorName;//
@property (nonatomic,copy) NSString *instructorTitle;//
@property (nonatomic,copy) NSString *instructorAvatar;//
@property (nonatomic,copy) NSString *coverImage;//
@property (nonatomic,copy) NSString *promoVideo;
@property (nonatomic,copy) NSString *price;
@property (nonatomic,copy) NSString *startDate;
@property (nonatomic,copy) NSString *trialURL;
@property (nonatomic,copy) NSString *payURL;
@property (nonatomic,copy) NSString *courseBrief;//
@property (nonatomic, copy) NSString *courseType;//
@end


@interface MyBadges : NSObject

@property (nonatomic, copy) NSString *badge_id;
@property (nonatomic, copy) NSString *badgeTitle;
@property (nonatomic, copy) NSString *image4small;
@property (nonatomic, copy) NSString *image4big;
@end

@interface MyAnnouncement : NSObject

@property (nonatomic, copy) NSString *course_id;
@property (nonatomic, copy) NSString *announcement_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *url;
@property BOOL hasRead;
@end