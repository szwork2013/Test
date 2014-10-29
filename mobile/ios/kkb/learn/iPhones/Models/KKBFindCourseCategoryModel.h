//
//  KKBFindCourseCategoryModel.h
//  learn
//
//  Created by zengmiao on 10/13/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBJSONSerialBaseModel.h"

@interface KKBFindCourseCategoryModel : KKBJSONSerialBaseModel

@property (nonatomic ,copy) NSNumber *courseID;
@property (nonatomic ,strong) NSURL *courseAvatorURL;
@property (nonatomic, copy) NSString *name;

@end
