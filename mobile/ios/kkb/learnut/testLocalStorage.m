//
//  testLocalStorage.m
//  learn
//
//  Created by caojing on 7/16/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LocalStorage.h"
#import <OCMock/OCMock.h>
#import "KKBUserInfo.h"

@interface testLocalStorage : XCTestCase

@end

@implementation testLocalStorage

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each
    // test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of
    // each test method in the class.
    [super tearDown];
}

- (void)testCourseName {
    NSString *courseName = @"name";
    NSString *courseId = @"100";
    [[LocalStorage shareInstance] saveCourseName:courseName course:courseId];
    XCTAssertEqual(
        YES,
        [courseName
            isEqual:[[LocalStorage shareInstance] getCourseNameBy:courseId]]);

    [KKBUserInfo shareInstance].userId = nil;
    id userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    [LocalStorage shareInstance].userDefaults = userDefaultsMock;

    [[LocalStorage shareInstance] saveCourseName:courseName course:courseId];

    OCMVerify([userDefaultsMock setObject:courseName forKey:[OCMArg any]]);
}

@end
