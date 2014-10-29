//
//  AssignmentInCourseStructs.m
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "AssignmentInCourseStructs.h"

@implementation AssignmentInCourseStructs

@synthesize assignmentsItemArray;


- (id)init
{
    if (self = [super init])
    {
        self.assignmentsItemArray = [NSMutableArray array];
          }
    
    return self;
}


@end

@implementation AssignmentItem

@synthesize _id;
@synthesize assignment_id;
@synthesize delayed_post_at;
@synthesize last_reply_at;
@synthesize podcast_has_student_posts;
@synthesize posted_at;
@synthesize root_topic_id;
@synthesize title;
@synthesize user_name;
@synthesize discussion_subentry_count;
@synthesize message;
@synthesize discussion_type;
@synthesize require_initial_post;
@synthesize podcast_url;
@synthesize read_state;
@synthesize unread_count;
@synthesize topic_children;
@synthesize attachments;
@synthesize locked;
@synthesize html_url;
@synthesize url;
@synthesize assignment_group_id;
@synthesize due_at;
@synthesize unlock_at;
@synthesize lock_at;
@synthesize name;
@synthesize points;

- (id)init
{
    if (self = [super init])
    {
//        self.permissions = [[[PermissionsItem alloc] init] autorelease];
//        self.author = [[[AuthorItem alloc] init] autorelease];
//        self.topic_children = [NSMutableArray array];
//        self.attachments = [NSMutableArray array];
//        podcast_has_student_posts = NO;
//        require_initial_post = NO;
//        locked = NO;
    }
    
    return self;
}


@end


