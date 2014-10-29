//
//  DiscussionOperator.h
//  learn
//
//  Created by User on 13-12-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"
#import "DiscussionTopicStructs.h"


@interface DiscussionOperator : BaseOperator

@property (nonatomic, retain) DiscussionTopicStructs *discussionTopic; //讨论结构体

//网络Url--------------------------------
//回复讨论
- (void)postDiscussionReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entries:(NSDictionary *)entries;
//回复人员讨论
- (void)postDiscussionPeopleReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entry_id:(NSString *)entry_id replies:(NSDictionary *)replies;
//网络请求 -------------------------------
- (void)requestDiscussions:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取讨论
- (void)requestALLTopicEntry:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id;//获取讨论ALLTopicEntry

//网络解析 -------------------------------
- (void)parseDiscussions:(NSString *)jsonDatas; //讨论
- (void)parseALLTopicEntry:(NSString *)jsonDatas; //讨论ALLTopicEntry


@end
