//
//  UserItem.m
//  learn
//
//  Created by Kenrick on 13-4-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "UserItem.h"

@implementation UserItem

@synthesize name;
@synthesize short_name;
@synthesize sortable_name;
@synthesize avatar;
@synthesize locale;
@synthesize time_zone;

- (id)init
{
    if (self = [super init])
    {
        self.locale = @"zh";
        self.time_zone = @"Beijing";
        self.avatar = [[Avatar alloc] init];
    }
    
    return self;
}


@end

@implementation Avatar

@synthesize token;
@synthesize url;


@end

@implementation Pseudonym

@synthesize unique_id;
@synthesize password;
@synthesize send_confirmation;

- (id)init
{
    if (self = [super init])
    {
        self.send_confirmation = 1;
    }
    
    return self;
}



@end


@implementation User4Request

@synthesize user;
@synthesize pseudonym;

- (id)init
{
    if (self = [super init])
    {
        self.user = [[UserItem alloc] init];
        self.pseudonym = [[Pseudonym alloc] init];
    }

    return self;
}


@end
