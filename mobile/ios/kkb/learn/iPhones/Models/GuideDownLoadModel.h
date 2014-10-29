//
//  GuideDownLoadModel.h
//  learn
//
//  Created by zxj on 14-8-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideDownLoadModel : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, retain) NSMutableArray *itemArray;

- (void)initWithDictionary:(NSDictionary *)dictionary;

@end
