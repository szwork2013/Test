//
//  DiscussionTopicStructs.h
//  learn
//
//  Created by User on 13-7-10.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALLTopicEntryItem;

@interface DiscussionTopicStructs : NSObject

@property (nonatomic, retain) NSMutableArray *announcementsItemArray; //通知Module的item，即DiscussionTopicItem
@property (nonatomic, retain) NSMutableArray *discussionsItemArray;
@property (nonatomic, retain) ALLTopicEntryItem *allTopicEntry;

@end



//*****************DiscussionTopic****************

@interface PermissionsItem : NSObject

@property (nonatomic, assign) BOOL attach;
@property (nonatomic, assign) BOOL update;
@property (nonatomic, assign) BOOL _delete;

@end


@interface AuthorItem : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *display_name;
@property (nonatomic, copy) NSString *avatar_image_url;
@property (nonatomic, copy) NSString *html_url;

@end


@interface DiscussionTopicItem : NSObject

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

@property (nonatomic, retain) PermissionsItem *permissions;
@property (nonatomic, retain) AuthorItem *author;


@end

//附件
@interface DiscussionTopicAttachmentsItem : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *display_name;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *unlock_at;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, copy) NSString *lock_at;
@property (nonatomic, assign) BOOL locked_for_user;
@property (nonatomic, assign) BOOL hidden_for_user;

@end

//*****************TopicEntry****************

@interface TopicEntryReplyItem : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *user_id;
//@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *message;
//@property (nonatomic, copy) NSString *read_state;
//@property (nonatomic, assign) BOOL has_more_replies;

@end

@interface TopicEntryItem : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *created_at;
@property (nonatomic, copy) NSString *parent_id;
@property (nonatomic, copy) NSString *updated_at;
@property (nonatomic, copy) NSString *user_id;
//@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *message;
//@property (nonatomic, copy) NSString *read_state;
//@property (nonatomic, assign) BOOL has_more_replies;

@property (nonatomic, retain) NSMutableArray *replys; //里面存放的是TopicEntryReplyItem

//@property (nonatomic, retain) TopicEntryReplyItem *replyItem;

@end


@interface TopicEntryParticipantsItem : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *display_name;
@property (nonatomic, copy) NSString *avatar_image_url;
@property (nonatomic, copy) NSString *html_url;

@end


@interface ALLTopicEntryItem : NSObject

@property (nonatomic, retain) NSMutableArray *unread_entries;
@property (nonatomic, retain) NSMutableArray *participants;
@property (nonatomic, retain) NSMutableArray *views;
//@property (nonatomic, retain) NSMutableArray *new_entries;

@end
