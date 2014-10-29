//
//  CourseUnitStructs.h
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseUnitStructs : NSObject

@property (nonatomic, retain) NSMutableArray *modulesArray; //指定课程的单元Modules
@property (nonatomic, retain) NSMutableDictionary *modulesItemDic; //可下载的单元详细item

@end


@interface UnitItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *prerequisite_module_ids;
@property (nonatomic, copy) NSString *require_sequential_progress;
@property (nonatomic, copy) NSString *unlock_at;
@property (nonatomic, copy) NSString *workflow_state;
@property (nonatomic, copy) NSString *ableDownload;

@end


@interface UnitDownladItem : NSObject

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videoTitle;
@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *hasDownloaded;

@end
/*
@interface UnitDetailItem : NSObject

@property (nonatomic, copy) NSString *html_url;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *indent;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *videoUrl;

@end
*/