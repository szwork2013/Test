//
//  KKBDownloadModelFactory.h
//  VideoDownload
//
//  Created by zengmiao on 9/3/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKBDownloadHeader.h"

@interface KKBDownloadModelFactory : NSObject

+ (KKBDownloadVideoModel *)convertToBridgeVideoModel:(KKBDownloadVideo *)model;
+ (KKBDownloadClassModel *)convertToBridgeClassModel:(KKBDownloadClass *)model;
@end
