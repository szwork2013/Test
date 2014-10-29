//
//  KKBUserInfo.m
//  learn
//
//  Created by zxj on 6/20/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBUserInfo.h"

@implementation KKBUserInfo
+ (KKBUserInfo *)shareInstance {
    static KKBUserInfo *singleton = nil;
    ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ singleton = [[KKBUserInfo alloc] init]; });
    return singleton;
}

-(NSString *)transTimeformat:(NSString *)dateString{
    
    NSString *moon = [dateString substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [dateString substringWithRange:NSMakeRange(8, 2)];
    NSString *formateString = [NSString stringWithFormat:@"%@月%@日",moon,day];
    return formateString;
}


- (id)init {
    self = [super init];
    if (self) {
        self.isLogin = NO;
        self.goToDownloadFromStudyVC = NO;
    }
    return self;
}

@end
