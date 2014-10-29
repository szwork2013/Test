//
//  KKBDownloadModelFactory.m
//  VideoDownload
//
//  Created by zengmiao on 9/3/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadModelFactory.h"

@implementation KKBDownloadModelFactory

+ (KKBDownloadVideoModel *)convertToBridgeVideoModel:(KKBDownloadVideo *)model {

    KKBDownloadVideoModel *videModel = [[KKBDownloadVideoModel alloc] init];
    videModel.status = [model.status integerValue];
    videModel.videoID = model.videoID;
    videModel.downloadPath = model.downloadPath;
    videModel.tmpPath = model.tmpPath;
    videModel.videoURL = model.videoURL;
    videModel.videoTitle = model.videoTitle;
    videModel.totalBytesFile = model.totalBytesFile;
    videModel.totalBytesReaded = model.totalBytesReaded;
    videModel.progress = model.progressValue;
    return videModel;
}

+ (KKBDownloadClassModel *)convertToBridgeClassModel:(KKBDownloadClass *)model {
    KKBDownloadClassModel *classModel = [[KKBDownloadClassModel alloc] init];
    classModel.classID = model.classID;
    classModel.name = model.name;
    classModel.classType = model.classTypeValue;
    return classModel;
}
@end
