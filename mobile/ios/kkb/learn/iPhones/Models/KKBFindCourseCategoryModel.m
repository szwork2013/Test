//
//  KKBFindCourseCategoryModel.m
//  learn
//
//  Created by zengmiao on 10/13/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBFindCourseCategoryModel.h"

@implementation KKBFindCourseCategoryModel

#pragma mark - MTLJSONSerializing Protol
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"courseID" : @"id", @"courseAvatorURL" : @"image_url" };
}

#pragma mark - propertyJSONTransformer
+ (NSValueTransformer *)courseAvatorURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}


@end
