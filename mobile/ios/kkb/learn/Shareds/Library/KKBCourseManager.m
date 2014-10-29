//
//  KKBCourseManager.m
//  learn
//
//  Created by zengmiao on 8/26/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBCourseManager.h"
#import "KKBHttpClient.h"

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@interface KKBCourseManager ()

@property(strong, nonatomic) NSDictionary *allCourses;

@end

@implementation KKBCourseManager

+ (instancetype)sharedInstace {
    static KKBCourseManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{ shareInstance = [[KKBCourseManager alloc] init]; });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _allCourses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (void)getAllCoursesForceReload:(BOOL)forceReload
               completionHandler:(completionHandler)handler {

    KKBCourseManager *manager = [KKBCourseManager sharedInstace];
    [manager getAllCoursesForceReload:forceReload completionHandler:handler];
}

- (void)getAllCoursesForceReload:(BOOL)forceReload
               completionHandler:(completionHandler)handler {

    NSString *urlPath = [NSString stringWithFormat:@"v1/courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:!forceReload
        success:^(id result, AFHTTPRequestOperation *operation) {

            if ([result isKindOfClass:[NSArray class]]) {
                [self processCoursesHashDic:result];
            }

            handler(self.allCourses, nil);
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {

            NSMutableDictionary *dictionary =
                [[NSMutableDictionary alloc] init];
            [dictionary setObject:@"获取所有课程信息失败！"
                           forKey:@"FailureReason"];
            NSError *err = [[NSError alloc] initWithDomain:@"KKBCourseManager"
                                                      code:0
                                                  userInfo:dictionary];

            handler(nil, err);
        }];
}

+ (void)updateAllCoursesForceReload:(BOOL)forceReload
                  completionHandler:(void (^)(BOOL success))block {

    KKBCourseManager *manager = [KKBCourseManager sharedInstace];

    NSString *urlPath = [NSString stringWithFormat:@"v1/courses"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:!forceReload
        success:^(id result, AFHTTPRequestOperation *operation) {

            if ([result isKindOfClass:[NSArray class]]) {
                [manager processCoursesHashDic:result];
            }

            block(YES);
        }
        failure:^(id result, AFHTTPRequestOperation *operation) { block(NO); }];
}

+ (void)getCourseWithID:(NSNumber *)courseID
            forceReload:(BOOL)forceReload
      completionHandler:(completionHandler)handler {
    KKBCourseManager *manager = [KKBCourseManager sharedInstace];

    [manager getCourseWithID:courseID
                 forceReload:forceReload
           completionHandler:handler];
}

/**
 *  根据courseIDs查询指定的course集合
 *
 *  @param courseIDs   courseIDs description
 *  @param forceReload forceReload description
 *  @param handler     集合
 */
+ (void)getCoursesWithIDs:(NSArray *)courseIDs
              forceReload:(BOOL)forceReload
        completionHandler:(completionHandler)handler {
    KKBCourseManager *manager = [KKBCourseManager sharedInstace];
    [manager getCoursesWithIDs:courseIDs
                   forceReload:forceReload
             completionHandler:handler];
}

- (void)getCourseWithID:(NSNumber *)courseID
            forceReload:(BOOL)forceReload
      completionHandler:(completionHandler)handler {

    if (!courseID) {
        DDLogError(@"查询的courseID为空");
        // TODO: byzm 返回错误error信息
        handler(nil, nil);
        return;
    }

    if ([_allCourses count] == 0 || forceReload) {
        //通过接口查询
        [self requestCoursesWithID:courseID completionHandler:handler];

    } else {
        // find course
        //从本地查询
        NSDictionary *dic = self.allCourses[courseID];
        if (dic) {
            handler(dic, nil);
        } else {
            //查询不到从网络获取
            DDLogCWarn(@"本地查询不到信息courseID:%@", courseID);
            [self requestCoursesWithID:courseID completionHandler:handler];
        }
    }
}

- (void)requestCoursesWithID:(NSNumber *)courseID
           completionHandler:(completionHandler)handler {
    //通过接口查询
    NSString *urlPath = [NSString stringWithFormat:@"v1/courses/%@", courseID];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
        method:@"GET"
        param:nil
        fromCache:NO
        success:^(id result,
                  AFHTTPRequestOperation *operation) { handler(result, nil); }
        failure:^(id result,
                  AFHTTPRequestOperation *operation) { handler(nil, result); }];
}

- (void)getCoursesWithIDs:(NSArray *)courseIDs
              forceReload:(BOOL)forceReload
        completionHandler:(completionHandler)handler {

    if (!courseIDs) {
        DDLogError(@"查询的courseIDs为nil");
        // TODO: byzm 返回错误error信息
        handler(nil, nil);
        return;
    }

    if ([_allCourses count] == 0 || forceReload) {
        //通过接口查询
        // TODO: byzm 需要能批量查询的接口
        NSString *urlPath = [NSString stringWithFormat:@"v1/courses"];
        [[KKBHttpClient shareInstance] requestAPIUrlPath:urlPath
            method:@"GET"
            param:nil
            fromCache:NO
            success:^(id result, AFHTTPRequestOperation *operation) {

                if ([result isKindOfClass:[NSArray class]]) {
                    [self processCoursesHashDic:result];

                    NSArray *coursesDetailArr =
                        [self searchCoursesWithIDs:courseIDs];
                    handler(coursesDetailArr, nil);

                } else {
                    DDLogError(@"接口返回错误格式");
                }
            }
            failure:^(id result, AFHTTPRequestOperation *operation) {
                handler(nil, result);
            }];

    } else {
        // find course
        //从本地查询
        NSArray *courses = [self searchCoursesWithIDs:courseIDs];
        handler(courses, nil);
    }
}

#pragma mark - 构造查询的dictionary
- (void)processCoursesHashDic:(NSArray *)courses {

    NSMutableDictionary *allCoursesDic =
        [[NSMutableDictionary alloc] initWithCapacity:[courses count]];

    for (NSDictionary *courseDic in courses) {
        NSNumber *courseID = courseDic[@"id"];
        allCoursesDic[courseID] = courseDic;
    }
    self.allCourses = allCoursesDic;
}

#pragma mark - 批量过滤
- (NSArray *)searchCoursesWithIDs:(NSArray *)coursesIDs {
    NSMutableArray *courses =
        [[NSMutableArray alloc] initWithCapacity:[coursesIDs count]];
    for (NSNumber *courseID in coursesIDs) {
        id courseObjct = self.allCourses[courseID];
        if (courseObjct) {
            //为空的判断
            [courses addObject:self.allCourses[courseID]];
        } else {
            // TODO: byzm 查询不到此id对应的对象，以后需要处理此处
        }
    }
    return courses;
}

@end
