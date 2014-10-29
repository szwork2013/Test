//
//  UserItem.h
//  learn
//
//  Created by Kenrick on 13-4-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Jastor.h"


@interface Avatar :  Jastor

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *url;

@end


@interface UserItem : Jastor
{
    
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *short_name;
@property (nonatomic, copy) NSString *sortable_name;
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, copy) NSString *time_zone;
@property (nonatomic, retain) Avatar *avatar;

@end


@interface Pseudonym :  Jastor

@property (nonatomic, copy) NSString *unique_id;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) int send_confirmation;

@end


@interface User4Request :  Jastor

@property (nonatomic, retain) UserItem  *user;
@property (nonatomic, retain) Pseudonym  *pseudonym;

@end

