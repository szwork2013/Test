//
//  AnnouncementOperator.h
//  learn
//
//  Created by User on 13-7-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "BaseOperator.h"
#import "DiscussionTopicStructs.h"


@interface AnnouncementOperator : BaseOperator

@property (nonatomic, retain) DiscussionTopicStructs *discussionTopic; //通知结构体


//网络Url--------------------------------

//网络请求 -------------------------------

//回复通告
- (void)postAnnouncementReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entries:(NSDictionary *)entries;
//回复人员讨论
- (void)postAnnouncementPeopleReply:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id entry_id:(NSString *)entry_id replies:(NSDictionary *)replies;
- (void)requestAnnouncements:(id)delegate token:(NSString *)token courseId:(NSString *)courseId;//获取通告
- (void)requestALLTopicEntry:(id)delegate token:(NSString *)token courseId:(NSString *)courseId topic_id:(NSString *)topic_id;//获取通告ALLTopicEntry

//网络解析 -------------------------------
- (void)parseAnnouncements:(NSString *)jsonDatas; //通告
- (void)parseALLTopicEntry:(NSString *)jsonDatas; //通告ALLTopicEntry

@end
