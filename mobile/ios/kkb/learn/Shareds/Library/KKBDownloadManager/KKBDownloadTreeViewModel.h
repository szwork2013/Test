//
//  KKBDownloadTreeViewModel.h
//  learn
//
//  Created by zengmiao on 9/12/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKBDownloadTreeViewModel : NSObject

@property (nonatomic, copy) NSNumber *sectionID;
@property (nonatomic, copy) NSString *sectionName;

@property (strong ,nonatomic) NSArray *childrens;

@end
