//
//  AssignmentInCourseStructs.h
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"
@interface AssignmentInCourseStructs : NSObject


@property (nonatomic, retain) NSMutableArray *assignmentsItemArray;
@end


@interface AssignmentItem : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *assignment_id;
@property (nonatomic, copy) NSString *delayed_post_at;
@property (nonatomic, copy) NSString *last_reply_at;
@property (nonatomic, assign) BOOL podcast_has_student_posts;
@property (nonatomic, copy) NSString *posted_at;
@property (nonatomic, copy) NSString *root_topic_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *discussion_subentry_count;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *discussion_type;
@property (nonatomic, copy) NSString *require_initial_post;
@property (nonatomic, copy) NSString *podcast_url;
@property (nonatomic, copy) NSString *read_state;
@property (nonatomic, copy) NSString *unread_count;
@property (nonatomic, retain) NSMutableArray *topic_children;
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, copy) NSString *html_url;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *assignment_group_id;
@property (nonatomic, copy) NSString *due_at;
@property (nonatomic, copy) NSString *unlock_at;
@property (nonatomic, copy) NSString *lock_at;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *points;


@end

