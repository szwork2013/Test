//
//  UserStructs.h
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersInCourseStructs : NSObject

@property (nonatomic, retain) NSMutableArray *teachers; //人员中老师
@property (nonatomic, retain) NSMutableArray *tas; //人员中助教
@property (nonatomic, retain) NSMutableArray *students; //人员中学生

@end


@interface User : NSObject

@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sortable_name;
@property (nonatomic, copy) NSString *short_name;
@property (nonatomic, copy) NSString *sis_user_id;
@property (nonatomic, copy) NSString *login_id;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, retain) NSMutableArray *enrollments;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, copy) NSString *last_login;

@end