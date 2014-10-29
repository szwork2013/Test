//
//  UserStructs.m
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "UsersInCourseStructs.h"

@implementation UsersInCourseStructs

@synthesize teachers;
@synthesize tas;
@synthesize students;

- (id)init
{
    if (self = [super init])
    {
        self.teachers = [NSMutableArray array];
        self.tas = [NSMutableArray array];
        self.students = [NSMutableArray array];
    }
    
    return self;
}


@end


@implementation User

@synthesize _id;
@synthesize name;
@synthesize sortable_name;
@synthesize short_name;
@synthesize sis_user_id;
@synthesize login_id;
@synthesize avatar_url;
@synthesize enrollments;
@synthesize email;
@synthesize locale;
@synthesize last_login;


- (id)init
{
    if (self = [super init])
    {
        self.enrollments = [[NSMutableArray alloc] init];
    }
    
    return self;
}


@end