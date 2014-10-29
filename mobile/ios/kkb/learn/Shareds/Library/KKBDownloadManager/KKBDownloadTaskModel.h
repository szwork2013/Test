//
//  KKBDownloadTaskModel.h
//  VideoDownload
//
//  Created by zengmiao on 9/1/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKBDownloadClassModel;
@class KKBDownloadVideoModel;

@interface KKBDownloadTaskModel : NSObject

@property (strong ,nonatomic) KKBDownloadClassModel *classModel;
@property (strong ,nonatomic) KKBDownloadVideoModel *videoModel;

@end
