//
//  DiscussionTopicStructs.m
//  learn
//
//  Created by User on 13-7-10.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "DiscussionTopicStructs.h"

@implementation DiscussionTopicStructs

@synthesize announcementsItemArray;
@synthesize discussionsItemArray;
@synthesize allTopicEntry;

- (id)init
{
    if (self = [super init])
    {
        self.announcementsItemArray = [NSMutableArray array];
        self.discussionsItemArray = [NSMutableArray array];
        self.allTopicEntry = [[ALLTopicEntryItem alloc] init];
    }
    
    return self;
}


@end

@implementation PermissionsItem

@synthesize attach;
@synthesize update;
@synthesize _delete;

- (id)init
{
    if (self = [super init])
    {
        attach = NO;
        update = NO;
        _delete = NO;
    }
    
    return self;
}


@end


@implementation AuthorItem

@synthesize _id;
@synthesize display_name;
@synthesize avatar_image_url;
@synthesize html_url;

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end


@implementation DiscussionTopicItem

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
@synthesize permissions;
@synthesize author;

- (id)init
{
    if (self = [super init])
    {
        self.permissions = [[PermissionsItem alloc] init];
        self.author = [[AuthorItem alloc] init];
        self.topic_children = [NSMutableArray array];
        self.attachments = [NSMutableArray array];
        podcast_has_student_posts = NO;
        require_initial_post = NO;
        locked = NO;
    }
    
    return self;
}


@end


@implementation DiscussionTopicAttachmentsItem

@synthesize _id;
@synthesize contentType;
@synthesize url;
@synthesize filename;
@synthesize display_name;
@synthesize size;
@synthesize created_at;
@synthesize updated_at;
@synthesize unlock_at;
@synthesize lock_at;
@synthesize hidden;
@synthesize locked;
@synthesize locked_for_user;
@synthesize hidden_for_user;

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end


@implementation TopicEntryReplyItem

@synthesize _id;
@synthesize created_at;
@synthesize parent_id;
@synthesize updated_at;
@synthesize user_id;
//@synthesize user_name;
@synthesize message;
//@synthesize read_state;
//@synthesize has_more_replies;

- (id)init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}


@end

@implementation TopicEntryItem

@synthesize _id;
@synthesize created_at;
@synthesize parent_id;
@synthesize updated_at;
@synthesize user_id;
//@synthesize user_name;
@synthesize message;
//@synthesize read_state;
//@synthesize has_more_replies;
@synthesize replys;

- (id)init
{
    if (self = [super init])
    {
        self.replys = [NSMutableArray array];
    }
    
    return self;
}


@end


@implementation TopicEntryParticipantsItem

@synthesize _id;
@synthesize display_name;
@synthesize avatar_image_url;
@synthesize html_url;

- (id)init
{
    if (self = [super init])
    {

    }
    
    return self;
}


@end


@implementation ALLTopicEntryItem

@synthesize unread_entries;
@synthesize participants;
@synthesize views;
//@synthesize new_entries;

- (id)init
{
    if (self = [super init])
    {
        self.unread_entries = [NSMutableArray array];
        self.participants = [NSMutableArray array];
        self.views = [NSMutableArray array];
//        self.new_entries = [NSMutableArray array];
    }
    
    return self;
}


@end
