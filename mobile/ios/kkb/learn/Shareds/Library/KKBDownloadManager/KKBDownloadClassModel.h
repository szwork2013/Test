//
//  KKBDownloadClassModel.h
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBDownloadHeader.h"

@interface KKBDownloadClassModel : NSObject

@property (strong ,nonatomic) NSNumber *classID;
@property (assign ,nonatomic) VideoDownloadClassType classType;
@property (nonatomic, copy) NSString *name;

@end
