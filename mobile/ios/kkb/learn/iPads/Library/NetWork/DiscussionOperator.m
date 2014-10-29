//
//  DiscussionOperator.m
//  learn
//
//  Created by User on 13-12-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "DiscussionOperator.h"
#import "JSONKit.h"
#import "AppUtilities.h"

@implementation DiscussionOperator
@synthesize discussionTopic;



- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_DISCUSSION;
        self.discussionTopic = [[DiscussionTopicStructs alloc] init];
    }
    
    return self;
}

//网络Url--------------------------------

//网络请求 -------------------------------

- (void)postDiscussionReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entries:(NSDictionary *)entries
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/discussion_topics/%@/entries", API_HOST, courseId,topic_id];
    NSString *json = [entries JSONString];
    [self postJSONFromUrl:delegate command:HTTP_CMD_COURSE_REPLYANNOUNCEMENTS jsonUrl:jsonUrl token:token json:json];
}

//回复人员讨论
- (void)postDiscussionPeopleReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entry_id:(NSString *)entry_id replies:(NSDictionary *)replies
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/discussion_topics/%@/entries/%@/replies", API_HOST, courseId,topic_id,entry_id];
    NSString *json = [replies JSONString];
    [self postJSONFromUrl:delegate command:HTTP_CMD_COURSE_REPLYPEOPLE jsonUrl:jsonUrl token:token json:json];
}
//获取讨论
- (void)requestDiscussions:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/discussion_topics?per_page=%d", API_HOST, courseId,PerPage];
//    NSLog(@"%@",jsonUrl);
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_DISCUSSION jsonUrl:jsonUrl token:token];
}

//获取讨论ALLTopicEntry
- (void)requestALLTopicEntry:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/discussion_topics/%@/view", API_HOST, courseId, topic_id];
//      NSLog(@"%@",jsonUrl);
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_DISSCUSSION_ALLTOPICENTRY jsonUrl:jsonUrl token:token];
}
//网络解析 -------------------------------

