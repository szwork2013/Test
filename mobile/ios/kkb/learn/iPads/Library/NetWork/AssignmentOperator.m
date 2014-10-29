//
//  AssignmentOperator.m
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "AssignmentOperator.h"
#import "JSONKit.h"

@implementation AssignmentOperator
@synthesize assignmentStructs;



- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_ASSIGNMENT;
        self.assignmentStructs = [[AssignmentInCourseStructs alloc] init];
    }
    
    return self;
}

//网络Url--------------------------------

//网络请求 -------------------------------

//获取作业
- (void)requestAssignments:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/assignments?per_page=%d", API_HOST, courseId,PerPage ];
//    NSLog(@"%@",jsonUrl);
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSE_ASSIGNMENT jsonUrl:jsonUrl token:token];
}

//网络解析 -------------------------------


- (void)parseAssignments:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
//    NSLog(@"json == %@",array);
    [self.assignmentStructs.assignmentsItemArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        AssignmentItem *item = [[AssignmentItem alloc] init];
        
        item._id = [dic objectForKey:@"id"];
        item.name = [dic objectForKey:@"name"];
        item.due_at = [dic objectForKey:@"due_at"];
//        item.assignment_group_id = [dic objectForKey:@"assignment_group_id"];
//        item.unlock_at = [dic objectForKey:@"unlock_at"];
//        item.html_url = [dic objectForKey:@"html_url"];
        item.points = [dic objectForKey:@"points_possible"];
        item.unlock_at = [dic objectForKey:@"lock_at"];
//        item.lock_at = [dic objectForKey:@"lock_at"];
//        NSArray *lock_info = [dic objectForKey:@"lock_info"];
//        for (NSDictionary *dicDetail in lock_info) {
//            
//        }
        
        NSDictionary *lock_info = [dic objectForKey:@"lock_info"];
        
         item.lock_at = [lock_info objectForKey:@"lock_at"];
//        NSLog(@"lock_info===%@",lock_info);
//        NSLog(@"**%@",[lock_info objectForKey:@"unlock_at"]);
//        NSLog(@"*%@",item.unlock_at);
        
         NSDictionary *discussion_topic = [dic objectForKey:@"discussion_topic"];
//        for (NSDictionary *dicDetail2 in discussion_topic) {
              item.message = [discussion_topic objectForKey:@"message"];
//        }
        [self.assignmentStructs.assignmentsItemArray addObject:item];
    }

    
//        item.assignment_id = [dic objectForKey:@"assignment_id"];
//        item.delayed_post_at = [dic objectForKey:@"delayed_post_at"];
//        item.last_reply_at = [dic objectForKey:@"last_reply_at"];
        
//        id posts = [dic objectForKey:@"podcast_has_student_posts"] ;
//        if( posts != [NSNull null]){
//            item.podcast_has_student_posts = [[dic objectForKey:@"podcast_has_student_posts"] boolValue];
//        }
//        item.posted_at = [dic objectForKey:@"posted_at"];
//        item.root_topic_id = [dic objectForKey:@"root_topic_id"];
//        item.title = [dic objectForKey:@"title"];
//        id users = [dic objectForKey:@"user_name"] ;
//        if( users != [NSNull null]){
//            item.user_name = [dic objectForKey:@"user_name"];
//        }
//        item.discussion_subentry_count = [dic objectForKey:@"discussion_subentry_count"];
//        item.message = [dic objectForKey:@"message"];
//        item.discussion_type = [dic objectForKey:@"discussion_type"];
//        item.require_initial_post = [dic objectForKey:@"require_initial_post"];
//        item.podcast_url = [dic objectForKey:@"podcast_url"];
//        item.read_state = [dic objectForKey:@"read_state"];
//        item.unread_count = [dic objectForKey:@"unread_count"];
//        item.locked = [[dic objectForKey:@"locked"] boolValue];
        
//        item.url = [dic objectForKey:@"url"];
        
//        NSDictionary *permissions = [dic objectForKey:@"permissions"];
//        item.permissions.attach = [[permissions objectForKey:@"attach"] boolValue];
//        item.permissions.update = [[permissions objectForKey:@"update"] boolValue];
//        item.permissions._delete = [[permissions objectForKey:@"delete"] boolValue];
//        
//        NSDictionary *author = [dic objectForKey:@"author"];
//        item.author._id = [author objectForKey:@"id"];
//        item.author.display_name = [author objectForKey:@"display_name"];
//        item.author.avatar_image_url = [author objectForKey:@"avatar_image_url"];
//        item.author.html_url = [author objectForKey:@"html_url"];
//        
//        NSArray *attachments = [dic objectForKey:@"attachments"];
//        for(NSDictionary *dic in attachments)
//        {
//            DiscussionTopicAttachmentsItem *attachmentsItem = [[DiscussionTopicAttachmentsItem alloc] init];
//            
//            attachmentsItem._id = [dic objectForKey:@"id"];
//            attachmentsItem.contentType = [dic objectForKey:@"content-type"];
//            attachmentsItem.display_name = [dic objectForKey:@"display_name"];
//            attachmentsItem.filename = [dic objectForKey:@"filename"];
//            attachmentsItem.url = [dic objectForKey:@"url"];
//            attachmentsItem.size = [dic objectForKey:@"size"];
//            attachmentsItem.created_at = [dic objectForKey:@"created_at"];
//            attachmentsItem.updated_at = [dic objectForKey:@"updated_at"];
//            attachmentsItem.unlock_at = [dic objectForKey:@"unlock_at"];
//            attachmentsItem.locked = [[permissions objectForKey:@"locked"] boolValue];
//            attachmentsItem.hidden = [[permissions objectForKey:@"hidden"] boolValue];
//            attachmentsItem.lock_at = [dic objectForKey:@"lock_at"];
//            attachmentsItem.locked_for_user = [[permissions objectForKey:@"locked_for_user"] boolValue];
//            attachmentsItem.hidden_for_user = [[permissions objectForKey:@"hidden_for_user"] boolValue];
//            
//            [item.attachments addObject:attachmentsItem];
//            [attachmentsItem release];
//        }
        
}



//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    if ([cmd compare:HTTP_CMD_COURSE_ASSIGNMENT] == NSOrderedSame)
    {
        [self parseAssignments:jsonDatas];
    }
    
    [super requestFinished:subDelegate cmd:cmd jsonDatas:jsonDatas url:url];
}

@end
