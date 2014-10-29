//
//  GlobalOperator.m
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "GlobalOperator.h"
#import "BaseOperator.h"
#import "HomePageOperator.h"
#import "CourseUnitOperator.h"
#import "UsersInCourseOperator.h"
#import "AnnouncementOperator.h"
#import "DiscussionOperator.h"
#import "AssignmentOperator.h"

@interface GlobalOperator ()
{
    NSMutableArray *operators;//所有模块操作符的指针(BaseOperator)
    int moduleTypes;
}

@property (nonatomic, retain) NSMutableArray *operators;


//根据KAIKEBA_MODULE_TYPE的集合来创建操作集
- (void)createOperatorWithModuleTypes:(int)types;

@end

static GlobalOperator *globalOperator = nil;

@implementation GlobalOperator

@synthesize user4Request;
@synthesize userId;
@synthesize isLogin;
@synthesize isLandscape;
@synthesize operators;

+ (GlobalOperator *)sharedInstance
{
    @synchronized(self)
    {
        if (globalOperator == nil)
        {
           globalOperator = [[self alloc] init];
        }
    }
    
    return globalOperator;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (globalOperator == nil)
        {
            globalOperator = [super allocWithZone:zone];
            
            return globalOperator;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
/*
- (id)retain
{
    return self;
}

- (unsigned long)retainCount
{
    return UINT_MAX;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}
*/

- (id)init
{
    if (self = [super init])
    {
        self.operators = [[NSMutableArray alloc] init];
        self.user4Request = [[User4Request alloc] init];
        self.isLogin = NO;
        self.isLandscape = YES;
        
        moduleTypes = KAIKEBA_MODULE_HOMEPAGE | KAIKEBA_MODULE_COURSEUNIT | KAIKEBA_MODULE_USERSINCOURSE | KAIKEBA_MODULE_ANNOUNCEMENT | KAIKEBA_MODULE_DISCUSSION | KAIKEBA_MODULE_ANNOUNCEMENT;
        [self createOperatorWithModuleTypes:moduleTypes];
    }
    
    return self;
}


//根据KAIKEBA_MODULE_TYPE的集合来创建操作集
- (void)createOperatorWithModuleTypes:(int)types
{
    if (types & KAIKEBA_MODULE_HOMEPAGE)
    {
        BaseOperator *op = [[HomePageOperator alloc] init];
        [operators addObject:op];
    }
    
    if (types & KAIKEBA_MODULE_COURSEUNIT)
    {
        BaseOperator *op = [[CourseUnitOperator alloc] init];
        [operators addObject:op];
    }
    
    if (types & KAIKEBA_MODULE_ANNOUNCEMENT)
    {
        BaseOperator *op = [[AnnouncementOperator alloc] init];
        [operators addObject:op];
    }
    
    if (types & KAIKEBA_MODULE_USERSINCOURSE)
    {
        BaseOperator *op = [[UsersInCourseOperator alloc] init];
        [operators addObject:op];
    }
    if (types & KAIKEBA_MODULE_DISCUSSION)
    {
        BaseOperator *op = [[DiscussionOperator alloc] init];
        [operators addObject:op];
    }
    if (types & KAIKEBA_MODULE_ANNOUNCEMENT)
    {
        BaseOperator *op = [[AssignmentOperator alloc] init];
        [operators addObject:op];
    }

    
    
}

//根据单个KAIKEBA_MODULE_TYPE类型来获得某一个操作实例
- (id)getOperatorWithModuleType:(KAIKEBA_MODULE_TYPE)type
{
    for (BaseOperator *op in operators)
    {
        if (op.moduleType == type)
        {
            return op;
        }
    }
    
    return nil;
}

@end