//通告
- (void)parseDiscussions:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [self.discussionTopic.discussionsItemArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        DiscussionTopicItem *item = [[DiscussionTopicItem alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.assignment_id = [dic objectForKey:@"assignment_id"];
        item.delayed_post_at = [dic objectForKey:@"delayed_post_at"];
        item.last_reply_at = [dic objectForKey:@"last_reply_at"];
        
        id posts = [dic objectForKey:@"podcast_has_student_posts"] ;
        if( posts != [NSNull null]){
            item.podcast_has_student_posts = [[dic objectForKey:@"podcast_has_student_posts"] boolValue];
        }
        item.posted_at = [dic objectForKey:@"posted_at"];
        item.root_topic_id = [dic objectForKey:@"root_topic_id"];
        item.title = [dic objectForKey:@"title"];
        id users = [dic objectForKey:@"user_name"] ;
        if( users != [NSNull null]){
            item.user_name = [dic objectForKey:@"user_name"];
        }
        item.discussion_subentry_count = [dic objectForKey:@"discussion_subentry_count"];
        item.message = [dic objectForKey:@"message"];
        item.discussion_type = [dic objectForKey:@"discussion_type"];
        item.require_initial_post = [dic objectForKey:@"require_initial_post"];
        item.podcast_url = [dic objectForKey:@"podcast_url"];
        item.read_state = [dic objectForKey:@"read_state"];
        item.unread_count = [dic objectForKey:@"unread_count"];
        item.locked = [[dic objectForKey:@"locked"] boolValue];
        item.html_url = [dic objectForKey:@"html_url"];
        item.url = [dic objectForKey:@"url"];
        
        NSDictionary *permissions = [dic objectForKey:@"permissions"];
        item.permissions.attach = [[permissions objectForKey:@"attach"] boolValue];
        item.permissions.update = [[permissions objectForKey:@"update"] boolValue];
        item.permissions._delete = [[permissions objectForKey:@"delete"] boolValue];
        
        NSDictionary *author = [dic objectForKey:@"author"];
        item.author._id = [author objectForKey:@"id"];
        item.author.display_name = [author objectForKey:@"display_name"];
        item.author.avatar_image_url = [author objectForKey:@"avatar_image_url"];
        item.author.html_url = [author objectForKey:@"html_url"];
        
        NSArray *attachments = [dic objectForKey:@"attachments"];
        for(NSDictionary *dic in attachments)
        {
            DiscussionTopicAttachmentsItem *attachmentsItem = [[DiscussionTopicAttachmentsItem alloc] init];
            
            attachmentsItem._id = [dic objectForKey:@"id"];
            attachmentsItem.contentType = [dic objectForKey:@"content-type"];
            attachmentsItem.display_name = [dic objectForKey:@"display_name"];
            attachmentsItem.filename = [dic objectForKey:@"filename"];
            attachmentsItem.url = [dic objectForKey:@"url"];
            attachmentsItem.size = [dic objectForKey:@"size"];
            attachmentsItem.created_at = [dic objectForKey:@"created_at"];
            attachmentsItem.updated_at = [dic objectForKey:@"updated_at"];
            attachmentsItem.unlock_at = [dic objectForKey:@"unlock_at"];
            attachmentsItem.locked = [[permissions objectForKey:@"locked"] boolValue];
            attachmentsItem.hidden = [[permissions objectForKey:@"hidden"] boolValue];
            attachmentsItem.lock_at = [dic objectForKey:@"lock_at"];
            attachmentsItem.locked_for_user = [[permissions objectForKey:@"locked_for_user"] boolValue];
            attachmentsItem.hidden_for_user = [[permissions objectForKey:@"hidden_for_user"] boolValue];
            
            [item.attachments addObject:attachmentsItem];
        }
        
        [self.discussionTopic.discussionsItemArray addObject:item];
    }
}

//通告ALLTopicEntry
- (void)parseALLTopicEntry:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    
    NSArray *participants = [dic objectForKey:@"participants"];
    [self.discussionTopic.allTopicEntry.participants removeAllObjects];
    for(NSDictionary *dic in participants)
    {
        TopicEntryParticipantsItem *item = [[TopicEntryParticipantsItem alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.display_name = [dic objectForKey:@"display_name"];
        item.avatar_image_url = [dic objectForKey:@"avatar_image_url"];
        item.html_url = [dic objectForKey:@"html_url"];
        
        [self.discussionTopic.allTopicEntry.participants addObject:item];
    }
    
    NSArray *views = [dic objectForKey:@"view"];
    [self.discussionTopic.allTopicEntry.views removeAllObjects];
    for(NSDictionary *dic in views)
    {
        TopicEntryItem *item = [[TopicEntryItem alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.created_at = [dic objectForKey:@"created_at"];
        item.parent_id = [dic objectForKey:@"parent_id"];
        item.updated_at = [dic objectForKey:@"updated_at"];
        item.user_id = [dic objectForKey:@"user_id"];
        item.message = [dic objectForKey:@"message"];
        
        NSArray *replies = [dic objectForKey:@"replies"];
        for(NSDictionary *dic in replies)
        {
            TopicEntryReplyItem *replyItem = [[TopicEntryReplyItem alloc] init];
            
            replyItem._id = [dic objectForKey:@"id"];
            replyItem.created_at = [dic objectForKey:@"created_at"];
            replyItem.parent_id = [dic objectForKey:@"parent_id"];
            replyItem.updated_at = [dic objectForKey:@"updated_at"];
            replyItem.user_id = [dic objectForKey:@"user_id"];
            replyItem.message = [AppUtilities cleanHtml:(NSMutableString *)[dic objectForKey:@"message"]];
            if([dic objectForKey:@"deleted"] == nil){
            [item.replys addObject:replyItem];
            }
        }
        
        [self.discussionTopic.allTopicEntry.views addObject:item];
    }
}
//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    if ([cmd compare:HTTP_CMD_COURSE_DISCUSSION] == NSOrderedSame)
    {
        [self parseDiscussions:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_COURSE_DISSCUSSION_ALLTOPICENTRY] == NSOrderedSame)
    {
        [self parseALLTopicEntry:jsonDatas];
    }
    
    [super requestFinished:subDelegate cmd:cmd jsonDatas:jsonDatas url:url];
}


@end
